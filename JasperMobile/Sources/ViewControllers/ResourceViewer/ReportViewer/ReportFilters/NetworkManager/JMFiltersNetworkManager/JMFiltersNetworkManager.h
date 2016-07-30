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
//  JMFiltersNetworkManager.h
//  TIBCO JasperMobile
//

/**
@author Aleksandr Dakhno odahno@tibco.com
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