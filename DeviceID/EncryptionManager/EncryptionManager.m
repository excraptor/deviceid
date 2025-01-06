//
//  EncryptionManager.m
//  DeviceID
//
//  Created by Tamás Balla on 2025. 01. 06..
//

#import "EncryptionManager.h"
#import <CommonCrypto/CommonDigest.h>

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
