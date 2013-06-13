//
//  UITableViewController+CellRelativeHeight.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/11/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#define kJMTextPadding 26
#define kJMTextLabelWidthGrouped 67
#define kJMTextLabelWidthPlain 91
#define kJMTextPaddingAfterHeightCalculation 10
#define kJMDisclosureIndicatorWidth 20

#import "UITableViewController+CellRelativeHeight.h"

@implementation UITableViewController (CellRelativeHeight)

#pragma mark - CellRelativeHeight

- (CGFloat)relativeHeightForTableViewCell:(UITableViewCell *)cell text:(NSString *)text detailText:(NSString *)detailText cellStyle:(UITableViewCellStyle)cellStyle
{    
    CGFloat width,
            height = 0;
    CGSize textSize,
           detailTextSize;
    
    // Calculate height depends on cell style
    if (cellStyle == UITableViewCellStyleValue2) {
        // Calculate width for textLabel (this label used as a title)
        CGFloat textLabelWidth = self.tableView.style == UITableViewStyleGrouped ? kJMTextLabelWidthGrouped : kJMTextLabelWidthPlain;
        // Calculate width for detailTextLabel (this label used as a description)
        width = [self contentWidthForTableViewCell:cell] - textLabelWidth;
        // Calculate size of text for textLabel 
        textSize = [text sizeWithFont:cell.textLabel.font constrainedToSize:CGSizeMake(textLabelWidth, CGFLOAT_MAX)];
        // Calculate size of details text for detailTextLabel
        detailTextSize = [detailText sizeWithFont:cell.detailTextLabel.font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)];
        // Check what label has bigger height (this is necessary only for UITableViewCellStyleValue2 cell style
        // where 2 labels locates on the same line)
        height = textSize.height > detailTextSize.height ? textSize.height : detailTextSize.height;
    } else if (cellStyle == UITableViewCellStyleSubtitle) {
        // Calculate width for whole cell
        width = [self contentWidthForTableViewCell:cell];
        textSize = [text sizeWithFont:cell.textLabel.font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)];
        detailTextSize = [detailText sizeWithFont:cell.detailTextLabel.font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)];
        // For UITableViewCellStyleSubtitle cell style new height equals sum of labels height
        // (detailTextLabel locates under textLabel)
        height = textSize.height + detailTextSize.height;
    } else if (cellStyle == UITableViewCellStyleDefault) {
        width = [self contentWidthForTableViewCell:cell];
        textSize = [text sizeWithFont:cell.textLabel.font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)];
        // For UITableViewCellStyleDefault cell style we don't have detailTextLabel at all so
        // we can ignore it
        height = textSize.height;
    }
    
    return height > [self defaultHeightForTableViewCell] ? height + kJMTextPaddingAfterHeightCalculation : [self defaultHeightForTableViewCell];
}

#pragma mark - Private

- (CGFloat)defaultHeightForTableViewCell
{
    static CGFloat height = 0.0f;
    if (height == 0.0f) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        height = cell.frame.size.height;
    }
    
    return height;
}

- (CGFloat)leftMarginForTableView
{
    if (self.tableView.style != UITableViewStyleGrouped) return 0.0f;
    CGFloat widthTable = self.tableView.bounds.size.width;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) return (10.0f);
    if (widthTable <= 400.0f) return (10.0f);
    if (widthTable <= 546.0f) return (31.0f);
    if (widthTable >= 720.0f) return (45.0f);
    return (31.0f + ceilf((widthTable - 547.0f) / 13.0f));
}

- (CGFloat)contentWidthForTableViewCell:(UITableViewCell *)cell;
{
    // Calclating width can be done only by using self.tableView.frame instead cell.contentView.frame
    // because contentView.frame depends on rotation, accessory views, cell initialization etc
    CGFloat width = self.tableView.frame.size.width - kJMTextPadding - [self leftMarginForTableView] * 2;
    // Check if cell has disclosure indicator
    if (cell.accessoryType != UITableViewCellAccessoryNone) {
        width -= kJMDisclosureIndicatorWidth;
    }
    
    return width;
}

@end
