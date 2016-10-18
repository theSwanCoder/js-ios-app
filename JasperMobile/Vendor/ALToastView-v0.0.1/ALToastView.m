//
//  ALToastView.h
//
//  Created by Alex Leutgöb on 17.07.11.
//  Copyright 2011 alexleutgoeb.com. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

//
//  Modified by Vlad Zavadskii vzavadskii@jaspersoft.com on 14.02.14.
//  Modified by Aleksey Gubarev ogubarie@tibco.com on 14.02.14.
//  Modified by Aleksey Gubarev ogubarie@tibco.com on 18.10.16.
//

#import <QuartzCore/QuartzCore.h>
#import "ALToastView.h"


// Set visibility duration
static const CGFloat kDuration = 2;


// Static toastview queue variable
static NSMutableArray *toasts;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@interface ALToastView ()

@property (nonatomic, readonly) UILabel *textLabel;

- (void)fadeToastOut;
+ (void)nextToast;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation ALToastView

@synthesize textLabel = _textLabel;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)initWithText:(NSString *)text {
	if ((self = [self initWithFrame:CGRectZero])) {
		// Add corner radius
		self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.8];
		self.layer.cornerRadius = 5;
		self.autoresizingMask = UIViewAutoresizingNone;
		self.autoresizesSubviews = NO;
		
		// Init and add label
        CGFloat maxWidth = [UIScreen mainScreen].applicationFrame.size.width - 10*2;
		_textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, maxWidth, MAXFLOAT)];
        _textLabel.numberOfLines = 2;
        _textLabel.textAlignment = NSTextAlignmentCenter;
		_textLabel.text = text;
		_textLabel.font = [UIFont systemFontOfSize:15];
		_textLabel.textColor = [UIColor whiteColor];
		_textLabel.adjustsFontSizeToFitWidth = NO;
		_textLabel.backgroundColor = [UIColor clearColor];
		[_textLabel sizeToFit];

		[self addSubview:_textLabel];
		_textLabel.frame = CGRectOffset(_textLabel.frame, 10, 5);
	}
	
	return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

+ (void)toastInView:(UIView *)parentView withText:(NSString *)text {
	// Add new instance to queue
	ALToastView *view = [[ALToastView alloc] initWithText:text];
    
	CGFloat lWidth = view.textLabel.frame.size.width;
	CGFloat lHeight = view.textLabel.frame.size.height;
	CGFloat pWidth = parentView.frame.size.width;
	CGFloat pHeight = parentView.frame.size.height;
	
	// Change toastview frame
    view.frame = CGRectMake(ceil((pWidth - lWidth - 20) / 2), pHeight - lHeight - 60, lWidth + 20, lHeight + 10);
	view.alpha = 0.0f;
    
    // Setup toast view Accessibility
    view.isAccessibilityElement = YES;
    view.accessibilityLabel = text;
    view.accessibilityIdentifier = JMToastViewAccessibilityId;
    
    if (!toasts) {
        toasts = [[NSMutableArray alloc] initWithCapacity:1];
    }
    [toasts addObject:@{@"view": view, @"parentView": parentView}];

	if ([toasts count] == 1) {
		[ALToastView nextToast];
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

- (void)fadeToastOut {
	// Fade in parent view
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.alpha = 0.f;
                     }
                     completion:^(BOOL finished){
                         // Remove current view
                         [self removeFromSuperview];
                         [toasts removeObjectAtIndex:0];
                         // Show next toast
                         [ALToastView nextToast];
                     }];
}

+ (void)nextToast{
	if ([toasts count] > 0) {
        ALToastView *view = [[toasts objectAtIndex:0] objectForKey:@"view"];
        UIView *parentView = [[toasts objectAtIndex:0] objectForKey:@"parentView"];
        
        if (parentView.superview) {
            // Fade into parent view
            [parentView addSubview:view];
            [UIView animateWithDuration:.5  delay:0 options:UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                                 view.alpha = 1.0;
                             } completion:^(BOOL finished){}];
            
            // Start timer for fade out
            [view performSelector:@selector(fadeToastOut) withObject:nil afterDelay:kDuration];
        } else {
            // Show next toast
            [view performSelector:@selector(fadeToastOut) withObject:nil afterDelay:0];
        }
    }
}

@end
