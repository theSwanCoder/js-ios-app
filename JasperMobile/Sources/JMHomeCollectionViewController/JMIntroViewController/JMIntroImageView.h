//
// Created by Aleksandr Dakhno on 11/30/14.
// Copyright (c) 2014 Tibco JasperMobile. All rights reserved.
//

@interface JMIntroImageView : UIImageView
- (void)setImageFrame:(CGRect)imageFrame forPageIdentifier:(NSString *)pageIdentifier;
- (CGRect)imageFrameForPageIdentifier:(NSString *)pageIdentifier;
- (void)updateFrameForPageWithIdentifier:(NSString *)pageIdentifier;
@end