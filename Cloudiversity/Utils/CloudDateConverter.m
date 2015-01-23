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
@property (nonatomic, strong) NSDateFormatter *fullDateFormatter;
@property (nonatomic, strong) NSDateFormatter *timeFormatter;
@property (nonatomic, strong) NSDateFormatter *dateAtTimeFormatter;
@property (nonatomic, strong) NSDateFormatter *fullDateAtTimeFormatter;
@property (nonatomic, strong) NSDateFormatter *dateAndTimeWithSecondsFormatter;

@end

@implementation CloudDateConverter

- (NSDateFormatter*)getDateFormatterUsingFormat:(CloudDateConverterFormat)format {
	NSArray *dateFormatters = @[self.dateAndTimeFormatter, self.dateAtTimeFormatter, self.fullDateAtTimeFormatter, self.dateFormatter, self.fullDateFormatter, self.timeFormatter];
	
	return dateFormatters[format];
}

+ (CloudDateConverter*)sharedMager {
    static CloudDateConverter *sharedCloudDateConverter = nil;
    static dispatch_once_t pred;
	dispatch_once(&pred, ^{
		sharedCloudDateConverter = [[CloudDateConverter alloc] init];
	});

    return sharedCloudDateConverter;
}

+ (NSString *)nullTime {
	return @"00:00";
}

+ (BOOL)isStringDateNull:(NSString*)stringDate {
	return (stringDate == nil || [stringDate isKindOfClass:[NSNull class]] || stringDate.length == 0);
}

- (instancetype)init {
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
		self.dateAndTimeWithSecondsFormatter = [[NSDateFormatter alloc] init];
		[self.dateAndTimeWithSecondsFormatter setDateFormat:DATE_AND_TIME_FORMAT_WITH_SECONDS];
		[self.dateAndTimeWithSecondsFormatter setTimeZone:timeZone];
		self.fullDateAtTimeFormatter = [[NSDateFormatter alloc] init];
		[self.fullDateAtTimeFormatter setDateFormat:FULL_DATE_AT_TIME_FORMAT];
		[self.fullDateAtTimeFormatter setTimeZone:timeZone];
		self.fullDateFormatter = [[NSDateFormatter alloc] init];
		[self.fullDateFormatter setDateFormat:FULL_DATE_FORMAT];
		[self.fullDateFormatter setTimeZone:timeZone];
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

- (NSDate*)dateAndTimeWithSecondsFromString:(NSString*)dateAndTimeWithSecondsString {
	return [self.dateAndTimeWithSecondsFormatter dateFromString:dateAndTimeWithSecondsString];
}

#pragma mark - Converting NSDate to NSSrting
- (NSString*)stringFromDateAndTime:(NSDate *)dateAndTime {
	return [self.dateAndTimeFormatter stringFromDate:dateAndTime];
}

- (NSString*)stringFromDateAtTime:(NSDate *)dateAtTime {
	return [self.dateAtTimeFormatter stringFromDate:dateAtTime];
}

- (NSString *)stringFromFullDateAtTime:(NSDate *)dateAtTime {
	return [self.fullDateAtTimeFormatter stringFromDate:dateAtTime];
}

- (NSString*)stringFromDate:(NSDate *)date {
	return [self.dateFormatter stringFromDate:date];
}

- (NSString*)stringFromFullDate:(NSDate *)date {
	return [self.fullDateFormatter stringFromDate:date];
}

- (NSString*)stringFromTime:(NSDate *)time {
	return [self.timeFormatter stringFromDate:time];
}

- (NSString*)stringFromDateAndTimeWithSeconds:(NSDate *)dateAndTimeWithSeconds {
	return [self.dateAndTimeWithSecondsFormatter stringFromDate:dateAndTimeWithSeconds];
}

#pragma mark - Converting NSDate to another NSDate
- (NSDate*)convertDate:(NSDate *)date toFormat:(CloudDateConverterFormat)outputFormat {
	
	return [[self getDateFormatterUsingFormat:outputFormat] dateFromString:[[self getDateFormatterUsingFormat:outputFormat] stringFromDate:date]];
}

@end
