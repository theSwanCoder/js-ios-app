//
//  JMBaseResourcesViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 7/4/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMBaseResourcesViewController.h"
#import "UIViewController+FetchInputControls.h"
#import "JMConstants.h"
#import "JMDetailReportViewerViewController.h"
#import "JMDetailReportOptionsViewController.h"
#import <Objection-iOS/Objection.h>

NSString * kJMResourceCellIdentifier = @"ResourceCell";
NSString * kJMLoadingCellIdentifier = @"LoadingCell";

@implementation JMBaseResourcesViewController
objection_requires(@"constants")

- (NSInteger)numberOfSections
{
    return 1;
}

- (NSInteger)numberOfResourcesInSection:(NSInteger)section
{
    NSInteger count = self.delegate.resources.count;
    if ([self.delegate hasNextPage]) count++;
    
    return count;
}

- (void)didSelectResourceAtIndexPath:(NSIndexPath *)indexPath
{
    JSResourceLookup *resourceLookup = [self.delegate.resources objectAtIndex:indexPath.row];
    if ([resourceLookup.resourceType isEqualToString:self.constants.WS_TYPE_REPORT_UNIT]) {
        [self fetchInputControlsForReport:resourceLookup];
    } else {
        NSDictionary *data = @{
                       kJMResourceLookup : resourceLookup
        };
        [self performSegueWithIdentifier:kJMShowReportViewerSegue sender:data];
    }
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
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSInteger row;
    
    if ([self isReportSegue:segue]) {
        JSResourceLookup *resourcesLookup = [sender objectForKey:kJMResourceLookup];
        row = [self.delegate.resources indexOfObject:resourcesLookup];
        
        if ([segue.identifier isEqualToString:kJMShowReportOptionsSegue]) {
            NSArray *inputControls = [sender objectForKey:kJMInputControls];
            BOOL hasMandatoryInputControls = [[sender objectForKey:kJMHasMandatoryInputControls] boolValue];
            id destinationViewController = segue.destinationViewController;
            [destinationViewController setInputControls:[inputControls mutableCopy]];
            [destinationViewController setHasMandatoryInputControls:hasMandatoryInputControls];
        }
    } else {
        row = [sender row];
    }
    
    NSDictionary *userInfo = @{
                   kJMResources : self.delegate.resources,
                   kJMTotalCount : @(self.delegate.totalCount),
                   kJMOffset : @(self.delegate.offset),
                   kJMSelectedResourceIndex : @(row)
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMShowResourcesListInMaster
                                                        object:nil
                                                      userInfo:userInfo];
}

#pragma mark - JMRefreshable

- (void)refresh
{
    @throw [NSException exceptionWithName:@"Method implementation is missing" reason:@"You need to implement \"refresh\" method in subclasses" userInfo:nil];
}

#pragma mark - JMActionBarProvider

- (id)actionBar
{
    return [self.delegate actionBar];
}

@end
