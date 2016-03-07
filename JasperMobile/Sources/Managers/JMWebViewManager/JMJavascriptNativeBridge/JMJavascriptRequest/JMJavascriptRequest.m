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
//  JMJavascriptRequest.m
//  TIBCO JasperMobile
//

#import "JMJavascriptRequest.h"

typedef NS_ENUM(NSInteger, JMJavascriptRequestType) {
    JMJavascriptRequestTypeVisualize,
    JMJavascriptRequestTypeCustom
};

@interface JMJavascriptRequest()
@property (nonatomic) JMJavascriptRequestType type;
@end

@implementation JMJavascriptRequest

#pragma mark - Init
- (instancetype)initWithCommand:(NSString *)command parametersAsString:(NSString *)parametersAsString
{
    self = [super init];
    if (self) {
        _command = command;
        _parametersAsString = parametersAsString;
        _type = JMJavascriptRequestTypeVisualize;
    }
    return self;
}

+ (instancetype)requestWithCommand:(NSString *)command parametersAsString:(NSString *)parametersAsString
{
    return [[self alloc] initWithCommand:command parametersAsString:parametersAsString];
}

- (instancetype)initWithScript:(NSString *)script
{
    self = [super init];
    if (self) {
        [self parseScript:script];
        if (!_command) {
            return nil;
        }
        _type = JMJavascriptRequestTypeCustom;
    }
    return self;
}

+ (instancetype)requestWithScript:(NSString *)script
{
    return [[self alloc] initWithScript:script];
}

#pragma mark - NSCopying + NSObject Protocol
- (NSUInteger)hash
{
    NSString *fullCommand = [NSString stringWithFormat:@"command:%@parametersAsString:%@", self.command, self.parametersAsString];
    NSUInteger hash = [fullCommand hash];
    return hash;
}

- (BOOL)isEqual:(JMJavascriptRequest *)secondRequest
{
    BOOL isCommandEqual = [self.command isEqual:secondRequest.command];
    BOOL isParametersEqual = [self.parametersAsString isEqual:secondRequest.parametersAsString];
    return isCommandEqual && isParametersEqual;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    JMJavascriptRequest *newRequest = (JMJavascriptRequest *) [[self class] allocWithZone:zone];
    newRequest.command = [self.command copyWithZone:zone];
    newRequest.parametersAsString = [self.parametersAsString copyWithZone:zone];
    return newRequest;
}

#pragma mark - Print
- (NSString *)description
{
    NSString *description = [NSString stringWithFormat:@"\nJMJavascriptRequest: %@\ncommand:%@\nparametersAsString:%@", [super description], self.command, self.parametersAsString];
    return description;
}


#pragma mark - Public API
- (NSString *)fullJavascriptRequestString
{
    NSString *command = self.command;
    NSString *parameters = self.parametersAsString ?: @"";
    NSString *fullJavascriptString;
    if (self.type == JMJavascriptRequestTypeVisualize) {
        fullJavascriptString = [NSString stringWithFormat:@"%@(%@);", command, parameters];
    } else if (self.type == JMJavascriptRequestTypeCustom) {
        fullJavascriptString = [NSString stringWithFormat:@"JasperMobile.Helper.execCustomScript(%@, %@);", command, parameters];
    }
    JMLog(@"fullJavascriptString: %@", fullJavascriptString);
    return fullJavascriptString;
}

#pragma mark - Helpers
- (void)parseScript:(NSString *)script
{
    NSString *fullCommand = [self fullCommandFromScript:script];
    JMLog(@"full command: %@", fullCommand);

    NSError *error;
    NSRegularExpression *commandRegex = [NSRegularExpression regularExpressionWithPattern:@"(\\S*)\\(([\\s*\\S*]*)\\);"
                                                                                 options:NSRegularExpressionCaseInsensitive
                                                                                   error:&error];
    NSArray *matches = [commandRegex matchesInString:fullCommand
                                             options:NSMatchingReportProgress
                                               range:NSMakeRange(0, fullCommand.length)];

    if (matches.count == 1) {
        NSTextCheckingResult *matchResult = matches.firstObject;

        if (matchResult.numberOfRanges == 3) {
            NSRange commandRange = [matchResult rangeAtIndex:1];
            NSRange parametersRange = [matchResult rangeAtIndex:2];

            _command = [fullCommand substringWithRange:commandRange];
            _parametersAsString = [fullCommand substringWithRange:parametersRange];
        }
    }
}

- (NSString *)fullCommandFromScript:(NSString *)script
{
    NSString *fullCommand;

    NSRange scriptRange = NSMakeRange(0, script.length);

    NSError *error;
    NSRegularExpression *scriptRegex = [NSRegularExpression regularExpressionWithPattern:@">([\\s*\\S*]*)<\\/script>"
                                                                                 options:NSRegularExpressionCaseInsensitive
                                                                                   error:&error];
    NSArray *matches = [scriptRegex matchesInString:script
                                            options:NSMatchingReportProgress
                                              range:scriptRange];

    if (matches.count == 1) {
        NSTextCheckingResult *matchResult = matches.firstObject;
        // select range
        NSRange selectedJSRange = [matchResult rangeAtIndex:1];
        fullCommand = [script substringWithRange:selectedJSRange];
    }

    fullCommand = [fullCommand stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    return fullCommand;
}

@end