//
//  JMReportSearchVC.h
//  TIBCO JasperMobile
//
//  Created by Alexey Gubarev on 8/8/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseViewController.h"
#import "JMWebEnvironment.h"

@class JSReportSearch;


@interface JMReportSearchVC : JMBaseViewController

@property(nonatomic, strong, nullable) JSReportSearch *currentSearch;

@property(nonatomic, weak, null_unspecified) JMWebEnvironment *webEnvironment;

@property(nonatomic, copy) void(^__nonnull exitBlock)(JSReportSearch * __nonnull resultSearch);

@end
