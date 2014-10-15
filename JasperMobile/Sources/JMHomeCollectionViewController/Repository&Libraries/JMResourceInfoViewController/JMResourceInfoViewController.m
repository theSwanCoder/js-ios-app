//
//  JMResourceInfoViewController.m
//  Tibco JasperMobile
//
//  Created by Oleksii Gubariev on 10/15/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMResourceInfoViewController.h"
#import "JMFavorites+Helpers.h"
#import "UITableViewCell+Additions.h"

NSString * const kJMShowResourceInfoSegue  = @"ShowResourceInfoSegue";

static NSString * const kJMTitleKey = @"title";
static NSString * const kJMValueKey = @"value";

@interface JMResourceInfoViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *resourceProperties;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation JMResourceInfoViewController
objection_requires(@"resourceClient", @"resourceLookup")

@synthesize resourceClient = _resourceClient;
@synthesize resourceLookup = _resourceLookup;

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.resourceLookup.label;
    [self updateFavoriteItem];
}

- (void) updateFavoriteItem
{
    UIImage *itemImage = [JMFavorites isResourceInFavorites:self.resourceLookup] ? [UIImage imageNamed:@"favorited_item"] : [UIImage imageNamed:@"make_favorite_item"];
    UIBarButtonItem *favoriteItem = [[UIBarButtonItem alloc] initWithImage:itemImage style:UIBarButtonItemStyleBordered target:self action:@selector(favoriteButtonTapped:)];
    favoriteItem.tintColor = [JMFavorites isResourceInFavorites:self.resourceLookup] ? [UIColor yellowColor] : [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = favoriteItem;
}

- (void)favoriteButtonTapped:(id)sender
{
    if ([JMFavorites isResourceInFavorites:self.resourceLookup]) {
        [JMFavorites removeFromFavorites:self.resourceLookup];
    } else {
        [JMFavorites addToFavorites:self.resourceLookup];
    }
    [self updateFavoriteItem];
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMFavoritesDidChangedNotification object:nil];
}

- (NSArray *)resourceProperties
{
    if (!_resourceProperties) {
        _resourceProperties = @[
                                @{
                                    kJMTitleKey : @"label",
                                    kJMValueKey : self.resourceLookup.label ?: @""
                                    },
                                @{
                                    kJMTitleKey : @"description",
                                    kJMValueKey : self.resourceLookup.resourceDescription ?: @""
                                    },
                                @{
                                    kJMTitleKey : @"uri",
                                    kJMValueKey : self.resourceLookup.uri ?: @""
                                    },

                                @{
                                    kJMTitleKey : @"type",
                                    kJMValueKey : self.resourceLookup.resourceType ?: @""
                                    },
                                @{
                                    kJMTitleKey : @"version",
                                    kJMValueKey : self.resourceLookup.version ? [NSString stringWithFormat:@"%@", self.resourceLookup.version]: @""
                                    },
                                @{
                                    kJMTitleKey : @"creationDate",
                                    kJMValueKey : self.resourceLookup.creationDate ?: @""
                                    }
                                ];
    }
    return _resourceProperties;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.resourceProperties.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"ResourceAttributeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (indexPath.row) {
        [cell setTopSeparatorWithHeight:0.5 color:tableView.separatorColor tableViewStyle:UITableViewStylePlain];
    }
    
    NSDictionary *item = [self.resourceProperties objectAtIndex:indexPath.row];
    cell.textLabel.text = JMCustomLocalizedString([NSString stringWithFormat:@"resource.%@.title", [item objectForKey:kJMTitleKey]], nil);
    cell.detailTextLabel.text = [item objectForKey:kJMValueKey];
    return cell;
}

@end
