//
//  JMShareSettingsViewController.m
//  TIBCO JasperMobile
//
//  Created by Oleksii Gubariev on 4/1/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMShareSettingsViewController.h"

@interface JMShareSettingsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *brushTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *brushValueLabel;
@property (weak, nonatomic) IBOutlet UISlider *brushSlider;

@property (weak, nonatomic) IBOutlet UILabel *opacityTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *opacityValueLabel;
@property (weak, nonatomic) IBOutlet UISlider *opacitySlider;

@property (weak, nonatomic) IBOutlet UIImageView *colorPreviewImageView;

@property (weak, nonatomic) IBOutlet UILabel *rgbPaletteTitleLabel;
@property (weak, nonatomic) IBOutlet UISlider *redSlider;
@property (weak, nonatomic) IBOutlet UILabel *redValueLabel;
@property (weak, nonatomic) IBOutlet UISlider *greenSlider;
@property (weak, nonatomic) IBOutlet UILabel *greenValueLabel;
@property (weak, nonatomic) IBOutlet UISlider *blueSlider;
@property (weak, nonatomic) IBOutlet UILabel *blueValueLabel;


@property (nonatomic, assign) CGFloat redComponent;
@property (nonatomic, assign) CGFloat greenComponent;
@property (nonatomic, assign) CGFloat blueComponent;

@end

@implementation JMShareSettingsViewController
@dynamic drawingColor;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = JMCustomLocalizedString(@"resource_viewer_share_settings_title", nil);
    self.opacityTitleLabel.text = JMCustomLocalizedString(@"resource_viewer_share_settings_opacity", nil);
    self.brushTitleLabel.text = JMCustomLocalizedString(@"resource_viewer_share_settings_brush", nil);
    self.rgbPaletteTitleLabel.text = JMCustomLocalizedString(@"resource_viewer_share_settings_rgb", nil);


    self.brushSlider.value = self.brushWidth;
    [self sliderValueChanged:self.brushSlider];
    
    self.opacitySlider.value = self.opacity;
    [self sliderValueChanged:self.opacitySlider];
    
    int redIntValue = self.redComponent * 255.0;
    self.redSlider.value = redIntValue;
    [self sliderValueChanged:self.redSlider];

    int greenIntValue = self.greenComponent * 255.0;
    self.greenSlider.value = greenIntValue;
    [self sliderValueChanged:self.greenSlider];

    int blueIntValue = self.blueComponent * 255.0;
    self.blueSlider.value = blueIntValue;
    [self sliderValueChanged:self.blueSlider];
}

#pragma mark - Custom Accessors
- (UIColor *)drawingColor
{
    return [UIColor colorWithRed:self.redComponent green:self.greenComponent blue:self.blueComponent alpha:1.f];
}

- (void)setDrawingColor:(UIColor *)drawingColor
{
    [drawingColor getRed:&_redComponent green:&_greenComponent blue:&_blueComponent alpha:nil];
}

#pragma mark - Actions
- (IBAction)applyButtonDidTapped:(id)sender
{
    [self.delegate settingsDidChangedOnController:self];
}

- (IBAction)cancelButtonDidTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sliderValueChanged:(id)sender
{
    UISlider * changedSlider = (UISlider*)sender;
    
    if(changedSlider == self.brushSlider) {
        self.brushWidth = self.brushSlider.value;
        self.brushValueLabel.text = [NSString stringWithFormat:@"%.1f", self.brushWidth];
    } else if(changedSlider == self.opacitySlider) {
        self.opacity = self.opacitySlider.value;
        self.opacityValueLabel.text = [NSString stringWithFormat:@"%.1f", self.opacity];
    } else if(changedSlider == self.redSlider) {
        self.redComponent = self.redSlider.value/255.0;
        self.redValueLabel.text = [NSString stringWithFormat:@"%@: %d", JMCustomLocalizedString(@"resource_viewer_share_settings_red", nil), (int)self.redSlider.value];
    } else if(changedSlider == self.greenSlider){
        self.greenComponent = self.greenSlider.value/255.0;
        self.greenValueLabel.text = [NSString stringWithFormat:@"%@: %d", JMCustomLocalizedString(@"resource_viewer_share_settings_green", nil), (int)self.greenSlider.value];
    } else if (changedSlider == self.blueSlider){
        self.blueComponent = self.blueSlider.value/255.0;
        self.blueValueLabel.text = [NSString stringWithFormat:@"%@: %d", JMCustomLocalizedString(@"resource_viewer_share_settings_blue", nil), (int)self.blueSlider.value];
    }
    
    UIGraphicsBeginImageContext(self.colorPreviewImageView.bounds.size);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(),self.brushWidth);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), self.redComponent, self.greenComponent, self.blueComponent, self.opacity);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), CGRectGetMidX(self.colorPreviewImageView.bounds), CGRectGetMidY(self.colorPreviewImageView.bounds));
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), CGRectGetMidX(self.colorPreviewImageView.bounds), CGRectGetMidY(self.colorPreviewImageView.bounds));
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.colorPreviewImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

@end
