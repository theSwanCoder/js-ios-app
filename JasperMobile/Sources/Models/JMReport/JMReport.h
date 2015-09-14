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
//  JMReport.h
//  TIBCO JasperMobile
//

/**
 @author Aleksandr Dakhno odahno@tibco.com
 @since 2.0
 */
extern NSString * const kJMReportIsMutlipageDidChangedNotification;
extern NSString * const kJMReportCountOfPagesDidChangeNotification;
extern NSString * const kJMReportCurrentPageDidChangeNotification;

@interface JMReport : NSObject
// getters
@property (nonatomic, strong, readonly) JSResourceLookup *resourceLookup;
@property (nonatomic, copy, readonly) NSArray *inputControls;
@property (nonatomic, copy, readonly) NSArray *reportParameters;
@property (nonatomic, copy, readonly) NSString *reportURI;
@property (nonatomic, assign, readonly) NSInteger currentPage;
@property (nonatomic, assign, readonly) NSInteger countOfPages;
@property (nonatomic, assign, readonly) BOOL isMultiPageReport;
@property (nonatomic, assign, readonly) BOOL isReportWithInputControls;
@property (nonatomic, assign, readonly) BOOL isReportEmpty;
@property (nonatomic, strong, readonly) NSString *requestId;
@property (nonatomic, assign, readonly) BOOL isReportAlreadyLoaded;

// html
@property (nonatomic, copy, readonly) NSString *HTMLString;
@property (nonatomic, copy, readonly) NSString *baseURLString;
// input controls
@property (nonatomic, assign, readonly) BOOL isInputControlsLoaded;
// thumbnails
@property (nonatomic, strong) UIImage *thumbnailImage;
// script
@property (nonatomic, strong) NSString *script;

- (instancetype)initWithResource:(JSResourceLookup *)resourceLookup
                   inputControls:(NSArray *)inputControls;
+ (instancetype)reportWithResource:(JSResourceLookup *)resourceLookup
                     inputControls:(NSArray *)inputControl;

// update state
- (void)updateInputControls:(NSArray *)inputControls;
- (void)updateReportParameters:(NSArray *)reportParameters;
- (void)updateCurrentPage:(NSInteger)currentPage;
- (void)updateCountOfPages:(NSInteger)countOfPages;
- (void)updateHTMLString:(NSString *)HTMLString
            baseURLSring:(NSString *)baseURLString;
- (void)updateRequestId:(NSString *)requestId;
- (void)updateIsMultiPageReport:(BOOL)isMultiPageReport;

- (void)updatePaths;

- (NSString *)destroyHighChartScriptString;

- (void)updateHighchartContainerId;

// restore state
- (void)restoreDefaultState;
// cache
- (void)cacheHTMLString:(NSString *)HTMLString forPageNumber:(NSInteger)pageNumber;
- (NSDictionary *)cachedReportPages;
- (void)clearCachedReportPages;

- (void)updateScriptWithWidth:(NSInteger)width height:(NSInteger)height;
@end
