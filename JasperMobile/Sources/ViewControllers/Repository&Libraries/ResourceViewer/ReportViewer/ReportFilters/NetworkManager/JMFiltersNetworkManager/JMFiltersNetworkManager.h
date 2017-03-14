/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
@author Oleksandr Dahno odahno@tibco.com
@since 2.6
*/

#import <Foundation/Foundation.h>
#import "JaspersoftSDK.h"

@interface JMFiltersNetworkManager : NSObject
- (instancetype __nullable)initWithRestClient:(JSRESTBase *__nonnull)restClient;
+ (instancetype __nullable)managerWithRestClient:(JSRESTBase *__nonnull)restClient;
- (void)loadInputControlsWithResourceURI:(NSString *__nonnull)resourceURI
                              completion:(void(^__nonnull)(NSArray *__nullable inputControls, NSError *__nullable error))completion;
- (void)loadInputControlsWithResourceURI:(NSString *__nonnull)resourceURI
                       initialParameters:(NSArray <JSReportParameter *>*__nullable)initialParameters
                              completion:(void(^__nonnull)(NSArray *__nullable inputControls, NSError *__nullable error))completion;
- (void)loadInputControlsForReportOption:(JSReportOption *__nonnull)option
                              completion:(void (^__nonnull)(NSArray *__nullable inputControls, NSError *__nullable error))completion;
- (void)loadReportOptionsWithResourceURI:(NSString *__nonnull)resourceURI
                              completion:(void(^__nonnull)(NSArray *__nullable reportOptions, NSError *__nullable error))completion;
- (void)updateInputControlsWithResourceURI:(NSString *__nonnull)resourceURI
                          inputControlsIds:(NSArray <NSString *>*__nonnull)inputControlsIds
                         updatedParameters:(NSArray <JSReportParameter *>*__nonnull)updatedParameters
                                completion:(void(^__nonnull)(NSArray <JSInputControlState *> *__nullable resultStates, NSError *__nullable error))completion;
- (void)createReportOptionWithResourceURI:(NSString *__nonnull)resourceURI
                                    label:(NSString *__nonnull)label
                         reportParameters:(NSArray <JSReportParameter *>*__nonnull)reportParameters
                               completion:(void(^__nonnull)(JSReportOption *__nullable reportOption, NSError *__nullable error))completion;
- (void)deleteReportOption:(JSReportOption *__nonnull)reportOption
             withReportURI:(NSString *__nonnull)reportURI
                completion:(void(^__nonnull)(BOOL success, NSError *__nullable error))completion;
- (void)reset;
@end
