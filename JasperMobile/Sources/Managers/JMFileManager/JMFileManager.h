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
//  JMFileManager.h
//  TIBCO JasperMobile
//

/**
@author Aleksandr Dakhno odahno@tibco.com
@since 2.0
*/


@interface JMFileManager : NSObject
+ (instancetype)sharedInstance;

- (BOOL)createDirectoryForReportWithName:(NSString *)reportName
                           fileExtension:(NSString *)fileExtension;

- (void)downloadReportWithName:(NSString *)reportName
                 fileExtension:(NSString *)fileExtension
                     requestId:(NSString *)requestId
                      exportId:(NSString *)exportId
               attachmentNames:(NSArray *)attachmentNames
                    completion:(void(^)(BOOL success, NSError *error))completion;

- (void)cancelDownloadReportWithName:(NSString *)reportName
                       fileExtension:(NSString *)fileExtension;

- (void)downloadThumbnailForReportWithName:(NSString *)reportName
                             fileExtension:(NSString *)fileExtension
                         resourceURLString:(NSString *)resourceURLString;
- (UIImage *)thumbnailForSavedReportWithReportName:(NSString *)reportName
                                     fileExtension:(NSString *)fileExtension;

@end
