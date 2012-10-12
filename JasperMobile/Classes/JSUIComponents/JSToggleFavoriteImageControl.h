//
//  JSToggleFavorieImageControl.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 07.08.12.
//  Copyright (c) 2012 Jaspersoft. All rights reserved.
//

#import <jasperserver-mobile-sdk-ios/JSResourceDescriptor.h>
#import <UIKit/UIKit.h>

@interface JSToggleFavoriteImageControl : UIControl

@property (nonatomic) BOOL isSelected;
@property (nonatomic, retain) UIImage *normalImage;
@property (nonatomic, retain) UIImage *selectedImage;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) JSResourceDescriptor *resourceDescriptor;

- (id)initWithFrame:(CGRect)frame andResourceDescriptor:(JSResourceDescriptor *)resourceDescriptor;

@end
