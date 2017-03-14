/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMShareTextAnnotationView.h"

@interface JMShareTextAnnotationView()
@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, assign) CGRect availableFrame;
@property (nonatomic, assign) UIEdgeInsets textEdgeInsets;

@end

@implementation JMShareTextAnnotationView

+ (instancetype)shareTextAnnotationWithText:(NSString *)text textColor:(UIColor *)color font:(UIFont *)font availableFrame:(CGRect)availableFrame
{
    JMShareTextAnnotationView *annotation = [JMShareTextAnnotationView new];
    annotation.backgroundColor = [UIColor clearColor];
    annotation.availableFrame = availableFrame;
    annotation.userInteractionEnabled = YES;
    annotation.textEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    
    annotation.textLabel = [[UILabel alloc] initWithFrame:annotation.bounds];
    annotation.textLabel.userInteractionEnabled = NO;
    annotation.textLabel.numberOfLines = 0;
    annotation.textLabel.textAlignment = NSTextAlignmentCenter;
    annotation.textLabel.backgroundColor = [UIColor clearColor];
    annotation.textLabel.textColor = color;
    annotation.textLabel.font = font;
    annotation.text = text;
    [annotation addSubview:annotation.textLabel];
    
    return annotation;
}

#pragma mark - Custom Accessories
- (NSString *)text
{
    return self.textLabel.text;
}

- (void)setText:(NSString *)text
{
    self.textLabel.text = text;
    [self updateFrame];
}

- (void)setBorders:(BOOL)borders
{
    _borders = borders;

    self.layer.cornerRadius = 4.f;
    self.layer.borderWidth = borders ? 1.f : 0;
    self.layer.borderColor = self.textLabel.textColor.CGColor;
}

#pragma mark - Private API
- (void)updateFrame
{
    CGRect textLabelFrame = CGRectMake(0, 0, CGRectGetWidth(self.availableFrame), CGRectGetHeight(self.availableFrame));
    self.textLabel.frame = UIEdgeInsetsInsetRect(textLabelFrame, self.textEdgeInsets);
    [self.textLabel sizeToFit];
    
    CGRect selfFrame = self.frame;
    selfFrame.size.height = ceil(CGRectGetHeight(self.textLabel.bounds) + self.textEdgeInsets.top + self.textEdgeInsets.bottom);
    selfFrame.size.width = ceil(CGRectGetWidth(self.textLabel.bounds) + self.textEdgeInsets.left + self.textEdgeInsets.right);
    self.frame = selfFrame;
}

@end
