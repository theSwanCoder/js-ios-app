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
    JMResourcesCollectionViewControllerPresentingType_None = 0,
    JMResourcesCollectionViewControllerPresentingType_Library,
    JMResourcesCollectionViewControllerPresentingType_Repository,
    JMResourcesCollectionViewControllerPresentingType_SavedItems
};

typedef NS_ENUM(NSInteger, JMResourcesRepresentationType) {
    JMResourcesRepresentationTypeHorizontalList = 0,
    JMResourcesRepresentationTypeGrid = 1
};


@interface JMResourcesCollectionViewController : UIViewController 
@property (nonatomic, assign) JMResourcesCollectionViewControllerPresentingType presentingType;
@property (nonatomic, assign) JMResourcesRepresentationType representationType;

@end
