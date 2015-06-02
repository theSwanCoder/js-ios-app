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
//  JMJavascriptNativeBridge.m
//  TIBCO JasperMobile
//

#import "JMJavascriptNativeBridge.h"
#import "JMJavascriptRequest.h"
#import "JMJavascriptCallback.h"


@interface JMJavascriptNativeBridge() <UIWebViewDelegate>
@end

@implementation JMJavascriptNativeBridge

#pragma mark - Custom Accessors
- (void)setWebView:(UIWebView *)webView
{
    _webView = webView;
    _webView.delegate = self;
}

#pragma mark - Public API
- (void)sendRequest:(JMJavascriptRequest *)request
{
    NSString *javascriptString = request.command;
    NSString *parameters = request.parametersAsString;
    NSString *fullJavascriptString = [NSString stringWithFormat:javascriptString, parameters];
    [self.webView stringByEvaluatingJavaScriptFromString:fullJavascriptString];
}

#pragma mark - UIWebViewDelegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *callback = @"http://jaspermobile.callback/";
    NSString *requestURLString = request.URL.absoluteString;
//    NSLog(@"requestURLString: %@", requestURLString);

    if ([requestURLString rangeOfString:callback].length) {

        NSRange callbackRange = [requestURLString rangeOfString:callback];
        NSRange commandRange = NSMakeRange(callbackRange.length, requestURLString.length - callbackRange.length);
        NSString *command = [requestURLString substringWithRange:commandRange];

        NSDictionary *parameters = [self parseCommand:command];

        JMJavascriptCallback *response = [JMJavascriptCallback new];
        response.type = parameters[@"callback.type"];
        response.parameters = parameters;
        [self.delegate javascriptNativeBridge:self didReceiveCallback:response];

        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Helpers
- (NSDictionary *)parseCommand:(NSString *)command
{
    NSString *decodedCommand = [command stringByRemovingPercentEncoding];
    NSArray *components = [decodedCommand componentsSeparatedByString:@"&"];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    result[@"callback.type"] = [components firstObject];

    NSMutableArray *parameters = [NSMutableArray arrayWithArray:components];
    [parameters removeObjectAtIndex:0];
    for (NSString *component in parameters) {
        NSArray *keyValue = [component componentsSeparatedByString:@"="];
        if (keyValue.count == 2) {
            result[keyValue[0]] = keyValue[1];
        }
    }
    return result;
}

@end