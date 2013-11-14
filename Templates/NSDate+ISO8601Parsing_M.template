/*NSDate+ISO8601Parsing.m
 *
 *Created by Peter Hosey on 2006-02-20.
 *Copyright 2006 Peter Hosey. All rights reserved.
 *Modified by Matthew Faupel on 2009-05-06 to use NSDate instead of NSCalendarDate (for iPhone compatibility).
 *Modifications copyright 2009 Micropraxis Ltd.
 */

#include <ctype.h>
#include <string.h>

#import "NSDate+ISO8601Parsing.h"

#ifndef DEFAULT_TIME_SEPARATOR
#	define DEFAULT_TIME_SEPARATOR ':'
#endif
unichar ISO8601ParserDefaultTimeSeparatorCharacter = DEFAULT_TIME_SEPARATOR;

static NSInteger read_segment_max(const unsigned char *str, const unsigned char **next, unsigned *out_num_digits, unsigned max) {
    unsigned num_digits = 0U;
    NSInteger value = 0;

    while (num_digits < max && isdigit(*str)) {
        value *= 10;
        value += *str - '0';
        ++num_digits;
        ++str;
    }

    if (next) *next = str;
    if (out_num_digits) *out_num_digits = num_digits;

    return value;
}

static NSInteger read_segment(const unsigned char *str, const unsigned char **next, unsigned *out_num_digits) {
    return read_segment_max(str, next, out_num_digits, 100);
}

static NSInteger read_segment_4digits(const unsigned char *str, const unsigned char **next, unsigned *out_num_digits) {
    return read_segment_max(str, next, out_num_digits, 4);
}

static NSInteger read_segment_2digits(const unsigned char *str, const unsigned char **next) {
    return read_segment_max(str, next, NULL, 2);
}

//strtod doesn't support ',' as a separator. This does.
static double read_double(const unsigned char *str, const unsigned char **next) {
    double value = 0.0;

    if (str) {
        unsigned int_value = 0;

        while (isdigit(*str)) {
            int_value *= 10U;
            int_value += (*(str++) - '0');
        }
        value = int_value;

        if (((*str == ',') || (*str == '.'))) {
            ++str;

            double multiplier = 0.1;
            double multiplier_multiplier = 0.1;

            while (isdigit(*str)) {
                value += (*(str++) - '0') * multiplier;
                multiplier *= multiplier_multiplier;
            }
        }
    }

    if (next) *next = str;

    return value;
}

static BOOL is_leap_year(NSInteger year) {
    return (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));
}

@implementation NSDate(ISO8601Parsing)

/*Valid ISO 8601 date formats:
 *
 *YYYYMMDD
 *YYYY-MM-DD
 *YYYY-MM
 *YYYY
 *YY //century
 * //Implied century: YY is 00-99
 *  YYMMDD
 *  YY-MM-DD
 * -YYMM
 * -YY-MM
 * -YY
 * //Implied year
 *  --MMDD
 *  --MM-DD
 *  --MM
 * //Implied year and month
 *   ---DD
 * //Ordinal dates: DDD is the number of the day in the year (1-366)
 *YYYYDDD
 *YYYY-DDD
 *  YYDDD
 *  YY-DDD
 *   -DDD
 * //Week-based dates: ww is the number of the week, and d is the number (1-7) of the day in the week
 *yyyyWwwd
 *yyyy-Www-d
 *yyyyWww
 *yyyy-Www
 *yyWwwd
 *yy-Www-d
 *yyWww
 *yy-Www
 * //Year of the implied decade
 *-yWwwd
 *-y-Www-d
 *-yWww
 *-y-Www
 * //Week and day of implied year
 *  -Wwwd
 *  -Www-d
 * //Week only of implied year
 *  -Www
 * //Day only of implied week
 *  -W-d
 */
+ (NSDate *)dateWithISO8601String:(NSString *)str strictly:(BOOL)strict timeSeparator:(unichar)timeSep getRange:(out NSRange *)outRange {
    if (str == nil) return nil;

    const unsigned char *ch = (const unsigned char *)[str UTF8String];
    if ([str length] == 0 || (strict && isspace(*ch))) {
    invalidDate:
        if (outRange)
            *outRange = NSMakeRange(NSNotFound, 0);
        return nil;
    }

    if (strict) timeSep = ISO8601ParserDefaultTimeSeparatorCharacter;
    NSAssert(timeSep != '\0', @"Time separator must not be NUL.");

    NSRange range = { 0U, 0U };

    // Skip leading whitespace.
    for (; *ch && isspace(*ch); ++ch)
        ++range.location;

    // Save start position for calcuating match length
    const unsigned char *start_of_date = ch;

    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];

    // Date
    NSInteger year;
    NSInteger month_or_week = 1;
    NSInteger day = 1;

    // Time
    NSInteger hour = 0;
    NSTimeInterval minute = 0.0;
    NSTimeInterval second = 0.0;

    // Time zone
    signed tz_hour = 0;
    signed tz_minute = 0;

    enum {
        monthAndDate,
        week,
        dateOnly
    } dateSpecification = monthAndDate;

    NSTimeZone *timeZone = nil;
    NSDate *date = nil;

    if (*ch == 'T') {
        //There is no date here, only a time. Set the date to now; then we'll parse the time.
        if (!isdigit(*++ch))
            goto invalidDate;

        year = [dateComps year];
        month_or_week = [dateComps month];
        day = [dateComps day];
    } else {
        unsigned num_leading_hyphens = 0U;
        while (*ch == '-') {
            ++num_leading_hyphens;
            ++ch;
        }

        unsigned num_digits = 0U;
        NSInteger segment = read_segment(ch, &ch, &num_digits);
        switch (num_digits) {
            case 0:
                if (*ch != 'W')
                    goto invalidDate;

                if ((ch[1] == '-') && isdigit(ch[2]) && ((num_leading_hyphens == 1U) || ((num_leading_hyphens == 2U) && !strict))) {
                    year = [dateComps year];
                    month_or_week = 1;
                    ch += 2;
                    goto parseDayAfterWeek;
                } else if (num_leading_hyphens == 1U) {
                    year = [dateComps year];
                    goto parseWeekAndDay;
                } else
                    goto invalidDate;
                break;

            case 8: //YYYY MM DD
                if (num_leading_hyphens > 0U)
                    goto invalidDate;

                day = segment % 100;
                segment /= 100;
                month_or_week = segment % 100;
                year = segment / 100;
                break;

            case 6: //YYMMDD (implicit century)
                if (num_leading_hyphens > 0U)
                    goto invalidDate;

                day = segment % 100;
                segment /= 100;
                month_or_week = segment % 100;
                year  = [dateComps year];
                year -= (year % 100);
                year += segment / 100;
                break;

            case 4:
                switch (num_leading_hyphens) {
                    case 0: //YYYY
                        year = segment;

                        if (*ch == '-') ++ch;

                        if (!isdigit(*ch)) {
                            if (*ch == 'W')
                                goto parseWeekAndDay;
                            month_or_week = day = 1;
                            break;
                        }

                        segment = read_segment(ch, &ch, &num_digits);
                        switch (num_digits) {
                            case 4: //MMDD
                                day = segment % 100;
                                month_or_week = segment / 100;
                                break;

                            case 2: //MM
                                month_or_week = segment;

                                if (*ch == '-') ++ch;
                                day = !isdigit(*ch) ? 1 : read_segment(ch, &ch, NULL);
                                break;

                            case 3: //DDD
                                day = segment % 1000;
                                dateSpecification = dateOnly;
                                if (strict && (day > (365 + is_leap_year(year))))
                                    goto invalidDate;
                                break;

                            default:
                                goto invalidDate;
                        }
                        break;

                    case 1: //YYMM
                        month_or_week = segment % 100;
                        year = segment / 100;

                        if (*ch == '-') ++ch;
                        day = !isdigit(*ch) ? 1 : read_segment(ch, &ch, NULL);
                        break;

                    case 2: //MMDD
                        day = segment % 100;
                        month_or_week = segment / 100;
                        year = [dateComps year];
                        break;

                    default:
                        goto invalidDate;
                } //switch (num_leading_hyphens) (4 digits)
                break;

            case 1:
                if (strict) {
                    //Two digits only - never just one.
                    if (num_leading_hyphens != 1U)
                        goto invalidDate;

                    if (*ch == '-') ++ch;
                    if (*++ch != 'W')
                        goto invalidDate;

                    year  = [dateComps year];
                    year -= (year % 10);
                    year += segment;
                    goto parseWeekAndDay;
                }

            case 2:
                switch (num_leading_hyphens) {
                    case 0:
                        if (*ch == '-') {
                            //Implicit century
                            year  = [dateComps year];
                            year -= (year % 100);
                            year += segment;

                            if (*++ch == 'W')
                                goto parseWeekAndDay;
                            if (!isdigit(*ch))
                                goto centuryOnly;

                            //Get month and/or date.
                            segment = read_segment_4digits(ch, &ch, &num_digits);
                            NSLog(@"(%@) parsing month; segment is %d and ch is %s", str, (int)segment, ch);
                            switch (num_digits) {
                                case 4: //YY-MMDD
                                    day = segment % 100;
                                    month_or_week = segment / 100;
                                    break;

                                case 1: //YY-M; YY-M-DD (extension)
                                    if (strict)
                                        goto invalidDate;

                                case 2: //YY-MM; YY-MM-DD
                                    month_or_week = segment;
                                    if (*ch == '-' && isdigit(*++ch))
                                        day = read_segment_2digits(ch, &ch);
                                    else
                                        day = 1;
                                    break;

                                case 3: //Ordinal date.
                                    day = segment;
                                    dateSpecification = dateOnly;
                                    break;
                            }
                        } else if (*ch == 'W') {
                            year  = [dateComps year];
                            year -= (year % 100);
                            year += segment;

                        parseWeekAndDay: //*ch should be 'W' here.
                            if (!isdigit(*++ch)) {
                                //Not really a week-based date; just a year followed by '-W'.
                                if (strict)
                                    goto invalidDate;
                                month_or_week = day = 1;
                            } else {
                                month_or_week = read_segment_2digits(ch, &ch);
                                if (*ch == '-') ++ch;
                            parseDayAfterWeek:
                                day = isdigit(*ch) ? read_segment_2digits(ch, &ch) : 1U;
                                dateSpecification = week;
                            }
                        } else {
                            //Century only. Assume current year.
                        centuryOnly:
                            year = segment * 100 + [dateComps year] % 100;
                            month_or_week = day = 1U;
                        }
                        break;

                    case 1:; //-YY; -YY-MM (implicit century)
                        NSLog(@"(%@) found %u digits and one hyphen, so this is either -YY or -YY-MM; segment (year) is %d", str, num_digits, (int)segment);
                        NSInteger current_year = [dateComps year];
                        NSInteger century = (current_year % 100);
                        year = segment + (current_year - century);
                        if (num_digits == 1) //implied decade
                            year += century - (current_year % 10);

                        if (*ch == '-') {
                            ++ch;
                            month_or_week = read_segment_2digits(ch, &ch);
                            NSLog(@"(%@) month is %d", str, (int)month_or_week);
                        } else {
                            month_or_week = 1;
                        }

                        day = 1;
                        break;

                    case 2: //--MM; --MM-DD
                        year = [dateComps year];
                        month_or_week = segment;
                        if (*ch == '-') {
                            ++ch;
                            day = read_segment_2digits(ch, &ch);
                        } else {
                            day = 1U;
                        }
                        break;

                    case 3: //---DD
                        year = [dateComps year];
                        month_or_week = [dateComps month];
                        day = segment;
                        break;

                    default:
                        goto invalidDate;
                } //switch (num_leading_hyphens) (2 digits)
                break;

            case 7: //YYYY DDD (ordinal date)
                if (num_leading_hyphens > 0U)
                    goto invalidDate;

                day = segment % 1000;
                year = segment / 1000;
                dateSpecification = dateOnly;
                if (strict && (day > (365 + is_leap_year(year))))
                    goto invalidDate;
                break;

            case 3: //--DDD (ordinal date, implicit year)
                //Technically, the standard only allows one hyphen. But it says that two hyphens is the logical implementation, and one was dropped for brevity. So I have chosen to allow the missing hyphen.
                if ((num_leading_hyphens < 1) || ((num_leading_hyphens > 2) && !strict))
                    goto invalidDate;

                day = segment;
                year = [dateComps year];
                dateSpecification = dateOnly;
                if (strict && (day > (365 + is_leap_year(year))))
                    goto invalidDate;
                break;

            default:
                goto invalidDate;
        }
    }

    if (isspace(*ch) || (*ch == 'T')) ++ch;

    if (isdigit(*ch)) {
        hour = read_segment_2digits(ch, &ch);
        if (*ch == timeSep) {
            ++ch;
            if ((timeSep == ',') || (timeSep == '.')) {
                //We can't do fractional minutes when '.' is the segment separator.
                //Only allow whole minutes and whole seconds.
                minute = read_segment_2digits(ch, &ch);
                if (*ch == timeSep) {
                    ++ch;
                    second = read_segment_2digits(ch, &ch);
                }
            } else {
                //Allow a fractional minute.
                //If we don't get a fraction, look for a seconds segment.
                //Otherwise, the fraction of a minute is the seconds.
                minute = read_double(ch, &ch);
                second = modf(minute, &minute);
                if (second > DBL_EPSILON)
                    second *= 60.0; //Convert fraction (e.g. .5) into seconds (e.g. 30).
                else if (*ch == timeSep) {
                    ++ch;
                    second = read_double(ch, &ch);
                }
            }
        }

        switch (*ch) {
            case 'Z':
                timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
                break;

            case '+':
            case '-':;
                BOOL negative = *ch == '-';
                if (isdigit(*++ch)) {
                    //Read hour offset.
                    tz_hour = *ch - '0';
                    if (isdigit(*++ch)) {
                        tz_hour *= 10U;
                        tz_hour += *(ch++) - '0';
                    }
                    if (negative) tz_hour = -tz_hour;

                    //Optional separator.
                    if (*ch == timeSep) ++ch;

                    if (isdigit(*ch)) {
                        //Read minute offset.
                        tz_minute = *ch - '0';
                        if (isdigit(*++ch)) {
                            tz_minute *= 10U;
                            tz_minute += *ch - '0';
                        }
                        if (negative) tz_minute = -tz_minute;
                    }

                    timeZone = [NSTimeZone timeZoneForSecondsFromGMT:(tz_hour * 3600) + (tz_minute * 60)];
                }
        }
    }

    if (timeZone)
        gregorian.timeZone = timeZone;

    switch (dateSpecification) {
        case monthAndDate:
            dateComps.year = year;
            dateComps.month = month_or_week;
            dateComps.day = day;
            dateComps.hour = hour;
            dateComps.minute = minute;
            dateComps.second = second;
            date = [gregorian dateFromComponents:dateComps];
            break;

        case week: {
            //Adapted from <http://personal.ecu.edu/mccartyr/ISOwdALG.txt>.
            //This works by converting the week date into an ordinal date, then letting the next case handle it.
            NSInteger prevYear = year - 1;
            NSInteger YY = prevYear % 100;
            NSInteger C = prevYear - YY;
            NSInteger G = YY + YY / 4;
            NSInteger isLeapYear = (((C / 100) % 4) * 5);
            NSInteger Jan1Weekday = (isLeapYear + G) % 7;
            enum { monday, tuesday, wednesday, thursday/*, friday, saturday, sunday*/ };
            day = ((8 - Jan1Weekday) + (7 * (Jan1Weekday > thursday))) + (day - 1) + (7 * (month_or_week - 2));
        }

        case dateOnly: //An "ordinal date".
            dateComps.year = year;
            dateComps.month = 1;
            dateComps.day = 1;
            dateComps.hour = hour;
            dateComps.minute = minute;
            dateComps.second = second;

            date = [gregorian dateFromComponents:dateComps];
            dateComps.year = 0;
            dateComps.month = 0;
            dateComps.day = day - 1;
            dateComps.hour = 0;
            dateComps.minute = 0;
            dateComps.second = 0;
            date = [gregorian dateByAddingComponents:dateComps toDate:date options:0];
            break;
    }

    if (outRange) {
        range.length = (NSUInteger)(ch - start_of_date);
        *outRange = range;
    }

    return date;
}

+ (NSDate *)dateWithISO8601String:(NSString *)str {
    return [self dateWithISO8601String:str strictly:NO getRange:NULL];
}
+ (NSDate *)dateWithISO8601String:(NSString *)str strictly:(BOOL)strict {
    return [self dateWithISO8601String:str strictly:strict getRange:NULL];
}
+ (NSDate *)dateWithISO8601String:(NSString *)str strictly:(BOOL)strict getRange:(out NSRange *)outRange {
    return [self dateWithISO8601String:str strictly:strict timeSeparator:ISO8601ParserDefaultTimeSeparatorCharacter getRange:NULL];
}

+ (NSDate *)dateWithISO8601String:(NSString *)str timeSeparator:(unichar)timeSep getRange:(out NSRange *)outRange {
    return [self dateWithISO8601String:str strictly:NO timeSeparator:timeSep getRange:outRange];
}
+ (NSDate *)dateWithISO8601String:(NSString *)str timeSeparator:(unichar)timeSep {
    return [self dateWithISO8601String:str strictly:NO timeSeparator:timeSep getRange:NULL];
}
+ (NSDate *)dateWithISO8601String:(NSString *)str getRange:(out NSRange *)outRange {
    return [self dateWithISO8601String:str strictly:NO timeSeparator:ISO8601ParserDefaultTimeSeparatorCharacter getRange:outRange];
}

@end
