//
//  CloudKeychainManager.m
//  Cloudiversity
//
//  Created by Nainculte on 4/23/14.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <Security/Security.h>
#import "CloudKeychainManager.h"

@implementation CloudKeychainManager

+ (BOOL)saveToken:(NSString *)token forEmail:(NSString *)email {
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    d[(__bridge id<NSCopying>)(kSecClass)] = (__bridge id)kSecClassGenericPassword;
    NSData *emailData = [email dataUsingEncoding:NSUTF8StringEncoding];
    d[(__bridge id<NSCopying>)(kSecAttrAccount)] = emailData;
    NSData *tokenData = [token dataUsingEncoding:NSUTF8StringEncoding];
    d[(__bridge id<NSCopying>)(kSecValueData)] = tokenData;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)d, NULL);
    if (status == errSecSuccess) {
        return YES;
    }
    return NO;
}

+ (NSString *)retrieveTokenWithEmail:(NSString *)email {
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    d[(__bridge id<NSCopying>)(kSecClass)] = (__bridge id)kSecClassGenericPassword;
    NSData *emailData = [email dataUsingEncoding:NSUTF8StringEncoding];
    d[(__bridge id<NSCopying>)(kSecAttrAccount)] = emailData;
    d[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    d[(__bridge id)kSecReturnData] = (id)kCFBooleanTrue;
    CFTypeRef result = nil;
    SecItemCopyMatching((__bridge CFDictionaryRef)d, &result);
    if (result) {
        NSData *res = (__bridge NSData *)result;
        return [[NSString alloc] initWithData:res encoding:NSUTF8StringEncoding];
    }
    return nil;
}

+ (void)deleteTokenWithEmail:(NSString *)email {
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    d[(__bridge id<NSCopying>)(kSecClass)] = (__bridge id)kSecClassGenericPassword;
    NSData *emailData = [email dataUsingEncoding:NSUTF8StringEncoding];
    d[(__bridge id<NSCopying>)(kSecAttrAccount)] = emailData;
    SecItemDelete((__bridge CFDictionaryRef)(d));
}

@end
