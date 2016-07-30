/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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
//  JMIntroModel.h
//  TIBCO JasperMobile
//

/**
@since 1.9
*/

@import UIKit;

@interface JMIntroModel : NSObject
@property (nonatomic, copy) NSString *pageTitle;
@property (nonatomic, copy) NSString *pageDescription;
@property (nonatomic, strong) UIImage *pageImage;

- (instancetype)initWithTitle:(NSString *)title description:(NSString *)description image:(UIImage *)image;

@end