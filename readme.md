# **Mobile Take-Home Challenge**

## Brief summary

The SDK provides a function called `getDeviceId(completion:_)` which returns a unique ID for a device. When creating the ID, the following data about the device is used:
- Max storage capacity
- Number of free `inodes` on the system
- The type of the device
- Time zone set in settings
- Preferred languages
- Type of keyboards installed

After gathering this data, it is encrypted by the **SHA-256** hashing algorithm. The resulting SHA-256 string is the `deviceId`.

The `deviceId` is then stored in the **Keychain**. Items in the keychain "survive" app reinstalls, so even after deleting and reinstalling the app, the same `deviceId` will be used to identify the device. However, it doesn't allow for persisting the `deviceId` even after performing a factory reset on the device. After a factory reset, a new `deviceId` will be created.


## Analysis of implementation

### Device specific information
The SDK gathers information about the device. Max storage capacity and the type of the device are information about the physical device, and they are not subject to change. 

As of January, 2025, Apple has released 46 different iPhone devices and 38 iPad devices. This field has over 84 possible values if we count other platforms, like watchOS or visionOS as well. However, most people will use the more recent types of devices, and the distribution of usage is not equal for each type of device. Apple supports [28 different iPhone devices](https://support.apple.com/guide/iphone/iphone-models-compatible-with-ios-18-iphe3fa5df43/ios) and [22 different iPad devices](https://support.apple.com/guide/ipad/ipad-models-compatible-with-ipados-18-ipad213a25b2/ipados). According to [this article](https://telemetrydeck.com/survey/apple/iPhone/models/#:~:text=iPhone%2013%20was%20clearly%20the,a%20closer%20second%20with%2015.02%25.), the most used device by the end of 2024 was iPhone 13.

All iPhones come in multiple variations for storage capacity. Most models come in 3 different version, but the Pro and Pro Max devices might have 4 versions.

In theory, this allows for more than `(28 + 22) * 3 = 150` configurations.

The number of free `inodes` on a device is one of the most unique values which build up the `deviceId`. For each file on the system, an `inode` is reserved, so the number of free `inodes` means how many more files can be created on the device. Users who have been using their device for some time, will have images, apps installed, these apps create files themselves, etc., and the total number of `inodes` are high, so this will be probably very unique to a device.

*Note*: I used the number of free `inodes` instead of free disk space because [Apple has explicitly disallowed using free disk space for fingerprinting](https://developer.apple.com/documentation/foundation/nsfilesystemfreesize), while they [didn't do so](https://developer.apple.com/documentation/foundation/nsfilesystemfreenodes) for free inodes.

### User settings

-   Time zone set in settings
-   Preferred languages
-   Type of keyboards installed

Time zone, preferred languages and type of keyboards installed are not independent values, but their combination can provide uniqueness for a device. Bigger countries may span multiple timezones. An English speaking user might install their second language on their phone. Language learners might use their target language to help them learn. Non-english speakers might install English on their phone, because they prefer using that to their language. People might install a random keyboard to try it out (I have a Chinese keyboard installed because I wanted to see how it works). 
There are 77 time zone identifiers, 40 languages and 50+ keyboards (I couldn't find the exact number), which allows for more than 150 000 possible combinations. 
### Number of possible unique `deviceId`s
Based on these data, there are around `150 * 150 000 = 22 500 000` possible combinations based on device data and user settings. Adding in the free `inodes` number, I suspect this number will be much higher. This means that there is a very low chance for collisions.
The `deviceId` is also stored on the Keychain, which means it will also persist between app reinstalls. This means the `deviceId` can be changed after performing a factory reset on the device.

### Additional notes

Apple has done a lot to prevent fingerprinting devices. They have removed access to the devices `UDID`, which is a true unique identifier for the device. 

Since then, they have introduced the `UIDevice.current.identifierForVendor` property, which uniquely identifies a device for a given vendor. This ID will be the same across the apps from the same vendor, and different for apps from different vendors. However, it does not persist between app reinstalls. 
It would have been possible to persist this ID in the keychain, which would have created a similar solution to mine, but the task has explicitly asked for a more creative solution. I also wanted to avoid using this identifier altogether.
 
 It would have been possible to just create a `UUID` for each device, and save it to the keychain, but that is also boring.

Apple has introduced the `DeviceCheck` framework, to allow apps to prevent fraudulent behavior from their users. It allows storing and query 2 bits of data per device. The SDK could use this service to flag each device, where a `deviceId` was created. This way we could check if a device has been factory reset since creating a `deviceId`. I couldn't use this service, because I am not a member of the Apple Developer Program and I don't have a server to handle the token generated by the framework. 
