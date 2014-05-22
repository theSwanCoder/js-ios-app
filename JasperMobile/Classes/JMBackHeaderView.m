//
//  JMBackButtonView.m
//  JasperMobile
//
//  Created by Vlad Zavadsky on 5/22/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMBackHeaderView.h"
#import "JMBaseResourceTableViewCell.h"

@interface JMBackHeaderView()
@property (nonatomic, copy) void (^callback)(UITapGestureRecognizer *);
@end

@implementation JMBackHeaderView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [self addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (void)setOnTapGestureCallback:(void (^)(UITapGestureRecognizer *))callback
{
    self.callback = callback;
}

- (IBAction)onTap:(UITapGestureRecognizer *)recognizer
{
    if (self.callback) {
        // TODO: refactor
        self.backgroundColor = [JMBaseResourceTableViewCell selectedColor];
        self.callback(recognizer);
    }
}

@end
