//
//  Object.m
//  Cloudiversity
//
//  Created by Rémy Marty on 05/02/2014.
//  Copyright (c) 2014 Rémy Marty. All rights reserved.
//

#import "Object.h"

@implementation Object

+ (Object *)fromJSON:(id)json {
    [NSException raise:@"Forbidden call to abstract method" format:@"fromJSON must be invoked from a subclass of DomainObject."];
    return nil;
}

+ (NSArray *)fromJSONArray:(id)json {
    NSMutableArray *array = [NSMutableArray array];
    for (id jsonObject in json) {
        Object *object = [self fromJSON:jsonObject];
        if (object != nil) {
            [array addObject:object];
        }
    }
    return array;
}

@end
