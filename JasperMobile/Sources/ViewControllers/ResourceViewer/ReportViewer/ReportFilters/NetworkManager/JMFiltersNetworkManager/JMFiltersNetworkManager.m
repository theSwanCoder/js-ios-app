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
//  JMFiltersNetworkManager.m
//  TIBCO JasperMobile
//

#import "JMFiltersNetworkManager.h"

@interface JMFiltersNetworkManager()
@property (nonatomic, strong) JSRESTBase *activeRestClient;
@end

@implementation JMFiltersNetworkManager

#pragma mark - Life Cycle

+ (instancetype)sharedManager
{
    static JMFiltersNetworkManager *sharedManager;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)initWithRestClient:(JSRESTBase *)restClient
{
    self = [super init];
    if (self) {
        _activeRestClient = restClient;
    }
    return self;
}

+ (instancetype)managerWithRestClient:(JSRESTBase *)restClient
{
    return [[self alloc] initWithRestClient:restClient];
}

#pragma mark - Public API

- (void)loadInputControlsWithResourceURI:(NSString *)resourceURI
                              completion:(void(^)(NSArray *inputControls, NSError *error))completion
{
    [self loadInputControlsWithResourceURI:resourceURI
                         initialParameters:nil
                                completion:completion];
}

- (void)loadInputControlsWithResourceURI:(NSString *)resourceURI
                       initialParameters:(NSArray <JSReportParameter *>*)initialParameters
                              completion:(void(^)(NSArray *inputControls, NSError *error))completion
{
    [self.restClient inputControlsForReport:resourceURI
                             selectedValues:initialParameters
                            completionBlock:^(JSOperationResult * _Nullable result) {
                                if (result.error) {
                                    completion(nil, result.error);
                                } else {
                                    NSMutableArray *visibleInputControls = [NSMutableArray array];
                                    for (JSInputControlDescriptor *inputControl in result.objects) {
                                        if (inputControl.visible.boolValue) {
                                            [visibleInputControls addObject:inputControl];
                                        }
                                    }
                                    completion(visibleInputControls, nil);
                                }
                            }];
}

- (void)loadInputControlsForReportOption:(JSReportOption *)option completion:(void(^)(NSArray *inputControls, NSError *error))completion
{
    [self loadInputControlsWithResourceURI:option.uri
                         initialParameters:nil
                                completion:completion];

}

- (void)loadReportOptionsWithResourceURI:(NSString *)resourceURI
                              completion:(void(^)(NSArray *reportOptions, NSError *error))completion
{
    [self.restClient reportOptionsForReportURI:resourceURI
                                    completion:^(JSOperationResult * _Nullable result) {
                                        if (result.error) {
                                            if (result.error.code == JSUnsupportedAcceptTypeErrorCode) {
                                                // TODO: skip for now
                                                // There is an case of getting 'string' object when there are no options.
                                                completion(@[], nil);
                                            } else {
                                                completion(nil, result.error);
                                            }
                                        } else {
                                            NSMutableArray *reportOptions = [NSMutableArray array];
                                            for (id reportOption in result.objects) {
                                                if ([reportOption isKindOfClass:[JSReportOption class]] && [reportOption identifier]) {
                                                    [reportOptions addObject:reportOption];
                                                }
                                            }
                                            completion(reportOptions, nil);
                                        }
                                    }];
}

- (void)updateInputControlsWithResourceURI:(NSString *)resourceURI
                          inputControlsIds:(NSArray <NSString *>*)inputControlsIds
                         updatedParameters:(NSArray <JSReportParameter *>*)updatedParameters
                                completion:(void(^)(NSArray <JSInputControlState *> *resultStates, NSError *error))completion
{
    [self.restClient updatedInputControlsValues:resourceURI
                                            ids:inputControlsIds
                                 selectedValues:updatedParameters
                                completionBlock:^(JSOperationResult *result) {
                                    completion(result.objects, result.error);
                                }];
}

- (void)createReportOptionWithResourceURI:(NSString *)resourceURI
                                    label:(NSString *)label
                         reportParameters:(NSArray <JSReportParameter *>*)reportParameters
                               completion:(void(^)(JSReportOption *reportOption, NSError *error))completion
{
    [self.restClient createReportOptionWithReportURI:resourceURI
                                         optionLabel:label
                                    reportParameters:reportParameters
                                          completion:^(JSOperationResult * _Nullable result) {
                                              if (result.error) {
                                                  completion(nil, result.error);
                                              } else {
                                                  if (result.objects.count > 1) {
                                                      // TODO: need handle this case?
                                                  } else {
                                                      completion(result.objects.firstObject, nil);
                                                  }
                                              }
                                          }];
}

- (void)deleteReportOption:(JSReportOption *)reportOption
             withReportURI:(NSString *)reportURI
                completion:(void(^)(BOOL success, NSError *error))completion
{
    [self.restClient deleteReportOption:reportOption
                          withReportURI:reportURI
                             completion:^(JSOperationResult * _Nullable result) {
                                 completion(result.error == nil, result.error);
                             }];
}

- (void)reset
{
    [self.restClient cancelAllRequests];
}


@end