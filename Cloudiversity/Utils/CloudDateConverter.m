//
//  CloudDateConverter.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 21/06/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "CloudDateConverter.h"

@interface CloudDateConverter ()

@property (nonatomic, strong) NSDateFormatter *dateAndTimeFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *timeFormatter;
@property (nonatomic, strong) NSDateFormatter *dateAtTimeFormatter;

@end

@implementation CloudDateConverter

+ (CloudDateConverter*)sharedMager {
    static CloudDateConverter *sharedCloudDateConverter = nil;
    static dispatch_once_t pred;
	dispatch_once(&pred, ^{
		sharedCloudDateConverter = [[CloudDateConverter alloc] init];
	});

    return sharedCloudDateConverter;
}

- (id)init {
	self = [super init];
	if (self) {
		// setting the timeZone in UTC
		NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];

		self.dateAndTimeFormatter = [[NSDateFormatter alloc] init];
		[self.dateAndTimeFormatter setDateFormat:DATE_AND_TIME_FORMAT];
		[self.dateAndTimeFormatter setTimeZone:timeZone];
		self.dateAtTimeFormatter = [[NSDateFormatter alloc] init];
		[self.dateAtTimeFormatter setDateFormat:DATE_AT_TIME_FORMAT];
		[self.dateAtTimeFormatter setTimeZone:timeZone];
		self.dateFormatter = [[NSDateFormatter alloc] init];
		[self.dateFormatter setDateFormat:DATE_FORMAT];
		[self.dateFormatter setTimeZone:timeZone];
		self.timeFormatter = [[NSDateFormatter alloc] init];
		[self.timeFormatter setDateFormat:TIME_FORMAT];
		[self.timeFormatter setTimeZone:timeZone];
	}
	
	return self;
}

#pragma mark - Converting NSString to NSDate
- (NSDate*)dateAndTimeFromString:(NSString*)dateAndTimeString {
	return [self.dateAndTimeFormatter dateFromString:dateAndTimeString];
}

- (NSDate*)dateAtTimeFromString:(NSString*)dateAtTimeString {
	return [self.dateAtTimeFormatter dateFromString:dateAtTimeString];
}

- (NSDate*)dateFromString:(NSString*)dateString {
	return [self.dateFormatter dateFromString:dateString];
}

- (NSDate*)timeFromString:(NSString*)timeString {
	return [self.timeFormatter dateFromString:timeString];
}

#pragma mark - Converting NSDate to NSSrting
- (NSString*)stringFromDateAndTime:(NSDate *)dateAndTime {
	return [self.dateAndTimeFormatter stringFromDate:dateAndTime];
}

- (NSString*)stringFromDateAtTime:(NSDate *)dateAtTime {
	return [self.dateAtTimeFormatter stringFromDate:dateAtTime];
}

- (NSString*)stringFromDate:(NSDate *)date {
	return [self.dateFormatter stringFromDate:date];
}

- (NSString*)stringFromTime:(NSDate *)time {
	return [self.timeFormatter stringFromDate:time];
}

@end
