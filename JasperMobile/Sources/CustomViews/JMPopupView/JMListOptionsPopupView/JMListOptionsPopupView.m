/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
 * http://community.jaspersoft.com/project/jaspermobile-ios
 *
 * Unless you have purchased a commercial license agreement from Jaspersoft,
 * the following license terms apply:
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/lgpl>.
 */


#import "JMListOptionsPopupView.h"
#import "JMResourcesListLoader.h"
#import "JMResourcesListLoaderOption.h"
#import "JMThemesManager.h"
#import "JMUtils.h"

#define kJMList

@interface JMListOptionsPopupView () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UILabel *listOptionsTitleLabel;
@property (nonatomic, weak) IBOutlet UITableView *listOptionsTableView;
@property (nonatomic, strong) NSArray <JMResourcesListLoaderOption *> *options;
@end


@implementation JMListOptionsPopupView
@synthesize selectedIndex = _selectedIndex;

- (id)initWithDelegate:(id<JMPopupViewDelegate>)delegate type:(JMPopupViewType)type options:(NSArray <JMResourcesListLoaderOption *>*)options
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
