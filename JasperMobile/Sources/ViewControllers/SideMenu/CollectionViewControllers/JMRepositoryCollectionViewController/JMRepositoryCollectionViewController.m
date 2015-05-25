/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
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
//  JMRepositoryCollectionViewController.h
//  TIBCO JasperMobile
//


#import "JMRepositoryCollectionViewController.h"
#import "JMBaseCollectionView.h"


@implementation JMRepositoryCollectionViewController

#pragma mark - LifeCycle
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = JMCustomLocalizedString(@"menuitem.repository.label", nil);
}

#pragma mark - Overloaded methods
- (JMMenuActionsViewAction)availableAction
{
    return JMMenuActionsViewAction_None;
}

- (NSString *)defaultRepresentationTypeKey
{
    NSString * keyString = @"RepresentationTypeKey";
    keyString = [@"Repository" stringByAppendingString:keyString];
    return keyString;
}

- (JSResourceLookup *)loadedResourceForIndexPath:(NSIndexPath *)indexPath
{
    NSArray *folders = self.resourceListLoader.sections[@(JMResourcesListSectionTypeFolder)];
    NSArray *reportUnits = self.resourceListLoader.sections[@(JMResourcesListSectionTypeReportUnit)];
    
    NSMutableArray *resources = [NSMutableArray arrayWithArray:folders];
    [resources addObjectsFromArray:reportUnits];
    
    return resources.count > 0 ? [resources objectAtIndex:indexPath.row] : nil;
}

- (Class)resourceLoaderClass
{
    return NSClassFromString(@"JMRepositoryListLoader");
}

@end
