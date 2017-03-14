/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.9
 */

@import UIKit;

@class JMReportViewerToolBar;
@protocol JMReportViewerToolBarDelegate <NSObject>

@optional
- (void)toolbar:(JMReportViewerToolBar *)toolbar
 changeFromPage:(NSInteger)fromPage
         toPage:(NSInteger)toPage;
@end

@interface JMReportViewerToolBar : UIView

@property (nonatomic, weak) id <JMReportViewerToolBarDelegate> toolbarDelegate;

@property (nonatomic, assign) NSInteger countOfPages;
@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, assign) BOOL enable;
@end
