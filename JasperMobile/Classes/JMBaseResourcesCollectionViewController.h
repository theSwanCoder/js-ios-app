//
//  JMBaseResourcesCollectionViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadsky on 5/5/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMRefreshable.h"
#import "JMResourceClientHolder.h"
#import "JMPagination.h"
#import "JMActionBarProvider.h"

// TODO: make universal view controller or avoid code duplications in other way
@interface JMBaseResourcesCollectionViewController : UICollectionViewController <JMRefreshable, JMActionBarProvider>

@property (nonatomic, weak) UIViewController <JMPagination, JMResourceClientHolder, JMActionBarProvider> *delegate;
@property (nonatomic, assign) CGFloat yLandscapeOffset;
@property (nonatomic, assign) CGFloat yPortraitOffset;
@property (nonatomic, assign) CGFloat edgesLandscapeInset;
@property (nonatomic, assign) CGFloat edgesPortraitInset;
@property (nonatomic, assign) UICollectionViewScrollPosition scrollPosition;
@property (nonatomic, weak) JSConstants *constants;

- (BOOL)isLoadingCell:(UICollectionViewCell *)cell;

@end
