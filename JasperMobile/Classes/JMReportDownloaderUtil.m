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
//  JMReportDownloaderUtil.m
//  Jaspersoft Corporation
//

#import "JMReportDownloaderUtil.h"
#import "JMConstants.h"
#import "JMRequestDelegate.h"
#import <Objection-iOS/Objection.h>

@implementation JMReportDownloaderUtil
objection_register_singleton(JMReportDownloaderUtil)
objection_requires(@"reportClient", @"constants")

@synthesize reportClient = _reportClient;

- (id <JSRequestDelegate>)runReportExecution:(NSString *)reportUri parameters:(NSArray *)parameters format:(NSString *)format path:(NSString *)path completionBlock:(void (^)(NSString *fullReportPath))completionBlock
{
    NSString * const attachmentPrefix = @"_";
    
    __block NSString *fullReportPath;

    JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        JSReportExecutionResponse *response = [result.objects objectAtIndex:0];
        JSExportExecution *export = [response.exports objectAtIndex:0];
        
        NSString *requestId = response.requestId;
        
        fullReportPath = [NSString stringWithFormat:@"%@/%@.%@", path, kJMReportFilename ,format];
        [self.reportClient saveReportOutput:requestId exportOutput:export.uuid path:fullReportPath delegate:[JMRequestDelegate requestDelegateForFinishBlock:nil]];
        
        for (JSReportOutputResource *attachment in export.attachments) {
            NSString *attachmentPath = [NSString stringWithFormat:@"%@/%@%@", path, @"_", attachment.fileName];
            [self.reportClient saveReportAttachment:requestId exportOutput:export.uuid attachmentName:attachment.fileName path:attachmentPath delegate:[JMRequestDelegate requestDelegateForFinishBlock:nil]];
        }
    }];
    
    [JMRequestDelegate setFinalBlock:^{
        completionBlock(fullReportPath);
    }];

    [self.reportClient runReportExecution:reportUri async:NO outputFormat:format interactive:YES freshData:YES saveDataSnapshot:NO ignorePagination:YES transformerKey:nil pages:nil attachmentsPrefix:attachmentPrefix parameters:parameters delegate:delegate];

    return delegate;
}


- (id <JSRequestDelegate>)runReport:(NSString *)reportUri parameters:(NSDictionary *)parameters format:(NSString *)format path:(NSString *)path completionBlock:(void (^)(NSString *fullReportPath))completionBlock
{
    __block NSString *fullReportPath;

    JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        JSReportDescriptor *reportDescriptor = [result.objects objectAtIndex:0];
        NSString *uuid = reportDescriptor.uuid;

        BOOL isPDF = [[format lowercaseString] isEqualToString:self.constants.CONTENT_TYPE_PDF];
        __block NSInteger numberOfAttachments = isPDF ? 1 : reportDescriptor.attachments.count;
        __block NSInteger downloadedAttachments = 0;

        for (JSReportAttachment *attachment in reportDescriptor.attachments) {
            NSString *fileName = attachment.name;
            NSString *fileType = attachment.type;
            NSString *extension = @"";

            if ([fileType isEqualToString:@"text/html"]) {
                extension = @".html";
            } else if ([fileType isEqualToString:@"application/pdf"]) {
                extension = @".pdf";
            // Skip to download all images for PDF report format
            } else if (isPDF) {
                continue;
            }

            // The path to write a file
            NSString *resourceFile = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", extension.length == 0 ? fileName : kJMReportFilename, extension]];

            // Set as main file to render in web view if extension is equals to HTML or PDF
            if (extension.length) {
                fullReportPath = resourceFile;
            }

            [self.reportClient reportFile:uuid fileName:fileName path:resourceFile usingBlock:^(JSRequest *request) {
                request.timeoutInterval = 0;
                // Request delegate uses as counter for asynchronous requests and finish block is not needed
                request.delegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
                    @synchronized (self) {
                        downloadedAttachments++;

                        if (downloadedAttachments == numberOfAttachments) {
                            completionBlock(fullReportPath);
                        }
                    }
                }];
            }];
        }
    }];

    [self.reportClient runReport:reportUri reportParams:parameters format:format delegate:delegate];

    return delegate;
}

@end
