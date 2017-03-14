/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 2.3
 */

#import "JMResource.h"

@interface JMExportResource : JMResource
@property (nonatomic, strong) NSString *format;
    
- (instancetype)initWithResourceLookup:(JSResourceLookup *)resourceLookup format:(NSString *)format;
+ (instancetype)resourceWithResourceLookup:(JSResourceLookup *)resourceLookup format:(NSString *)format;

@end
