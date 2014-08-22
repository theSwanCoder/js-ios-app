//
//  JMLoadingCollectionViewCell.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 8/21/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMLoadingCollectionViewCell.h"
NSString * kJMLoadingCellIdentifier = @"LoadingCell";
NSString * kJMLoadingCellNibKey = @"LoadingCellNibKey";

NSString * kJMVerticalLoadingCellNib = @"JMVerticalLoadingCollectionViewCell";
NSString * kJMHorizontalLoadingCellNib = @"JMHorizontalLoadingCollectionViewCell";
NSString * kJMGridLoadingCellNib = @"JMGridLoadingCollectionViewCell";

@interface JMLoadingCollectionViewCell ()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@end

@implementation JMLoadingCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.titleLabel.text = JMCustomLocalizedString(@"detail.resourcesloading.msg", nil);
}

@end
