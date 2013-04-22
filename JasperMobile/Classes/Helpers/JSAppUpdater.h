/*
 * JasperMobile for iOS
 * Copyright (C) 2005 - 2012 Jaspersoft Corporation. All rights reserved.
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
//  JSAppUpdater.h
//  Jaspersoft Corporation
//

#import <Foundation/Foundation.h>

/**
 This class updates automatically specific part of application if application
 was updated from App Store. Idea is to store version of application inside
 NSUserDefaults, and if that version was changed update app automatically.
 Example: if old app was 1.0 version, and there was some major changes (i.e.
 changed database structure), after updating to 1.2 updates 1.1 and 1.2 will
 be performed (which adapts and move data from old to new database structure)

 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @since 1.2
 */
@interface JSAppUpdater : NSObject <UIAlertViewDelegate>

// Updates app
+ (void)update;
+ (void)updateAppVersionTo:(NSNumber *)appVersion;
+ (NSNumber *)currentAppVersion;
+ (NSNumber *)latestAppVersion;
+ (BOOL)hasErrors;
+ (void)showErrors;

@end
