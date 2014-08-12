//
//  JMFullScreenButtonProvider.h
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/21/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JMFullScreenButtonProvider <NSObject>

@optional
- (BOOL)shouldDisplayFullScreenButton;

- (UIColor *)fullScreenButtonImageColor;

@end
