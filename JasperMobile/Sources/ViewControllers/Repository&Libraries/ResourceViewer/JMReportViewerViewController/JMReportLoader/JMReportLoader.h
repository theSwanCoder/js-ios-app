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
    JMReportLoaderErrorTypeAuthentification
};

@class JMReport;
@protocol JMReportLoader <NSObject>

@required
@property (nonatomic, weak, readonly) JMReport *report;
@property (nonatomic, assign, readonly) BOOL isReportInLoadingProcess;

- (instancetype)initWithReport:(JMReport *)report;
+ (instancetype)loaderWithReport:(JMReport *)report;

- (void)fetchStartPageWithCompletion:(void(^)(BOOL success, NSError *error))completionBlock;

- (void)fetchPageNumber:(NSInteger)pageNumber withCompletion:(void(^)(BOOL success, NSError *error))completionBlock;

- (void) cancelReport;

@end

