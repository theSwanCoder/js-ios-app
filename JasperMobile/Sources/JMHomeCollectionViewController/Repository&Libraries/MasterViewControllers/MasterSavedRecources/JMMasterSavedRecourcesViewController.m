//
//  JMMasterSavedRecourcesViewController.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 9/18/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMMasterSavedRecourcesViewController.h"

#import "JMMasterLibraryTableViewController.h"
#import "JMLibraryTableViewCell.h"
#import "JMMenuSectionView.h"

typedef NS_ENUM(NSInteger, JMTableViewSection) {
    JMTableViewSection_SortingType = 0
};

typedef NS_ENUM(NSInteger, JMSortBy) {
    JMSortByName = 0,
    JMSortByDate,
    JMSortByCreator
};

static NSString * const kJMSettingTypeKey = @"settingsType";
static NSString * const kJMTitleKey = @"title";
static NSString * const kJMRowsKey = @"rows";

@interface JMMasterSavedRecourcesViewController ()
@property (nonatomic, strong) NSArray *cellsAndSectionsProperties;
@property (nonatomic, assign) JMSortBy sortByEnum;

@end

@implementation JMMasterSavedRecourcesViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (NSInteger i = 0; i < [self.cellsAndSectionsProperties count]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    [self loadResourcesIntoDetailViewController];
}

- (NSString *)sortBy
{
    switch (self.sortByEnum) {
        case JMSortByName:
            return @"label";
        case JMSortByDate:
            return @"creationDate";
        case JMSortByCreator:
            return @"label";
    }
}

- (NSArray *)cellsAndSectionsProperties
{
    if (!_cellsAndSectionsProperties) {
        _cellsAndSectionsProperties = @[@{
                                            kJMSettingTypeKey : @(JMTableViewSection_SortingType),
                                            kJMTitleKey : @"sortby",
                                            kJMRowsKey : @[
                                                    @"name", @"date"
                                                    ]
                                            }
                                        ];
    }
    
    return _cellsAndSectionsProperties;
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    JMMenuSectionView *view = [[[NSBundle mainBundle] loadNibNamed:@"JMMenuSectionView" owner:self.tableView options:nil] lastObject];
    CGRect nibViewFrame = view.bounds;
    nibViewFrame.size.width = tableView.frame.size.width;
    view.frame = nibViewFrame;
    view.title.text = [self localizedSectionTitle:section];
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.cellsAndSectionsProperties.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *sectionProperties = [self.cellsAndSectionsProperties objectAtIndex:section];
    return [[sectionProperties objectForKey:kJMRowsKey] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MenuCell";
    JMLibraryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [self localizedRowTitle:indexPath.row forSection:indexPath.section];
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMTableViewSection sectionType = [[[self.cellsAndSectionsProperties objectAtIndex:indexPath.section] objectForKey:kJMSettingTypeKey] integerValue];
    switch (sectionType) {
        case JMTableViewSection_SortingType:
            self.sortByEnum = (JMSortBy) indexPath.row;
            break;
    }
    
    [self loadResourcesIntoDetailViewController];
    
    
    for (NSIndexPath *selectedIndexPath in [self.tableView indexPathsForSelectedRows]) {
        if (selectedIndexPath.section == indexPath.section && indexPath.row != selectedIndexPath.row) {
            [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:NO];
        }
    }
}

#pragma mark - JMRefreshable
- (void)refresh
{
    [self loadResourcesIntoDetailViewController];
}

- (NSDictionary *)paramsForLoadingResourcesIntoDetailViewController
{
    NSMutableDictionary *paramsDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             @[self.constants.WS_TYPE_REPORT_UNIT, self.constants.WS_TYPE_DASHBOARD], kJMResourcesTypes,
                                             @(YES), kJMLoadRecursively,
                                             self.searchQuery ?: @"", kJMSearchQuery,
                                             self.sortBy, kJMSortBy, nil];
    return paramsDictionary;
}

#pragma mark - Localization

- (NSString *)localizedRowTitle:(NSInteger)row forSection:(NSInteger)section
{
    NSDictionary *properties = [self.cellsAndSectionsProperties objectAtIndex:section];
    NSString *sectionTitle = [properties objectForKey:kJMTitleKey];
    NSString *rowTitle = [[properties objectForKey:kJMRowsKey] objectAtIndex:row];
    NSString *localizationKey = [NSString stringWithFormat:@"master.%@.type.%@", sectionTitle, rowTitle];
    return JMCustomLocalizedString(localizationKey, nil);
}

- (NSString *)localizedSectionTitle:(NSInteger)section
{
    NSDictionary *properties = [self.cellsAndSectionsProperties objectAtIndex:section];
    NSString *localizationKey = [NSString stringWithFormat:@"master.%@.title", [properties objectForKey:kJMTitleKey]];
    return JMCustomLocalizedString(localizationKey, nil);
}
@end
