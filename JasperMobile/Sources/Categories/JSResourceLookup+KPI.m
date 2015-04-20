/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
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
//  JSResourceLookup+KPI.m
//  TIBCO JasperMobile
//

#import "JSResourceLookup+KPI.h"


@implementation JSResourceLookup (KPI)

- (void)fetchKPIwithCompletion:(void(^)(NSDictionary *kpi, NSError *error))completion
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        id kpiJSON;

        NSString *pathToKPI = [NSString stringWithFormat:@"%@/rest_v2/reports%@_files/KPI.json", self.restClient.serverProfile.serverUrl, self.uri];
        NSURL *URLforKPI = [NSURL URLWithString:pathToKPI];
        NSURLRequest *requestForKPI = [NSURLRequest requestWithURL:URLforKPI];
        NSURLResponse *response;
        NSError *error;

        NSData *kpiJSONData = [NSURLConnection sendSynchronousRequest:requestForKPI returningResponse:&response error:&error];
        if (kpiJSONData) {
            NSError *parseError;
            kpiJSON = [NSJSONSerialization JSONObjectWithData:kpiJSONData options:0 error:&parseError];
        } else {
            NSLog(@"Error getting KPI: %@", error.localizedDescription);
        }

        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (completion && [kpiJSON isKindOfClass:[NSArray class]] && ((NSArray *)kpiJSON).firstObject ) {
                completion(((NSArray *)kpiJSON).firstObject, error);
            }
        });

    });
}

@end