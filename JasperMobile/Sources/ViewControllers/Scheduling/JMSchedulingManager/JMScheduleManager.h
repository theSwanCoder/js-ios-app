/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2016 TIBCO Software, Inc. All rights reserved.
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
//  JMScheduleManager.h
//  TIBCO JasperMobile
//

/**
@author Aleksandr Dakhno odahno@tibco.com
@since 2.3
*/

#import "JMResourcesListLoader.h"

@class JSScheduleResponse;
@class JSScheduleRequest;
@class JSScheduleSummary;

@interface JMScheduleManager : NSObject
- (void)loadSchedulesWithCompletion:(void (^)(NSArray <JSScheduleSummary *> *, NSError *))completion;
- (void)loadSchedulesForResourceLookup:(JSResourceLookup *)resourceLookup completion:(void (^)(NSArray <JSScheduleSummary *> *, NSError *))completion;
- (void)loadScheduleInfoWithScheduleId:(NSInteger)scheduleId completion:(void(^)(JSScheduleResponse *, NSError *))completion;
- (void)createJobWithData:(JSScheduleResponse *)jobData completion:(void (^)(JSScheduleResponse *, NSError *))completion;
- (void)updateSchedule:(JSScheduleResponse *)schedule completion:(void(^)(JSScheduleResponse *, NSError *))completion;
- (void)deleteJobWithJobIdentifier:(NSInteger)identifier completion:(void (^)(NSError *))completion;
@end