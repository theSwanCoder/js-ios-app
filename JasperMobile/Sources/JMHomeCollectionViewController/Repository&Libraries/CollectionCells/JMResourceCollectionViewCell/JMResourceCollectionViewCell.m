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

@property (nonatomic, weak) JSConstants *constants;

@end

@implementation JMResourceCollectionViewCell
@synthesize constants = _constants;

objection_requires(@"constants")

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[JSObjection defaultInjector] injectDependencies:self];

    self.resourceImage.backgroundColor = kJMResourcePreviewBackgroundColor;
}

- (void)setResourceLookup:(JSResourceLookup *)resourceLookup
{
    _resourceLookup = resourceLookup;
    self.resourceName.text = resourceLookup.label;
    self.resourceDescription.text = resourceLookup.resourceDescription;
    self.resourceDataCreation.text = resourceLookup.creationDate;
    
    if ([resourceLookup.resourceType isEqualToString:self.constants.WS_TYPE_REPORT_UNIT]) {
        self.resourceImage.image = [UIImage imageNamed:@"Report.png"];
    } else if ([resourceLookup.resourceType isEqualToString:self.constants.WS_TYPE_DASHBOARD]) {
        self.resourceImage.image = [UIImage imageNamed:@"Dashboard.png"];
    }
}
@end
