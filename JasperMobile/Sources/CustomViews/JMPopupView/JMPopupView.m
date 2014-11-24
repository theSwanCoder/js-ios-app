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

#import "JMPopupView.h"
#import <QuartzCore/QuartzCore.h>

NSInteger const kJMPopupViewContentMaxHeight = 260.f;
NSInteger const kJMPopupViewDefaultWidth = 260.f;
NSInteger const kJMPopupViewButtonsHeight = 35.f;

static NSMutableArray* visiblePopupsArray = nil;

@interface JMPopupView ()

@property (nonatomic, assign) BOOL animatedNow;
@end

@implementation JMPopupView
@synthesize contentView = _contentView;

- (id)initWithDelegate:(id<JMPopupViewDelegate>)delegate type:(JMPopupViewType)type{
    self = [super init];
    if (self) {
        if (!visiblePopupsArray) {
            visiblePopupsArray = [NSMutableArray array];
        }
        self.delegate = delegate;
        _type = type;
        
        [visiblePopupsArray addObject:self];
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kJMPopupViewDefaultWidth, kJMPopupViewButtonsHeight)];
        _backGroundView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        _backGroundView.backgroundColor = [kJMSearchBarBackgroundColor colorWithAlphaComponent:0.98f];
        _backGroundView.layer.borderColor = [UIColor whiteColor].CGColor;
        _backGroundView.layer.borderWidth = 1.f;
        _backGroundView.layer.masksToBounds = NO;
        
        if (type == JMPopupViewType_OkCancelButtons) {
            UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kJMPopupViewDefaultWidth / 2, kJMPopupViewButtonsHeight)];
            [cancelButton setTitle:JMCustomLocalizedString(@"dialog.button.cancel", nil) forState:UIControlStateNormal];
            cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
            [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            [cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            cancelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
            [_backGroundView addSubview:cancelButton];
            
            UIButton *okButton = [[UIButton alloc] initWithFrame:CGRectMake(kJMPopupViewDefaultWidth / 2, 0, kJMPopupViewDefaultWidth / 2, kJMPopupViewButtonsHeight)];
            [okButton setTitle:JMCustomLocalizedString(@"dialog.button.ok", nil) forState:UIControlStateNormal];
            okButton.titleLabel.font = [UIFont systemFontOfSize:15];
            [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [okButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            [okButton addTarget:self action:@selector(okButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            okButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
            [_backGroundView addSubview:okButton];
            
            UIView *horizontalSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kJMPopupViewDefaultWidth, 1.f)];
            horizontalSeparatorView.backgroundColor = [UIColor grayColor];
            horizontalSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
            [_backGroundView addSubview:horizontalSeparatorView];
            
            UIView *verticalSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(kJMPopupViewDefaultWidth / 2, 0, 1.f ,kJMPopupViewButtonsHeight)];
            verticalSeparatorView.backgroundColor = [UIColor grayColor];
            verticalSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
            [_backGroundView addSubview:verticalSeparatorView];
        }

        [self addSubview:_backGroundView];
    }
    return self;
}

+ (BOOL)isShowedPopup{
    if ([visiblePopupsArray count]) {
        return YES;
    }
    return NO;
}

- (void)setContentView:(UIView *)contentView{
    _contentView = contentView;
    switch (self.type) {
        case JMPopupViewType_ContentViewOnly:
            _backGroundView.frame = _contentView.bounds;
            break;
        case JMPopupViewType_OkCancelButtons:
            _backGroundView.frame = CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height + kJMPopupViewButtonsHeight);
            break;
    }
    _contentView.center = CGPointMake(contentView.frame.size.width / 2, contentView.frame.size.height / 2);
    [_backGroundView addSubview:_contentView];
}

- (void) show{
    [self showFromPoint:CGPointZero onView:nil];
}

- (void) showFromPoint:(CGPoint)point onView:(UIView*)view{
    if (self.animatedNow) {
        return;
    }
    UIView* topView = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
    self.frame = topView.bounds;
    [topView addSubview:self];
    
    CGPoint centerPoint = self.center;
    if (view) {
        centerPoint = [self convertPoint:point fromView:view];
        if (centerPoint.y < _backGroundView.frame.size.height / 2) {
            centerPoint.y = _backGroundView.frame.size.height / 2;
        }
        if (centerPoint.y > self.frame.size.height - _backGroundView.frame.size.height / 2) {
            centerPoint.y = self.frame.size.height - _backGroundView.frame.size.height / 2;
        }
        if (centerPoint.x < _backGroundView.frame.size.width / 2) {
            centerPoint.x = _backGroundView.frame.size.width / 2;
        }
        if (centerPoint.x > self.frame.size.width - _backGroundView.frame.size.width / 2) {
            centerPoint.x = self.frame.size.width - _backGroundView.frame.size.width / 2;
        }
    }
    
    _backGroundView.center = centerPoint;
    
    //Add a tap gesture recognizer to the large invisible view (self), which will detect taps anywhere on the screen.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    tap.cancelsTouchesInView = NO; // Allow touches through to a UITableView or other touchable view, as suggested by Dimajp.
    [self addGestureRecognizer:tap];
    self.userInteractionEnabled = YES;
    
    // Make the view small and transparent before animation
    _backGroundView.alpha = 0.f;
    _backGroundView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(popupViewWillShow:)]) {
        [self.delegate popupViewWillShow:self];
    }
    self.animatedNow = YES;
    // animate into full size
    [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _backGroundView.alpha = 1.f;
        _backGroundView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.08f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _backGroundView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            self.animatedNow = NO;
            if (self.delegate && [self.delegate respondsToSelector:@selector(popupViewDidShow:)]) {
                [self.delegate popupViewDidShow:self];
            }
        }];
    }];
}

#pragma -
#pragma mark - Actions

- (void)okButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(popupViewDidApplied:)]) {
        [self.delegate popupViewDidApplied:self];
    }
    [self dismiss:YES];
}

- (void)cancelButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(popupViewDidCanceled:)]) {
        [self.delegate popupViewDidCanceled:self];
    }
    [self dismiss:YES];
}

- (void)tapped:(UITapGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:_backGroundView];
    BOOL found = NO;
    
    if (!found && CGRectContainsPoint(_backGroundView.bounds, point)) {
        found = YES;
    }
    
    if (!found) {
        [self dismiss:YES];
    }
}

- (IBAction) dismissByValueChanged
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(popupViewValueDidChanged:)]) {
        [self.delegate popupViewValueDidChanged:self];
    }
    [self dismiss:YES];
}

- (void)dismiss
{
    [self dismiss:YES];
}

- (void)dismiss:(BOOL)animated
{
    if (self.animatedNow) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(popupViewWillDismissed:)]) {
        [self.delegate popupViewWillDismissed:self];
    }
    if (!animated) {
        [self removeFromSuperview];
        if (self.delegate && [self.delegate respondsToSelector:@selector(popupViewDidDismissed:)]) {
            [self.delegate popupViewDidDismissed:self];
        }
    } else {
        self.animatedNow = YES;
        [UIView animateWithDuration:0.3f animations:^{
            _backGroundView.alpha = 0.1f;
            _backGroundView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            self.animatedNow = NO;
            if (self.delegate && [self.delegate respondsToSelector:@selector(popupViewDidDismissed:)]) {
                [self.delegate popupViewDidDismissed:self];
            }
        }];
    }
    [visiblePopupsArray removeObject:self];
}

+ (void)dismissAllVisiblePopups:(BOOL)animated{
    for (JMPopupView* popup in visiblePopupsArray) {
        [popup dismiss:animated];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    size_t locationsCount = 2;
    CGFloat locations[2] = {0.0f, 1.0f};
    CGFloat colors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
    CGColorSpaceRelease(colorSpace);
    
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    float radius = MIN(self.bounds.size.width , self.bounds.size.height) ;
    CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
}
@end
