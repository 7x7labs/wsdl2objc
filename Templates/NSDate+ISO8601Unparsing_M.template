/*NSDate+ISO8601Unparsing.m
 *
 *Created by Peter Hosey on 2006-05-29.
 *Copyright 2006 Peter Hosey. All rights reserved.
 *Modified by Matthew Faupel on 2009-05-06 to use NSDate instead of NSCalendarDate (for iPhone compatibility).
 *Modifications copyright 2009 Micropraxis Ltd.
 */

#import <Foundation/Foundation.h>

#ifndef DEFAULT_TIME_SEPARATOR
#	define DEFAULT_TIME_SEPARATOR ':'
#endif
unichar ISO8601UnparserDefaultTimeSeparatorCharacter = DEFAULT_TIME_SEPARATOR;

static BOOL is_leap_year(NSInteger year) {
    return (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));
}

@interface NSString(ISO8601Unparsing)
//Replace all occurrences of ':' with timeSep.
- (NSString *)prepareDateFormatWithTimeSeparator:(unichar)timeSep;
@end

@implementation NSDate(ISO8601Unparsing)
#pragma mark Public methods

- (NSString *)ISO8601DateStringWithTime:(BOOL)includeTime timeSeparator:(unichar)timeSep {
    NSString *dateFormat = [(includeTime ? @"yyyy-MM-dd'T'HH:mm:ss" : @"yyyy-MM-dd") prepareDateFormatWithTimeSeparator:timeSep];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormat];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];

    NSString *str = [formatter stringForObjectValue:self];
    if (includeTime) // NSDate - all values are UTC
        return [str stringByAppendingString: @"Z"];
    return str;
}

/*Adapted from:
 *	Algorithm for Converting Gregorian Dates to ISO 8601 Week Date
 *	Rick McCarty, 1999
 *	http://personal.ecu.edu/mccartyr/ISOwdALG.txt
 */
- (NSString *)ISO8601WeekDateStringWithTime:(BOOL)includeTime timeSeparator:(unichar)timeSep {
    enum {
        monday, tuesday, wednesday, thursday, friday, saturday, sunday
    };
    enum {
        january = 1U, february, march,
        april, may, june,
        july, august, september,
        october, november, december
    };

    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:self];
    NSInteger year = [dateComps year];
    NSInteger week = 0;
    NSInteger dayOfWeek = ([dateComps weekday] + 6) % 7;
    NSInteger dayOfYear = (NSInteger)[gregorian ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:self];

    NSInteger prevYear = year - 1;

    BOOL yearIsLeapYear = is_leap_year(year);
    BOOL prevYearIsLeapYear = is_leap_year(prevYear);

    NSInteger YY = prevYear % 100;
    NSInteger C = prevYear - YY;
    NSInteger G = YY + YY / 4;
    NSInteger Jan1Weekday = (((C / 100) % 4) * 5 + G) % 7;

    NSInteger weekday = (dayOfYear + Jan1Weekday - 1) % 7;

    if (dayOfYear <= (7 - Jan1Weekday) && Jan1Weekday > thursday) {
        week = 52 + ((Jan1Weekday == friday) || ((Jan1Weekday == saturday) && prevYearIsLeapYear));
        --year;
    }
    else {
        NSInteger lengthOfYear = 365 + yearIsLeapYear;
        if ((lengthOfYear - dayOfYear) < (thursday - weekday)) {
            ++year;
            week = 1;
        } else {
            NSInteger J = dayOfYear + (sunday - weekday) + Jan1Weekday;
            week = J / 7 - (Jan1Weekday > thursday);
        }
    }

    NSString *timeString = @"";
    if (includeTime) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:[@"'T'HH:mm:ss'Z'" prepareDateFormatWithTimeSeparator:timeSep]];
        timeString = [formatter stringForObjectValue:self];
    }

    return [NSString stringWithFormat:@"%d-W%02d-%02d%@", (int)year, (int)week, (int)dayOfWeek + 1, timeString];
}

- (NSString *)ISO8601OrdinalDateStringWithTime:(BOOL)includeTime timeSeparator:(unichar)timeSep {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComps = [gregorian components: NSYearCalendarUnit fromDate: self];
    NSInteger year = [dateComps year];
    NSUInteger dayOfYear = [gregorian ordinalityOfUnit: NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:self];
    NSString *timeString;

    if (includeTime) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:[@"'T'HH:mm:ss'Z'" prepareDateFormatWithTimeSeparator:timeSep]];
        timeString = [formatter stringForObjectValue:self];
    } else
        timeString = @"";

    return [NSString stringWithFormat:@"%d-%03d%@", (int)year, (int)dayOfYear, timeString];
}

#pragma mark -

- (NSString *)ISO8601DateStringWithTime:(BOOL)includeTime {
    return [self ISO8601DateStringWithTime:includeTime timeSeparator:ISO8601UnparserDefaultTimeSeparatorCharacter];
}
- (NSString *)ISO8601WeekDateStringWithTime:(BOOL)includeTime {
    return [self ISO8601WeekDateStringWithTime:includeTime timeSeparator:ISO8601UnparserDefaultTimeSeparatorCharacter];
}
- (NSString *)ISO8601OrdinalDateStringWithTime:(BOOL)includeTime {
    return [self ISO8601OrdinalDateStringWithTime:includeTime timeSeparator:ISO8601UnparserDefaultTimeSeparatorCharacter];
}

#pragma mark -

- (NSString *)ISO8601DateStringWithTimeSeparator:(unichar)timeSep {
    return [self ISO8601DateStringWithTime:YES timeSeparator:timeSep];
}
- (NSString *)ISO8601WeekDateStringWithTimeSeparator:(unichar)timeSep {
    return [self ISO8601WeekDateStringWithTime:YES timeSeparator:timeSep];
}
- (NSString *)ISO8601OrdinalDateStringWithTimeSeparator:(unichar)timeSep {
    return [self ISO8601OrdinalDateStringWithTime:YES timeSeparator:timeSep];
}

#pragma mark -

- (NSString *)ISO8601DateString {
    return [self ISO8601DateStringWithTime:YES timeSeparator:ISO8601UnparserDefaultTimeSeparatorCharacter];
}
- (NSString *)ISO8601WeekDateString {
    return [self ISO8601WeekDateStringWithTime:YES timeSeparator:ISO8601UnparserDefaultTimeSeparatorCharacter];
}
- (NSString *)ISO8601OrdinalDateString {
    return [self ISO8601OrdinalDateStringWithTime:YES timeSeparator:ISO8601UnparserDefaultTimeSeparatorCharacter];
}

@end

@implementation NSString(ISO8601Unparsing)
- (NSString *)prepareDateFormatWithTimeSeparator:(unichar)timeSep {
    if (timeSep == ':') return self;
    return [self stringByReplacingOccurrencesOfString:@":"
                                           withString:[NSString stringWithCharacters:&timeSep length:1U]
                                              options:NSBackwardsSearch | NSLiteralSearch
                                                range:NSMakeRange(0U, [self length])];
}

@end
