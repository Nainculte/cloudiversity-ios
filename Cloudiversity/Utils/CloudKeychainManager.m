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
    [d setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id<NSCopying>)(kSecClass)];
    NSData *emailData = [email dataUsingEncoding:NSUTF8StringEncoding];
    [d setObject:emailData forKey:(__bridge id<NSCopying>)(kSecAttrAccount)];
    NSData *tokenData = [token dataUsingEncoding:NSUTF8StringEncoding];
    [d setObject:tokenData forKey:(__bridge id<NSCopying>)(kSecValueData)];
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)d, NULL);
    if (status == errSecSuccess) {
        return YES;
    }
    return NO;
}

+ (NSString *)retrieveTokenWithEmail:(NSString *)email {
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    [d setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id<NSCopying>)(kSecClass)];
    NSData *emailData = [email dataUsingEncoding:NSUTF8StringEncoding];
    [d setObject:emailData forKey:(__bridge id<NSCopying>)(kSecAttrAccount)];
    [d setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    [d setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
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
    [d setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id<NSCopying>)(kSecClass)];
    NSData *emailData = [email dataUsingEncoding:NSUTF8StringEncoding];
    [d setObject:emailData forKey:(__bridge id<NSCopying>)(kSecAttrAccount)];
    SecItemDelete((__bridge CFDictionaryRef)(d));
}

@end
