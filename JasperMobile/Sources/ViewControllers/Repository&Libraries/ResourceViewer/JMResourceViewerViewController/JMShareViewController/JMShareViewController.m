//
//  JMShareViewController.m
//  TIBCO JasperMobile
//
//  Created by Oleksii Gubariev on 3/31/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMShareViewController.h"
#import "JMShareActivityItemProvider.h"
#import "JMShareSettingsViewController.h"
#import "JMMainNavigationController.h"

@interface JMShareViewController () <JMShareSettingsViewControllerDelegate>

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
    
    self.title = JMCustomLocalizedString(@"resource_viewer_share_title", nil);
    
    
    UIBarButtonItem *resetItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reset_action"] style:UIBarButtonItemStylePlain target:self action:@selector(resetButtonDidTapped:)];
    UIBarButtonItem *settingsItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings_action"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonDidTapped:)];
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share_action"] style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonDidTapped:)];

    UIBarButtonItem *dividerItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *dividerItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    
    self.toolbarItems = @[resetItem, dividerItem, settingsItem, dividerItem1, shareItem];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.toolbarHidden = NO;
}

#pragma mark - Actions
- (void)resetButtonDidTapped:(id)sender
{
    self.mainImageView.image = self.imageForSharing;
}

- (void)settingsButtonDidTapped:(id)sender
{
    JMShareSettingsViewController *settingsController = [self.storyboard instantiateViewControllerWithIdentifier:@"JMShareSettingsViewController"];
    settingsController.drawingColor = self.drawingColor;
    settingsController.brushWidth = self.brushWidth;
    settingsController.opacity = self.opacity;
    settingsController.delegate = self;
    
    JMMainNavigationController *nextNC = [[JMMainNavigationController alloc] initWithRootViewController:settingsController];
    
    nextNC.modalPresentationStyle = UIModalPresentationFormSheet;

    [self presentViewController:nextNC animated:YES completion:nil];
}

- (void)shareButtonDidTapped:(id)sender
{
    JMShareActivityItemProvider * textProvider = [[JMShareActivityItemProvider alloc] initWithPlaceholderItem:kSkypeActivityType];
    UIImage *imageForSharing = self.mainImageView.image;
    
    NSArray *objectsToShare = @[textProvider, imageForSharing];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSMutableArray *excludeActivities = [@[UIActivityTypePrint,
                                           UIActivityTypeCopyToPasteboard,
                                           UIActivityTypeAssignToContact,
                                           UIActivityTypeAddToReadingList,
                                           UIActivityTypeAirDrop] mutableCopy];
    if ([JMUtils isSystemVersion9]) {
        [excludeActivities addObject:UIActivityTypeOpenInIBooks];
    }
    
    activityVC.excludedActivityTypes = excludeActivities;
    activityVC.popoverPresentationController.barButtonItem = [self.toolbarItems lastObject];
    
    [self presentViewController:activityVC animated:YES completion:nil];    
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
    
    UIGraphicsBeginImageContextWithOptions(self.mainImageView.bounds.size, 0, self.mainImageView.image.scale);
    [self.mainImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    [self.tempDrawImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    self.mainImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    self.tempDrawImageView.image = nil;
    UIGraphicsEndImageContext();
}

#pragma mark - JMShareSettingsViewControllerDelegate
- (void)settingsDidChangedOnController:(JMShareSettingsViewController *)settingsController
{
    self.drawingColor = settingsController.drawingColor;
    self.brushWidth = settingsController.brushWidth;
    self.opacity = settingsController.opacity;

    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
