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

@interface JMFiltersNetworkManager : NSObject
- (instancetype)initWithRestClient:(JSRESTBase *)restClient;
+ (instancetype)managerWithRestClient:(JSRESTBase *)restClient;
- (void)loadInputControlsWithResourceURI:(NSString *)resourceURI
                              completion:(void(^)(NSArray *inputControls, NSError *error))completion;
- (void)loadInputControlsWithResourceURI:(NSString *)resourceURI
                       initialParameters:(NSArray <JSReportParameter *>*)initialParameters
                              completion:(void(^)(NSArray *inputControls, NSError *error))completion;
- (void)loadInputControlsForReportOption:(JSReportOption *)option completion:(void (^)(NSArray *inputControls, NSError *error))completion;
- (void)loadReportOptionsWithResourceURI:(NSString *)resourceURI
                              completion:(void(^)(NSArray *reportOptions, NSError *error))completion;
- (void)updateInputControlsWithResourceURI:(NSString *)resourceURI
                          inputControlsIds:(NSArray <NSString *>*)inputControlsIds
                         updatedParameters:(NSArray <JSReportParameter *>*)updatedParameters
                                completion:(void(^)(NSArray <JSInputControlState *> *resultStates, NSError *error))completion;
- (void)createReportOptionWithResourceURI:(NSString *)resourceURI
                                    label:(NSString *)label
                         reportParameters:(NSArray <JSReportParameter *>*)reportParameters
                               completion:(void(^)(JSReportOption *reportOption, NSError *error))completion;
- (void)deleteReportOption:(JSReportOption *)reportOption
             withReportURI:(NSString *)reportURI
                completion:(void(^)(BOOL success, NSError *error))completion;
- (void)reset;
@end