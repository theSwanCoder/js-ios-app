//
//  JMReportViewerPaginationToolbar.h
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 1/25/15.
//  Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

@protocol JMReportViewerPaginationToolbarDelegate;

@interface JMReportViewerPaginationToolbar : UIView
@property (nonatomic, weak) id<JMReportViewerPaginationToolbarDelegate>toolBarDelegate;
@property (nonatomic, assign) NSInteger countOfPages;
@property (nonatomic, assign) NSInteger currentPage;
- (void)updateCurrentPageWithPageNumber:(NSUInteger)pageNumber;
@end

@protocol JMReportViewerPaginationToolbarDelegate <NSObject>
@optional
- (void)reportViewerPaginationToolbar:(JMReportViewerPaginationToolbar *)toolbar didChangePage:(NSUInteger)page;
- (void)reportViewerPaginationToolbarWillBeginChangePage:(JMReportViewerPaginationToolbar *)toolbar;
@end
