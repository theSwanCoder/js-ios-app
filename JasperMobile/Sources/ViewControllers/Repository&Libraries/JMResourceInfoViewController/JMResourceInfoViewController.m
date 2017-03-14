/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMResourceInfoViewController.h"
#import "PopoverView.h"
#import "UIViewController+Additions.h"
#import "JMResource.h"
#import "JMThemesManager.h"
#import "JMUtils.h"
#import "JMConstants.h"
#import "JMLocalization.h"


NSString * const kJMShowResourceInfoSegue  = @"ShowResourceInfoSegue";

@interface JMResourceInfoViewController ()<UITableViewDataSource, UITableViewDelegate, PopoverViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) PopoverView *popoverView;
@end

@implementation JMResourceInfoViewController
@synthesize resource = _resource;

#pragma mark - UIViewController Life Cycle
- (instancetype)init
{
    return [self initWithNibName:@"JMResourceInfoViewController" bundle:[NSBundle mainBundle]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Accessibility
    self.view.isAccessibilityElement = NO;
    self.view.accessibilityIdentifier = [self accessibilityIdentifier];
    
    self.view.backgroundColor = [[JMThemesManager sharedManager] viewBackgroundColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self showNavigationItems];
    [self resetResourceProperties];
    [self addObservers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateIfNeeded];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Accessibility
- (NSString *)accessibilityIdentifier
{
    return [NSString stringWithFormat:@"%@AccessibilityId", NSStringFromClass(self.class)];
}

#pragma mark - Observers
- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetResourceProperties) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceOrientationDidChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)resetResourceProperties
{
    self.title = self.resource.resourceLookup.label;
    self.resourceProperties = nil;
    [self.tableView reloadData];
    self.needLayoutUI = YES;
}

- (void)interfaceOrientationDidChanged:(id)notification
{
    self.needLayoutUI = YES;
}

#pragma mark - Actions
- (void)cancelButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Public API
- (NSArray *)resourceProperties
{
    
    if (!_resourceProperties) {
        NSString *createdAtString = [JMUtils localizedStringFromDate:self.resource.resourceLookup.creationDate];
        NSString *modifiedAtString = [JMUtils localizedStringFromDate:self.resource.resourceLookup.updateDate];

        _resourceProperties = @[
                                @{
                                    kJMTitleKey : @"label",
                                    kJMValueKey : self.resource.resourceLookup.label ?: @""
                                    },
                                @{
                                    kJMTitleKey : @"description",
                                    kJMValueKey : self.resource.resourceLookup.resourceDescription ?: @""
                                    },
                                @{
                                    kJMTitleKey : @"uri",
                                    kJMValueKey : self.resource.resourceLookup.uri ?: @""
                                    },
                                
                                @{
                                    kJMTitleKey : @"type",
                                    kJMValueKey : [self.resource localizedResourceType] ?: @""
                                    },
                                @{
                                    kJMTitleKey : @"version",
                                    kJMValueKey : self.resource.resourceLookup.version ? [NSString stringWithFormat:@"%@", self.resource.resourceLookup.version]: @""
                                    },
                                @{
                                    kJMTitleKey : @"creationDate",
                                    kJMValueKey : createdAtString ?: @""
                                    },
                                @{
                                    kJMTitleKey : @"modifiedDate",
                                    kJMValueKey : modifiedAtString ?: @""
                                    }
                                ];
    }
    return _resourceProperties;
}

- (JMMenuActionsViewAction)availableAction
{
    return JMMenuActionsViewAction_None;
}

- (nullable UIBarButtonItem *)additionalBarButtonItem
{
    return nil;
}

- (void)setNeedLayoutUI:(BOOL)needLayoutUI
{
    _needLayoutUI = needLayoutUI;
    [self updateIfNeeded];
}

#pragma mark - Private API

- (void)updateIfNeeded
{
    if (self.needLayoutUI && [self isVisible]) {
        [self showNavigationItems];
        self.needLayoutUI = NO;
    }
}

#pragma mark - Setup Navigation Items
- (void) showNavigationItems
{
    BOOL selfIsModalViewController = [self.navigationController.viewControllers count] == 1;

    NSMutableArray *rightBarItems = [NSMutableArray array];
    if (selfIsModalViewController) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                              target:self
                                                                                              action:@selector(cancelButtonTapped:)];
        self.navigationItem.leftBarButtonItem.tintColor = [[JMThemesManager sharedManager] barItemsColor];
    } else {
        JMMenuActionsViewAction availableAction = [self availableAction];
        if (availableAction) {
            [rightBarItems addObject:[self actionBarButtonItem]];
        }
    }

    UIBarButtonItem *additionalBarButtonItem = [self additionalBarButtonItem];
    if (additionalBarButtonItem) {
        [rightBarItems addObject:additionalBarButtonItem];
    }

    self.navigationItem.rightBarButtonItems = rightBarItems;
}

- (UIBarButtonItem *) actionBarButtonItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                         target:self
                                                         action:@selector(showAvailableActions)];
}

- (void)showAvailableActions
{
    JMMenuActionsView *actionsView = [JMMenuActionsView new];
    actionsView.delegate = self;
    [actionsView setAvailableActions:[self availableAction]
                     disabledActions:JMMenuActionsViewAction_None];
    CGPoint point = CGPointMake(CGRectGetWidth(self.view.frame), -10);
    
    self.popoverView = [PopoverView showPopoverAtPoint:point
                                                inView:self.view
                                             withTitle:nil
                                       withContentView:actionsView
                                              delegate:self];
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
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [[JMThemesManager sharedManager] tableViewCellTitleFont];
        cell.textLabel.textColor = [[JMThemesManager sharedManager] tableViewCellTitleTextColor];
        cell.detailTextLabel.font = [[JMThemesManager sharedManager] tableViewCellDetailFont];
        cell.detailTextLabel.textColor = [[JMThemesManager sharedManager] tableViewCellDetailsTextColor];
        cell.detailTextLabel.numberOfLines = 2;
    }
        
    NSDictionary *item = self.resourceProperties[indexPath.row];
    cell.textLabel.text = JMLocalizedString([NSString stringWithFormat:@"resource_%@_title", item[kJMTitleKey]]);
    cell.detailTextLabel.text = item[kJMValueKey];
    return cell;
}

#pragma mark - JMMenuActionsViewDelegate
- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    [self.popoverView performSelector:@selector(dismiss) withObject:nil afterDelay:0.2f];
}

#pragma mark - PopoverViewDelegate Methods
- (void)popoverViewDidDismiss:(PopoverView *)popoverView
{
    self.popoverView = nil;
}

#pragma mark - Handle rotates
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    if (self.popoverView) {
        [self.popoverView dismiss:NO];
        [self showAvailableActions];
    }
}

@end
