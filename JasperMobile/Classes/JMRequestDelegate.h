/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2013 Jaspersoft Corporation. All rights reserved.
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
//  JMRequestDelegate.h
//  Jaspersoft Corporation
//

#import <Foundation/Foundation.h>
#import <jaspersoft-sdk/JaspersoftSDK.h>

/**
 Helper class which gives possibility to work with multiple requests in the same
 View Controller. Each new instance is adding to request pool and removing when
 request is complete
 
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @since 1.6
 */
@interface JMRequestDelegate : NSObject <JSRequestDelegate>

/**
 Sets a block which will be invoked after all requests will finish

 @param block A final block
 */
+ (void)setFinalBlock:(void (^)(void))block;

/**
 Creates new instance of request delegate and adds it to the request pool
 
 @param finishedBlock 
 @return An new request delegate instance
 */
+ (JMRequestDelegate *)requestDelegateForFinishBlock:(JSRequestFinishedBlock)finishedBlock;

/**
 Creates new instance of request delegate and adds it to the request pool.
 Sets the view controller (for all requests in pool) that will be dismissed if any request will fail

 @param finishedBlock
 @param viewController A view controller that will be dismissed
 @return An new request delegate instance
 */
+ (JMRequestDelegate *)requestDelegateForFinishBlock:(JSRequestFinishedBlock)finishedBlock viewControllerToDismiss:(UIViewController *)viewController;

/**
 Passes a request result to final delegate object if request was successful. Otherwise displays alert view dialog
 with error message

 @param delegate A delegate object
 @return An new request delegate instance
 */
+ (JMRequestDelegate *)checkRequestResultForDelegate:(id <JSRequestDelegate>)delegate;

/**
 Passes a request result to final delegate object if request was successful. Otherwise displays alert view dialog
 with error message. Sets the view controller (for all requests in pool) that will be dismissed if any request will fail

 @param delegate A delegate object
 @param viewController A view controller that will be dismissed
 @return An new request delegate instance
 */
+ (JMRequestDelegate *)checkRequestResultForDelegate:(id <JSRequestDelegate>)delegate viewControllerToDismiss:(UIViewController *)viewController;

/**
 Check if request pool is empty (no any active request exists)
 
 @return YES if request pool is empty, otherwise returns NO
 */
+ (BOOL)isRequestPoolEmpty;

/**
 Removes all requests from request pool. This will also disable callback
 */
+ (void)clearRequestPool;

@end
