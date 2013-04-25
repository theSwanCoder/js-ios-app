/*
 * JasperMobile for iOS
 * Copyright (C) 2005 - 2013 Jaspersoft Corporation. All rights reserved.
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
//  ServerProfile.h
//  Jaspersoft Corporation
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Favorites, ReportOptions;

@interface ServerProfile : NSManagedObject

@property (nonatomic, retain) NSString * alias;
@property (nonatomic, retain) NSNumber * askPassword;
@property (nonatomic, retain) NSString * organization;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * serverUrl;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet *favorites;
@property (nonatomic, retain) NSSet *reportOptions;
@end

@interface ServerProfile (CoreDataGeneratedAccessors)

- (void)addFavoritesObject:(Favorites *)value;
- (void)removeFavoritesObject:(Favorites *)value;
- (void)addFavorites:(NSSet *)values;
- (void)removeFavorites:(NSSet *)values;

- (void)addReportOptionsObject:(ReportOptions *)value;
- (void)removeReportOptionsObject:(ReportOptions *)value;
- (void)addReportOptions:(NSSet *)values;
- (void)removeReportOptions:(NSSet *)values;

@end
