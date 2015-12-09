//
//  JMReportLoader.h
//  TIBCO JasperMobile
//
//  Created by Oleksii Gubariev on 4/6/15.
//  Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JMReportLoaderErrorType) {
    JMReportLoaderErrorTypeUndefined,
    JMReportLoaderErrorTypeEmtpyReport,
    JMReportLoaderErrorTypeAuthentification,
    JMReportLoaderErrorTypeLoadingCanceled
};

@class JMReport;
@protocol JMReportLoaderDelegate;
@protocol JMJavascriptNativeBridgeProtocol;

@protocol JMReportLoader <NSObject>

@required
@property (nonatomic, weak, readonly) JMReport *report;
@property (nonatomic, assign, readonly) BOOL isReportInLoadingProcess;
@property (nonatomic, weak) id<JMReportLoaderDelegate> delegate;
@property (nonatomic, strong) id<JMJavascriptNativeBridgeProtocol>bridge;

- (instancetype)initWithReport:(JMReport *)report;
+ (instancetype)loaderWithReport:(JMReport *)report;

- (void)runReportWithPage:(NSInteger)page completion:(void(^)(BOOL success, NSError *error))completionBlock;
- (void)fetchPageNumber:(NSInteger)pageNumber withCompletion:(void(^)(BOOL success, NSError *error))completionBlock;
- (void)cancel;
- (void)destroy;

@optional
- (void)changeFromPage:(NSInteger)fromPage toPage:(NSInteger)toPage withCompletion:(void (^)(BOOL success, NSError *error))completion;
- (void)applyReportParametersWithCompletion:(void (^)(BOOL success, NSError *error))completion;
- (void)refreshReportWithCompletion:(void(^)(BOOL success, NSError *error))completion;
- (void)exportReportWithFormat:(NSString *)exportFormat;
- (void)authenticate;

@end


@protocol JMReportLoaderDelegate <NSObject>
@optional
- (void)reportLoader:(id<JMReportLoader>)reportLoader didReceiveOnClickEventForResourceLookup:(JSResourceLookup *)resourceLookup withParameters:(NSArray *)reportParameters;
- (void)reportLoader:(id<JMReportLoader>)reportLoder didReceiveOnClickEventForReference:(NSURL *)urlReference;
- (void)reportLoader:(id<JMReportLoader>)reportLoader didReceiveOutputResourcePath:(NSString *)resourcePath fullReportName:(NSString *)fullReportName;
@end

