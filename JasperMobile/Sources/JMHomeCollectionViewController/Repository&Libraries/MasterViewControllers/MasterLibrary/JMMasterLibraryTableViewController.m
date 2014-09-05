//
//  JMMasterLibraryTableViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadsky on 3/18/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMMasterLibraryTableViewController.h"
#import "JMLibraryTableViewCell.h"
#import "JMMenuSectionView.h"

typedef NS_ENUM(NSInteger, JMTableViewSection) {
    JMTableViewSection_ResourceType = 0,
    JMTableViewSection_SortingType
};

typedef NS_ENUM(NSInteger, JMResourcesType) {
    JMResourceTypeAll = 0,
    JMResourceTypeReport,
    JMResourceTypeDashboard
};

typedef NS_ENUM(NSInteger, JMSortBy) {
    JMSortByName = 0,
    JMSortByDate,
    JMSortByCreator
};

static NSString * const kJMSettingTypeKey = @"settingsType";
static NSString * const kJMTitleKey = @"title";
static NSString * const kJMRowsKey = @"rows";

@interface JMMasterLibraryTableViewController ()
@property (nonatomic, strong) NSArray *cellsAndSectionsProperties;
@property (nonatomic, assign) JMResourcesType resourcesTypeEnum;
@property (nonatomic, assign) JMSortBy sortByEnum;
@end

@implementation JMMasterLibraryTableViewController
- (NSArray *)resourcesTypes
{
    switch (self.resourcesTypeEnum) {
        case JMResourceTypeReport:
            return @[self.constants.WS_TYPE_REPORT_UNIT];
        case JMResourceTypeDashboard:
            return @[self.constants.WS_TYPE_DASHBOARD];
        case JMResourceTypeAll:
        default:
            return @[self.constants.WS_TYPE_REPORT_UNIT, self.constants.WS_TYPE_DASHBOARD];
    }
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
        _cellsAndSectionsProperties = @[
                                        @{
                                            kJMSettingTypeKey : @(JMTableViewSection_ResourceType),
                                            kJMTitleKey : @"resources",
                                            // Temp solution
                                            // TODO: refactor / re-implement
                                            kJMRowsKey : @[
                                                    @"all", @"reportUnit", @"dashboard"
                                                    ]
                                            },
                                        @{
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


#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (NSInteger i = 0; i < [self.cellsAndSectionsProperties count]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
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
    cell.label.text = [self localizedRowTitle:indexPath.row forSection:indexPath.section];

    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMLibraryTableViewCell *cell = (JMLibraryTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell.isSelected) return nil;
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMLibraryTableViewCell *cell = (JMLibraryTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
    cell.selected = YES;
    JMTableViewSection sectionType = [[[self.cellsAndSectionsProperties objectAtIndex:indexPath.section] objectForKey:kJMSettingTypeKey] integerValue];
    switch (sectionType) {
        case JMTableViewSection_ResourceType:
            self.resourcesTypeEnum = (JMResourcesType) indexPath.row;
            break;
        case JMTableViewSection_SortingType:
            self.sortByEnum = (JMSortBy) indexPath.row;
            break;
    }
    
    [self loadResourcesIntoDetailViewController];
    // Deselect other rows
    for (NSInteger i = [self.tableView numberOfRowsInSection:indexPath.section] - 1; i >= 0; i--) {
        if (i == indexPath.row) continue;
        NSIndexPath *cellToDeselect = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
        cell = (JMLibraryTableViewCell *) [self.tableView cellForRowAtIndexPath:cellToDeselect];
        cell.selected = NO;
    }
}

#pragma mark - Actions

- (IBAction)refresh:(id)sender
{
    [self loadResourcesIntoDetailViewController];
}

- (NSDictionary *)paramsForLoadingResourcesIntoDetailViewController
{
    return @{
            kJMResourcesTypes : self.resourcesTypes,
            kJMLoadRecursively : @(YES),
            kJMSearchQuery : self.searchQuery ?: @"",
            kJMSortBy : self.sortBy
    };
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
