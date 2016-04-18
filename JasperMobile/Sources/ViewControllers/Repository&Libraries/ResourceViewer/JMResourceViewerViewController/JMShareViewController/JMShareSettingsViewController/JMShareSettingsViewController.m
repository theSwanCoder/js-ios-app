//
//  JMShareSettingsViewController.m
//  TIBCO JasperMobile
//
//  Created by Oleksii Gubariev on 4/1/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMShareSettingsViewController.h"
#import "JMPopupView.h"

#define JMShareSettingsAvailableColors @[[UIColor blackColor], [UIColor whiteColor], [UIColor grayColor], [UIColor redColor], [UIColor greenColor], [UIColor blueColor], [UIColor cyanColor], [UIColor yellowColor], [UIColor magentaColor], [UIColor orangeColor], [UIColor purpleColor], [UIColor brownColor]]

@interface JMShareSettingsViewController () <JMPopupViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *brushTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *brushValueLabel;
@property (weak, nonatomic) IBOutlet UISlider *brushSlider;

@property (weak, nonatomic) IBOutlet UILabel *opacityTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *opacityValueLabel;
@property (weak, nonatomic) IBOutlet UISlider *opacitySlider;

@property (weak, nonatomic) IBOutlet UIButton *colorPreviewButton;

@property (weak, nonatomic) IBOutlet UILabel *fontSizeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *fontSizeValueLabel;
@property (weak, nonatomic) IBOutlet UISlider *fontSizeSlider;

@property (weak, nonatomic) IBOutlet UILabel *borderTitleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *borderSwitch;

@property (strong, nonatomic, readonly) NSArray *availableColors;

@end

@implementation JMShareSettingsViewController
@synthesize availableColors = _availableColors;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = JMCustomLocalizedString(@"resource_viewer_share_settings_title", nil);
    self.opacityTitleLabel.text = JMCustomLocalizedString(@"resource_viewer_share_settings_opacity", nil);
    self.brushTitleLabel.text = JMCustomLocalizedString(@"resource_viewer_share_settings_brush", nil);
    self.borderTitleLabel.text = JMCustomLocalizedString(@"resource_viewer_share_settings_border", nil);
    self.fontSizeTitleLabel.text = JMCustomLocalizedString(@"resource_viewer_share_settings_font_size", nil);

    self.brushSlider.value = self.brushWidth;
    [self sliderValueChanged:self.brushSlider];
    
    self.opacitySlider.value = self.opacity;
    [self sliderValueChanged:self.opacitySlider];
    
    self.selectedFont = self.selectedFont;
    self.fontSizeSlider.value = self.selectedFont.pointSize;
    [self sliderValueChanged:self.fontSizeSlider];
    
    self.borderSwitch.on = self.borders;
    
    self.colorPreviewButton.layer.cornerRadius = 4.f;
    self.colorPreviewButton.layer.borderWidth = 0.5f;
    self.colorPreviewButton.layer.borderColor = [UIColor grayColor].CGColor;

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
    } else if(changedSlider == self.fontSizeSlider) {
        int fontSize = round(self.fontSizeSlider.value);
        self.selectedFont = [self.selectedFont fontWithSize:fontSize];
        self.fontSizeValueLabel.text = [NSString stringWithFormat:@"%dpt", fontSize];
    }
    
    [self updateColorPreview];
}

- (IBAction)borderSwitchValueChanged:(id)sender
{
    self.borders = self.borderSwitch.on;
}

- (IBAction)colorPreviewButtonDidTapped:(id)sender
{
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, kJMPopupViewDefaultWidth, 200)];
    pickerView.dataSource = self;
    pickerView.delegate = self;
    pickerView.showsSelectionIndicator = YES;
    pickerView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.4];
    
    NSInteger selectedColorIndex = [self.availableColors indexOfObject:self.drawingColor];
    if (selectedColorIndex != NSNotFound) {
        [pickerView selectRow:selectedColorIndex inComponent:0 animated:NO];
    }
    
    JMPopupView *popup = [[JMPopupView alloc] initWithDelegate:self type:JMPopupViewType_OkCancelButtons];
    popup.contentView = pickerView;
    popup.isDissmissWithTapOutOfButton = NO;
    [popup show];
}

- (void) updateColorPreview
{
    UIGraphicsBeginImageContext(self.colorPreviewButton.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context,self.brushWidth);
    CGContextSetStrokeColorWithColor(context, [self.drawingColor colorWithAlphaComponent:self.opacity].CGColor);
    CGContextMoveToPoint(context, CGRectGetMidX(self.colorPreviewButton.bounds), CGRectGetMidY(self.colorPreviewButton.bounds));
    CGContextAddLineToPoint(context, CGRectGetMidX(self.colorPreviewButton.bounds), CGRectGetMidY(self.colorPreviewButton.bounds));
    CGContextStrokePath(context);
    
    [self.colorPreviewButton setBackgroundImage:UIGraphicsGetImageFromCurrentImageContext() forState:UIControlStateNormal];
    UIGraphicsEndImageContext();
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.availableColors.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;
{
    if (!view) {
        CGRect viewFrame = CGRectZero;
        viewFrame.size = [pickerView rowSizeForComponent:component];
        viewFrame.size.width -= 40;
        view = [[UIView alloc] initWithFrame:viewFrame];
    }
    view.backgroundColor = self.availableColors[row];
    return view;
}

- (NSArray *)availableColors
{
    if(!_availableColors) {
        _availableColors = [JMShareSettingsAvailableColors copy];
    }
    return _availableColors;
}

#pragma mark - JMPopupViewDelegate
- (void)popupViewDidApplied:(JMPopupView *)popup
{
    UIPickerView *pickerView = (UIPickerView *)popup.contentView;
    NSInteger selectedColorIndex = [pickerView selectedRowInComponent:0];
    if (selectedColorIndex != NSNotFound) {
        self.drawingColor = self.availableColors[selectedColorIndex];
        [self updateColorPreview];
    }
}

@end
