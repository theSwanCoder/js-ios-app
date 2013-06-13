//
//  UITableViewController+CellRelativeHeight.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/11/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewController (CellRelativeHeight)

/**
 Calculates height for table view cell according to amount of text inside cell.
 Works only for cell with UITableViewCellStyleValue2, UITableViewCellStyleSubtitle or
 UITableViewCellStyleDefault style
 
 @param cell A table view cell
 @param text A text for "textLabel"
 @param detailText A text for "detailTextLabel"
 @param cellStyle The style of table view cell
 */
- (CGFloat)relativeHeightForTableViewCell:(UITableViewCell *)cell text:(NSString *)text detailText:(NSString *)detailText cellStyle:(UITableViewCellStyle)cellStyle;

@end
