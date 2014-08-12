//
//  JMMainNavigationItemProvider.h
//  JasperMobile
//
//  Created by Oleksii Gubariev on 8/6/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JMMainNavigationItemProvider <NSObject>
@optional
- (NSString *) titleForMainNavigationItem;
- (NSArray *) leftItemsForMainNavigationItem;
- (NSArray *) rightItemsForMainNavigationItem;
@end
