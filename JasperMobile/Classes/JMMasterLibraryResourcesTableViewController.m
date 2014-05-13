//
//  JMMasterLibraryResourcesTableViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadsky on 5/7/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <Objection-iOS/JSObjection.h>
#import <Objection-iOS/Objection.h>
#import "JMMasterLibraryResourcesTableViewController.h"
#import "JMRequestDelegate.h"
#import "JMPaginationData.h"
#import "JMConstants.h"

static NSInteger const kJMLimit = 15;
static NSInteger const kJMBackCell = 0;

@implementation JMMasterLibraryResourcesTableViewController

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - UIViewController

//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//
//    defaultCellColor = [UIColor colorWithRed:[self rgbComponent:50.0f]
//                                       green:[self rgbComponent:52.0f]
//                                        blue:[self rgbComponent:59.0f]
//                                       alpha:1.0f];
//    selectedCellColor = [UIColor colorWithRed:[self rgbComponent:72.0f]
//                                        green:[self rgbComponent:79.0f]
//                                         blue:[self rgbComponent:89.0f]
//                                        alpha:1.0f];
//    defaultCircleImageName = @"circle.png";
//    selectedCircleImageName = @"circle_selected.png";
//
//    self.resources = [NSMutableArray array];
//
//    // TODO: show downloading progress
//
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(loadNextPage)
//                                                 name:kJMLoadNextPageNotification
//                                               object:nil];
//    [self loadNextPage];
//}
//

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0f;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 44.0f;
//}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"JMMenuSectionView" owner:self.tableView options:nil];
//    JMMenuSectionView *view = [nib objectAtIndex:0];
//    view.frame = CGRectMake(0, 0, 163, 10.0f);
//    view.title.text = section != kJMToolsSection ? [self localizedSectionTitle:section] : @"";
//    return view;
//}
//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.resources.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ResourceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell viewWithTag:1];

    if (indexPath.row == kJMBackCell) {
        // TODO: localize
        label.text = @"Back";
    } else {
        label.text = [[self.resources objectAtIndex:(indexPath.row - 1)] label];
    }

    return cell;
}

//- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    JMMenuTableViewCell *cell = (JMMenuTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
//    if (cell.isSelected) return nil;
//    return indexPath;
//}
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == kJMBackCell) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.selected = YES;

}

//    Deselect other rows
//    for (NSInteger i = [self.tableView numberOfRowsInSection:indexPath.section] - 1; i >= 0; i--) {
//        if (i == indexPath.row) continue;
//        NSIndexPath *cellToDeselect = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
//        cell = (JMMenuTableViewCell *) [self.tableView cellForRowAtIndexPath:cellToDeselect];
//        cell.selected = NO;
//    }
//}
//
//#pragma mark - NSObject
//
//- (void)dealloc
//{
//    defaultCellColor = nil;
//    selectedCellColor = nil;
//    defaultCircleImageName = nil;
//    selectedCircleImageName = nil;
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}
//
//#pragma mark - Private
//
//#pragma mark - Pagination
//
//- (void)loadNextPage
//{
//    __weak JMMasterLibraryTableViewController *weakSelf = self;
//
//    JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
//        if (!weakSelf.totalCount) {
//            weakSelf.totalCount = [[result.allHeaderFields objectForKey:@"Total-Count"] integerValue];
//        }
//
//        [weakSelf.resources addObjectsFromArray:result.objects];
//
//        JMPaginationData *paginationData = [[JMPaginationData alloc] init];
//        paginationData.resources = weakSelf.resources;
//        paginationData.totalCount = weakSelf.totalCount;
//        paginationData.isNewResourcesType = weakSelf.isResourcesTypeChanged;
//        paginationData.hasNextPage = weakSelf.hasNextPage;
//
//        [[NSNotificationCenter defaultCenter] postNotificationName:kJMPageLoadedNotification object:nil userInfo:@{
//                kJMPaginationData : paginationData
//        }];
//
//        weakSelf.isResourcesTypeChanged = NO;
//    } errorBlock:^(JSOperationResult *result) {
//        weakSelf.offset -= kJMLimit;
//        // TODO: add error handler
//    }];
//
////    [self.resourceClient resourceLookups:self.folderUri query:nil types:self.resourcesType recursive:YES offset:self.offset limit:kJMLimit delegate:delegate];
//    [self.resourceClient resourceLookups:nil query:nil types:self.resourcesType recursive:YES offset:self.offset limit:kJMLimit delegate:delegate];
//    self.offset += kJMLimit;
//}
//
//- (BOOL)hasNextPage
//{
//    return self.offset < self.totalCount;
//}
//
//#pragma mark - Localization
//
//- (NSString *)localizedRowTitle:(NSInteger)row forSection:(NSInteger)section
//{
//    NSDictionary *properties = [self.cellsAndSectionsProperties objectForKey:[NSNumber numberWithInteger:section]];
//    NSString *sectionTitle = [properties objectForKey:kJMTitleKey];
//    NSString *rowTitle = [[properties objectForKey:kJMRowsKey] objectAtIndex:row];
//    NSString *localizationKey = [NSString stringWithFormat:@"master.%@.type.%@", sectionTitle, rowTitle];
//    return JMCustomLocalizedString(localizationKey, nil);
//}
//
//- (NSString *)localizedSectionTitle:(NSInteger)section
//{
//    NSDictionary *properties = [self.cellsAndSectionsProperties objectForKey:[NSNumber numberWithInteger:section]];
//    NSString *localizationKey = [NSString stringWithFormat:@"master.%@.title", [properties objectForKey:kJMTitleKey]];
//    return JMCustomLocalizedString(localizationKey, nil);
//}

@end
