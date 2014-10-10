//
//  Object.h
//  Cloudiversity
//
//  Created by Rémy Marty on 05/02/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloudiversityObject : NSObject

+ (instancetype)fromJSON:(id)json;
+ (NSArray *)fromJSONArray:(id)json;

@end
