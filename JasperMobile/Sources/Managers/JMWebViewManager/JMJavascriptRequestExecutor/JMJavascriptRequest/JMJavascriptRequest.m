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
@property (nonatomic, copy, readwrite) NSString *command;
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, strong) NSString *parametersAsString;
@property (nonatomic, assign) JMJavascriptNamespace namespace;
@end

@implementation JMJavascriptRequest

#pragma mark - Init
- (instancetype __nullable)initWithCommand:(NSString * __nonnull)command
                               inNamespace:(JMJavascriptNamespace)namespace
                                parameters:(NSDictionary * __nullable)parameters
{
    self = [super init];
    if (self) {
        _command = command;
        _parameters = parameters;
        _namespace = namespace;
    }
    return self;
}

+ (instancetype __nullable)requestWithCommand:(NSString * __nonnull)command
                                  inNamespace:(JMJavascriptNamespace)namespace
                                   parameters:(NSDictionary * __nullable)parameters
{
    return [[self alloc] initWithCommand:command
                             inNamespace:namespace
                              parameters:parameters];
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
    newRequest.namespace = self.namespace;
    newRequest.parametersAsString = [self.parametersAsString copyWithZone:zone];
    return newRequest;
}

#pragma mark - Print
- (NSString *)description
{
    NSString *description = [NSString stringWithFormat:@"\nJMJavascriptRequest: %@\ncommand:%@\n", [super description], [self fullCommand]];
    return description;
}


#pragma mark - Public API
- (NSString *)fullJavascriptRequestString
{
    self.parametersAsString = [self prepareParamsAsStringFromParameters:self.parameters];
    NSString *namespaceStringValue = [self stringValueForNamespace:self.namespace];
    NSString *fullJavascriptString;
    fullJavascriptString = [NSString stringWithFormat:@"%@%@(%@);", namespaceStringValue, self.command, self.parametersAsString];
    return fullJavascriptString;
}

- (NSString *)fullCommand
{
    NSString *namespaceStringValue = [self stringValueForNamespace:self.namespace];
    return [NSString stringWithFormat:@"%@%@", namespaceStringValue, self.command];
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

- (NSString *)stringValueForNamespace:(JMJavascriptNamespace)namespace
{
    NSString *stringValue;
    switch(namespace) {
        case JMJavascriptNamespaceDefault: {
            stringValue = @"";
            break;
        }
        case JMJavascriptNamespaceVISReport: {
            stringValue = @"JasperMobile.VIS.Report.";
            break;
        }
        case JMJavascriptNamespaceVISDashboard: {
            stringValue = @"JasperMobile.VIS.Dashboard.";
            break;
        }
        case JMJavascriptNamespaceRESTReport: {
            stringValue = @"JasperMobile.REST.Report.";
            break;
        }
        case JMJavascriptNamespaceRESTDashboard: {
            stringValue = @"JasperMobile.REST.Dashboard.";
            break;
        }
        case JMJavascriptNamespaceVISAdHoc: {
            stringValue = @"JasperMobile.VIS.AdHoc.";
            break;
        }
    }
    return stringValue;
}

@end
