//
//  JMSavedResources+Helpers.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 9/18/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMSavedResources+Helpers.h"
#import "JMServerProfile+Helpers.h"

NSString * const kJMSavedResources = @"SavedResources";


@implementation JMSavedResources (Helpers)

+ (JMSavedResources *)savedReportsFromResourceLookup:(JSResourceLookup *)resource
{
    NSFetchRequest *fetchRequest = [self savedReportsFetchRequest:resource.label];
    return [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] lastObject];
}

+ (void)addReport:(JSResourceLookup *)resource withName:(NSString *)name format:(NSString *)format
{
    JMServerProfile *activeServerProfile = [JMServerProfile activeServerProfile];
    JMSavedResources *savedReport = [NSEntityDescription insertNewObjectForEntityForName:kJMSavedResources inManagedObjectContext:self.managedObjectContext];
    savedReport.label = name;
    savedReport.uri = resource.uri;
    savedReport.wsType = resource.resourceType;
    savedReport.creationDate = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
    savedReport.resourceDescription = resource.resourceDescription;
    savedReport.username = activeServerProfile.username;
    savedReport.organization = activeServerProfile.organization;
    savedReport.format = format;
    [activeServerProfile addSavedResourcesObject:savedReport];
    
    [self.managedObjectContext save:nil];
}

+ (void)removeReport:(JSResourceLookup *)resource
{
    JMSavedResources *savedReport = [self savedReportsFromResourceLookup:resource];
    NSString *pathToReport = [[[JMUtils documentsReportDirectoryPath] stringByAppendingPathComponent:savedReport.label] stringByAppendingPathExtension:savedReport.format];
    
    [[NSFileManager defaultManager] removeItemAtPath:pathToReport error:nil];
    [self.managedObjectContext deleteObject:savedReport];
    [self.managedObjectContext save:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMSavedResourcesDidChangedNotification object:nil];
}

+ (BOOL)isAvailableReportName:(NSString *)reportName
{
    NSFetchRequest *fetchRequest = [self savedReportsFetchRequest:reportName];
    return ([self.managedObjectContext countForFetchRequest:fetchRequest error:nil] == 0);
}

- (void)renameReportTo:(NSString *)newName
{
    NSString *currentPath = [[[JMUtils documentsReportDirectoryPath] stringByAppendingPathComponent:self.label] stringByAppendingPathExtension:self.format];
    NSString *newPath = [[[JMUtils documentsReportDirectoryPath] stringByAppendingPathComponent:newName] stringByAppendingPathExtension:self.format];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] moveItemAtPath:currentPath toPath:newPath error:&error];
    if (!error) {
        self.label = newName;
        [self.managedObjectContext save:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kJMSavedResourcesDidChangedNotification object:nil];
    }
}

- (JSResourceLookup *)wrapperFromSavedReports
{
    JSResourceLookup *resource = [[JSResourceLookup alloc] init];
    resource.uri = self.uri;
    resource.label = self.label;
    resource.resourceType = self.wsType;
    resource.creationDate = self.creationDate;
    resource.resourceDescription = self.resourceDescription;
    return resource;
}

#pragma mark - Private

+ (NSManagedObjectContext *)managedObjectContext
{
    return [JMUtils managedObjectContext];
}

+ (NSFetchRequest *)savedReportsFetchRequest:(NSString *)resourceName
{
    JMServerProfile *activeServerProfile = [JMServerProfile activeServerProfile];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kJMSavedResources];
    NSMutableString *format = [NSMutableString stringWithString:@"(serverProfile == %@) AND (label LIKE[cd] %@) AND (username LIKE[cd] %@) AND "];
    
    if (activeServerProfile.organization.length) {
        [format appendString:@"(organization LIKE[cd] %@)"];
    } else {
        [format appendString:@"(organization = %@)"];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:format, activeServerProfile, resourceName, activeServerProfile.username, activeServerProfile.organization];
    fetchRequest.predicate = predicate;
    
    return fetchRequest;
}

@end
