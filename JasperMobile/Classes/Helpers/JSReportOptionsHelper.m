/*
 * JasperMobile for iOS
 * Copyright (C) 2005 - 2013 Jaspersoft Corporation. All rights reserved.
 * http://community.jaspersoft.com/project/jaspermobile-ios
 *
 * Unless you have purchased a commercial license agreement from Jaspersoft,
 * the following license terms apply:
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/lgpl>.
 */

//
//  JSReportOptionsHelper.m
//  Jaspersoft Corporation
//

#import "JSReportOptionsHelper.h"
#import "JasperMobileAppDelegate.h"
#import "ReportOptions.h"

@interface JSReportOptionsHelper()

@property (nonatomic, retain) ServerProfile *serverProfile;

@end

@implementation JSReportOptionsHelper

@synthesize serverProfile = _serverProfile;

- (id)initWithServerProfile:(ServerProfile *)serverProfile {
    if (self = [super init]) {
        self.serverProfile = serverProfile;
    }
    return self;
}

- (void)updateReportOptions:(NSDictionary *)parameters forReport:(NSString *)reportUri {
    JasperMobileAppDelegate *app = [JasperMobileAppDelegate sharedInstance];
    NSManagedObjectContext *managedObjectContext = [app managedObjectContext];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ReportOptions"];
    fetchRequest.predicate = [self reportOptionsPredicateForReport:reportUri];
    NSArray *reportOptions = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    for (ReportOptions *reportOption in reportOptions) {
        [managedObjectContext deleteObject:reportOption];
    }
    
    for (NSString *icName in [parameters allKeys]) {
        ReportOptions *reportOptions = [NSEntityDescription insertNewObjectForEntityForName:@"ReportOptions" inManagedObjectContext:managedObjectContext];
        reportOptions.username = self.serverProfile.username;
        reportOptions.organization = self.serverProfile.organization;
        reportOptions.name = icName;
       
        id values = [parameters objectForKey:icName];
        if ([values isKindOfClass:[NSArray class]]) {
            reportOptions.value = [values componentsJoinedByString:@","];
            reportOptions.isListItem = [NSNumber numberWithBool:YES];
        } else {
            reportOptions.value = values;
            reportOptions.isListItem = [NSNumber numberWithBool:NO];
        }
        
        reportOptions.reportUri = reportUri;
        [self.serverProfile addReportOptionsObject:reportOptions];
    }
    
    [managedObjectContext save:nil];
}

- (NSDictionary *)reportOptionsAsDictionaryForReport:(NSString *)reportUri {
    JasperMobileAppDelegate *app = [JasperMobileAppDelegate sharedInstance];
    NSManagedObjectContext *managedObjectContext = [app managedObjectContext];

    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ReportOptions"];
    fetchRequest.predicate = [self reportOptionsPredicateForReport:reportUri];
    NSArray *reportOptions = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    if ([reportOptions count]) {
        NSMutableDictionary *reportOptionsAsDictionary = [NSMutableDictionary dictionary];
        
        for (ReportOptions *reportOption in reportOptions) {
            if ([reportOption.isListItem boolValue]) {
                [reportOptionsAsDictionary setObject:[NSMutableArray arrayWithArray:[reportOption.value componentsSeparatedByString:@","]] forKey:reportOption.name];
            } else {
                [reportOptionsAsDictionary setObject:reportOption.value forKey:reportOption.name];
            }
        }
        
        return reportOptionsAsDictionary;
    }
    
    return nil;
}

- (NSPredicate *)reportOptionsPredicateForReport:(NSString *)reportUri {
    return [NSPredicate predicateWithFormat:@"(serverProfile = %@) AND (username = %@) AND (organization = %@) AND (reportUri = %@)",
            self.serverProfile, self.serverProfile.username, self.serverProfile.organization, reportUri];
}

@end
