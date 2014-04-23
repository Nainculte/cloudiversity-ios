//
//  CloudKeychainManager.h
//  Cloudiversity
//
//  Created by Nainculte on 4/23/14.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloudKeychainManager : NSObject

+ (BOOL)saveToken:(NSString *)token forEmail:(NSString *)email;
+ (NSString *)retrieveTokenWithEmail:(NSString *)email;
+ (void)deleteTokenWithEmail:(NSString *)email;

@end
