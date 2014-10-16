//
//  JMSavedResources+Helpers.h
//  JasperMobile
//
//  Created by Oleksii Gubariev on 9/18/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMSavedResources.h"

extern NSString * const kJMSavedResources;

@interface JMSavedResources (Helpers)

// Returns saved report from JSResourceLookup
+ (JMSavedResources *)savedReportsFromResourceLookup:(JSResourceLookup *)resource;

// Adds saved resource with path to CoreData
+ (void)addReport:(JSResourceLookup *)resource withName:(NSString *)name format:(NSString *)format;

// Removes saved resource
+ (void)removeReport:(JSResourceLookup *)resource;

// Returns YES if report with name reportName is absent
+ (BOOL)isAvailableReportName:(NSString *)reportName;

// Rename saved resource
- (void)renameReportTo:(NSString *)newName;

// Returns wrapper from SavedReports. Wrapper is a JSResourceLookup
- (JSResourceLookup *)wrapperFromSavedReports;

+ (NSString *)uriForSavedReportWithName:(NSString *)name format:(NSString *)format;

+ (NSString *)pathToDirectoryForSavedReportWithName:(NSString *)name format:(NSString *)format;

@end
