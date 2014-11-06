//
//  CloudDateConverter.h
//  Cloudiversity
//
//  Created by Anthony MERLE on 21/06/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DATE_AND_TIME_FORMAT	@"yyyy-MM-dd HH:mm"
#define DATE_AT_TIME_FORMAT		@"yyyy-MM-dd 'at' HH:mm"
#define FULL_DATE_AT_TIME_FORMAT		@"yyyy MMM dd 'at' HH:mm"
#define DATE_FORMAT				@"yyyy-MM-dd"
#define FULL_DATE_FORMAT				@"yyyy MMM dd"
#define TIME_FORMAT				@"HH:mm"

// Bonus
#define DATE_AND_TIME_FORMAT_WITH_SECONDS	@"yyyy-MM-dd HH:mm:ss"

typedef NS_ENUM(NSInteger, CloudDateConverterFormat) {
    CloudDateConverterFormatDateAndTime = 0,
    CloudDateConverterFormatDateAtTime,
    CloudDateConverterFormatFullDateAtTime,
	CloudDateConverterFormatDate,
	CloudDateConverterFormatFullDate,
	CloudDateConverterFormatTime
} ;

@interface CloudDateConverter : NSObject

+ (CloudDateConverter*)sharedMager;

+ (NSString *)nullTime;
+ (BOOL)isStringDateNull:(NSString*)stringDate;

#pragma mark - Converting NSString to NSDate
- (NSDate*)dateAndTimeFromString:(NSString*)dateAndTimeString;	// Use a string in the DATE_AND_TIME_FORMAT format
- (NSDate*)dateAtTimeFromString:(NSString*)dateAtTimeString;	// Use a string in the DATE_AT_TIME_FORMAT format
- (NSDate*)dateFromString:(NSString*)dateString;				// Use a string in the DATE_FOMART format
- (NSDate*)timeFromString:(NSString*)timeString;				// Use a string in the TIME_FORMAT format
- (NSDate*)dateAndTimeWithSecondsFromString:(NSString*)dateAndTimeWithSecondsString;	// Use a string in the DATE_AND_TIME_FORMAT_WITH_SECONDS format

#pragma mark - Converting NSDate to NSSrting
- (NSString*)stringFromDateAndTime:(NSDate*)dateAndTime;	// Gives a string in the DATE_AND_TIME_FORMAT format
- (NSString*)stringFromDateAtTime:(NSDate*)dateAtTime;		// Gives a string in the DATE_AT_TIME_FORMAT format
- (NSString*)stringFromFullDateAtTime:(NSDate*)dateAtTime;		// Gives a string in the FULL_DATE_AT_TIME_FORMAT format
- (NSString*)stringFromDate:(NSDate*)date;					// Gives a string in the DATE_FOMART format
- (NSString*)stringFromFullDate:(NSDate*)date;					// Gives a string in the DATE_FOMART format
- (NSString*)stringFromTime:(NSDate*)time;					// Gives a string in the TIME_FORMAT format
- (NSString*)stringFromDateAndTimeWithSeconds:(NSDate*)dateAndTimeWithSeconds;	// Gives a string in the DATE_AND_TIME_FORMAT_SECONDS format

#pragma mark - Converting NSDate to another NSDate
- (NSDate*)convertDate:(NSDate*)date toFormat:(CloudDateConverterFormat)outputFormat;

@end
