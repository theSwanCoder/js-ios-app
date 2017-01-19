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
//  JMContentResourceLoader.h
//  TIBCO JasperMobile
//

/**
 @author Alexey Gubarev ogubarie@tibco.com
 @since 2.6
 */

#import <Foundation/Foundation.h>
@class JMResource, JMSavedResources;

@interface JMContentResourceLoader : NSObject
@property (nonatomic, strong, readonly) JMSavedResources *savedResource;
@property (nonatomic, strong, readonly) JSContentResource *contentResource;
@property (nonatomic, strong, readonly) NSURL *contentResourceURL;
@property (nonatomic, copy, readonly) JSRESTBase *restClient;

- (instancetype)initWithRESTClient:(JSRESTBase *)restClient
                    webEnvironment:(JMWebEnvironment *)webEnvironment;
+ (instancetype)loaderWithRESTClient:(JSRESTBase *)restClient
                      webEnvironment:(JMWebEnvironment *)webEnvironment;

- (void)loadContentResourceForResource:(JMResource *)resource
                            completion:(void (^)(NSURL *baseURL, NSError *error))completion;

- (void)cancel;

@end
