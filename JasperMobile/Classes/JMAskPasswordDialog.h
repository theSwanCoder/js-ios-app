//
//  JMAskPasswordDialog.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 7/22/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMServerProfile.h"

/**
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @since 1.3
 */
@interface JMAskPasswordDialog : NSObject <UIAlertViewDelegate>

/**
 Creates ask password dialog
 
 @param profile A Server Profile to which password will be set
 @return a fully configured alert view as ask password dialog
 */
+ (UIAlertView *)askPasswordDialogForServerProfile:(JMServerProfile *)profile;

@end
