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
//  JMAdHocLoader.h
//  TIBCO JasperMobile
//


/**
 @author Alexey Gubarev ogubarie@tibco.com
 @since 2.7
*/

#import "JMAdHoc.h"

typedef void(^JMAdHocLoaderCompletion)(BOOL success, NSError * __nullable error);

typedef NS_ENUM(NSInteger, JMAdHocLoaderState) {
    JMAdHocLoaderState_Initial,    
    JMAdHocLoaderState_Configured, 
    JMAdHocLoaderState_Loading,    
    JMAdHocLoaderState_Ready,      
    JMAdHocLoaderState_Failed,     
    JMAdHocLoaderState_Destroy,    
    JMAdHocLoaderState_Cancel
};

@protocol JMAdHocLoader <NSObject>
@property (nonatomic, strong, readonly, nonnull) JMAdHoc *adHoc;
@property (nonatomic, assign, readonly) JMAdHocLoaderState state;
@property (nonatomic, copy, readonly, nonnull) JSRESTBase *restClient;

- (id<JMAdHocLoader> __nullable)initWithRESTClient:(nonnull JSRESTBase *)restClient
                                    webEnvironment:(nonnull JMWebEnvironment *)webEnvironment;
+ (id<JMAdHocLoader> __nullable)loaderWithRESTClient:(nonnull JSRESTBase *)restClient
                                      webEnvironment:(nonnull JMWebEnvironment *)webEnvironment;

- (void)runAdHoc:(nonnull JMAdHoc *)adHoc completion:(nonnull JMAdHocLoaderCompletion) completion;
- (void)destroy; // TODO: need completion?
- (void)cancel; // TODO: need completion?
@optional
- (void)reloadWithCompletion:(nonnull JMAdHocLoaderCompletion) completion;
@end

@interface JMAdHocLoader : NSObject <JMAdHocLoader>

@end
