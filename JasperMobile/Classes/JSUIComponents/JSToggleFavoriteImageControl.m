//
//  JSToggleFavorieImageControl.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 07.08.12.
//  Copyright (c) 2012 Jaspersoft. All rights reserved.
//

#import "JasperMobileAppDelegate.h"
#import "JSToggleFavoriteImageControl.h"

@implementation JSToggleFavoriteImageControl

@synthesize isSelected = _isSelected;
@synthesize normalImage = _normalImage;
@synthesize selectedImage = _selectedImage;
@synthesize imageView = _imageView;
@synthesize resourceDescriptor = _resourceDescriptor;

- (id)initWithFrame:(CGRect)frame andResourceDescriptor:(JSResourceDescriptor *)resourceDescriptor {
    self = [super initWithFrame:frame];
    if (self) {
        self.resourceDescriptor = resourceDescriptor;
        self.normalImage = [UIImage imageNamed: @"samples.png"];
        self.selectedImage = [UIImage imageNamed: @"repository.png"];
        self.isSelected = [[JasperMobileAppDelegate sharedInstance].favoritesHelper isResourceInFavorites:resourceDescriptor];
        
        if (self.isSelected) {
            self.imageView = [[[UIImageView alloc] initWithImage: self.selectedImage] autorelease];
        } else {
            self.imageView = [[[UIImageView alloc] initWithImage: self.normalImage] autorelease];
        }        
        
        [self addSubview:self.imageView];
        [self addTarget:self action:@selector(touched) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame andResourceDescriptor:nil];
}

- (void)touched {    
    if (!self.isSelected) {
        [[JasperMobileAppDelegate sharedInstance].favoritesHelper addToFavorites:self.resourceDescriptor];
        self.imageView.image = self.selectedImage;
        self.isSelected = true;
    } else {
        [[JasperMobileAppDelegate sharedInstance].favoritesHelper removeFromFavorites:self.resourceDescriptor];
        self.imageView.image = self.normalImage;
        self.isSelected = false;
    }
}

@end
