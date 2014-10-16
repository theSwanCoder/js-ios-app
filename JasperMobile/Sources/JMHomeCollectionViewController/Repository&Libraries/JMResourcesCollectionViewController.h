//
//  JMResourcesCollectionViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/16/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMResourcesListLoader.h"

typedef NS_ENUM(NSInteger, JMResourcesCollectionViewControllerPresentingType) {
    JMResourcesCollectionViewControllerPresentingType_Library = 1 << 0,
    JMResourcesCollectionViewControllerPresentingType_Repository = 1 << 1,
    JMResourcesCollectionViewControllerPresentingType_SavedItems = 1 << 2,
    JMResourcesCollectionViewControllerPresentingType_Favorites = 1 << 3
};

typedef NS_ENUM(NSInteger, JMResourcesRepresentationType) {
    JMResourcesRepresentationTypeHorizontalList = 0,
    JMResourcesRepresentationTypeGrid = 1
};


@interface JMResourcesCollectionViewController : UIViewController 
@property (nonatomic, assign) JMResourcesCollectionViewControllerPresentingType presentingType;
@property (nonatomic, assign) JMResourcesRepresentationType representationType;

@end
