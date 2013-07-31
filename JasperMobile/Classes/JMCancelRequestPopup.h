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
//  JMCancelRequestPopup.h
//  Jaspersoft Corporation
//

#import <UIKit/UIKit.h>
#import <jaspersoft-sdk/JaspersoftSDK.h>

typedef void(^JMCancelRequestBlock)(void);

/**
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @since 1.6
 */
@interface JMCancelRequestPopup : UIViewController

/**
 Presents cancel request popup in view controller
 
 @param viewController A view controller inside which popup will be shown
 @param progressMessage A message of progress dialog
 @param restClient A rest client to cancel all requests
 @param cancelBlock A cancelBlock to execute
 */
+ (void)presentInViewController:(UIViewController *)viewController progressMessage:(NSString *)progressMessage restClient:(JSRESTBase *)client cancelBlock:(JMCancelRequestBlock)cancelBlock;

/**
 Dismisses last presented popup
 */
+ (void)dismiss;

@end

