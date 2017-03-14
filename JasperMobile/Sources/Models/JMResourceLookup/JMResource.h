/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.5
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JMResourceType) {
    JMResourceTypeFile,
    JMResourceTypeFolder,
    JMResourceTypeSavedReport,
    JMResourceTypeSavedDashboard,
    JMResourceTypeReport,
    JMResourceTypeTempExportedReport,
    JMResourceTypeTempExportedDashboard,
    JMResourceTypeDashboard,
    JMResourceTypeLegacyDashboard,
    JMResourceTypeSchedule
};

@interface JMResource : NSObject
@property (nonatomic, strong, nonnull) JSResourceLookup *resourceLookup;
@property (nonatomic, assign) JMResourceType type;
- (instancetype __nullable)initWithResourceLookup:(JSResourceLookup *__nonnull)resourceLookup;
+ (instancetype __nullable)resourceWithResourceLookup:(JSResourceLookup *__nonnull)resourceLookup;
- (id __nullable)modelOfResource;
- (NSString *__nullable)localizedResourceType;
- (NSString *__nullable)resourceViewerVCIdentifier;
- (NSString *__nullable)infoVCIdentifier;
    
+ (JMResourceType)typeForResourceLookupType:(nonnull NSString *)resourceLookupType;

@end
