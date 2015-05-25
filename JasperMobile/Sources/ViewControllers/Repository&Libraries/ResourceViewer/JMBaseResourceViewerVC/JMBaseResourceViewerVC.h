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
//  JMBaseResourceViewerVC.h
//  TIBCO JasperMobile
//

/**
 @author Olexandr Dahno odahno@tibco.com
 @since 2.1
 */

#import "GAITrackedViewController.h"
#import "JMResourceClientHolder.h"
#import "JMMenuActionsView.h"
#import "JMCancelRequestPopup.h"

extern NSString * const kJMShowReportOptionsSegue;
extern NSString * const kJMShowMultiPageReportSegue;
extern NSString * const kJMShowDashboardViewerSegue;
extern NSString * const kJMShowSavedRecourcesViewerSegue;

@interface JMBaseResourceViewerVC : GAITrackedViewController <JMResourceClientHolder, JMMenuActionsViewDelegate>
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) BOOL isResourceLoaded;
@property (nonatomic, strong) NSURLRequest *resourceRequest;

// setup
- (void)setupSubviews;
- (void)setupLeftBarButtonItems NS_REQUIRES_SUPER;
- (void)setupRightBarButtonItems NS_REQUIRES_SUPER;
- (void)resetSubViews;


// Resource Viewing
- (void) startResourceViewing;
- (void) cancelResourceViewingAndExit NS_REQUIRES_SUPER;

- (JMMenuActionsViewAction)availableActionForResource:(JSResourceLookup *)resource;

// Loaders
- (void)startShowLoadingIndicators;
- (void)stopShowLoadingIndicators;
- (void)startShowLoaderWithMessage:(NSString *)message cancelBlock:(JMCancelRequestBlock)cancelBlock;
- (void)stopShowLoader;

// UIBarButtonItem helpers
- (UIBarButtonItem *)infoPageBarButtonItem;
- (UIBarButtonItem *)backBarButtonItemWithTarget:(id)target
                                          action:(SEL)action;

- (void) backButtonTapped:(id)sender;
@end
