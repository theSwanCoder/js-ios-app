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
//  JMResourcesListLoader.h
//  TIBCO JasperMobile
//

/**
 @author Alexey Gubarev ogubarie@tibco.com
 @since 1.9
 */

#import <UIKit/UIKit.h>
#import "JMResourcesListLoader.h"
#import "GAITrackedViewController.h"

typedef NS_ENUM(NSInteger, JMResourcesCollectionViewControllerPresentingType) {
    JMResourcesCollectionViewControllerPresentingType_Library = 1 << 0,
    JMResourcesCollectionViewControllerPresentingType_Repository = 1 << 1,
    JMResourcesCollectionViewControllerPresentingType_SavedItems = 1 << 2,
    JMResourcesCollectionViewControllerPresentingType_Favorites = 1 << 3
};

@interface JMResourcesCollectionViewController : GAITrackedViewController
@property (nonatomic, assign) JMResourcesCollectionViewControllerPresentingType presentingType;

@end
