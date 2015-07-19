//
// Created by Aleksandr Dakhno on 7/19/15.
// Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JMPrintResourceCollectionCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end