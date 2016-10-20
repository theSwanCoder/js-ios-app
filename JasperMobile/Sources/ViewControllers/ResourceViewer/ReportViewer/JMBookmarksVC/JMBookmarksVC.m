/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2016 TIBCO Software, Inc. All rights reserved.
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

//
//  JMBookmarksVC.m
//  TIBCO JasperMobile
//

#import "JMBookmarksVC.h"
#import "JMBookmarkTableViewCell.h"
#import "JSReportBookmark.h"

static NSString *const kJMBookmarkTableViewCellId = @"JMBookmarkTableViewCell";

@interface JMBookmarksVC() <UITableViewDelegate, UITableViewDataSource, JMBookmarkTableViewCellDelegate>
@property(nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation JMBookmarksVC

#pragma mark - UIViewController LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = JMLocalizedString(@"bookmarks_view_title");
    [self.view setAccessibility:NO withTextKey:@"bookmarks_view_title" identifier:JMReportViewerBookmarkPageAccessibilityId];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.bookmarks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMBookmarkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kJMBookmarkTableViewCellId forIndexPath:indexPath];
    JSReportBookmark *bookmark = self.bookmarks[indexPath.row];
    cell.anchorLabel.text = bookmark.anchor;
    cell.pageLabel.text = [NSString stringWithFormat:@"Page: %@", bookmark.page.stringValue];
    cell.showBookmarksButton.hidden = (bookmark.bookmarks == nil);
    cell.delegate = self;
    return cell;
}

// TODO: enable 'selecting' bookmarks.
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    JMReportBookmark *bookmark = self.bookmarks[indexPath.row];
//    if (bookmark.isSelected) {
//        JMLog(@"bookmark selected");
//        [cell setSelected:YES animated:YES];
//    }
//}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    JSReportBookmark *bookmark = self.bookmarks[indexPath.row];
    self.exitBlock(bookmark);
}

#pragma mark - JMBookmarkTableViewCellDelegate
- (void)bookmarkCellDidTapShowBookmarksButton:(JMBookmarkTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    JSReportBookmark *bookmark = self.bookmarks[indexPath.row];
    NSAssert(bookmark.bookmarks != nil, @"sholdn't to call if there isn't bookmarks");

    JMBookmarksVC *bookmarksVC = [self.storyboard instantiateViewControllerWithIdentifier:@"JMBookmarksVC"];
    bookmarksVC.bookmarks = bookmark.bookmarks;
    bookmarksVC.exitBlock = self.exitBlock;
    [self.navigationController pushViewController:bookmarksVC animated:YES];
}

@end
