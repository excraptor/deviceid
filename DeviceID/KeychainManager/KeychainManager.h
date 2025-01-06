//
//  KeychainManager.h
//  DeviceID
//
//  Created by Tamás Balla on 2025. 01. 06..
//

#ifndef KeychainManager_h
#define KeychainManager_h
#import <Foundation/Foundation.h>
#import <Security/Security.h>

OSStatus saveToKeychain(NSString* key, NSData* data);
NSData* loadDataFromKeychain(NSString* key);



#endif /* KeychainManager_h */
