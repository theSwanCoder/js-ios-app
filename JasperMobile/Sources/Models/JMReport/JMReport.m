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


//
//  JMReport.h
//  TIBCO JasperMobile
//

#import "JMReport.h"
#import "JMReportBookmark.h"
#import "JMReportPart.h"

NSString * __nonnull const JMReportBookmarksDidUpdateNotification = @"JMReportBookmarksDidUpdateNotification";

@implementation JMReport

- (void)setBookmarks:(NSArray<JMReportBookmark *> *)bookmarks
{
    JMReportBookmark *selectedBookmark = [self findSelectedBookmark];

    if (selectedBookmark) {
        // select bookmark in new array
        for (JMReportBookmark *bookmark in bookmarks) {
            if ([bookmark.anchor isEqualToString:selectedBookmark.anchor]) {
                bookmark.selected = YES;
                break;
            }
        }
    }

    _bookmarks = bookmarks;
    [[NSNotificationCenter defaultCenter] postNotificationName:JMReportBookmarksDidUpdateNotification
                                                        object:self];
}

#pragma mark - Public API
- (JMReportBookmark *)findSelectedBookmark
{
    // find selected bookmark if there is
    JMReportBookmark *selectedBookmark;
    for (JMReportBookmark *bookmark in self.bookmarks) {
        if (bookmark.isSelected) {
            selectedBookmark = bookmark;
            break;
        }
    }
    return selectedBookmark;
}

- (void)markBookmarkAsSelected:(JMReportBookmark *)selectedBookmark
{
    for (JMReportBookmark *bookmark in self.bookmarks) {
        bookmark.selected = NO;
    }
    selectedBookmark.selected = YES;
}

@end
