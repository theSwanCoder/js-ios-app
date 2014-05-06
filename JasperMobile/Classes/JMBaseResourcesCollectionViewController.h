//
//  JMBaseResourcesCollectionViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadsky on 5/5/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMRefreshable.h"
#import "JMDetailViewController.h"

@interface JMBaseResourcesCollectionViewController : UICollectionViewController <JMRefreshable>

@property (nonatomic, weak) JMDetailViewController *delegate;
@property (nonatomic, assign) CGFloat yLandscapeOffset;
@property (nonatomic, assign) CGFloat yPortraitOffset;
@property (nonatomic, assign) CGFloat edgesLandscapeInset;
@property (nonatomic, assign) CGFloat edgesPortraitInset;
@property (nonatomic, assign) UICollectionViewScrollPosition scrollPosition;

- (BOOL)isLoadingCell:(UICollectionViewCell *)cell;

@end
