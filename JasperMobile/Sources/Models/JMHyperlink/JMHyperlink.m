/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2016 TIBCO Software, Inc. All rights reserved.
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
//  JMHyperlink.h
//  TIBCO JasperMobile
//

#import "JMHyperlink.h"


@implementation JMHyperlink

#pragma mark - Public API

+ (instancetype)hyperlinkWithHref:(NSString *)href withRawData:(NSDictionary *)data
{
    JMHyperlink *hyperlink = [JMHyperlink new];
    NSDictionary *linkParameters = data;
    if (linkParameters) {
        NSMutableDictionary *params = [linkParameters mutableCopy];
        NSArray <NSString *>*outputs = [self extractOutputsDataFromParameters:&params];
        if (outputs) {
            NSArray <JSReportParameter *>*reportParameters = [self extractReportParametersFromParameters:params];
            hyperlink.type = JMHyperlinkTypeReportExecutionOutput;
            hyperlink.href = href;
            hyperlink.outputFormats = outputs;
            hyperlink.parameters = reportParameters;
        } else {
            NSNumber *page = [self extractPageDataFromParameters:&params];
            NSString *anchor = [self extractAnchorDataFromParameters:&params];
            NSArray <JSReportParameter *>*reportParameters = [self extractReportParametersFromParameters:params];
            if (page || anchor) {
                JSReportDestination *destination = [JSReportDestination new];
                if (anchor) {
                    destination.anchor = anchor;
                } else {
                    destination.page = page.integerValue;
                }
                hyperlink.type = JMHyperlinkTypeReportExecutionDestination;
                hyperlink.href = href;
                hyperlink.destination = destination;
                hyperlink.parameters = reportParameters;
            } else {
                hyperlink.type = JMHyperlinkTypeReportExecution;
                hyperlink.href = href;
                hyperlink.parameters = reportParameters;
            }
        }
    } else {
        hyperlink.type = JMHyperlinkTypeReportExecution;
        hyperlink.href = href;
    }
    return hyperlink;
}

#pragma mark - Helpers

+ (NSNumber *)extractPageDataFromParameters:(NSMutableDictionary **)parameters
{
    if (!parameters || ![*parameters isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    NSArray *pageData = (*parameters)[@"_page"];
    if (!pageData) {
        return nil;
    }

    [(*parameters) removeObjectForKey:@"_page"];

    if (![pageData isKindOfClass:[NSArray class]]) {
        // TODO: need handle other cases
        return nil;
    }

    if (pageData.count == 0) {
        return nil;
    } else if (pageData.count == 1) {
        NSString *pageString = pageData.firstObject;
        return @(pageString.integerValue);
    } else {
        // TODO: need handle multiple pages?
        NSString *pageString = pageData.firstObject;
        return @(pageString.integerValue);
    }
}

+ (NSString *)extractAnchorDataFromParameters:(NSMutableDictionary **)parameters
{
    if (!parameters || ![*parameters isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    NSArray *anchorData = (*parameters)[@"_anchor"];
    if (!anchorData) {
        return nil;
    }

    [(*parameters) removeObjectForKey:@"_anchor"];

    if (![anchorData isKindOfClass:[NSArray class]]) {
        // TODO: need handle other cases
        return nil;
    }

    if (anchorData.count == 0) {
        return nil;
    } else if (anchorData.count == 1) {
        return anchorData.firstObject;
    } else {
        // TODO: need handle multiple anchors?
        return anchorData.firstObject;
    }
}

+ (NSArray <NSString *>*)extractOutputsDataFromParameters:(NSMutableDictionary **)parameters
{
    if (!parameters || ![*parameters isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    NSArray *outputsData = (*parameters)[@"_output"];
    if (!outputsData) {
        return nil;
    }

    [(*parameters) removeObjectForKey:@"_output"];

    return outputsData;
}

+ (NSArray <JSReportParameter *>*)extractReportParametersFromParameters:(NSDictionary *)parameters
{
    NSMutableArray *reportParameters = [NSMutableArray array];
    for (NSString *key in parameters) {
        JSReportParameter *reportParameter = [[JSReportParameter alloc] initWithName:key
                                                                               value:parameters[key]];
        [reportParameters addObject:reportParameter];
    }
    return reportParameters;
}

@end