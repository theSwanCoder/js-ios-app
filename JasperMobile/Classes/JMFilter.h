//
//  JMRESTFilter.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 5/30/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JaspersoftSDK.h"

@interface JMFilter : NSObject <JSRequestDelegate, UIAlertViewDelegate>

/**
 Calls a block of code if network is reachable. Otherwise presents alert view dialog
 with "OK" button
 
 @param block The block which will be called if network is reachable
 @param delegate An alert view delegate object
 */
+ (void)checkNetworkReachabilityForBlock:(void (^)(void))block viewControllerToDismiss:(id)viewController;

/**
 Passes request result to final delegate object if request was successful. Otherwise displays
 alert view dialog with error message
 
 @param delegate A deleage object
 */
+ (JMFilter *)checkRequestResultForDelegate:(id <JSRequestDelegate>)delegate;

@end
