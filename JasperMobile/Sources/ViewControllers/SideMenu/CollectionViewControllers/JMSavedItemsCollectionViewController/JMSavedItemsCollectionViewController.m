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
//  JMSavedItemsCollectionViewController.h
//  TIBCO JasperMobile
//


#import "JMSavedItemsCollectionViewController.h"

@interface JMSavedItemsCollectionViewController()
@end

@implementation JMSavedItemsCollectionViewController

#pragma mark -LifeCycle

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.resourceListLoader = [NSClassFromString(@"JMSavedResourcesListLoader") new];
    self.title = @"Saved Items";
}

#pragma mark - Overloaded methods
- (NSString *)defaultRepresentationTypeKey
{
    NSString * keyString = @"RepresentationTypeKey";
    keyString = [@"SavedItems" stringByAppendingString:keyString];
    return keyString;
}

- (void)didSelectResourceAtIndexPath:(NSIndexPath *)indexPath
{
    JSResourceLookup *resourceLookup = [self.resourceListLoader resourceAtIndex:indexPath.row];
    JMSavedResources *savedResources = [JMSavedResources savedReportsFromResourceLookup:resourceLookup];
    if (savedResources) {
        // TODO: replace seque with constant
        [self performSegueWithIdentifier:@"ShowSavedRecourcesViewer"
                                  sender:@{kJMResourceLookup:resourceLookup}];
    } else {
        //TODO: need some action )
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowSavedRecourcesViewer"]) {
        [segue.destinationViewController  performSelector:@selector(setResourceLookup:) withObject:sender[kJMResourceLookup]];
    }
}

@end