//
// Created by Vlad Zavadskii on 5/29/14.
// Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JMMenuItemCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UILabel *desc;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIView *coloredView;

@end