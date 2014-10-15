//
//  JMResourceCollectionViewCell.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 8/20/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMResourceCollectionViewCell.h"

NSString * kJMHorizontalResourceCell = @"JMHorizontalResourceCollectionViewCell";
NSString * kJMGridResourceCell = @"JMGridResourceCollectionViewCell";


@interface JMResourceCollectionViewCell()
@property (nonatomic, weak) IBOutlet UIImageView *resourceImage;
@property (nonatomic, weak) IBOutlet UILabel *resourceName;
@property (nonatomic, weak) IBOutlet UILabel *resourceDescription;

@property (nonatomic, weak) JSConstants *constants;

@end

@implementation JMResourceCollectionViewCell
@synthesize constants = _constants;

objection_requires(@"constants")

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [[JSObjection defaultInjector] injectDependencies:self];

    self.resourceImage.backgroundColor = kJMResourcePreviewBackgroundColor;
}

- (void)setResourceLookup:(JSResourceLookup *)resourceLookup
{
    _resourceLookup = resourceLookup;
    self.resourceName.text = resourceLookup.label;
    self.resourceDescription.text = resourceLookup.resourceDescription;
    
    if ([resourceLookup.resourceType isEqualToString:self.constants.WS_TYPE_REPORT_UNIT]) {
        self.resourceImage.image = [UIImage imageNamed:@"Report"];
    } else if ([resourceLookup.resourceType isEqualToString:self.constants.WS_TYPE_DASHBOARD]) {
        self.resourceImage.image = [UIImage imageNamed:@"Dashboard"];
    } else if ([resourceLookup.resourceType isEqualToString:self.constants.WS_TYPE_FOLDER]) {
        self.resourceImage.image = [UIImage imageNamed:@"Folder"];
    }
}

- (IBAction)infoButtonDidTapped:(id)sender
{
    [self.delegate infoButtonDidTappedOnCell:self];
}
@end
