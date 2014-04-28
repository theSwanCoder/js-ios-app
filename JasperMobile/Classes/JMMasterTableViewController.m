//
//  JMMasterTableViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadsky on 3/18/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMMasterTableViewController.h"
#import "JMMenuSectionView.h"
#import "JMLocalization.h"
#import "JMCancelRequestPopup.h"
#import "JMRequestDelegate.h"
#import "JMConstants.h"
#import "JMPaginationData.h"
#import <Objection-iOS/Objection.h>

#define kJMResourcesSection 0
#define kJMSortSection 1
#define kJMCategoriesSection 2
#define kJMToolsSection 3

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

typedef NS_ENUM(NSInteger, JMCategory) {
    JMCategoryAll = 0,
    JMCategorySales,
    JMCategoryMarketing
};

typedef NS_ENUM(NSInteger, JMTool) {
    JMToolRefresh = 0
};

// TODO: ask what value it should be
static NSInteger const kJMLimit = 15;

static NSString * const kJMTitleKey = @"title";
static NSString * const kJMRowsKey = @"rows";

static UIColor *defaultCellColor;
static UIColor *selectedCellColor;
static NSString *defaultCircleImageName;
static NSString *selectedCircleImageName;

@interface JMMasterTableViewController ()
@property (nonatomic, strong) NSDictionary *cellsAndSectionsProperties;
@property (nonatomic, assign) JMResourcesType resourcesTypeEnum;
@property (nonatomic, assign) BOOL isResourcesTypeChanged;
@end

@implementation JMMasterTableViewController
objection_requires(@"resourceClient", @"constants")

@synthesize resourceClient = _resourcesClient;
@synthesize totalCount = _totalCount;
@synthesize offset = _offset;

#pragma mark - Accessors

- (NSArray *)resourcesType
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
                  @"name", @"date", @"creator"
                ]
            },
            @kJMCategoriesSection : @{
                kJMTitleKey : @"category",
                kJMRowsKey : @[
                    @"all", @"sales", @"marketing"
                ]
            },
            @kJMToolsSection : @{
                kJMTitleKey : @"tools",
                kJMRowsKey : @[
                    @"refresh"
                ]
            }
        };
    }

    return _cellsAndSectionsProperties;
}

- (CGFloat)rgbComponent:(CGFloat)color
{
    return color / 255.0f;
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

    defaultCellColor = [UIColor colorWithRed:[self rgbComponent:50.0f]
                                       green:[self rgbComponent:52.0f]
                                        blue:[self rgbComponent:59.0f]
                                       alpha:1.0f];
    selectedCellColor = [UIColor colorWithRed:[self rgbComponent:72.0f]
                                        green:[self rgbComponent:79.0f]
                                         blue:[self rgbComponent:89.0f]
                                        alpha:1.0f];
    defaultCircleImageName = @"circle.png";
    selectedCircleImageName = @"circle_selected.png";

    self.resources = [NSMutableArray array];

    // TODO: show downloading progress

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadNextPage)
                                                 name:kJMLoadNextPage
                                               object:nil];
    [self loadNextPage];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    for (NSInteger i = [self.cellsAndSectionsProperties count] - 2; i >= 0; i--) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // TODO: add cleaning logic
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"JMMenuSectionView" owner:self.tableView options:nil];
    JMMenuSectionView *view = [nib objectAtIndex:0];
    view.frame = CGRectMake(0, 0, 163, 10.0f);
    view.title.text = section != kJMToolsSection ? [self localizedSectionTitle:section] : @"";
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
    JMMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.title.text = [self localizedRowTitle:indexPath.row forSection:indexPath.section];

    if (indexPath.section != kJMSortSection && indexPath.section != kJMToolsSection) {

    } else {
        cell.numberOfResources.text = @"";
    }

    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMMenuTableViewCell *cell = (JMMenuTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell.isSelected) return nil;
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMMenuTableViewCell *cell = (JMMenuTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
    cell.selected = YES;
    
    switch (indexPath.section) {
        case kJMResourcesSection:
            self.resourcesTypeEnum = (JMResourcesType) indexPath.row;
            [self.resources removeAllObjects];
            self.totalCount = 0;
            self.offset = 0;
            self.isResourcesTypeChanged = YES;
            [self loadNextPage];

            // Load resources special type
            break;

        case kJMSortSection:
            break;

        case kJMCategoriesSection:
            // TODO: get some info about what categories are
            break;

        case kJMToolsSection:
            break;
    }

    // Deselect other rows
    for (NSInteger i = [self.tableView numberOfRowsInSection:indexPath.section] - 1; i >= 0; i--) {
        if (i == indexPath.row) continue;
        NSIndexPath *cellToDeselect = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
        cell = (JMMenuTableViewCell *) [self.tableView cellForRowAtIndexPath:cellToDeselect];
        cell.selected = NO;
    }
}

#pragma mark - NSObject

- (void)dealloc
{
    defaultCellColor = nil;
    selectedCellColor = nil;
    defaultCircleImageName = nil;
    selectedCircleImageName = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private

#pragma mark - Pagination

- (void)loadNextPage
{
    __weak JMMasterTableViewController *weakSelf = self;

    JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        if (!weakSelf.totalCount) {
            weakSelf.totalCount = [[result.allHeaderFields objectForKey:@"Total-Count"] integerValue];
        }

        [weakSelf.resources addObjectsFromArray:result.objects];

        JMPaginationData *paginationData = [[JMPaginationData alloc] init];
        paginationData.resources = weakSelf.resources;
        paginationData.totalCount = weakSelf.totalCount;
        paginationData.isNewResourcesType = weakSelf.isResourcesTypeChanged;
        paginationData.hasNextPage = weakSelf.hasNextPage;

        [[NSNotificationCenter defaultCenter] postNotificationName:kJMPageLoaded object:nil userInfo: @{
                kJMPaginationData : paginationData
        }];

        weakSelf.isResourcesTypeChanged = NO;
    } errorBlock:^(JSOperationResult *result) {
        weakSelf.offset -= kJMLimit;
        // TODO: add error handler
    }];

    [self.resourceClient resourceLookups:self.folderUri query:nil types:self.resourcesType recursive:YES offset:self.offset limit:kJMLimit delegate:delegate];
    self.offset += kJMLimit;
}

- (BOOL)hasNextPage
{
    return self.offset < self.totalCount;
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

@implementation JMMenuTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.contentView.backgroundColor = selectedCellColor;
        [self.circleImageView setImage:[UIImage imageNamed:selectedCircleImageName]];
    } else {
        self.contentView.backgroundColor = defaultCellColor;
        [self.circleImageView setImage:[UIImage imageNamed:defaultCircleImageName]];
    }
}

@end
