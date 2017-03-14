/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 2.2
 */


#import "GAITrackedViewController.h"
#import "JSReportOption.h"

@class JMReportOptionsViewController;
@protocol JMReportOptionsViewControllerDelegate <NSObject>

@required
- (void) reportOptionsViewController:(JMReportOptionsViewController *)controller didSelectOption:(JSReportOption *)option;

@end

@interface JMReportOptionsViewController : GAITrackedViewController

@property (nonatomic, strong) NSArray *listOfValues;
@property (nonatomic, strong) JSReportOption *selectedReportOption;
@property (nonatomic, weak) id <JMReportOptionsViewControllerDelegate> delegate;
@end
