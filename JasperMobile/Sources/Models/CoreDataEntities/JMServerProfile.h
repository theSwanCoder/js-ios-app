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
//  JMServerProfile.h
//  TIBCO JasperMobile
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class JMFavorites, JMSavedResources;

/**
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @author Alexey Gubarev ogubarie@tibco.com
 @since 1.6
 */
@interface JMServerProfile : NSManagedObject

@property (nonatomic, strong) NSString * alias;
@property (nonatomic, strong) NSNumber * askPassword;
@property (nonatomic, strong) NSNumber * useVisualize;
@property (nonatomic, strong) NSNumber * keepSession;
@property (nonatomic, strong) NSString * organization;
@property (nonatomic, strong) NSString * serverUrl;
@property (nonatomic, strong) NSSet *favorites;
@property (nonatomic, strong) NSSet *savedResources;

@end

@interface JMServerProfile (CoreDataGeneratedAccessors)

- (void)addFavoritesObject:(JMFavorites *)value;
- (void)removeFavoritesObject:(JMFavorites *)value;
- (void)addFavorites:(NSSet *)values;
- (void)removeFavorites:(NSSet *)values;

- (void)addSavedResourcesObject:(JMSavedResources *)value;
- (void)removeSavedResourcesObject:(JMSavedResources *)value;
- (void)addSavedResources:(NSSet *)values;
- (void)removeSavedResources:(NSSet *)values;

@end
