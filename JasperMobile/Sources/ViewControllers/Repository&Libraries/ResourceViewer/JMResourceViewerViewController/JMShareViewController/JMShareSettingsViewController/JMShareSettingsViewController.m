//
//  JMShareSettingsViewController.m
//  TIBCO JasperMobile
//
//  Created by Oleksii Gubariev on 4/1/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMShareSettingsViewController.h"
#import "JMTextField.h"
#import "JMFontPickerView.h"

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

@property (weak, nonatomic) IBOutlet UILabel *fontSettingsLabel;
@property (weak, nonatomic) IBOutlet JMTextField *fontTextField;

@property (nonatomic, strong) JMFontPickerView *fontPickerView;

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
    self.fontSettingsLabel.text = JMCustomLocalizedString(@"resource_viewer_share_settings_font", nil);


    self.brushSlider.value = self.brushWidth;
    [self sliderValueChanged:self.brushSlider];
    
    self.opacitySlider.value = self.opacity;
    [self sliderValueChanged:self.opacitySlider];
    
    self.selectedFont = self.selectedFont;
    self.fontTextField.inputView = self.fontPickerView;
    self.fontTextField.inputAccessoryView = [self pickerToolbar];

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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.fontTextField resignFirstResponder];
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

- (void)setSelectedFont:(UIFont *)selectedFont
{
    _selectedFont = selectedFont;
    self.fontTextField.text = [NSString stringWithFormat:JMCustomLocalizedString(@"resource_viewer_share_settings_selected_font", nil), self.selectedFont.fontName, (int) self.selectedFont.pointSize];
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
        self.brushWidth = round(self.brushSlider.value);
        self.brushValueLabel.text = [NSString stringWithFormat:@"%dpx", (int)self.brushWidth];
    } else if(changedSlider == self.opacitySlider) {
        self.opacity = self.opacitySlider.value;
        self.opacityValueLabel.text = [NSString stringWithFormat:@"%d%%", (int)(self.opacity * 100)];
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
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context,self.brushWidth);
    CGContextSetRGBStrokeColor(context, self.redComponent, self.greenComponent, self.blueComponent, self.opacity);
    CGContextMoveToPoint(context, CGRectGetMidX(self.colorPreviewImageView.bounds), CGRectGetMidY(self.colorPreviewImageView.bounds));
    CGContextAddLineToPoint(context, CGRectGetMidX(self.colorPreviewImageView.bounds), CGRectGetMidY(self.colorPreviewImageView.bounds));
    CGContextStrokePath(context);

    self.colorPreviewImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

#pragma mark - Picker
- (JMFontPickerView *)fontPickerView
{
    if (!_fontPickerView) {
        _fontPickerView = [JMFontPickerView new];
        _fontPickerView.currentFont = self.selectedFont;
    }
    return _fontPickerView;
}

- (UIToolbar *)pickerToolbar
{
    UIToolbar *pickerToolbar = [[UIToolbar alloc] init];
    [pickerToolbar sizeToFit];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [pickerToolbar setItems:@[flexibleSpace, cancel, done]];
    
    return pickerToolbar;
}

- (void)done:(id)sender
{
    self.selectedFont = self.fontPickerView.currentFont;
    [self hidePicker];
}

- (void)cancel:(id)sender
{
    [self hidePicker];
}

- (void)hidePicker
{
    [self.fontTextField resignFirstResponder];
}

@end
