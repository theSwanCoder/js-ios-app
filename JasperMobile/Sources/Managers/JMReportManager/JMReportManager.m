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
//  JMReportManager.m
//  TIBCO JasperMobile
//

#import "JMReportManager.h"
#import "JSReportOption.h"
#import "JMVisualizeReport.h"
#import "JMRestReport.h"


@implementation JMReportManager

#pragma mark - Public API
+ (void)fetchReportLookupWithResourceURI:(NSString *)reportURI
                              completion:(void(^)(JSOperationResult *result))completion
{
    [self.restClient resourceLookupForURI:reportURI resourceType:@"reportUnit"
                               modelClass:[JSResourceReportUnit class]
                          completionBlock:@weakself(^(JSOperationResult *result)) {
                              if (completion) {
                                  completion(result);
                              }
                          }@weakselfend];
}

+ (void)fetchInputControlsWithReportURI:(NSString *)reportURI
                             completion:(void (^)(JSOperationResult *result))completion
{
    [self.restClient inputControlsForReport:reportURI
                                        ids:nil
                             selectedValues:nil
                            completionBlock:@weakself(^(JSOperationResult *result)) {
                                if (completion) {
                                    completion(result);
                                }
                            }@weakselfend];
}

+ (void)fetchReportOptionsWithReportURI:(NSString *)reportURI
                             completion:(void(^)(JSOperationResult *result))completion
{
    [self.restClient reportOptionsForReportURI:reportURI
                                    completion:@weakself(^(JSOperationResult *result)) {
                                        if (completion) {
                                            completion(result);
                                        }
                                    }@weakselfend];
}

+ (void)deleteReportOption:(JSReportOption *)reportOption withReportURI:(NSString *)reportURI completion:(void(^)(NSError *error))completion
{
    [self.restClient deleteReportOption:reportOption
                          withReportURI:reportURI
                             completion:^(JSOperationResult *result) {
                                 JMLog(@"error: %@", result.error);
                                 JMLog(@"result: %@", result.objects);
                                 if (completion) {
                                     completion(result.error);
                                 }
                             }];
}

+ (void)createReportOptionWithReportURI:(NSString *)reportURI
                            optionLabel:(NSString *)optionLabel
                       reportParameters:(NSArray *)reportParameters
                             completion:(void(^)(JSReportOption *reportOption))completion
{
    [self.restClient createReportOptionWithReportURI:reportURI
                                         optionLabel:optionLabel
                                    reportParameters:reportParameters
                                          completion:^(JSOperationResult *result) {
                                              if (result.error) {
                                                  // handle error
                                              } else {
                                                  JSReportOption *reportOption = result.objects.firstObject;
                                                  if (reportOption && completion) {
                                                      completion(reportOption);
                                                  }
                                              }
                                          }];
}

+ (NSArray *)reportParametersFromInputControls:(NSArray *)inputControls
{
    NSMutableArray *parameters = [NSMutableArray array];
    for (JSInputControlDescriptor *inputControlDescriptor in inputControls) {
        [parameters addObject:[[JSReportParameter alloc] initWithName:inputControlDescriptor.uuid
                                                                value:inputControlDescriptor.selectedValues]];
    }
    return [parameters copy];
}


@end