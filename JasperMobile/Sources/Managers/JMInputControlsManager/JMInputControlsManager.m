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
//  JMInputControlsManager.m
//  TIBCO JasperMobile
//

#import "JMInputControlsManager.h"
#import "JSReportOption.h"


@implementation JMInputControlsManager

#pragma mark - Public API
- (void)fetchInputControlsWithReportURI:(NSString *)reportURI
                             completion:(void (^)(NSArray *inputControls, NSError *error))completion
{
    [self.restClient inputControlsForReport:reportURI
                                        ids:nil
                             selectedValues:nil
                            completionBlock:@weakself(^(JSOperationResult *result)) {

                                    if (result.error) {
                                        if (result.error.code == JSSessionExpiredErrorCode) {
                                            if (self.restClient.keepSession && [self.restClient isSessionAuthorized]) {
                                                [self fetchInputControlsWithReportURI:reportURI completion:completion];
                                            } else {
                                                [JMUtils showLoginViewAnimated:YES completion:@weakself(^(void)) {
                                                        [self cancel];
                                                    } @weakselfend];
                                            }
                                        } else {
                                            if (completion) {
                                                completion(nil, result.error);
                                            }
                                        }
                                    } else {

                                        NSMutableArray *invisibleInputControls = [NSMutableArray array];
                                        for (JSInputControlDescriptor *inputControl in result.objects) {
                                            if (!inputControl.visible.boolValue) {
                                                [invisibleInputControls addObject:inputControl];
                                            }
                                        }

                                        if (result.objects.count - invisibleInputControls.count == 0) {
                                            completion(nil, nil);
                                        } else {
                                            NSMutableArray *inputControls = [result.objects mutableCopy];
                                            if (invisibleInputControls.count) {
                                                [inputControls removeObjectsInArray:invisibleInputControls];
                                            }
                                            completion([inputControls copy], nil);
                                        }
                                    }

                                }@weakselfend];
}

// TODO: move to another manager
- (void)fetchReportLookupWithResourceURI:(NSString *)reportURI
                              completion:(void(^)(JSResourceReportUnit *reportUnit, NSError *error))completion
{
    [self.restClient resourceLookupForURI:reportURI resourceType:@"reportUnit"
                               modelClass:[JSResourceReportUnit class]
                          completionBlock:@weakself(^(JSOperationResult *result)) {
                                  if (result.error) {
                                      if (completion) {
                                          completion(nil, result.error);
                                      }
                                  } else {
                                      JSResourceReportUnit *reportUnit = [result.objects firstObject];
                                      if (reportUnit) {
                                          if (completion) {
                                              completion(reportUnit, nil);
                                          }
                                      } else {
                                          // TODO: add error
                                          completion(nil, nil);
                                      }
                                  }
                              }@weakselfend];
}

- (void)fetchReportOptionsWithReportURI:(NSString *)reportURI
                             completion:(void(^)(NSArray *reportOptions, NSError *error))completion
{
    [self.restClient reportOptionsForReportURI:reportURI
                                    completion:^(JSOperationResult *result) {
                                        if (completion) {
                                            NSMutableArray *reportOptions = [NSMutableArray array];
                                            for (JSReportOption *reportOption in result.objects) {
                                                if (reportOption.identifier) {
                                                    [reportOptions addObject:reportOption];
                                                }
                                            }
                                            completion([reportOptions copy], result.error);
                                        }
                                    }];
}

- (void)deleteReportOption:(JSReportOption *)reportOption withReportURI:(NSString *)reportURI completion:(void(^)(NSError *error))completion
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

- (void)createReportOptionWithReportURI:(NSString *)reportURI
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

#pragma mark - Private API
- (void)cancel
{
    [self.restClient cancelAllRequests];
}

@end