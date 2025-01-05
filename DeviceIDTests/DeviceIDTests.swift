//
//  DeviceIDTests.swift
//  DeviceIDTests
//
//  Created by Tamás Balla on 2025. 01. 03..
//

import Testing
import System
import UIKit

extension UIDevice {
        var modelName: String {
            var systemInfo = utsname()
            uname(&systemInfo)
//            print(systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
            return identifier
        }
    }

struct DeviceIDTests {

    @Test func playground() {
//        #import <sys/utsname.h> // import it in your header or implementation file.
//
//            NSString* deviceName()
//            {
//                struct utsname systemInfo;
//                uname(&systemInfo);
//            
//                return [NSString stringWithCString:systemInfo.machine
//                                          encoding:NSUTF8StringEncoding];
//            }
        
//        print(UIDevice.current.modelName)
        
        let paths = NSSearchPathForDirectoriesInDomains(.musicDirectory, .allDomainsMask, false)
        print(paths)
    }

}
