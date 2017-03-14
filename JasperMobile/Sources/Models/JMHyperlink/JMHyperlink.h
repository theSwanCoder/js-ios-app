/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

@import Foundation;
#import "JaspersoftSDK.h"

typedef NS_ENUM(NSInteger, JMHyperlinkType) {
    JMHyperlinkTypeReportExecution,
    JMHyperlinkTypeReportExecutionDestination,
    JMHyperlinkTypeReportExecutionOutput,
    JMHyperlinkTypeLocalAnchor,
    JMHyperlinkTypeLocalPage,
    JMHyperlinkTypeReference,
    JMHyperlinkTypeRemoteAnchor,
    JMHyperlinkTypeRemotePage,
    JMHyperlinkTypeAdHocExecution
};


@interface JMHyperlink : NSObject
@property (nonatomic) JMHyperlinkType type;
@property (nonatomic, strong) NSString *href;
@property (nonatomic, strong) JSReportDestination *destination;
@property (nonatomic, strong) NSArray <JSReportParameter *>*parameters;
@property (nonatomic, strong) NSArray *outputFormats;
+ (instancetype)hyperlinkWithHref:(NSString *)href withRawData:(NSDictionary *)data;
@end
