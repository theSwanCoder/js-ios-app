/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
 * http://community.jaspersoft.com/project/jaspermobile-ios
 *
 * Unless you have purchased a commercial license agreement from Jaspersoft,
 * the following license terms apply:
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/lgpl>.
 */


//
//  JMHTMLParser.m
//  TIBCO JasperMobile
//

#import "JMHTMLParser.h"

@interface JMHTMLParser()
@property (nonatomic, strong) NSString *htmlString;
@property (nonatomic, strong) NSString *contentString;
@end

@implementation JMHTMLParser

#pragma mark - Life Cycle
- (instancetype __nullable)initWithHTMLString:(NSString * __nonnull)htmlString
{
    self = [super init];
    if (self) {
        _htmlString = htmlString;
    }
    return self;
}

+ (instancetype __nullable)parserWithHTMLString:(NSString * __nonnull)htmlString
{
    return [[self alloc] initWithHTMLString:htmlString];
}

#pragma mark - Public API
- (void)parse
{
    NSString *htmlBodyString = [self extractBodyFromHTMLPage:self.htmlString];
    NSArray *scripts = [self scriptsFromPage:self.htmlString];

    // remove wrapper table
    [self extractContentFromBodyString:htmlBodyString];
    NSString *htmlBodyStringWithoutScripts = [self removeScripts:scripts fromPage:htmlBodyString];
    NSString *content = [self extractContentFromBodyString:htmlBodyStringWithoutScripts];
    if (content) {
        self.contentString = content;
    } else {
        self.contentString = htmlBodyStringWithoutScripts;
    }
}

- (NSString *)content
{
    return self.contentString;
}

#pragma mark - Helpers
- (NSString *)extractBodyFromHTMLPage:(NSString *)page
{
    NSError *error;
    NSString *pattern = @"<body\\s*.*>((\\s*.*)*)<\\/body>";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    __block NSString *bodyString;
    [regex enumerateMatchesInString:page
                            options:NSMatchingReportProgress
                              range:NSMakeRange(0, page.length)
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             if (result) {
                                 NSRange range = result.range;
                                 bodyString = [page substringWithRange:range];
                             }
                         }];
    return bodyString;
}

- (NSString *)extractContentFromBodyString:(NSString *)bodyString
{
    NSRange range = [bodyString rangeOfString:@"<a name=\"JR_PAGE_ANCHOR"
                                                 options:NSCaseInsensitiveSearch
                                                   range:NSMakeRange(0, bodyString.length)];

    if (range.length == 0) {
        return nil;
    }

    NSUInteger location = range.location;
    NSUInteger length = bodyString.length - location;

    NSRange contentRange = NSMakeRange(location, length);
    NSString *substring = [bodyString substringWithRange:contentRange];

    JMLog(@"substring: %@", substring);
    return substring;
}

- (NSArray *)scriptsFromPage:(NSString *)page
{
    NSMutableArray *scripts = [@[] mutableCopy];

    NSRange searchRange = NSMakeRange(0, page.length);

    NSUInteger startSearchLength = searchRange.length;
    while (searchRange.location <= startSearchLength) {
        NSRange startScriptRange = [page rangeOfString:@"<script"
                                               options:NSCaseInsensitiveSearch
                                                 range:searchRange];

        if (startScriptRange.length == 0) {
            break;
        }

        NSRange endScriptRange = [page rangeOfString:@"</script>"
                                             options:NSCaseInsensitiveSearch
                                               range:searchRange];

        NSUInteger scriptRangeLocation = startScriptRange.location;
        NSUInteger scriptRangeLength = endScriptRange.location + endScriptRange.length - scriptRangeLocation;
        NSRange scriptRange = NSMakeRange(scriptRangeLocation, scriptRangeLength);
        NSString *script = [page substringWithRange:scriptRange];

        [scripts addObject:script];

        searchRange.location = endScriptRange.location + endScriptRange.length;
        searchRange.length = startSearchLength - searchRange.location;
    }

    return scripts;
}

- (NSString *)removeScripts:(NSArray *)scripts fromPage:(NSString *)page
{
    NSString *pageWithoutScripts = page;
    for (NSString *script in scripts) {
        pageWithoutScripts = [pageWithoutScripts stringByReplacingOccurrencesOfString:script withString:@""];
    }

    return pageWithoutScripts;
}

@end