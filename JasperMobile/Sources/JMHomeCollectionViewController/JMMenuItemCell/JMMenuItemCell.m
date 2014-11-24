/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
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


#import "JMMenuItemCell.h"

// Localization keys defined as lowercase version of MenuItem identifier (e.g library, saveditems etc)
NSString * const kJMMenuItemLibrary = @"Library";
NSString * const kJMMenuItemSettings = @"Settings";
NSString * const kJMMenuItemRepository = @"Repository";
NSString * const kJMMenuItemSavedItems = @"SavedItems";
NSString * const kJMMenuItemFavorites = @"Favorites";

@interface JMMenuItemCell()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIView *coloredView;
@end

@implementation JMMenuItemCell

-(void)setMenuItem:(NSString *)menuItem
{
    _menuItem = menuItem;
    self.coloredView.backgroundColor = [menuItem isEqualToString:[kJMMenuItemSettings lowercaseString]] ? kJMMasterResourceCellSelectedBackgroundColor : kJMResourcePreviewBackgroundColor;
    self.imageView.image = [UIImage imageNamed:menuItem];

    NSString *titleString = JMCustomLocalizedString([NSString stringWithFormat:@"home.menuitem.%@.label", self.menuItem], nil);
    NSMutableAttributedString *attributedTitleString = [[NSMutableAttributedString alloc] initWithString:titleString attributes:self.titleAttributes];
    if (![JMUtils isIphone]) {
        NSString *descriptionString = [NSString stringWithFormat:@"\n%@",JMCustomLocalizedString([NSString stringWithFormat:@"home.menuitem.%@.description", self.menuItem], nil)];
        [attributedTitleString appendAttributedString:[[NSAttributedString alloc] initWithString:descriptionString attributes:self.descriptionAttributes]];
    }

    self.titleLabel.attributedText = attributedTitleString;
}

- (NSDictionary *)titleAttributes
{
    return @{NSForegroundColorAttributeName:[UIColor darkGrayColor], NSFontAttributeName:[JMFont menuItemTitleFont]};
}

- (NSDictionary *)descriptionAttributes
{
    return @{NSForegroundColorAttributeName:[UIColor lightGrayColor], NSFontAttributeName:[JMFont menuItemDescriptionFont]};
}

@end