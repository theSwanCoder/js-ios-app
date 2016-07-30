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
//  JMTextField.h
//  TIBCO JasperMobile
//

#import "JMTextField.h"
#import "JMThemesManager.h"

@implementation JMTextField

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = [[JMThemesManager sharedManager] textFieldBackgroundColor];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    self.textColor = enabled ? [[JMThemesManager sharedManager] textFieldEditableTextColor] : [[JMThemesManager sharedManager] textFieldUnEditableTextColor];
}

- (void)setPlaceholder:(NSString *)placeholder
{
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[self.textColor colorWithAlphaComponent: 0.5f]};
    [self setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:placeholder attributes:attributes]];
}

- (void)setTextColor:(UIColor *)textColor
{
    [super setTextColor:textColor];
    if (self.placeholder && self.placeholder.length) {
        self.placeholder = self.placeholder;
    }
}
@end
