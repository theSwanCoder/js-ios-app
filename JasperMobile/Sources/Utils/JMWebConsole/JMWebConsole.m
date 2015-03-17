/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
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
//  JMWebConsole.m
//  TIBCO JasperMobile
//


#import "JMWebConsole.h"


@implementation JMWebConsole
+ (void) enable {
    [NSURLProtocol registerClass:self];
}

+ (void) disable {
    [NSURLProtocol unregisterClass:self];
}

+ (BOOL) canInitWithRequest:(NSURLRequest *)request {
    
//    if ([request.URL.absoluteString containsString:@"visualize.js"]) {
//        NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
//        NSLog(@"request absolute path: %@", request.URL.absoluteString);
//        NSLog(@"request path: %@", request.URL.path);
//        NSLog(@"request relativePath: %@", request.URL.relativePath);
//        NSLog(@"request fragment: %@", request.URL.fragment);
//        NSLog(@"request query: %@", request.URL.query);
//        NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
//        NSLog(@"cached response:%@", cachedResponse);
//    }
    
    if ([request.URL.host isEqualToString:@"debugger"]){
        NSLog(@"%@", [[[request URL] path] substringFromIndex: 1]);
    } else {
        NSString *requestUrl = [request.URL absoluteString];
        NSString *loginUrlRegex = [NSString stringWithFormat:@"%@/login.html(.+)?", self.restClient.serverProfile.serverUrl];
        
        NSPredicate *loginUrlValidator = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", loginUrlRegex];
        if ([loginUrlValidator evaluateWithObject:requestUrl]) {
            for (NSHTTPCookie *cookie in self.restClient.cookies) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            }
            // TODO: Here need to handle session expired issue
        }
    }
    return NO;
}

@end