/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMListOptionsPopupView.h"
#import "JMResourcesListLoader.h"
#import "JMResourceLoaderOption.h"
#import "JMThemesManager.h"
#import "JMUtils.h"

#define kJMList

@interface JMListOptionsPopupView () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UILabel *listOptionsTitleLabel;
@property (nonatomic, weak) IBOutlet UITableView *listOptionsTableView;
@property (nonatomic, strong) NSArray <JMResourceLoaderOption *> *options;
@end


@implementation JMListOptionsPopupView
@synthesize selectedIndex = _selectedIndex;

- (id)initWithDelegate:(id<JMPopupViewDelegate>)delegate type:(JMPopupViewType)type options:(NSArray <JMResourceLoaderOption *>*)options
{
    self = [super initWithDelegate:delegate type:type];
    if (self) {
        UIView *nibView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];

        self.options = options;
        [self.listOptionsTableView reloadData];
        
        CGRect neededRect = nibView.frame;
        neededRect.size.height = self.listOptionsTableView.frame.origin.y + self.listOptionsTableView.contentSize.height;
        if (neededRect.size.height > kJMPopupViewContentMaxHeight) {
            neededRect.size.height = kJMPopupViewContentMaxHeight;
        }
        nibView.frame = neededRect;
        self.listOptionsTableView.scrollEnabled = (self.listOptionsTableView.contentSize.height > self.listOptionsTableView.frame.size.height);
        self.listOptionsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        self.contentView = nibView;
    }
    
    return self;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    [self.listOptionsTableView reloadData];
}

-(void)setTitleString:(NSString *)titleString
{
    self.listOptionsTitleLabel.text = titleString;
}

- (NSString *)titleString
{
    return self.listOptionsTitleLabel.text;
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ListItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [[JMThemesManager sharedManager] navigationBarTitleFont];
        cell.textLabel.textColor = [[JMThemesManager sharedManager] popupsTextColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = [self.options[indexPath.row] title];
    cell.accessoryType = indexPath.row == self.selectedIndex ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView: (UITableView*)tableView willDisplayCell: (UITableViewCell*)cell forRowAtIndexPath: (NSIndexPath*)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath.row;
    [self performSelector:@selector(dismissByValueChanged) withObject:nil afterDelay:0.2];
}

@end
