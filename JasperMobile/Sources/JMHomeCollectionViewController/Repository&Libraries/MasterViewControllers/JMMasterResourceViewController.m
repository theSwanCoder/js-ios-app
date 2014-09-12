//
//  JMMasterResourceViewController.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 9/5/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMMasterResourceViewController.h"
#import "JMConstants.h"
#import <Objection-iOS/Objection.h>

@interface JMMasterResourceViewController ()
@property (weak, nonatomic) IBOutlet UILabel *masterMenuTitle;

@end

@implementation JMMasterResourceViewController
objection_requires(@"constants")


#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[JSObjection defaultInjector] injectDependencies:self];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.masterMenuTitle.text = JMCustomLocalizedString(@"master.base.resources.title", nil);
}

#pragma mark - UITableViewDatasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

#pragma mark - JMSearchable

- (void)searchWithQuery:(NSString *)query
{
    self.searchQuery = query;
    [self loadResourcesIntoDetailViewController];
}

- (void)didClearSearch
{
    if (self.searchQuery.length) {
        self.searchQuery = nil;
        [self loadResourcesIntoDetailViewController];
    }
}

- (NSString *)currentQuery
{
    return self.searchQuery;
}

- (void)loadResourcesIntoDetailViewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMLoadResourcesInDetail
                                                        object:nil
                                                      userInfo:[self paramsForLoadingResourcesIntoDetailViewController]];
}

- (NSDictionary *)paramsForLoadingResourcesIntoDetailViewController
{
    @throw [NSException exceptionWithName:@"Method implementation is missing" reason:@"You need to implement \"paramsForLoadingResourcesIntoDetailViewController\" method in subclasses" userInfo:nil];
}

#pragma mark - JMRefreshable
- (void)refresh
{
    @throw [NSException exceptionWithName:@"Method implementation is missing" reason:@"You need to implement \"refresh\" method in subclasses" userInfo:nil];
}


@end
