//
//  GetDeviceID.m
//  DeviceID
//
//  Created by Tamás Balla on 2025. 01. 03..
//

#import "GetDeviceID.h"
#import <sys/utsname.h>
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import <Security/Security.h>

NSString* deviceIdDataToString(NSData* deviceIdData) {
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++)
    {
        [ret appendFormat:@"%02x", ((unsigned char*)deviceIdData.bytes)[i]];
    }
    return ret;
}

NSData* createDeviceIdDataFromInfo(NSDictionary<NSString*, NSString*>* deviceInfo, NSError* error) {
    NSData* deviceInfoData = [NSKeyedArchiver archivedDataWithRootObject:deviceInfo requiringSecureCoding:true error:&error];
    NSMutableData* deviceId = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(deviceInfoData.bytes, (CC_LONG)deviceInfoData.length, deviceId.mutableBytes);
    return deviceId;
}

OSStatus saveToKeychain(NSString* key, NSData* data) {
    NSDictionary<NSString*, id>* query = @{
        (id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (id)kSecAttrAccount: key,
        (id)kSecValueData: data,
    };
    
    return SecItemAdd((__bridge CFDictionaryRef)query, nil);
}

NSString* loadFromKeychain(NSString* key) {
    NSDictionary *getQuery = @{
        (id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (id)kSecAttrAccount: (id)key,
        (__bridge id)kSecReturnData: @YES,
        (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne // Only one item
    };
    
    // Retrieve the item
    CFTypeRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)getQuery, &result);
    if (status == errSecSuccess) {
        NSData *identityData = (__bridge_transfer NSData *)result;
        return deviceIdDataToString(identityData);
    }
    printf("error: %d", status);
    return nil;
}

void getDeviceId(void (^completion)(NSString *deviceId)) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString* key = loadFromKeychain(@"DeviceId");
        if (key != nil && ![key isEqualToString: @""]) {
            printf("Serving deviceId from Keychain.");
            completion(key);
            return;
        }
        
        printf("Didn't find deviceId in Keychain, creating a new one.");
        
        // Device name
        NSString* deviceName = [[UIDevice currentDevice] name];
        
        // Available storage
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSString* filePath = [fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSSystemDomainMask].lastObject.path;
        NSNumber* systemSize = nil;
        NSNumber* freeNodes = nil;
        NSError* error = nil;
        if(filePath) {
            systemSize = [fileManager attributesOfFileSystemForPath:filePath error:&error][NSFileSystemSize];
            freeNodes = [fileManager attributesOfFileSystemForPath:filePath error:&error][NSFileSystemFreeNodes];
        }
        // TODO: handle error
        
        // Get model name, etc.
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString* machineName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
        
        // TimeZone
        NSTimeZone* timeZone = [NSTimeZone localTimeZone];
        NSString* timeZoneName = [timeZone name];
        
        // Locale information
        NSArray<NSString*>* preferredLanguages = [NSLocale preferredLanguages];
        
        // Keyboards
        NSArray<NSString*>* keyboards = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleKeyboards"];

        NSDictionary<NSString*, NSString*>* deviceInfo = @{
            @"deviceName": deviceName,
            @"systemSize": [systemSize stringValue],
            @"freeNodes": [freeNodes stringValue],
            @"machineType": machineName,
            @"timeZoneName": timeZoneName,
            @"preferredLanguages": [preferredLanguages componentsJoinedByString:@""],
            @"keyboards": [keyboards componentsJoinedByString:@""]
        };
        
        // TODO: error handling
        
        NSData* deviceId = createDeviceIdDataFromInfo(deviceInfo, error);
        
        // Store in keychain
        OSStatus saveStatus = saveToKeychain(@"DeviceId", deviceId);

        // TODO: proper error handling
        if (saveStatus != errSecSuccess) {
            printf("an error has occurred");
        }
        
        completion(deviceIdDataToString(deviceId));
    });
}
