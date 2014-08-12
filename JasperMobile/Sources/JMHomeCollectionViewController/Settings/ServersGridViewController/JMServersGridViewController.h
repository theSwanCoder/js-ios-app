//
//  JMServersGridViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 7/22/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JMServersGridViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@end
