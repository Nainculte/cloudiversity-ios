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
#define DATE_FORMAT				@"yyyy-MM-dd"
#define TIME_FORMAT				@"HH:mm"

@interface CloudDateConverter : NSObject

+ (CloudDateConverter*)sharedMager;

#pragma mark - Converting NSString to NSDate
- (NSDate*)dateAndTimeFromString:(NSString*)dateAndTimeString;	// Use a string in the DATE_AND_TIME_FORMAT format
- (NSDate*)dateAtTimeFromString:(NSString*)dateAtTimeString;	// Use a string in the DATE_AT_TIME_FORMAT format
- (NSDate*)dateFromString:(NSString*)dateString;				// Use a string in the DATE_FOMART format
- (NSDate*)timeFromString:(NSString*)timeString;				// Use a string in the TIME_FORMAT format

#pragma mark - Converting NSDate to NSSrting
- (NSString*)stringFromDateAndTime:(NSDate*)dateAndTime;	// Gives a string in the DATE_AND_TIME_FORMAT format
- (NSString*)stringFromDateAtTime:(NSDate*)dateAtTime;		// Gives a string in the DATE_AT_TIME_FORMAT format
- (NSString*)stringFromDate:(NSDate*)date;					// Gives a string in the DATE_FOMART format
- (NSString*)stringFromTime:(NSDate*)time;					// Gives a string in the TIME_FORMAT format

@end
