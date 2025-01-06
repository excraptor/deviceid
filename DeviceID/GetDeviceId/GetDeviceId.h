//
//  GetDeviceId.h
//  DeviceID
//
//  Created by Tamás Balla on 2025. 01. 03..
//

#ifndef GetDeviceID_h
#define GetDeviceID_h
#import <Foundation/Foundation.h>

void getDeviceId(void (^completionHandler)(NSString *item, NSError* error));

#endif /* GetDeviceId_h */
