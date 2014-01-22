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
//  JMReportDownloaderUtil.h
//  Jaspersoft Corporation
//

#import <Foundation/Foundation.h>
#import "JMReportClientHolder.h"
#import <jaspersoft-sdk/JaspersoftSDK.h>

/**
 Helps to run report, download it with all attachments and save to the file system
 
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @since 1.8
 */
@interface JMReportDownloaderUtil : NSObject <JMReportClientHolder>

@property (nonatomic, strong) JSConstants *constants;

// Runs report using REST v2 report execution service
// Returns delegate to provide a possibility to cancel request for it (instead of canceling all requests)
- (id <JSRequestDelegate>)runReportExecution:(NSString *)reportUri parameters:(NSArray *)parameters format:(NSString *)format path:(NSString *)path completionBlock:(void (^)(NSString *fullReportPath))completionBlock;

// Runs report using REST v1 report service
// Returns delegate to provide a possibility to cancel request for it (instead of canceling all requests)
- (id <JSRequestDelegate>)runReport:(NSString *)reportUri parameters:(NSDictionary *)parameters format:(NSString *)format path:(NSString *)path completionBlock:(void (^)(NSString *fullReportPath))completionBlock;

@end
