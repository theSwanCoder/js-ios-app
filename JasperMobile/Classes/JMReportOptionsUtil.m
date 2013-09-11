/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2013 Jaspersoft Corporation. All rights reserved.
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
//  JMReportOptionsUtil.m
//  Jaspersoft Corporation
//

#define kJMReportOptions @"ReportOptions"

#import "JMReportOptionsUtil.h"
#import "JMReportOptions.h"
#import <Objection-iOS/Objection.h>

@implementation JMReportOptionsUtil
objection_register_singleton(JMReportOptionsUtil)
objection_requires(@"managedObjectContext");

- (void)updateReportOptions:(NSDictionary *)parameters forReport:(NSString *)reportUri
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kJMReportOptions];
    fetchRequest.predicate = [self reportOptionsPredicateForReport:reportUri];
    NSArray *options = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    for (JMReportOptions *reportOption in options) {
        [self.managedObjectContext deleteObject:reportOption];
    }
    
    for (NSString *icName in [parameters allKeys]) {
        JMReportOptions *reportOptions = [NSEntityDescription insertNewObjectForEntityForName:kJMReportOptions inManagedObjectContext:self.managedObjectContext];
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
    
    [self.managedObjectContext save:nil];
}

- (NSDictionary *)reportOptionsForReport:(NSString *)reportUri
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kJMReportOptions];
    fetchRequest.predicate = [self reportOptionsPredicateForReport:reportUri];
    NSArray *reportOptions = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    if (!reportOptions.count) return nil;
    
    NSMutableDictionary *reportOptionsAsDictionary = [NSMutableDictionary dictionary];
        
    for (JMReportOptions *reportOption in reportOptions) {
        if ([reportOption.isListItem boolValue]) {
            [reportOptionsAsDictionary setObject:[NSMutableArray arrayWithArray:[reportOption.value componentsSeparatedByString:@","]] forKey:reportOption.name];
        } else {
            [reportOptionsAsDictionary setObject:reportOption.value forKey:reportOption.name];
        }
    }
    
    return reportOptionsAsDictionary;
}

- (NSPredicate *)reportOptionsPredicateForReport:(NSString *)reportUri
{
    return [NSPredicate predicateWithFormat:@"(serverProfile = %@) AND (username = %@) AND (organization = %@) AND (reportUri = %@)",
            self.serverProfile, self.serverProfile.username, self.serverProfile.organization, reportUri];
}

@end
