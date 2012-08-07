//
//  JSToggleFavorieImageControl.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 07.08.12.
//  Copyright (c) 2012 Jaspersoft. All rights reserved.
//

#import "JasperMobileAppDelegate.h"
#import "JSToggleFavorieImageControl.h"

@implementation JSToggleFavorieImageControl

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
        self.isSelected = [self isResourceInFavorites:self.resourceDescriptor];
        
        if (self.isSelected) {
            self.imageView = [[UIImageView alloc] initWithImage: self.selectedImage];
        } else {
            self.imageView = [[UIImageView alloc] initWithImage: self.normalImage];
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

- (BOOL)isResourceInFavorites:(JSResourceDescriptor *)resourceDescriptor {
    if (!resourceDescriptor) {
        return NO;
    }
    
    NSLog(@"%i", [JasperMobileAppDelegate sharedInstance].activeServerIndex);
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *activeServer = [NSString stringWithFormat: @"jaspersoft.server.favorites.%d", 
                              [JasperMobileAppDelegate sharedInstance].activeServerIndex];
    return [[prefs objectForKey:activeServer] objectForKey:resourceDescriptor.uri] ? YES : NO;
    
}

- (void)touched {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *activeServer = [NSString stringWithFormat: @"jaspersoft.server.favorites.%d", 
                              [JasperMobileAppDelegate sharedInstance].activeServerIndex];
    NSDictionary *favorites = [prefs objectForKey:activeServer] ?: [[NSDictionary alloc] init];
    NSMutableDictionary *editableFavorites = [[NSMutableDictionary alloc] initWithDictionary:favorites];
    
    if (!self.isSelected) {
        [editableFavorites setObject:self.resourceDescriptor.label forKey:self.resourceDescriptor.uri];
        self.imageView.image = self.selectedImage;
        self.isSelected = true;
    } else {
        [editableFavorites removeObjectForKey:self.resourceDescriptor.uri];
        self.imageView.image = self.normalImage;
        self.isSelected = false;
    }
    
    [prefs setObject:editableFavorites forKey:activeServer];
    [prefs synchronize];
}

@end
