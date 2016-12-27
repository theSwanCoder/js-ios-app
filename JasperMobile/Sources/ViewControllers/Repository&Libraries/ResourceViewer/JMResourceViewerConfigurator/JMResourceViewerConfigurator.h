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
//  JMResourceViewerConfigurator.h
//  TIBCO JasperMobile
//

/**
 @author Alexey Gubarev ogubarie@tibco.com
 @since 2.6
 */

#import <UIKit/UIKit.h>

@class JMWebEnvironment;
@class JMResourceViewerStateManager;
@class JMResourceViewerPrintManager;
@class JMResourceViewerInfoPageManager;
@class JMResourceViewerShareManager;
@class JMResourceViewerHyperlinksManager;
@class JMResourceViewerDocumentManager;
@class JMResourceViewerExternalScreenManager;
@class JMResourceViewerSessionManager;

NS_ASSUME_NONNULL_BEGIN

@interface JMResourceViewerConfigurator : NSObject
@property (nonatomic, strong, readonly) JMWebEnvironment *webEnvironment;
@property (nonatomic, strong) JMResourceViewerStateManager *stateManager;
@property (nonatomic, strong) JMResourceViewerPrintManager *printManager;
@property (nonatomic, strong) JMResourceViewerInfoPageManager *infoPageManager;
@property (nonatomic, strong) JMResourceViewerShareManager *shareManager;
@property (nonatomic, strong) JMResourceViewerHyperlinksManager *hyperlinksManager;
@property (nonatomic, strong) JMResourceViewerDocumentManager *documentManager;
@property (nonatomic, strong) JMResourceViewerSessionManager *sessionManager;
@property (nonatomic, strong) JMResourceViewerExternalScreenManager *externalScreenManager;
@property (nonatomic, assign) CGFloat viewportScaleFactor;


- (instancetype)initWithWebEnvironment:(JMWebEnvironment *)webEnvironment;
+ (instancetype)configuratorWithWebEnvironment:(JMWebEnvironment *)webEnvironment;

- (void)configWithWebEnvironment:(JMWebEnvironment *)webEnvironment NS_REQUIRES_SUPER;

- (void)setup;
- (void)reset;

NS_ASSUME_NONNULL_END
@end
