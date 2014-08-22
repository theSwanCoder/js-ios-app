//
//  JMResourceCollectionViewCell.h
//  JasperMobile
//
//  Created by Oleksii Gubariev on 8/20/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
extern NSString * kJMResourceCellIdentifier;
extern NSString * kJMResourceCellNibKey;

extern NSString * kJMVerticalResourceCellNib;
extern NSString * kJMHorizontalResourceCellNib;
extern NSString * kJMGridResourceCellNib;

@interface JMResourceCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) JSResourceLookup *resourceLookup;


@end
