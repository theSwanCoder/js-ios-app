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
                              completion:(void (^)(JSResourceReportUnit *reportUnit, NSError *error))completion
{
    [self.restClient resourceLookupForURI:reportURI resourceType:@"reportUnit"
                               modelClass:[JSResourceReportUnit class]
                          completionBlock:@weakself(^(JSOperationResult *result)) {
                              if (result.error) {
                                  [self.restClient verifyIsSessionAuthorizedWithCompletion:@weakself(^(BOOL isSessionAuthorized)) {
                                          if (result.error.code == JSSessionExpiredErrorCode && self.restClient.keepSession && isSessionAuthorized) {
                                              [self fetchReportLookupWithResourceURI:reportURI completion:completion];
                                          } else if (completion) {
                                              completion(nil, result.error);
                                          }
                                  }@weakselfend];
                              } else if (completion) {
                                  JSResourceReportUnit *reportUnit = [result.objects firstObject];
                                  completion(reportUnit, nil);
                              }
                          }@weakselfend];
}

+ (void)fetchInputControlsWithReportURI:(NSString *)reportURI
                             completion:(void (^)(NSArray *inputControls, NSError *error))completion
{
    [self.restClient inputControlsForReport:reportURI
                                        ids:nil
                             selectedValues:nil
                            completionBlock:@weakself(^(JSOperationResult *result)) {
                                if (result.error) {
                                    [self.restClient verifyIsSessionAuthorizedWithCompletion:@weakself(^(BOOL isSessionAuthorized)) {
                                            if (result.error.code == JSSessionExpiredErrorCode && self.restClient.keepSession && isSessionAuthorized) {
                                                [self fetchInputControlsWithReportURI:reportURI completion:completion];
                                            } else if (completion) {
                                                completion(nil, result.error);
                                            }
                                        }@weakselfend];
                                } else if (completion) {
                                    NSMutableArray *visibleInputControls = [NSMutableArray array];
                                    for (JSInputControlDescriptor *inputControl in result.objects) {
                                        if (inputControl.visible.boolValue) {
                                            [visibleInputControls addObject:inputControl];
                                        }
                                    }
                                    completion(visibleInputControls, nil);
                                }
                            }@weakselfend];
}

+ (void)fetchReportOptionsWithReportURI:(NSString *)reportURI
                             completion:(void(^)(NSArray *reportOptions, NSError *error))completion
{
    [self.restClient reportOptionsForReportURI:reportURI
                                    completion:@weakself(^(JSOperationResult *result)) {
                                        if (result.error) {
                                            [self.restClient verifyIsSessionAuthorizedWithCompletion:@weakself(^(BOOL isSessionAuthorized)) {
                                                    if (result.error.code == JSSessionExpiredErrorCode && self.restClient.keepSession && isSessionAuthorized) {
                                                        [self fetchInputControlsWithReportURI:reportURI completion:completion];
                                                    } else if (completion) {
                                                        completion(nil, result.error);
                                                    }
                                                }@weakselfend];
                                        } else if (completion) {
                                            NSMutableArray *reportOptions = [NSMutableArray array];

                                            for (id reportOption in result.objects) {
                                                if ([reportOption isKindOfClass:[JSReportOption class]] && [reportOption identifier]) {
                                                    JMExtendedReportOption *extendedOption = [JMExtendedReportOption new];
                                                    extendedOption.reportOption = reportOption;
                                                    [reportOptions addObject:extendedOption];
                                                }
                                            }
                                            completion(reportOptions, nil);
                                        }
                                    }@weakselfend];
}

+ (void)deleteReportOption:(JSReportOption *)reportOption withReportURI:(NSString *)reportURI completion:(void(^)(NSError *error))completion
{
    [self.restClient deleteReportOption:reportOption
                          withReportURI:reportURI
                             completion:^(JSOperationResult *result) {
                                 if (result.error) {
                                     [self.restClient verifyIsSessionAuthorizedWithCompletion:@weakself(^(BOOL isSessionAuthorized)) {
                                             if (result.error.code == JSSessionExpiredErrorCode && self.restClient.keepSession && isSessionAuthorized) {
                                                 [self deleteReportOption:reportOption withReportURI:reportURI completion:completion];
                                             } else if (completion) {
                                                 completion(result.error);
                                             }
                                         }@weakselfend];
                                 } else if (completion) {
                                     completion(nil);
                                 }
                             }];
}

+ (void)createReportOptionWithReportURI:(NSString *)reportURI
                            optionLabel:(NSString *)optionLabel
                       reportParameters:(NSArray *)reportParameters
                             completion:(void(^)(JSReportOption *reportOption, NSError *error))completion
{
    [self.restClient createReportOptionWithReportURI:reportURI
                                         optionLabel:optionLabel
                                    reportParameters:reportParameters
                                          completion:^(JSOperationResult *result) {
                                              if (result.error) {
                                                  [self.restClient verifyIsSessionAuthorizedWithCompletion:@weakself(^(BOOL isSessionAuthorized)) {
                                                          if (result.error.code == JSSessionExpiredErrorCode && self.restClient.keepSession && isSessionAuthorized) {
                                                              [self createReportOptionWithReportURI:reportURI optionLabel:optionLabel reportParameters:reportParameters completion:completion];
                                                          } else if (completion) {
                                                              completion(nil, result.error);
                                                          }
                                                      }@weakselfend];
                                              } else if (completion) {
                                                  JSReportOption *reportOption = [result.objects firstObject];
                                                  completion(reportOption, nil);
                                              }
                                          }];
}

#pragma mark - Helpers
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