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
//  JMReportViewerStateManager.h
//  TIBCO JasperMobile
//

/**
@author Aleksandr Dakhno odahno@tibco.com
@since 2.6
*/

@protocol JMResourceClientHolder;
@protocol JMResourceViewProtocol;
@protocol JMMenuActionsViewDelegate;

typedef NS_ENUM(NSInteger, JMReportViewerState) {
    JMReportViewerStateInitial,
    JMReportViewerStateDestroy,
    JMReportViewerStateLoading,
    JMReportViewerStateResourceReady,
    JMReportViewerStateResourceFailed,
    JMReportViewerStateResourceNotExist,
    JMReportViewerStateNestedResource
};

typedef NS_ENUM(NSInteger, JMReportVieweToolbarState) {
    JMReportVieweToolbarStateTopVisible,
    JMReportVieweToolbarStateTopHidden,
    JMReportVieweToolbarStateBottomVisible,
    JMReportVieweToolbarStateBottomHidden
};

@interface JMReportViewerStateManager : NSObject
@property (nonatomic, weak) UIViewController <JMResourceClientHolder, JMResourceViewProtocol, JMMenuActionsViewDelegate>*controller;
@property (nonatomic, assign) JMReportViewerState activeState;
@property (nonatomic, copy) void(^cancelOperationBlock)(void);
@property (nonatomic, copy) void(^backActionBlock)(void);
- (void)setupPageForState:(JMReportViewerState)state;
- (void)updatePageForToolbarState:(JMReportVieweToolbarState)toolbarState;
- (void)updatePageForChangingSizeClass;
- (void)hideMenuView;
@end