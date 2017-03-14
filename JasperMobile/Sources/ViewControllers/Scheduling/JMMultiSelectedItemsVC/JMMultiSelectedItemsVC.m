/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMMultiSelectedItemsVC.h"
#import "JMSelectedItem.h"

@interface JMMultiSelectedItemsVC() <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray <JMSelectedItem *>*selectedItems;
@end

@implementation JMMultiSelectedItemsVC

#pragma mark - UIViewController Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *backButtonItem = [self backButtonWithTitle:nil
                                                         target:self
                                                         action:@selector(backButtonTapped)];
    self.navigationItem.leftBarButtonItem = backButtonItem;

    self.selectedItems = [NSMutableArray new];
    for (JMSelectedItem *item in self.availableItems) {
        if (item.selected) {
            [self.selectedItems addObject:item];
        }
    }
}

#pragma mark - Actions
- (void)backButtonTapped
{
    if (self.exitBlock) {
        self.exitBlock(self.selectedItems);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView Data Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.availableItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JMMultiValuesCell"
                                                            forIndexPath:indexPath];
    JMSelectedItem *item = self.availableItems[indexPath.row];
    cell.textLabel.text = item.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMSelectedItem *item = self.availableItems[indexPath.row];
    cell.selected = item.isSelected;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    JMSelectedItem *item = self.availableItems[indexPath.row];
    if ([self.selectedItems containsObject:item]) {
        item.selected = NO;
        cell.selected = NO;
        [self.selectedItems removeObject:item];
    } else {
        item.selected = YES;
        cell.selected = YES;
        [self.selectedItems addObject:item];
    }
}

@end
