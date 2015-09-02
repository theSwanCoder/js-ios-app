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
//  JMReportManager.h
//  TIBCO JasperMobile
//


/**
 @author Aleksandr Dakhno odahno@tibco.com
 @author Alexey Gubarev ogubarie@tibco.com

 @since 2.2
 */

#import "JMExtendedReportOption.h"
#import "JSRequest.h"
#import "JMReport.h"
#import "JSResourceLookup.h"

@interface JMReportManager : NSObject

+ (void)fetchReportLookupWithResourceURI:(NSString *)reportURI
                              completion:(void(^)(JSResourceReportUnit *reportUnit, NSError *error))completion;

+ (void)fetchInputControlsWithReportURI:(NSString *)reportURI
                             completion:(void(^)(NSArray *inputControls, NSError *error))completion;

+ (void)fetchReportOptionsWithReportURI:(NSString *)reportURI
                             completion:(void(^)(NSArray *reportOptions, NSError *error))completion;

+ (void)deleteReportOption:(JSReportOption *)reportOption
             withReportURI:(NSString *)reportURI
                completion:(void (^)(NSError *error))completion;

+ (void)createReportOptionWithReportURI:(NSString *)reportURI
                            optionLabel:(NSString *)optionLabel
                       reportParameters:(NSArray *)reportParameters
                             completion:(void (^)(JSReportOption *reportOption, NSError *error))completion;

// helper
+ (NSArray *)reportParametersFromInputControls:(NSArray *)inputControls;

@end