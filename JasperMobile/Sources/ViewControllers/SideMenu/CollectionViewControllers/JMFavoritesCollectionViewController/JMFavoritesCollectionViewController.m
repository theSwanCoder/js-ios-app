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
//  JMFavoritesCollectionViewController.h
//  TIBCO JasperMobile
//

#import "JMFavoritesCollectionViewController.h"

@interface JMFavoritesCollectionViewController()
@property (nonatomic) JMResourcesRepresentationType repositoryRepresentationType;
@end

@implementation JMFavoritesCollectionViewController

#pragma mark - LifeCycle
-(void)awakeFromNib
{
    [super awakeFromNib];
    self.title = JMCustomLocalizedString(@"menuitem.favorites.label", nil);
}

#pragma mark - UIViewController LifeCycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self saveRepositoryRepresentaionType];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self restoreRepositoryRepresentaionType];
}

#pragma mark - Overloaded methods
- (Class)resourceLoaderClass
{
    return NSClassFromString(@"JMFavoritesListLoader");
}

- (NSString *)defaultRepresentationTypeKey
{
    NSString * keyString = @"RepresentationTypeKey";
    keyString = [@"Favorites" stringByAppendingString:keyString];
    return keyString;
}

- (NSString *)noResultText
{
    return JMCustomLocalizedString(@"resources.noresults.favorites.msg", nil);
}

#pragma mark - Helpers
- (NSString *)repositoryDefaultRepresentationTypeKey
{
    NSString * keyString = @"RepresentationTypeKey";
    keyString = [@"Repository" stringByAppendingString:keyString];
    return keyString;
}

- (void)saveRepositoryRepresentaionType
{
    JMResourcesRepresentationType repositoryRepresentationType = JMResourcesRepresentationTypeFirst();
    NSString *repositoryDefaultRepresentationTypeKey = [self repositoryDefaultRepresentationTypeKey];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:repositoryDefaultRepresentationTypeKey]) {
        repositoryRepresentationType = (JMResourcesRepresentationType) [[NSUserDefaults standardUserDefaults] integerForKey:repositoryDefaultRepresentationTypeKey];
    }
    self.repositoryRepresentationType = repositoryRepresentationType;
}

- (void)restoreRepositoryRepresentaionType
{
    NSString *repositoryDefaultRepresentationTypeKey = [self repositoryDefaultRepresentationTypeKey];
    [[NSUserDefaults standardUserDefaults] setInteger:self.repositoryRepresentationType
                                               forKey:repositoryDefaultRepresentationTypeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
