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

@interface JMJavascriptRequest()
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, strong) NSString *parametersAsString;
@end

@implementation JMJavascriptRequest

#pragma mark - Init
- (instancetype __nullable)initWithCommand:(NSString * __nonnull)command parameters:(NSDictionary * __nullable)parameters
{
    self = [super init];
    if (self) {
        _command = command;
        _parameters = parameters;
    }
    return self;
}

+ (instancetype __nullable)requestWithCommand:(NSString * __nonnull)command parameters:(NSDictionary * __nullable)parameters
{
    return [[self alloc] initWithCommand:command parameters:parameters];
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
    self.parametersAsString = [self prepareParamsAsStringFromParameters:self.parameters];
    NSString *fullJavascriptString;
    fullJavascriptString = [NSString stringWithFormat:@"%@(%@);", command, self.parametersAsString];
    JMLog(@"fullJavascriptString: %@", fullJavascriptString);
    return fullJavascriptString;
}

#pragma mark - Helpers
- (NSString *)prepareParamsAsStringFromParameters:(NSDictionary *)parameters
{
    if (!parameters) {
        return @"";
    }

    NSError *serializeError;
    NSData *paramsData = [NSJSONSerialization dataWithJSONObject:parameters
                                                         options:NSJSONWritingPrettyPrinted
                                                           error:&serializeError];

    NSString *paramsDataAsString = [[NSString alloc] initWithData:paramsData
                                               encoding:NSUTF8StringEncoding];
    return paramsDataAsString;
}

@end