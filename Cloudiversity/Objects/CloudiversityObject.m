//
//  Object.m
//  Cloudiversity
//
//  Created by Rémy Marty on 05/02/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "CloudiversityObject.h"

@implementation CloudiversityObject

+ (CloudiversityObject *)fromJSON:(id)json {
    [NSException raise:@"Forbidden call to abstract method" format:@"fromJSON must be invoked from a subclass of DomainObject."];
    return nil;
}

+ (NSArray *)fromJSONArray:(id)json {
    NSMutableArray *array = [NSMutableArray array];
    for (id jsonObject in json) {
        CloudiversityObject *object = [self fromJSON:jsonObject];
        if (object != nil) {
            [array addObject:object];
        }
    }
    return array;
}

@end
