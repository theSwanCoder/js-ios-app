//
//  JMFontPickerView.m
//  TIBCO JasperMobile
//
//  Created by Oleksii Gubariev on 4/12/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMFontPickerView.h"

typedef NS_ENUM(NSInteger, JMFontPickerViewComponent) {
    JMFontPickerViewComponent_Name = 0,
    JMFontPickerViewComponent_Size
};

static const NSInteger kJMFontPickerMinFontSize = 8;
static const NSInteger kJMFontPickerMaxFontSize = 72;
static const NSInteger kJMFontPickerItemsFontSize = 17;

@interface JMFontPickerView() <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) NSArray *fontsArray;
@property (nonatomic, strong) NSArray *fontSizesArray;
@end

@implementation JMFontPickerView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.showsSelectionIndicator = YES;
    }
    return self;
}

#pragma mark - Custom Accessories 

- (NSArray *)fontsArray
{
    if (!_fontsArray) {
        // Get list of all system fonts' names
        NSArray *fontFamilyNames = [UIFont familyNames];
        NSMutableArray *fonts = [NSMutableArray array];
        for (NSString *familyName in fontFamilyNames) {
            NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
            [fonts addObjectsFromArray:fontNames];
        }
        
        // sort by font name
        _fontsArray = [fonts sortedArrayUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
            return [str1 localizedCaseInsensitiveCompare:str2];
        }];
    }
    return _fontsArray;
}

- (NSArray *)fontSizesArray
{
    if (!_fontSizesArray) {
        NSMutableArray *sizesArray = [NSMutableArray array];
        for (NSInteger fontSize = kJMFontPickerMinFontSize; fontSize <= kJMFontPickerMaxFontSize; fontSize ++) {
            NSNumber *size = [NSNumber numberWithInteger:fontSize];
            [sizesArray addObject:size];
        }
        _fontSizesArray = [sizesArray copy];
    }
    return _fontSizesArray;
}

- (UIFont *)currentFont
{
    NSInteger selectedFontNameIndex = [self selectedRowInComponent:JMFontPickerViewComponent_Name];
    NSInteger selectedFontSizeIndex = [self selectedRowInComponent:JMFontPickerViewComponent_Size];
 
    if (selectedFontSizeIndex == -1 || selectedFontNameIndex == -1) {
        UIFont *systemFont = [UIFont systemFontOfSize:17];
        selectedFontNameIndex = [self indexForFontName:systemFont.fontName];
        selectedFontSizeIndex = [self indexForFontSize:systemFont.pointSize];
    }
    
    if (selectedFontNameIndex != NSNotFound && selectedFontSizeIndex != NSNotFound) {
        return [UIFont fontWithName:self.fontsArray[selectedFontNameIndex] size:[self.fontSizesArray[selectedFontSizeIndex] integerValue]];
    }
    return [UIFont systemFontOfSize:17];
}

- (void)setCurrentFont:(UIFont *)currentFont
{
    NSInteger selectedFontNameIndex = [self indexForFontName:currentFont.fontName];
    NSInteger selectedFontSizeIndex = [self indexForFontSize:currentFont.pointSize];
    
    if (selectedFontNameIndex == NSNotFound) {
        NSMutableArray *fonts = [self.fontsArray mutableCopy];
        [fonts addObject:currentFont.fontName];
        
        self.fontsArray = [fonts sortedArrayUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
            return [str1 localizedCaseInsensitiveCompare:str2];
        }];
        [self reloadComponent:JMFontPickerViewComponent_Name];
        
        selectedFontNameIndex = [self indexForFontName:currentFont.fontName];
    }
    
    if (selectedFontSizeIndex == NSNotFound) {
        selectedFontSizeIndex = [self indexForFontSize:floor(currentFont.pointSize)];
    }
    
    [self selectRow:selectedFontNameIndex inComponent:JMFontPickerViewComponent_Name animated:NO];
    [self selectRow:selectedFontSizeIndex inComponent:JMFontPickerViewComponent_Size animated:NO];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case JMFontPickerViewComponent_Name:
            return self.fontsArray.count;
        case JMFontPickerViewComponent_Size:
            return self.fontSizesArray.count;
        default:
            return 0;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    switch (component) {
        case JMFontPickerViewComponent_Name:
            return CGRectGetWidth(pickerView.bounds) * 0.8;
        case JMFontPickerViewComponent_Size:
            return CGRectGetWidth(pickerView.bounds) * 0.2;
        default:
            return 0;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;
{
    CGRect labelFrame = CGRectZero;
    labelFrame.size = [pickerView rowSizeForComponent:component];

    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor darkTextColor];
    label.font = [UIFont systemFontOfSize:kJMFontPickerItemsFontSize];
    label.textAlignment = NSTextAlignmentCenter;
    
    switch (component) {
        case JMFontPickerViewComponent_Name: {
            NSString *fontName = self.fontsArray[row];
            label.text = fontName;
            label.font = [UIFont fontWithName:fontName size:kJMFontPickerItemsFontSize];
            break;
        }
        case JMFontPickerViewComponent_Size: {
            label.text = [NSString stringWithFormat:@"%@", self.fontSizesArray[row]];
            break;
        }
    }

    return label;
}

#pragma mark - Private API
- (NSInteger)indexForFontName:(NSString *)fontName
{
    for (NSString *currentFontName in self.fontsArray) {
        if ([currentFontName isEqualToString:fontName]) {
            return [self.fontsArray indexOfObject:currentFontName];
        }
    }
    if ([fontName hasPrefix:@"."]) {
        fontName = [fontName substringFromIndex:1];
        return [self indexForFontName:fontName];
    }
    return NSNotFound;
}

- (NSInteger)indexForFontSize:(CGFloat)pointSize
{
    for (NSNumber *currentFontSize in self.fontSizesArray) {
        if (currentFontSize.floatValue == pointSize) {
            return [self.fontSizesArray indexOfObject:currentFontSize];
        }
    }
    return NSNotFound;
}
@end
