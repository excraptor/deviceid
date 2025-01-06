//
//  KeychainManager.m
//  DeviceID
//
//  Created by Tamás Balla on 2025. 01. 06..
//

#import "KeychainManager.h"

OSStatus saveToKeychain(NSString* key, NSData* data) {
    // Generic password is usually used for all types of strings that we want to store in Keychain
    NSDictionary<NSString*, id>* query = @{
        (id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (id)kSecAttrAccount: key,
        (id)kSecValueData: data,
    };
    
    return SecItemAdd((__bridge CFDictionaryRef)query, nil);
}

NSData* loadDataFromKeychain(NSString* key) {
    NSDictionary *getQuery = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrAccount: key,
        (__bridge id)kSecReturnData: @YES,
        (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne
    };
    
    // Retrieve the item
    CFTypeRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)getQuery, &result);
    if (status != errSecSuccess) {
        NSLog(@"Error while loading device id data from keychain. OSStatus: %d", status);
        return nil;
    }
    
    NSData *identityData = (__bridge_transfer NSData *)result;
    return identityData;
}
