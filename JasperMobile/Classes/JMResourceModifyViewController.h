//
//  JMResourceModifyViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/13/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMResourceClientHolder.h"

@protocol JMResourceModifyViewControllerDelegate;

@interface JMResourceModifyViewController : UIViewController <JMResourceClientHolder, JSRequestDelegate, UITextFieldDelegate>

@property (nonatomic, weak) id <JMResourceModifyViewControllerDelegate> delegate;

@end

@protocol JMResourceModifyViewControllerDelegate <NSObject>
@required
@property (nonatomic, assign) BOOL needsToRefreshResourceDescriptorData;

@end
