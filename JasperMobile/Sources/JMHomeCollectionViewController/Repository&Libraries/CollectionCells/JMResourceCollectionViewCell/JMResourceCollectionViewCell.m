//
//  JMResourceCollectionViewCell.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 8/20/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMResourceCollectionViewCell.h"
NSString * kJMResourceCellIdentifier = @"ResourceCell";
NSString * kJMResourceCellNibKey = @"ResourceCellNibKey";

NSString * kJMVerticalResourceCellNib = @"JMVerticalResourceCollectionViewCell";
NSString * kJMHorizontalResourceCellNib = @"JMHorizontalResourceCollectionViewCell";
NSString * kJMGridResourceCellNib = @"JMGridResourceCollectionViewCell";


@interface JMResourceCollectionViewCell()
@property (nonatomic, weak) IBOutlet UIImageView *resourceImage;
@property (nonatomic, weak) IBOutlet UILabel *resourceName;
@property (nonatomic, weak) IBOutlet UILabel *resourceDescription;
@property (nonatomic, weak) IBOutlet UILabel *resourceDataCreation;
@end

@implementation JMResourceCollectionViewCell

- (void)setResourceLookup:(JSResourceLookup *)resourceLookup
{
    _resourceLookup = resourceLookup;
    self.resourceName.text = resourceLookup.label;
    self.resourceDescription.text = resourceLookup.resourceDescription;
    self.resourceDataCreation.text = resourceLookup.creationDate;
}
@end
