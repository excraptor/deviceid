//
//  EncryptionManager.h
//  DeviceID
//
//  Created by Tamás Balla on 2025. 01. 06..
//

#ifndef EncryptionManager_h
#define EncryptionManager_h
#import <Foundation/Foundation.h>

NSString* deviceIdDataToString(NSData* deviceIdData);
NSData* createDeviceIdDataFromInfo(NSDictionary<NSString*, NSString*>* deviceInfo, NSError* error);

#endif /* EncryptionManager_h */
