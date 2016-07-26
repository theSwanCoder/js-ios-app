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
//  JMAnalyticsManager.h
//  TIBCO JasperMobile
//

/**
 @author Olexandr Dahno odahno@tibco.com
 @since 2.5
 */


@interface JMAnalyticsManager : NSObject
+ (instancetype __nullable)sharedManager;
- (void)sendAnalyticsEventWithInfo:(NSDictionary *__nonnull)eventInfo;
- (void)sendAnalyticsEventAboutLoginSuccess:(BOOL)success additionInfo:(NSDictionary *__nonnull)additionInfo;
- (void)sendAnalyticsEventAboutLogout;
- (void)sendThumbnailEventIfNeed;

- (NSString * __nonnull)mapClassNameToReadableName:(NSString * __nonnull)className;
@end