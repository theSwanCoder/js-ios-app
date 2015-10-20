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
//  JMSavedResources.h
//  TIBCO JasperMobile
//

/**
 @author Alexey Gubarev ogubarie@tibco.com
 @since 1.9
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class JMServerProfile;

@interface JMSavedResources : NSManagedObject

@property (nonatomic, retain) NSDate   * creationDate;
@property (nonatomic, strong) NSDate   * updateDate;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * uri;
@property (nonatomic, retain) NSString * wsType;
@property (nonatomic, retain) NSString * resourceDescription;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) JMServerProfile *serverProfile;

@end
