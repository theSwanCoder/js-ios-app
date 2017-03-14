/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMFiltersNetworkManager.h"

@interface JMFiltersNetworkManager()
@property (nonatomic, copy) JSRESTBase *activeRestClient;
@end

@implementation JMFiltersNetworkManager

#pragma mark - Life Cycle

- (instancetype)initWithRestClient:(JSRESTBase *)restClient
{
    self = [super init];
    if (self) {
        _activeRestClient = [restClient copy];
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
    [self.activeRestClient inputControlsForReport:resourceURI
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
    [self.activeRestClient reportOptionsForReportURI:resourceURI
                                    completion:^(JSOperationResult * _Nullable result) {
                                        if (result.error) {
                                            if (result.error.code == JSHTTPErrorCode && result.statusCode == 404) {
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
    [self.activeRestClient updatedInputControlsValues:resourceURI
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
    [self.activeRestClient createReportOptionWithReportURI:resourceURI
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
    [self.activeRestClient deleteReportOption:reportOption
                          withReportURI:reportURI
                             completion:^(JSOperationResult * _Nullable result) {
                                 completion(result.error == nil, result.error);
                             }];
}

- (void)reset
{
    [self.activeRestClient cancelAllRequests];
}


@end
