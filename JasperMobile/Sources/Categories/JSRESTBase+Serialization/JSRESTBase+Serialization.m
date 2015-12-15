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
//  JSRESTBase+Serialization.m
//  TIBCO JasperMobile
//

#import "JSRESTBase+Serialization.h"
#import "JSProfile+Serialization.h"

NSString * const kJSRESTBaseServerProfileKey = @"kJSRESTBaseServerProfileKey";
NSString * const kJSRESTBaseTimeoutIntervalKey = @"kJSRESTBaseTimeoutIntervalKey";
NSString * const kJSRESTBaseKeepSessionKey = @"kJSRESTBaseKeepSessionKey";

@implementation JSRESTBase (Serialization)

+ (JSRESTBase *)clientFromDictionary:(NSDictionary*)dictionary
{
    NSTimeInterval timeInterval = ((NSNumber *)dictionary[kJSRESTBaseTimeoutIntervalKey]).doubleValue;
    BOOL keepSession = ((NSNumber *)dictionary[kJSRESTBaseKeepSessionKey]).boolValue;
    NSDictionary *serverProfileDictionary = dictionary[kJSRESTBaseServerProfileKey];
    JSProfile *profile = [JSProfile profileFromDictionary:serverProfileDictionary];

    JSRESTBase *restClient = [[JSRESTBase alloc] initWithServerProfile:profile
                                                            keepLogged:keepSession];
    restClient.timeoutInterval = timeInterval;
    return restClient;
}

- (NSDictionary *)convertToDictionary
{
    NSDictionary *dictionary = @{
            kJSRESTBaseServerProfileKey   : [self.serverProfile convertToDictionary],
            kJSRESTBaseTimeoutIntervalKey : @(self.timeoutInterval),
            kJSRESTBaseKeepSessionKey     : @(self.keepSession)
    };
    return dictionary;
}

@end