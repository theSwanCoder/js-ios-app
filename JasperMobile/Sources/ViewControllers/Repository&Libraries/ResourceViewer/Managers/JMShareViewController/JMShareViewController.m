/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMShareViewController.h"
#import "JMShareImageActivityItemProvider.h"
#import "JMShareSettingsViewController.h"
#import "JMMainNavigationController.h"

#import "UIView+Additions.h"
#import "UIAlertController+Additions.h"
#import "JMShareTextAnnotationView.h"
#import "JMLocalization.h"
#import "JMUtils.h"

@interface JMShareViewController () <JMShareSettingsViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *mainImageView;

@property (nonatomic, strong) UIButton *settingsButton;


@property (nonatomic, assign) CGPoint lastDrawingPoint;

@property (nonatomic, strong) UIColor *drawingColor;
@property (nonatomic, assign) CGFloat brushWidth;
@property (nonatomic, assign) CGFloat opacity;

@property (nonatomic, assign) BOOL borders;

@property (nonatomic, strong) UIFont *selectedFont;

@end

@implementation JMShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = JMLocalizedString(@"resource_viewer_share_title");
    
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share_action"] style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonDidTapped:)];
    
    self.navigationItem.rightBarButtonItem = shareItem;
    
    UIBarButtonItem *addTextItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add_text_action"] style:UIBarButtonItemStylePlain target:self action:@selector(addTextButtonDidTapped:)];
    UIBarButtonItem *settingsItem = [[UIBarButtonItem alloc] initWithCustomView:self.settingsButton];
    UIBarButtonItem *resetItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reset_action"] style:UIBarButtonItemStylePlain target:self action:@selector(resetButtonDidTapped:)];

    UIBarButtonItem *dividerItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *dividerItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.toolbarItems = @[addTextItem, dividerItem, settingsItem, dividerItem1, resetItem];
    
    [self setDefaults];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.toolbarHidden = NO;
}

- (void)setDefaults
{
    self.mainImageView.image = self.imageForSharing;
    self.drawingColor = [UIColor redColor];
    self.brushWidth = 10.f;
    self.opacity = 1.f;
    self.selectedFont = [UIFont systemFontOfSize:16];
    self.borders = YES;
}

#pragma mark - Custom Accessories
- (UIButton *)settingsButton
{
    if (!_settingsButton) {
        CGFloat toolbarHeight = CGRectGetHeight(self.navigationController.toolbar.bounds);
        _settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, toolbarHeight - 8)];
        _settingsButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _settingsButton.layer.cornerRadius = 4.f;
        [_settingsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_settingsButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_settingsButton addTarget:self action:@selector(settingsButtonDidTapped:) forControlEvents:UIControlEventTouchUpInside];

        // Configure shadow
        _settingsButton.layer.masksToBounds = NO;
        _settingsButton.layer.shadowOffset = CGSizeZero;
        _settingsButton.layer.shadowOpacity = 1.f;
        _settingsButton.layer.shadowRadius = 4.f;
        
        // Configure title label
        _settingsButton.titleLabel.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.6];
        _settingsButton.titleLabel.font = [UIFont systemFontOfSize:15];
        _settingsButton.titleLabel.layer.cornerRadius = 5.f;
        _settingsButton.titleLabel.layer.masksToBounds = YES;
    }
    return _settingsButton;
}

- (void)setBrushWidth:(CGFloat)brushWidth
{
    _brushWidth = brushWidth;
    NSString *settingsButtonTitle = [NSString stringWithFormat:@"  %dpx  ", (int)round(brushWidth)];
    [_settingsButton setTitle:settingsButtonTitle forState:UIControlStateNormal];
}

- (void)setDrawingColor:(UIColor *)drawingColor
{
    _drawingColor = drawingColor;
    [_settingsButton setBackgroundColor:drawingColor];
    _settingsButton.layer.shadowColor = drawingColor.CGColor;
}

#pragma mark - Actions
- (void)addTextButtonDidTapped:(id)sender
{
    [self editTextAnnotation:nil fromPoint:self.mainImageView.center];
}

- (void)resetButtonDidTapped:(id)sender
{
    @synchronized (self.mainImageView) {
        [self.mainImageView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        self.mainImageView.layer.sublayers = nil;
    }
}

- (void)settingsButtonDidTapped:(id)sender
{
    JMShareSettingsViewController *settingsController = [self.storyboard instantiateViewControllerWithIdentifier:@"JMShareSettingsViewController"];
    settingsController.drawingColor = self.drawingColor;
    settingsController.brushWidth = self.brushWidth;
    settingsController.opacity = self.opacity;
    settingsController.selectedFont = self.selectedFont;
    settingsController.borders = self.borders;
    settingsController.delegate = self;

    JMMainNavigationController *nextNC = [[JMMainNavigationController alloc] initWithRootViewController:settingsController];
    nextNC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:nextNC animated:YES completion:nil];
}

- (void)shareButtonDidTapped:(id)sender
{
    UIImage *imageForSharing = [self.mainImageView renderedImage];
    
    JMShareImageActivityItemProvider * imageProvider = [[JMShareImageActivityItemProvider alloc] initWithImage:imageForSharing];

    NSArray *objectsToShare = @[imageProvider];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSMutableArray *excludeActivities = [@[UIActivityTypePrint,
                                           UIActivityTypeCopyToPasteboard,
                                           UIActivityTypeAssignToContact,
                                           UIActivityTypeAddToReadingList,
                                           UIActivityTypeAirDrop] mutableCopy];
    if ([JMUtils isSystemVersionEqualOrUp9]) {
        [excludeActivities addObject:UIActivityTypeOpenInIBooks];
    }
    
    activityVC.excludedActivityTypes = excludeActivities;
    activityVC.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    
    [self presentViewController:activityVC animated:YES completion:nil];    
}

- (IBAction)addTextRecognizerDidTouched:(UILongPressGestureRecognizer *)sender
{
    CGPoint touchPoint = [sender locationInView:sender.view];
    [self editTextAnnotation:nil fromPoint:touchPoint];
}

#pragma mark - Text Annotations

- (void) editTextAnnotation:(JMShareTextAnnotationView *)annotation fromPoint:(CGPoint)point
{
    __weak typeof(self)weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertTextDialogueControllerWithLocalizedTitle:@"resource_viewer_share_annotation_title"
                                                                                                  message:nil
                                                                            textFieldConfigurationHandler:^(UITextField * _Nonnull textField) {
                                                                                textField.placeholder = JMLocalizedString(@"resource_viewer_share_annotation_placeholder");
                                                                                textField.text = annotation.text;
                                                                            } textValidationHandler:^NSString * _Nonnull(NSString * _Nullable text) {
                                                                                NSString *errorMessage = nil;
                                                                                if (!text.length) {
                                                                                    errorMessage = JMLocalizedString(@"resource_viewer_share_annotation_empty_error");
                                                                                }
                                                                                return errorMessage;
                                                                            } textEditCompletionHandler:^(NSString * _Nullable text) {
                                                                                __strong typeof(self) strongSelf = weakSelf;
                                                                                if (annotation) {
                                                                                    annotation.text = text;
                                                                                } else {
                                                                                    [strongSelf addTextAnnotationWithText:text fromPoint:point];
                                                                                }
                                                                            }];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) addTextAnnotationWithText:(NSString *)text fromPoint:(CGPoint)point
{
    JMShareTextAnnotationView *annotation = [JMShareTextAnnotationView shareTextAnnotationWithText:text textColor:self.drawingColor font:self.selectedFont availableFrame:self.mainImageView.bounds];
    [annotation addTarget:self action:@selector(annotationViewEdit:withEvent:) forControlEvents:UIControlEventTouchDownRepeat];
    [annotation addTarget:self action:@selector(annotationViewMoved:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    
    annotation.center = point;
    annotation.borders = self.borders;
    [self.mainImageView addSubview:annotation];
}

- (void)annotationViewEdit:(JMShareTextAnnotationView *)annotationView withEvent:(UIEvent *)event
{
    [self editTextAnnotation:annotationView fromPoint:CGPointZero];
}

- (void)annotationViewMoved:(JMShareTextAnnotationView *)annotationView withEvent:(UIEvent *)event
{
    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
    annotationView.center = point;
}

#pragma mark - Touches
- (CGPoint)locationFromTouches:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
    return [touch locationInView:self.view];
}

- (void)drawLineFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    CALayer *layer = [self.mainImageView.layer.sublayers lastObject];
    CALayer *copyLayer = [CALayer layer];
    copyLayer.contents = layer.contents;
    copyLayer.frame = layer.frame;
    
    UIGraphicsBeginImageContext(self.view.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [copyLayer renderInContext:context];
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, self.brushWidth);
    CGContextSetStrokeColorWithColor(context, self.drawingColor.CGColor);
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    CGContextStrokePath(context);
    
    layer.contents = (__bridge id _Nullable)(UIGraphicsGetImageFromCurrentImageContext().CGImage);
    UIGraphicsEndImageContext();
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    self.lastDrawingPoint = [touch locationInView:self.view];
    CALayer *layer = [CALayer layer];
    layer.frame = self.mainImageView.bounds;
    layer.opacity = self.opacity;
    [self.mainImageView.layer addSublayer:layer];
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
}

#pragma mark - JMShareSettingsViewControllerDelegate
- (void)settingsDidChangedOnController:(JMShareSettingsViewController *)settingsController
{
    self.drawingColor = settingsController.drawingColor;
    self.brushWidth = settingsController.brushWidth;
    self.opacity = settingsController.opacity;
    self.selectedFont = settingsController.selectedFont;
    self.borders = settingsController.borders;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end
