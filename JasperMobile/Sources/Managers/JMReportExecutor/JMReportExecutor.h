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
//  JMReportExecutor.h
//  TIBCO JasperMobile
//


/**
@author Aleksandr Dakhno odahno@tibco.com
@since 2.1
*/

@interface JSRESTBase(Export)
- (void)exportExecutionStatusWithExecutionID:(NSString *)executionID exportOutput:(NSString *)exportOutput completion:(JSRequestCompletionBlock)block;
@end

@implementation JSRESTBase(Export)
- (void)exportExecutionStatusWithExecutionID:(NSString *)executionID exportOutput:(NSString *)exportOutput completion:(JSRequestCompletionBlock)block
{
    NSString *uri = [NSString stringWithFormat:@"%@/%@/exports/%@/status", [JSConstants sharedInstance].REST_REPORT_EXECUTION_URI, executionID, exportOutput];
    JSRequest *request = [[JSRequest alloc] initWithUri:uri];
    request.expectedModelClass = [JSExecutionStatus class];
    request.restVersion = JSRESTVersion_2;
    request.completionBlock = block;
    [self sendRequest:request];
}
@end

@class JMReport;
@class JMReportPagesRange;

@interface JMReportExecutor : NSObject
@property (nonatomic, assign) BOOL shouldExecuteAsync;
// TODO: move to separate instance
@property (nonatomic, copy) NSString *format;
@property (nonatomic, copy) NSString *attachmentsPrefix;
@property (nonatomic, assign) BOOL interactive;
@property (nonatomic, strong) JMReportPagesRange *pagesRange;

- (instancetype)initWithReport:(JMReport *)report;
+ (instancetype)executorWithReport:(JMReport *)report;

- (void)executeWithCompletion:(void(^)(JSReportExecutionResponse *executionResponse, NSError *error))completion;
- (void)exportWithCompletion:(void (^)(JSExportExecutionResponse *exportResponse, NSError *error))completion;
@end