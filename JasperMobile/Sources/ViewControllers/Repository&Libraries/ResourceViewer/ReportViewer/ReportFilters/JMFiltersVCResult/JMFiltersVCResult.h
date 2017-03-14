/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
@author Oleksandr Dahno odahno@tibco.com
@since 2.6
*/

@import Foundation;
#import "JaspersoftSDK.h"

typedef NS_ENUM(NSInteger, JMFiltersVCResultType) {
    JMFiltersVCResultTypeNotChange,
    JMFiltersVCResultTypeEmptyFilters,
    JMFiltersVCResultTypeReportParameters,
    JMFiltersVCResultTypeFilterOption,
};

@interface JMFiltersVCResult : NSObject
@property (nonatomic, assign) JMFiltersVCResultType type;
@property (nonatomic, strong) NSArray <JSReportParameter *> *reportParameters;
@property (nonatomic, strong) NSString *filterOptionURI;
@end
