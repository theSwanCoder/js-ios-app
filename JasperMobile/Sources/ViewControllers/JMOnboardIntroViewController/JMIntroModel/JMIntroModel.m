/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMIntroModel.h"

@implementation JMIntroModel

- (instancetype)initWithTitle:(NSString *)title description:(NSString *)description image:(UIImage *)image {
    self = [super init];
    if (self) {
        _pageTitle = title;
        _pageDescription = description;
        _pageImage = image;
    }
    return self;
}


@end
