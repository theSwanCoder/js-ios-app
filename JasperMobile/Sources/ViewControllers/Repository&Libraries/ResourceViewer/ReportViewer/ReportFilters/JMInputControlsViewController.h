/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.9
 */

#import "JMEditabledViewController.h"

@class JMFiltersVCResult;

@interface JMInputControlsViewController : JMEditabledViewController
@property (nonatomic, copy) NSString * __nonnull reportURI;
@property (nonatomic, copy) NSArray * __nullable initialReportParameters;
@property (nonatomic, copy) NSString *__nullable initialReportOptionURI;
@property (nonatomic, copy) void(^ __nullable completionBlock)(JMFiltersVCResult * __nonnull result);
@end
