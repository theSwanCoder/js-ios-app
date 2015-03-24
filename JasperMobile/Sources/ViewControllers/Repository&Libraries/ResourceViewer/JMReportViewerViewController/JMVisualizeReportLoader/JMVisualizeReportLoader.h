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
//  JMVisualizeReportLoader.h
//  TIBCO JasperMobile
//

/**
 @author Aleksandr Dakhno odahno@tibco.com
 @since 2.0
 */

@class JMVisualizeReport;
@protocol JMVisualizeReportLoaderDelegate;


@interface JMVisualizeReportLoader : NSObject <UIWebViewDelegate>
@property (nonatomic, assign) BOOL isReportInLoadingProcess;
@property (nonatomic, weak) UIWebView *webView;
@property (nonatomic, weak) id<JMVisualizeReportLoaderDelegate> delegate;

- (instancetype)initWithReport:(JMVisualizeReport *)report;
+ (instancetype)loaderWithReport:(JMVisualizeReport *)report;

- (void)fetchStartPageWithCompletion:(void(^)(BOOL success, NSError *error))reportLoadCompletion;
- (void)reloadReportWithInputControls:(NSArray *)inputControls;
- (void)loadPageWithNumber:(NSInteger)pageNumber completion:(void(^)(BOOL success, NSError *error))reportLoadCompletion;
- (void)refreshReportWithCompletion:(void(^)(BOOL success, NSError *error))completion;
- (void)cancelReport;
- (void)destroyReport;
- (void)authenticate;
@end

@protocol JMVisualizeReportLoaderDelegate <NSObject>
- (void)reportLoader:(JMVisualizeReportLoader *)reportLoader didReciveOnClickEventForReport:(JMVisualizeReport *)report withParameters:(NSDictionary *)reportParameters;
@end

