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
//  JMResourceCollectionViewController.h
//  TIBCO JasperMobile
//

/**
 @author Alexey Gubarev ogubarie@tibco.com
 @since 2.6
 */

#import "JMMenuActionsView.h"
#import "JMSavedResources+Helpers.h"
#import "JMResourcesListLoader.h"
#import "JMBaseViewController.h"

typedef NS_ENUM(NSInteger, JMResourcesRepresentationType) {
    JMResourcesRepresentationType_HorizontalList = 0,
    JMResourcesRepresentationType_Grid = 1
};

static inline JMResourcesRepresentationType JMResourcesRepresentationTypeFirst() { return JMResourcesRepresentationType_HorizontalList; }
static inline JMResourcesRepresentationType JMResourcesRepresentationTypeLast() { return JMResourcesRepresentationType_Grid; }

@interface JMResourceCollectionViewController : JMBaseViewController <JMResourcesListLoaderDelegate>

@property (nonatomic, strong) NSString *noResultString;
@property (nonatomic, strong) NSString *representationTypeKey;
@property (nonatomic, strong) JMResourcesListLoader *resourceListLoader;

@property (nonatomic, assign) BOOL shouldShowButtonForChangingViewPresentation;     // YES by default
@property (nonatomic, assign) BOOL needShowSearchBar;                               // YES by default

@property (nonatomic, assign) JMMenuActionsViewAction availableAction;

@property (nonatomic, copy) void(^actionBlock)(JMResource *);

@end
