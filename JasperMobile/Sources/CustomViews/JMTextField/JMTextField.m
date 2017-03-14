/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


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
