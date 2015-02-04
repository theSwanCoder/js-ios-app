//
//  JMReportLoader.h
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 1/25/15.
//  Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#import "JMReportClientHolder.h"

@protocol JMReportLoaderDelegate;

@interface JMReportLoader : NSObject <JMResourceClientHolder, JMReportClientHolder>
@property (nonatomic, weak) id<JMReportLoaderDelegate>delegate;
@property (nonatomic, strong) NSArray *inputControls;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, readonly) NSInteger countOfPages;
@property (nonatomic, readonly) BOOL isMultiPageReport;

- (instancetype)initWithResourceLookup:(JSResourceLookup *)resource;
- (void) runReportExecution;
- (void) startLoadPage:(NSInteger)page withCompletion:(void(^)(NSString *HTMLString, NSString *baseURL))completionBlock;
- (void) cancelReport;
@end

@protocol JMReportLoaderDelegate <NSObject>
@optional
// run report execution
- (void)reportLoaderDidRunReportExecution:(JMReportLoader *)reportLoader;
- (void)reportLoaderDidEndReportExecution:(JMReportLoader *)reportLoader;
- (void)reportLoaderDidEndWithEmptyReport:(JMReportLoader *)reportLoader;
// page info
- (void)reportLoader:(JMReportLoader *)reportLoader didReceiveCountOfPages:(NSUInteger)countOfPages;
- (void)reportLoader:(JMReportLoader *)reportLoader didUpdateIsMultipageReportValue:(BOOL)isMultipageReport;
// start export execution
- (void)reportLoaderDidBeginExportExecution:(JMReportLoader *)reportLoader forPageNumber:(NSInteger)pageNumber;
- (void)reportLoaderDidEndExportExecution:(JMReportLoader *)loader forPageNumber:(NSInteger)pageNumber;
// start load output resources
- (void)reportLoaderDidBeginLoadOutputResources:(JMReportLoader *)reportLoader forPageNumber:(NSInteger)pageNumber;
- (void)reportLoaderDidEndLoadOutputResources:(JMReportLoader *)reportLoader forPageNumber:(NSInteger)pageNumber;
// cancel
- (void)reportLoaderDidCancel:(JMReportLoader *)reportLoader;
// load html
- (void)reportLoader:(JMReportLoader *)reportLoader didLoadHTMLString:(NSString *)HTMLString withBaseURL:(NSString *)baseURL forPageNumber:(NSUInteger)pageNumber;
- (void)reportLoader:(JMReportLoader *)reportLoader didFailedLoadHTMLStringWithError:(JSErrorDescriptor *)error forPageNumber:(NSInteger)pageNumber;
@end