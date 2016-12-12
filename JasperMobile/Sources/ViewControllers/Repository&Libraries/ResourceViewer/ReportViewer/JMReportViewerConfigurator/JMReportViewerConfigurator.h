/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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
//  JMReportViewerConfigurator.h
//  TIBCO JasperMobile
//


/**
@author Aleksandr Dakhno odahno@tibco.com
@since 2.1
*/

#import <UIKit/UIKit.h>

@protocol JMReportLoaderProtocol, JMReportLoaderDelegate;
@class JSReport;
@class JMWebEnvironment;
@class JMReportViewerStateManager;
@class JMResourceViewerPrintManager;
@class JMResourceViewerInfoPageManager;
@class JMResourceViewerShareManager;
@class JMResourceViewerHyperlinksManager;
@class JMResourceViewerDocumentManager;
@class JMReportViewerExternalScreenManager;

@interface JMReportViewerConfigurator : NSObject
@property (nonatomic, strong, readonly) id <JMReportLoaderProtocol> __nonnull reportLoader;
@property (nonatomic, strong, readonly) JMWebEnvironment * __nonnull webEnvironment;
@property (nonatomic, strong) JMReportViewerStateManager * __nonnull stateManager;
@property (nonatomic, strong) JMResourceViewerPrintManager * __nonnull printManager;
@property (nonatomic, strong) JMResourceViewerInfoPageManager * __nonnull infoPageManager;
@property (nonatomic, strong) JMResourceViewerShareManager * __nonnull shareManager;
@property (nonatomic, strong) JMResourceViewerHyperlinksManager * __nonnull hyperlinksManager;
@property (nonatomic, strong) JMResourceViewerDocumentManager * __nonnull documentManager;
@property (nonatomic, strong) JMReportViewerExternalScreenManager * __nonnull externalScreenManager;
@property (nonatomic, assign) CGFloat viewportScaleFactor;

- (instancetype __nonnull)initWithWebEnvironment:(JMWebEnvironment * __nonnull)webEnvironment;
+ (instancetype __nullable)configuratorWithWebEnvironment:(JMWebEnvironment *__nonnull)webEnvironment;

- (void)setup;
- (void)reset;
@end