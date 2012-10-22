/*
 * JasperMobile for iOS
 * Copyright (C) 2005 - 2012 Jaspersoft Corporation. All rights reserved.
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
//  JSUILoadingView.m
//
//  The code of this class derives from code created by Matt Gallagher on 12/04/09.
//  Copyright Matt Gallagher 2009. All rights reserved.
// 
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "JSUILoadingView.h"
#import <QuartzCore/QuartzCore.h>

//
// NewPathWithRoundRect
//
// Creates a CGPathRect with a round rect of the given radius.
//
CGPathRef NewPathWithRoundRect(CGRect rect, CGFloat cornerRadius) {
	//
	// Create the boundary path
	//
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL,
		rect.origin.x,
		rect.origin.y + rect.size.height - cornerRadius);

	// Top left corner
	CGPathAddArcToPoint(path, NULL,
		rect.origin.x,
		rect.origin.y,
		rect.origin.x + rect.size.width,
		rect.origin.y,
		cornerRadius);

	// Top right corner
	CGPathAddArcToPoint(path, NULL,
		rect.origin.x + rect.size.width,
		rect.origin.y,
		rect.origin.x + rect.size.width,
		rect.origin.y + rect.size.height,
		cornerRadius);

	// Bottom right corner
	CGPathAddArcToPoint(path, NULL,
		rect.origin.x + rect.size.width,
		rect.origin.y + rect.size.height,
		rect.origin.x,
		rect.origin.y + rect.size.height,
		cornerRadius);

	// Bottom left corner
	CGPathAddArcToPoint(path, NULL,
		rect.origin.x,
		rect.origin.y + rect.size.height,
		rect.origin.x,
		rect.origin.y,
		cornerRadius);

	// Close the path at the rounded rect
	CGPathCloseSubpath(path);
    
	return path;
}

@interface JSUILoadingView()

@property (nonatomic, retain) UIButton *cancelButton;
@property (nonatomic, retain) JSRESTBase *restClient;
@property (nonatomic, retain) id<JSRequestDelegate> delegate;
@property (nonatomic, copy) JSUILoadingViewCancelBLock cancelBlock;

@end

@implementation JSUILoadingView

static JSUILoadingView *sharedInstance = nil;

@synthesize cancelButton = _cancelButton;
@synthesize restClient = _restClient;
@synthesize delegate = _delegate;
@synthesize cancelBlock;

+ (void)showLoadingInView:(UIView *)view {
    if (sharedInstance != nil) return;
    
    sharedInstance = [[JSUILoadingView alloc] initWithFrame:view.window.bounds];
    [sharedInstance showInView: view.window];    
}

+ (void)showCancelableLoadingInView:(UIView *)view restClient:(JSRESTBase *)restClient
                           delegate:(id<JSRequestDelegate>)delegate cancelBlock:(JSUILoadingViewCancelBLock)theCancelBlock {
    if (sharedInstance != nil) return;    
    sharedInstance = [[JSUILoadingView alloc] initWithFrame:view.window.bounds 
                                                 restClient:restClient delegate:delegate cancelBlock:theCancelBlock];
    [sharedInstance showInView: view.window];
}

+ (void)hideLoadingView {
    if (sharedInstance == nil) return;
    [sharedInstance removeView];
    sharedInstance = nil;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.opaque = NO;
	self.autoresizingMask =
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
    
	const CGFloat DEFAULT_LABEL_WIDTH = 280.0;
	const CGFloat DEFAULT_LABEL_HEIGHT = 50.0;
	CGRect labelFrame = CGRectMake(0, 0, DEFAULT_LABEL_WIDTH, DEFAULT_LABEL_HEIGHT);
	UILabel *loadingLabel = [[UILabel alloc] initWithFrame:labelFrame];
	loadingLabel.text = NSLocalizedString(@"Loading...", nil);
	loadingLabel.textColor = [UIColor whiteColor];
	loadingLabel.backgroundColor = [UIColor clearColor];
	loadingLabel.textAlignment = UITextAlignmentCenter;
	loadingLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
	loadingLabel.autoresizingMask =
    UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleBottomMargin;
	
	[self addSubview:loadingLabel];
    
	UIActivityIndicatorView *activityIndicatorView =
    [[UIActivityIndicatorView alloc]
      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[self addSubview:activityIndicatorView];
	activityIndicatorView.autoresizingMask =
    UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleBottomMargin;
	[activityIndicatorView startAnimating];
	
	CGFloat totalHeight =
    loadingLabel.frame.size.height +
    activityIndicatorView.frame.size.height;
	labelFrame.origin.x = floor(0.5 * (frame.size.width - DEFAULT_LABEL_WIDTH)) + 30;
	labelFrame.origin.y = floor(0.5 * (frame.size.height - totalHeight));
	loadingLabel.frame = labelFrame;
	
	CGRect activityIndicatorRect = activityIndicatorView.frame;
	activityIndicatorRect.origin.x =
    0.5 * (frame.size.width - activityIndicatorRect.size.width) - 37;
	activityIndicatorRect.origin.y = floor(0.5 * (frame.size.height - totalHeight)) + 7;
	activityIndicatorView.frame = activityIndicatorRect;
    
    return self;
}

- (id)initWithFrame:(CGRect)frame restClient:(JSRESTBase *)restClient 
           delegate:(id<JSRequestDelegate>)delegate cancelBlock:(JSUILoadingViewCancelBLock)theCancelBlock {
    if (self = [self initWithFrame:frame]) {        
        CGFloat cancelWidth = 120;
        CGFloat cancelHeight = 35;
    
        self.restClient = restClient;
        self.delegate = delegate;
        self.cancelBlock = theCancelBlock;
        
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cancelButton.frame = CGRectMake(frame.size.width / 2 - cancelWidth / 2, 
                                        floor(0.75 * (frame.size.height - 140)),
                                        cancelWidth, cancelHeight);
        [self.cancelButton setTitle:nil forState:UIControlStateNormal];
        [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"Cancel.png"] forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.cancelButton];
    }
    
	return self;
    
}


// Cancel all requests by delegate
- (IBAction)cancel:(id)sender {
    if (self.restClient && self.delegate) {
        [self.restClient cancelRequestsWithDelegate:self.delegate];
    }
    
    [self removeView];
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    
    sharedInstance = nil;
}

- (void)showInView:(UIView *)view {
    [view addSubview:self];
    
	// Set up the fade-in animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
    
	[[view layer] addAnimation:animation forKey:@"layerAnimation"];
}

//
// removeView
//
// Animates the view out from the superview. As the view is removed from the
// superview, it will be released.
//
- (void)removeView {
	[self removeFromSuperview];

	// Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	
	[[self.window layer] addAnimation:animation forKey:@"layerAnimation"];
}

//
// drawRect:
//
// Draw the view.
//
- (void)drawRect:(CGRect)rect {
	
	// Center the rectanlge...
	
	rect.origin.y = rect.origin.y + (rect.size.height - 150)/2;
    
    if (self.cancelButton != nil) {
        rect.size.height = 160;
    } else {
        rect.size.height = 115;
    }
    
	rect.size.width -= 1;
	
	const CGFloat RECT_PADDING = 8.0;
	rect = CGRectInset(rect, RECT_PADDING, RECT_PADDING);
	
	const CGFloat ROUND_RECT_CORNER_RADIUS = 5.0;
	CGPathRef roundRectPath = NewPathWithRoundRect(rect, ROUND_RECT_CORNER_RADIUS);
	
	CGContextRef context = UIGraphicsGetCurrentContext();

	const CGFloat BACKGROUND_OPACITY = 0.75;
	CGContextSetRGBFillColor(context, 0, 0, 0, BACKGROUND_OPACITY);
	CGContextAddPath(context, roundRectPath);
	CGContextFillPath(context);

	const CGFloat STROKE_OPACITY = 0.25;
	CGContextSetRGBStrokeColor(context, 1, 1, 1, STROKE_OPACITY);
	CGContextAddPath(context, roundRectPath);
	CGContextStrokePath(context);    
}

@end
