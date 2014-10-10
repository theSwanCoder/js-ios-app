//
//  JMResourcesCollectionViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/16/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMResourcesListLoader.h"

typedef NS_ENUM(NSInteger, JMResourcesCollectionViewControllerType) {
    JMResourcesCollectionViewControllerType_None = 0,
    JMResourcesCollectionViewControllerType_Library,
    JMResourcesCollectionViewControllerType_Repository,
    JMResourcesCollectionViewControllerType_SavedItems
};

typedef NS_ENUM(NSInteger, JMResourcesRepresentationType) {
    JMResourcesRepresentationTypeHorizontalList = 0,
    JMResourcesRepresentationTypeGrid = 1
};


@interface JMResourcesCollectionViewController : UIViewController 
@property (nonatomic, assign) JMResourcesCollectionViewControllerType resourcesType;
@property (nonatomic, assign) JMResourcesRepresentationType representationType;

@end
