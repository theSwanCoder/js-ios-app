/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMBookmarksVC.h"
#import "JMBookmarkTableViewCell.h"
#import "JSReportBookmark.h"
#import "JMLocalization.h"

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
