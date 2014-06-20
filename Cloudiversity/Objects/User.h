//
//  User.h
//  Cloudiversity
//
//  Created by Rémy Marty on 05/02/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "Object.h"

@interface User : Object

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSArray *roles;

+ (User *)sharedUser;
+ (User *)withEmail:(NSString *)email andToken:(NSString *)token;
- (void)saveUser;
- (void)deleteUser;

@end
