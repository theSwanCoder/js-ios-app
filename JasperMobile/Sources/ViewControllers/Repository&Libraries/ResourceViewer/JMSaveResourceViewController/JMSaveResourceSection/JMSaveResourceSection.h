/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @author Oleksandr Dahno odahno@tibco.com
 @since 1.9.1
*/

typedef NS_ENUM(NSInteger, JMSaveResourceSectionType) {
    JMSaveResourceSectionTypeName,
    JMSaveResourceSectionTypeFormat,
    JMSaveResourceSectionTypePageRange
};

@interface JMSaveResourceSection : NSObject
@property (nonatomic, assign) JMSaveResourceSectionType sectionType;
@property (nonatomic, copy) NSString *title;
- (instancetype)initWithSectionType:(JMSaveResourceSectionType)sectionType title:(NSString *)title;
+ (JMSaveResourceSection *)sectionWithType:(JMSaveResourceSectionType)sectionType title:(NSString *)title;
@end
