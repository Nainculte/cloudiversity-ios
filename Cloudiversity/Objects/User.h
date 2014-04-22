//
//  User.h
//  Cloudiversity
//
//  Created by Rémy Marty on 05/02/2014.
//  Copyright (c) 2014 Rémy Marty. All rights reserved.
//

#import "Object.h"

@interface User : Object

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *school;
@property (nonatomic, copy) NSString *token;

+ (User *)withName:(NSString *)name lastName:(NSString *)lastName andEmail:(NSString *)email;
+ (User *)withEmail:(NSString *)email andToken:(NSString *)token;

@end
