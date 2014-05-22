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
#import "JMLocalization.h"
#import "JMRequestDelegate.h"
#import "JMConstants.h"
#import "JMPaginationData.h"
#import <Objection-iOS/Objection.h>

#define kJMResourcesSection 0
#define kJMSortSection 1

typedef NS_ENUM(NSInteger, JMResourcesType) {
    JMResourceTypeAll = 0,
    JMResourceTypeReport,
    JMResourceTypeDashboard,
};

typedef NS_ENUM(NSInteger, JMSortBy) {
    JMSortByName = 0,
    JMSortByDate,
    JMSortByCreator
};

static NSString * const kJMShowResourcesSegue = @"ShowResources";
static NSString * const kJMTitleKey = @"title";
static NSString * const kJMRowsKey = @"rows";

@interface JMMasterLibraryTableViewController ()
@property (nonatomic, strong) NSDictionary *cellsAndSectionsProperties;
@property (nonatomic, assign) JMResourcesType resourcesTypeEnum;
@end

@implementation JMMasterLibraryTableViewController
objection_requires(@"resourceClient", @"constants")

@synthesize resourceClient = _resourcesClient;

#pragma mark - Accessors

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

- (NSDictionary *)cellsAndSectionsProperties
{
    if (!_cellsAndSectionsProperties) {
        _cellsAndSectionsProperties = @{
                @kJMResourcesSection : @{
                        kJMTitleKey : @"resources",
                        // Temp solution
                        // TODO: refactor / re-implement
                        kJMRowsKey : @[
                                @"all", @"reportUnit", @"dashboard"
                        ]
                },
                @kJMSortSection : @{
                        kJMTitleKey : @"sortby",
                        kJMRowsKey : @[
                                @"name", @"date"
                        ]
                }
        };
    }

    return _cellsAndSectionsProperties;
}

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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showResourcesListInMaster:)
                                                 name:kJMShowResourcesListInMaster
                                               object:nil];

    for (NSInteger i = [self.cellsAndSectionsProperties count] - 1; i >= 0; i--) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
    }

    [self loadResources];
}


- (void)showResourcesListInMaster:(NSNotification *)notification
{
    [self performSegueWithIdentifier:kJMShowResourcesSegue sender:[notification.userInfo objectForKey:kJMPaginationData]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kJMShowResourcesSegue]) {
        JMPaginationData *paginationData = sender;
        id destinationViewController = segue.destinationViewController;
        [destinationViewController setTotalCount:paginationData.totalCount];
        [destinationViewController setResources:paginationData.resources];
        [destinationViewController setOffset:paginationData.offset];
        [destinationViewController setResourceLookup:paginationData.resourceLookup];
        [destinationViewController setResourcesTypes:self.resourcesTypes];
    }
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"JMMenuSectionView" owner:self.tableView options:nil];
    JMMenuSectionView *view = [nib objectAtIndex:0];
    view.frame = CGRectMake(0, 0, 163, 10.0f);
    view.title.text = [self localizedSectionTitle:section];
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.cellsAndSectionsProperties.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *sectionProperties = [self.cellsAndSectionsProperties objectForKey:[NSNumber numberWithInt:section]];
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

    switch (indexPath.section) {
        case kJMResourcesSection:
            self.resourcesTypeEnum = (JMResourcesType) indexPath.row;
            [self loadResources];
            break;

        case kJMSortSection:
            break;
    }

    // Deselect other rows
    for (NSInteger i = [self.tableView numberOfRowsInSection:indexPath.section] - 1; i >= 0; i--) {
        if (i == indexPath.row) continue;
        NSIndexPath *cellToDeselect = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
        cell = (JMLibraryTableViewCell *) [self.tableView cellForRowAtIndexPath:cellToDeselect];
        cell.selected = NO;
    }
}

#pragma mark - NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private -

- (void)loadResources
{
    JMPaginationData *paginationData = [[JMPaginationData alloc] init];
    paginationData.resourcesTypes = self.resourcesTypes;
    paginationData.loadRecursively = YES;
    NSDictionary *userInfo = @{
            kJMPaginationData : paginationData
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMLoadResourcesInDetail
                                                        object:nil
                                                      userInfo:userInfo];
}

#pragma mark - Localization

- (NSString *)localizedRowTitle:(NSInteger)row forSection:(NSInteger)section
{
    NSDictionary *properties = [self.cellsAndSectionsProperties objectForKey:[NSNumber numberWithInteger:section]];
    NSString *sectionTitle = [properties objectForKey:kJMTitleKey];
    NSString *rowTitle = [[properties objectForKey:kJMRowsKey] objectAtIndex:row];
    NSString *localizationKey = [NSString stringWithFormat:@"master.%@.type.%@", sectionTitle, rowTitle];
    return JMCustomLocalizedString(localizationKey, nil);
}

- (NSString *)localizedSectionTitle:(NSInteger)section
{
    NSDictionary *properties = [self.cellsAndSectionsProperties objectForKey:[NSNumber numberWithInteger:section]];
    NSString *localizationKey = [NSString stringWithFormat:@"master.%@.title", [properties objectForKey:kJMTitleKey]];
    return JMCustomLocalizedString(localizationKey, nil);
}

@end
