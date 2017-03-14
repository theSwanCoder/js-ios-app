/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */

/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.0
 */

@import UIKit;

@interface JMIntroImageView : UIImageView
- (void)setImageFrame:(CGRect)imageFrame forPageIdentifier:(NSString *)pageIdentifier;
- (CGRect)imageFrameForPageIdentifier:(NSString *)pageIdentifier;
- (void)updateFrameForPageWithIdentifier:(NSString *)pageIdentifier;
@end
