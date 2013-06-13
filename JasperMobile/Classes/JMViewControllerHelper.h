//
//  JMViewControllerHelper.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/7/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMResourceClientHolder.h"

@interface JMViewControllerHelper : NSObject

/**
 Inejcts all required dependencies into navigation view controller that implements 
 JMResourceClientHolder protocol. Also sets title equals to resource's name or 
 profile's alias if resource is <b>nil</b>
 
 @param viewController A viewController to configure
 */
+ (void)awakeFromNibForResourceViewController:(UIViewController <JMResourceClientHolder>*)viewController;

@end
