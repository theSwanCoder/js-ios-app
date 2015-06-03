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
//  JMReportSaver.m
//  TIBCO JasperMobile
//

#import "JMReportSaver.h"
#import "JMSavedResources+Helpers.h"
#import "JSResourceLookup+Helpers.h"

NSString * const kJMAttachmentPrefix = @"_";


@interface JMReportSaver()
@property (nonatomic, weak, readwrite) JMReport *report;

@property (nonatomic, strong) NSString *reportDirectory;
@property (nonatomic, strong) JSReportExecutionResponse *requestExecution;
@property (nonatomic, strong) JSExportExecutionResponse *exportExecution;
@end

@implementation JMReportSaver

#pragma mark - Lifecycle
- (instancetype)initWithReport:(JMReport *)report
{
    self = [super init];
    if (self) {
        _report = report;
    }
    return self;
}

#pragma mark - Public API
- (void)saveReportWithName:(NSString *)name format:(NSString *)format pages:(NSString *)pages addToDB:(BOOL)addToDB completion:(SaveReportCompletion)completionBlock
{
    self.reportDirectory = [JMSavedResources pathToReportDirectoryWithName:name format:format];
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:self.reportDirectory error:nil];
    BOOL isDirectoryCreated = [[NSFileManager defaultManager] createDirectoryAtPath:self.reportDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    if (!isDirectoryCreated && error) {
        if (completionBlock) {
            completionBlock(nil, error);
        }
    } else {
        [self.restClient runReportExecution:self.report.resourceLookup.uri
                                      async:NO
                               outputFormat:format
                                interactive:NO
                                  freshData:NO
                           saveDataSnapshot:YES
                           ignorePagination:NO
                             transformerKey:nil
                                      pages:pages
                          attachmentsPrefix:kJMAttachmentPrefix
                                 parameters:self.report.reportParameters
                            completionBlock:@weakself(^(JSOperationResult *result)) {
                                if (result.error) {
                                    if (completionBlock) {
                                        completionBlock(nil, result.error);
                                    }
                                } else {
                                    self.requestExecution = result.objects.firstObject;
                                    self.exportExecution = self.requestExecution.exports.firstObject;

                                    [self downloadReportWithName:name
                                                   fileExtension:format
                                                      completion:@weakself(^(NSError *error)) {
                                                          if (error) {
                                                              if (completionBlock) {
                                                                  completionBlock(nil, error);
                                                              }
                                                          } else {
                                                              if (addToDB) {
                                                                  [JMSavedResources addReport:self.report.resourceLookup
                                                                                     withName:name
                                                                                       format:format];
                                                                  // Save thumbnail image
                                                                  [self downloadThumbnailForReportWithName:name
                                                                                             fileExtension:format
                                                                                         resourceURLString:[self.report.resourceLookup thumbnailImageUrlString]];
                                                              }
                                                              if (completionBlock) {
                                                                  NSString *reportURI = [JMSavedResources uriForSavedReportWithName:name format:format];
                                                                  completionBlock(reportURI, nil);
                                                              }
                                                          }
                                                      }@weakselfend];
                                }
                            }@weakselfend];
    }
}

- (void)cancelReport
{
    [self.restClient cancelAllRequests];
    NSURLSession *session = [NSURLSession sharedSession];
    [session invalidateAndCancel];
    [[NSFileManager defaultManager] removeItemAtPath:self.reportDirectory error:nil];
}

#pragma mark - Private API

- (void)downloadReportWithName:(NSString *)reportName
                 fileExtension:(NSString *)fileExtension
                    completion:(void(^)(NSError *error))completion
{
    [JMUtils showNetworkActivityIndicator];
    
    [self downloadResourceFromURLString:[self outputResourceURL]
                             completion:@weakself(^(NSURL *location, NSURLResponse *response, NSError *error)) {
                                 if (!error) {
                                     // save report to disk
                                     NSURL *reportLocation = [NSURL fileURLWithPath:[JMSavedResources pathToReportWithName:reportName format:fileExtension]];
                                     NSError *error = [self moveResourceFromLocation:location toLocation:reportLocation];
                                     if (error) {
                                         if (completion) {
                                             completion(error);
                                         }
                                     } else {
                                         // save attachments or exit
                                         [self downloadAttachmentsForReportWithName:reportName
                                                                      fileExtension:fileExtension
                                                                         completion:@weakself(^(NSError *attError)) {
                                                                             if (completion) {
                                                                                 completion(attError);
                                                                             }
                                                                         }@weakselfend];
                                     }
                                 }else {
                                     if (completion) {
                                         completion(error);
                                     }
                                 }
                             }@weakselfend];
}

- (void)downloadAttachmentsForReportWithName:(NSString *)reportName
                               fileExtension:(NSString *)fileExtension
                                    completion:(void(^)(NSError *error))completion
{
    NSMutableArray *attachmentNames = [NSMutableArray array];
    for (JSReportOutputResource *attachment in self.exportExecution.attachments) {
        [attachmentNames addObject:attachment.fileName];
    }

    __block NSInteger attachmentCount = attachmentNames.count;
    if (attachmentCount) {
        for (NSString *attachmentName in attachmentNames) {
            NSString *attachmentURLString = [self attachmentURLWithName:attachmentName];
            [self downloadResourceFromURLString:attachmentURLString
                                     completion:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                         if (error) {
                                             if (completion) {
                                                 completion(error);
                                             }
                                         } else {
                                             NSURL *attachmentLocation = [NSURL fileURLWithPath:[self.reportDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", kJMAttachmentPrefix, attachmentName]]];
                                             NSError *error = [self moveResourceFromLocation:location toLocation:attachmentLocation];
                                             if (error) {
                                                 if (completion) {
                                                     completion(error);
                                                 }
                                             } else if (--attachmentCount == 0) {
                                                 if (completion) {
                                                     completion(nil);
                                                 }
                                             }
                                         }
                                     }];
        }
    } else {
        if (completion) {
            completion(nil);
        }
    }
}

#pragma mark - Network calls
- (void)downloadResourceFromURLString:(NSString *)resourceURLString
                           completion:(void(^)(NSURL *location, NSURLResponse *response, NSError *error))completion
{
    [JMUtils showNetworkActivityIndicator];
    NSURL *URL = [NSURL URLWithString:resourceURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request
                                                            completionHandler:@weakself(^(NSURL *location, NSURLResponse *response, NSError *error)) {
                                                                [JMUtils hideNetworkActivityIndicator];
                                                                if (error) {
                                                                    [self cancelReport];
                                                                }
                                                                if (completion) {
                                                                    completion(location, response, error);
                                                                }
                                                            } @weakselfend];
    [downloadTask resume];
}

- (void)downloadThumbnailForReportWithName:(NSString *)reportName
                             fileExtension:(NSString *)fileExtension
                         resourceURLString:(NSString *)resourceURLString
{
    [self downloadResourceFromURLString:resourceURLString
                             completion:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                 if (!error) {
                                     NSURL *thumbnailLocation = [NSURL fileURLWithPath:[self.reportDirectory stringByAppendingPathComponent:kJMThumbnailImageFileName]];
                                     [self moveResourceFromLocation:location toLocation:thumbnailLocation];
                                 }
                             }];
}

#pragma mark - URI helpers
- (NSString *)exportURL
{
    // TODO: improve logic of making server URL
    NSString *serverURL = [self.restClient.serverProfile.serverUrl stringByAppendingString:@"/rest_v2"];
    return [serverURL stringByAppendingFormat:@"%@/%@/exports/%@/", [JSConstants sharedInstance].REST_REPORT_EXECUTION_URI,self.requestExecution.requestId, self.exportExecution.uuid];
}

- (NSString *)outputResourceURL
{
    return [[self exportURL] stringByAppendingString:@"outputResource?sessionDecorator=no&decorate=no#"];
}

- (NSString *)attachmentURLWithName:(NSString *)attachmentName
{
    return [[self exportURL] stringByAppendingFormat:@"attachments/%@", attachmentName];
}

#pragma mark - File manage helpers
- (NSError *)moveResourceFromLocation:(NSURL *)fromLocation toLocation:(NSURL *)toLocation
{
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtURL:toLocation error:nil];
    [[NSFileManager defaultManager] moveItemAtURL:fromLocation
                                            toURL:toLocation
                                            error:&error];
    return error;
}

@end
