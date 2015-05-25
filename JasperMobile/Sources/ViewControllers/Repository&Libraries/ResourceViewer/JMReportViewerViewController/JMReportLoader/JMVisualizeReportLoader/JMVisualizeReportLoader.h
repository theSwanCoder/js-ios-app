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

#import "JMReportLoader.h"

@class JMVisualizeReport;
@protocol JMVisualizeReportLoaderDelegate;


@interface JMVisualizeReportLoader : NSObject <JMReportLoader, UIWebViewDelegate>
@property (nonatomic, weak) UIWebView *webView;
@property (nonatomic, weak) id<JMVisualizeReportLoaderDelegate> delegate;

- (void)applyReportParametersWithCompletion:(void (^)(BOOL success, NSError *error))completion;

- (void)refreshReportWithCompletion:(void(^)(BOOL success, NSError *error))completion;
- (void)exportReportWithFormat:(NSString *)exportFormat;
- (void)destroyReport;
- (void)authenticate;

@end

@protocol JMVisualizeReportLoaderDelegate <NSObject>
@optional
- (void)reportLoader:(JMVisualizeReportLoader *)reportLoader didReceiveOnClickEventForResourceLookup:(JSResourceLookup *)resourceLookup withParameters:(NSDictionary *)reportParameters;
- (void)reportLoader:(JMVisualizeReportLoader *)reportLoder didReceiveOnClickEventForReference:(NSURL *)urlReference;
- (void)reportLoader:(JMVisualizeReportLoader *)reportLoader didReceiveOutputResourcePath:(NSString *)resourcePath fullReportName:(NSString *)fullReportName;
@end