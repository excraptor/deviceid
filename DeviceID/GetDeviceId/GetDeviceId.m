//
//  GetDeviceId.m
//  DeviceID
//
//  Created by Tamás Balla on 2025. 01. 03..
//

#import "GetDeviceID.h"
#import <sys/utsname.h>
#import <UIKit/UIKit.h>
#import "KeychainManager.h"
#import "EncryptionManager.h"

void getDeviceId(void (^completion)(NSString* deviceId, NSError* error)) {
    
    // Saving/loading from the Keychain blocks the current thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        // If a deviceId was already created, and saved to the Keychain, we return that
        NSString* key = deviceIdDataToString(loadDataFromKeychain(@"DeviceId"));
        if (key.length > 0) {
            NSLog(@"Serving deviceId from Keychain.");
            completion(key, nil);
            return;
        }
        
        NSLog(@"Didn't find deviceId in Keychain, creating a new one.");
        
        // Creating the ID
        // Gather info about max storage and number of free inodes
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSString* filePath = [fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSSystemDomainMask].lastObject.path;
        NSNumber* systemSize = nil;
        NSNumber* freeNodes = nil;
        NSError* error = nil;
        if(filePath) {
            systemSize = [fileManager attributesOfFileSystemForPath:filePath error:&error][NSFileSystemSize];
            freeNodes = [fileManager attributesOfFileSystemForPath:filePath error:&error][NSFileSystemFreeNodes];
        }
        if(error) {
            NSLog(@"An error has occurred when reading from the file system. Error code: %ld, domain: %@", error.code, error.domain);
            completion(nil, error);
            return;
        }
        
        // Model name
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

        // Construct a dict from the gathered data
        NSDictionary<NSString*, NSString*>* deviceInfo = @{
            @"systemSize": [systemSize stringValue],
            @"freeNodes": [freeNodes stringValue],
            @"machineType": machineName,
            @"timeZoneName": timeZoneName,
            @"preferredLanguages": [preferredLanguages componentsJoinedByString:@""],
            @"keyboards": [keyboards componentsJoinedByString:@""]
        };
        
        NSData* deviceId = createDeviceIdDataFromInfo(deviceInfo, error);
        if (error) {
            NSLog(@"Error while creating data from dictionary. Error code: %ld, domain: %@\n", error.code, error.domain);
            completion(nil, error);
            return;
        }
        
        // Store in keychain
        OSStatus saveStatus = saveToKeychain(@"DeviceId", deviceId);

        if (saveStatus != errSecSuccess) {
            NSLog(@"Couldn't save deviceId to keychain.\n");
            completion(nil, [[NSError alloc] initWithDomain:@"GetDeviceId.KeychainError" code:saveStatus userInfo:nil]);
            return;
        }
        
        completion(deviceIdDataToString(deviceId), nil);
    });
}
