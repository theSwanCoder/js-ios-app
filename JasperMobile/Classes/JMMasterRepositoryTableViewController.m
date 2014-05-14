//
//  JMMasterRepositoryTableViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 5/13/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMMasterRepositoryTableViewController.h"
#import "JMRequestDelegate.h"
#import "JMPaginationData.h"
#import "JMConstants.h"
#import <Objection-iOS/Objection.h>

static NSInteger const kJMLimit = 15;
static NSInteger const kJMRootFolderCell = 0;

@interface JMMasterRepositoryTableViewController ()
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, assign) NSInteger offset;
@property (weak, nonatomic) IBOutlet UIView *backView;
@end

@implementation JMMasterRepositoryTableViewController
objection_requires(@"resourceClient", @"constants")

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
    
    self.folders = [NSMutableArray array];
    
    if (!self.currentFolder) {
        self.currentFolder = [[JSResourceLookup alloc] init];
        // TODO: localize
        self.currentFolder.label = @"Root";
        // TODO: find prop value
        self.currentFolder.uri = @"/";
        
        self.backView.hidden = YES;
        self.backView.frame = CGRectZero;
    } else {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(back:)];
        [self.backView addGestureRecognizer:tapGestureRecognizer];
    }
    
    __weak  JMMasterRepositoryTableViewController *weakSelf = self;
    
    JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        if (weakSelf.totalCount) {
            weakSelf.totalCount = [[result.allHeaderFields objectForKey:@"Total-Count"] integerValue];
        }
        
        [weakSelf.folders addObject:weakSelf.currentFolder];
        [weakSelf.folders addObjectsFromArray:result.objects];
        [weakSelf.tableView reloadData];
        [weakSelf loadResourcesIntoDetailViewController];
    }];
    
    [self.resourceClient resourceLookups:self.currentFolder.uri query:nil types:@[self.constants.WS_TYPE_FOLDER] recursive:NO offset:self.offset limit:kJMLimit delegate:delegate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    JSResourceLookup *selectedFolder = [self.folders objectAtIndex:indexPath.row];
    [segue.destinationViewController setCurrentFolder:selectedFolder];
    [segue.destinationViewController setDelegate:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = self.folders.count;
    if (self.offset < self.totalCount) count++;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *cellIdentifier = (indexPath.row == kJMRootFolderCell) ? @"RootCell" : @"FolderCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];;
    UILabel *label = (UILabel *) [cell viewWithTag:1];
    label.text = [[self.folders objectAtIndex:indexPath.row] label];
    
    return cell;
}

#pragma mark - JMMasterRepositoryTableViewController

- (void)loadResourcesIntoDetailViewController
{
    JMPaginationData *paginationData = [[JMPaginationData alloc] init];
    paginationData.currentFolder = self.currentFolder;
    NSDictionary *userInfo = @{
        kJMPaginationData : paginationData
    };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMLoadResourcesInDetail
                                                        object:nil
                                                      userInfo:userInfo];
}

#pragma mark - Actions

- (IBAction)back:(UITapGestureRecognizer *)recognizer
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate loadResourcesIntoDetailViewController];
}

@end
