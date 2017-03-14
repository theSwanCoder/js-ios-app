/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMExternalWindowDashboardControlsVC.h"
#import "JMExternalWindowDashboardControlsTableViewCell.h"
#import "JMLocalization.h"

@interface JMExternalWindowDashboardControlsVC () <UITableViewDelegate, UITableViewDataSource, JMExternalWindowDashboardControlsTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSArray <JSDashboardComponent *> *visibleComponents;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSNumber *>*maximizedComponents;
@end

@implementation JMExternalWindowDashboardControlsVC

#pragma mark - Custom Accessor
- (void)setComponents:(NSArray *)components
{
    _components = components;

    NSMutableArray <JSDashboardComponent *>*visibleComponents = [NSMutableArray array];
    NSMutableDictionary *maximizedComponets = [NSMutableDictionary dictionary];
    for (JSDashboardComponent *component in components) {
        BOOL isReportUnitComponent = [component.type isEqualToString:@"reportUnit"];
        BOOL isChartComponent = [component.type isEqualToString:@"chart"];
        BOOL isAdhocComponent = [component.type isEqualToString:@"adhocDataView"];
        if (isReportUnitComponent || isChartComponent || isAdhocComponent) {
            [visibleComponents addObject:component];
        }
    }
    self.visibleComponents = visibleComponents;
    self.maximizedComponents = maximizedComponets;

    [self.tableView reloadData];
}

#pragma mark - UIViewController LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    UINib *cellNib = [UINib nibWithNibName:@"JMExternalWindowDashboardControlsTableViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"JMExternalWindowDashboardControlsTableViewCell"];
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.visibleComponents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMExternalWindowDashboardControlsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JMExternalWindowDashboardControlsTableViewCell"
                                                                                           forIndexPath:indexPath];
    JSDashboardComponent *component = self.visibleComponents[indexPath.row];
    cell.nameLabel.text = component.label;
    BOOL isMaximized = ((NSNumber *)self.maximizedComponents[component.identifier]).boolValue;
    NSString *buttonTitle;
    if (isMaximized) {
        buttonTitle = JMLocalizedString(@"external_screen_button_title_manimize");
        cell.backgroundColor = [UIColor lightGrayColor];
    } else {
        buttonTitle = JMLocalizedString(@"external_screen_button_title_maximize");
        cell.backgroundColor = [UIColor whiteColor];
    }
    [cell.maximizeButton setTitle:buttonTitle
                         forState:UIControlStateNormal];
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // find maximized component
    JSDashboardComponent *selectedComponent = self.visibleComponents[indexPath.row];
    NSString *selectedComponentID = selectedComponent.identifier;
    BOOL isSelectedComponentMaximized = ((NSNumber *)self.maximizedComponents[selectedComponentID]).boolValue;
    if (isSelectedComponentMaximized) {
        // minimize
        self.maximizedComponents[selectedComponentID] = @(NO);
        if ([self.delegate respondsToSelector:@selector(externalWindowDashboardControlsVC:didAskMinimizeDashlet:)]) {
            [self.delegate externalWindowDashboardControlsVC:self didAskMinimizeDashlet:selectedComponent];
        }
    } else {
        // maximize if there aren't any other maximized
        NSString *maximizedComponentID;
        for (NSString *componentID in self.maximizedComponents.allKeys) {
            BOOL isMaximized = ((NSNumber *)self.maximizedComponents[componentID]).boolValue;
            if (isMaximized) {
                maximizedComponentID = componentID;
                break;
            }
        }

        if (!maximizedComponentID) {
            // maximize
            self.maximizedComponents[selectedComponentID] = @(YES);
            if ([self.delegate respondsToSelector:@selector(externalWindowDashboardControlsVC:didAskMaximizeDashlet:)]) {
                [self.delegate externalWindowDashboardControlsVC:self didAskMaximizeDashlet:selectedComponent];
            }
        }
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Public API

- (void)markComponentAsMinimized:(JSDashboardComponent *)component
{
    NSString *minimizedComponentID = component.identifier;

    for (NSString *componentID in self.maximizedComponents.allKeys) {
        if ([componentID isEqualToString:minimizedComponentID]) {
            self.maximizedComponents[componentID] = @NO;
        }
    }

    [self.tableView reloadData];
}

@end
