/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

@import UIKit;

@class JSReportPart;
@protocol JMReportPartViewToolbarDelegate;


@interface JMReportPartViewToolbar : UIView
@property (nonatomic, strong, readonly) JSReportPart *currentPart;
@property (nonatomic, strong) NSArray <JSReportPart *> *parts;
@property (nonatomic, weak) NSObject <JMReportPartViewToolbarDelegate> *delegate;
- (void)updateCurrentPartForPage:(NSInteger)page;
@end

@protocol JMReportPartViewToolbarDelegate
@optional
- (void)reportPartViewToolbarDidChangePart:(JMReportPartViewToolbar *)toolbar;
@end
