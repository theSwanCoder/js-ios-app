//
//  JMSearchBar.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 8/12/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMSearchBar.h"

#define kJMSearchBarCancelButtonWidth       100.f

static NSString * const JMReplacingTextString = @"ReplacingTextString";
static NSString * const JMReplacingTextRange  = @"ReplacingTextRange";

@interface JMSearchBar () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *clearButton;
@end

@implementation JMSearchBar
@dynamic text;
@dynamic placeholder;
@dynamic textColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [super setBackgroundColor:[UIColor clearColor]];
        CGRect textFieldFrame = frame;
        textFieldFrame.size.width -= kJMSearchBarCancelButtonWidth;
        self.textField = [[UITextField alloc] initWithFrame:textFieldFrame];
        self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.textField.borderStyle = UITextBorderStyleRoundedRect;
        self.textField.textAlignment = NSTextAlignmentLeft;
        self.textField.delegate = self;
        self.textField.textColor = [UIColor lightGrayColor];
        self.textField.returnKeyType = UIReturnKeySearch;
        self.textField.backgroundColor = kJMSearchBarBackgroundColor;
        self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.height, frame.size.height)];
        leftView.image = [UIImage imageNamed:@"search_button.png"];
        leftView.backgroundColor = [UIColor clearColor];
        leftView.contentMode = UIViewContentModeCenter;
        self.textField.leftView = leftView;
        self.textField.leftViewMode = UITextFieldViewModeAlways;

        self.clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.clearButton.frame = CGRectMake(0, 0, frame.size.height, frame.size.height);
        self.clearButton.backgroundColor = [UIColor clearColor];
        [self.clearButton addTarget:self action:@selector(clearButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.clearButton setImage:[UIImage imageNamed:@"clear_button.png"] forState:UIControlStateNormal];
        [self.clearButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.textField.rightView = self.clearButton;
        self.textField.rightViewMode = UITextFieldViewModeNever;
        
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cancelButton.frame = CGRectMake(frame.size.width - kJMSearchBarCancelButtonWidth, 0, kJMSearchBarCancelButtonWidth, frame.size.height);
        self.cancelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.cancelButton.backgroundColor = [UIColor clearColor];
        [self.cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.cancelButton setTitle:JMCustomLocalizedString(@"dialog.button.cancel", nil) forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        [self addSubview:self.cancelButton];
        [self addSubview:self.textField];
    }
    return self;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textField resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(searchBarSearchButtonClicked:)]) {
        [self.delegate searchBarSearchButtonClicked:self];
    }
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([newString length]) {
        if (self.textField.rightViewMode != UITextFieldViewModeAlways) {
            self.textField.rightViewMode = UITextFieldViewModeAlways;
        }
    } else {
        self.textField.rightViewMode = UITextFieldViewModeNever;
    }
    
    if ([self.delegate respondsToSelector:@selector(searchBarDidChangeText:)]) {
        [((NSObject *)self.delegate) performSelector:@selector(searchBarDidChangeText:) withObject:self afterDelay: 0.1];
    }

    return YES;
}

#pragma mark - Actions
- (void)clearButtonTapped:(id)sender
{
    self.textField.text = @"";
    self.textField.rightViewMode = UITextFieldViewModeNever;
}

- (void)cancelButtonTapped:(id)sender
{
    [self.textField resignFirstResponder];
    [self clearButtonTapped:self.clearButton];
    
    if ([self.delegate respondsToSelector:@selector(searchBarCancelButtonClicked:)]) {
        [self.delegate searchBarCancelButtonClicked:self];
    }
}

#pragma Properties
- (UIColor *)textColor
{
    return self.textField.textColor;
}

- (void)setTextColor:(UIColor *)textColor
{
    self.textField.textColor = textColor;
}

- (NSString *)text
{
    return self.textField.text;
}

- (void)setText:(NSString *)text
{
    self.textField.text = text;
}

- (NSString *)placeholder
{
    return self.textField.placeholder;
}

-(void)setPlaceholder:(NSString *)placeholder
{
    NSAttributedString *attrPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:[self attributesForPlaceholder]];
    self.textField.attributedPlaceholder = attrPlaceholder;
}

- (NSDictionary *)attributesForPlaceholder
{
    return [NSDictionary dictionaryWithObjectsAndKeys:[UIColor darkGrayColor], NSForegroundColorAttributeName, self.textField.font, NSFontAttributeName, nil];
}

@end
