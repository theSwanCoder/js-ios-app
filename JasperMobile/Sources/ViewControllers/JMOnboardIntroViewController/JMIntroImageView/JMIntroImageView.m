/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
 * http://community.jaspersoft.com/project/jaspermobile-ios
 *
 * Unless you have purchased a commercial license agreement from Jaspersoft,
 * the following license terms apply:
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/lgpl>.
 */


//
//  JMIntroImageView.h
//  TIBCO JasperMobile
//

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