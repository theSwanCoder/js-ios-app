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
//  JMContentResourceViewerConfigurator.m
//  TIBCO JasperMobile
//


#import "JMContentResourceViewerConfigurator.h"
#import "JMContentResourceViewerStateManager.h"
#import "JMContentResourceLoader.h"
#import "JMContentResourceViewerExternalScreenManager.h"

@interface JMContentResourceViewerConfigurator ()
@property (nonatomic, strong, readwrite, nonnull) JMContentResourceLoader * contentResourceLoader;

@end

@implementation JMContentResourceViewerConfigurator

- (void)configWithWebEnvironment:(JMWebEnvironment *)webEnvironment
{
    [super configWithWebEnvironment:webEnvironment];
    
    _contentResourceLoader = [JMContentResourceLoader loaderWithRESTClient:self.restClient
                                                            webEnvironment:webEnvironment];
}

- (JMResourceViewerStateManager *)createStateManager
{
    return [JMContentResourceViewerStateManager new];
}

- (JMResourceViewerExternalScreenManager *)createExternalScreenManager
{
    return [JMContentResourceViewerExternalScreenManager new];
}

@end
