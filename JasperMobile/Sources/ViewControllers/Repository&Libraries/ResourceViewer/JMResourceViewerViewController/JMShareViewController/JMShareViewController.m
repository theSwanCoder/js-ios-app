//
//  JMShareViewController.m
//  TIBCO JasperMobile
//
//  Created by Oleksii Gubariev on 3/31/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMShareViewController.h"

@interface JMShareViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *mainImageView;
@property (nonatomic, weak) IBOutlet UIImageView *tempDrawImageView;

@property (nonatomic, assign) CGPoint lastDrawingPoint;

@property (nonatomic, strong) UIColor *drawingColor;
@property (nonatomic, assign) CGFloat brushWidth;
@property (nonatomic, assign) CGFloat opacity;

@end

@implementation JMShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mainImageView.image = self.imageForSharing;
    self.drawingColor = [UIColor redColor];
    self.brushWidth = 10.f;
    self.opacity = 1.f;
    
    self.title = JMCustomLocalizedString(@"resource.sharing.title", nil);
    
    
    UIBarButtonItem *resetItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:nil action:nil];
    UIBarButtonItem *settingsItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:nil action:nil];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:nil action:nil];

    UIBarButtonItem *dividerItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *dividerItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    
    self.toolbarItems = @[resetItem, dividerItem, settingsItem, dividerItem1, doneItem];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.toolbarHidden = NO;
}

#pragma mark - Touches
- (CGPoint)locationFromTouches:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
    return [touch locationInView:self.view];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    self.lastDrawingPoint = [touch locationInView:self.view];
}

- (void)drawLineFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.tempDrawImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), self.brushWidth);
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), self.drawingColor.CGColor);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), startPoint.x, startPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), endPoint.x, endPoint.y);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.tempDrawImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.tempDrawImageView setAlpha:self.opacity];
    UIGraphicsEndImageContext();
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint currentPoint = [self locationFromTouches:touches];
    [self drawLineFromPoint:self.lastDrawingPoint toPoint:currentPoint];
    
    self.lastDrawingPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint currentPoint = [self locationFromTouches:touches];
    [self drawLineFromPoint:self.lastDrawingPoint toPoint:currentPoint];
    
    UIGraphicsBeginImageContext(self.mainImageView.bounds.size);
    [self.mainImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.tempDrawImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    self.mainImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    self.tempDrawImageView.image = nil;
    UIGraphicsEndImageContext();
}
@end
