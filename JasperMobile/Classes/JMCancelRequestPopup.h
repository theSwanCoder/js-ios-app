//
//  JMLoadingViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/6/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JaspersoftSDK.h"

typedef void(^JMCancelRequestBlock)(void);

@interface JMCancelRequestPopup : UIViewController

/**
 Presents cancel request popup in view controller
 
 @param viewController A view controller inside which popup will be shown
 @param client A rest client to cancel all requests
 @param cancelBlock A cancelBlock to execute
 */
+ (void)presentInViewController:(UIViewController *)viewController restClient:(JSRESTBase *)client cancelBlock:(JMCancelRequestBlock)cancelBlock;

/**
 Dismisses last presented popup
 */
+ (void)dismiss;

@end

