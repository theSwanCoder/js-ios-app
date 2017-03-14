/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMIntroImageView.h"

@interface JMIntroImageView ()
@property (strong, nonatomic) NSMutableDictionary *frameForPages;
@end

@implementation JMIntroImageView

#pragma mark - Life Circle
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - Setup
- (void)setup {
    _frameForPages = [NSMutableDictionary new];
}

#pragma mark - Public API
- (void)setImageFrame:(CGRect)imageFrame forPageIdentifier:(NSString *)pageIdentifier {
    self.frameForPages[pageIdentifier] = [NSValue valueWithCGRect:imageFrame];
}

- (CGRect)imageFrameForPageIdentifier:(NSString *)pageIdentifier {
    return ((NSValue *)self.frameForPages[pageIdentifier]).CGRectValue;
}

- (void)updateFrameForPageWithIdentifier:(NSString *)pageIdentifier {
    self.frame = ((NSValue *)self.frameForPages[pageIdentifier]).CGRectValue;
}

@end
