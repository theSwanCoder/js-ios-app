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
#import "JMReportExecutor.h"
#import "JMReportPagesRange.h"

NSString * const kJMAttachmentPrefix = @"_";
NSString * const kBackgroundSessionConfigurationIdentifier = @"kBackgroundSessionConfigurationIdentifier.save.report";

@interface JMReportSaver()
@property (nonatomic, weak, readonly) JMReport *report;
@property (nonatomic, strong) NSString *temporaryDirectory;
@property (nonatomic, strong) NSString *originalDirectory;
@property (nonatomic, strong) JSReportExecutionResponse *requestExecution;
@property (nonatomic, strong) JSExportExecutionResponse *exportExecution;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) JMReportPagesRange *pagesRange;
@property (nonatomic, strong) JMReportExecutor *reportExecutor;
@end

@implementation JMReportSaver

#pragma mark - Lifecycle
- (instancetype)initWithReport:(JMReport *)report
{
    self = [super init];
    if (self) {
        _report = report;
        _reportExecutor = [JMReportExecutor executorWithReport:_report];
        _reportExecutor.shouldExecuteAsync = YES;
        _reportExecutor.interactive = NO; // TODO: need change this value?
        _reportExecutor.attachmentsPrefix = kJMAttachmentPrefix;
    }
    return self;
}

#pragma mark - Public API
- (void)saveReportWithName:(NSString *)name
                    format:(NSString *)format
                     pages:(NSString *)pages
                   addToDB:(BOOL)addToDB
                completion:(SaveReportCompletion)completionBlock
{
    [self preparePathsForName:name fileExtension:format];

    NSError *errorOfCreationLocation = [self createLocationAtPath:self.temporaryDirectory];
    if (errorOfCreationLocation) {
        if (completionBlock) {
            completionBlock(nil, errorOfCreationLocation);
        }
    } else {
        if (!self.pagesRange) {
            NSArray *components = [pages componentsSeparatedByString:@"-"];
            NSUInteger startPage = 0;
            NSUInteger endPage = 0;
            if (components.count == 2) {
                startPage = ((NSNumber *)components[0]).integerValue;
                endPage = ((NSNumber *)components[1]).integerValue;
            } else if (components.count == 1) {
                startPage = ((NSNumber *)components.firstObject).integerValue;
                endPage = ((NSNumber *)components.firstObject).integerValue;
            }
            self.pagesRange = [JMReportPagesRange rangeWithStartPage:startPage endPage:endPage];
        }

        [self fetchOutputResourceURLForReportWithFileExtension:format
                                                    completion:@weakself(^(BOOL success, NSError *error)) {
                                                        if (success) {
                                                            [self downloadReportWithName:name
                                                                           fileExtension:format
                                                                              completion:@weakself(^(NSError *error)) {
                                                                                      if (error) {
                                                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                                                              if (completionBlock) {
                                                                                                  completionBlock(nil, error);
                                                                                              }
                                                                                          });
                                                                                      } else {
                                                                                          // move saved report from temp location to origin

                                                                                          if ([self isExistSavedReportWithName:name fileExtension:format]) {
                                                                                              [self removeReportAtPath:self.originalDirectory];
                                                                                          }
                                                                                          [self moveResourceFromPath:self.temporaryDirectory
                                                                                                              toPath:self.originalDirectory];

                                                                                          // save to DB
                                                                                          if (addToDB) {
                                                                                              [JMSavedResources addReport:self.report.resourceLookup
                                                                                                                 withName:name
                                                                                                                   format:format];
                                                                                              // Save thumbnail image
                                                                                              [self downloadThumbnailForReportWithName:name
                                                                                                                         fileExtension:format
                                                                                                                     resourceURLString:[self.restClient generateThumbnailImageUrl:self.report.resourceLookup.uri]];
                                                                                          }

                                                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                                                              if (completionBlock) {
                                                                                                  NSString *reportURI = [JMSavedResources uriForSavedReportWithName:name format:format];
                                                                                                  completionBlock(reportURI, nil);
                                                                                              }
                                                                                          });
                                                                                      }
                                                                                  }@weakselfend];
                                                        } else {
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                if (completionBlock) {
                                                                    completionBlock(nil, error);
                                                                }
                                                            });
                                                        }
                                                    }@weakselfend];
    }
}


- (void)saveReportWithName:(NSString *)name
                    format:(NSString *)format
                pagesRange:(JMReportPagesRange *)pagesRange
                   addToDB:(BOOL)addToDB
                completion:(SaveReportCompletion)completionBlock
{
    self.pagesRange = pagesRange;

    [self saveReportWithName:name
                      format:format
                       pages:pagesRange.pagesFormat
                     addToDB:addToDB completion:completionBlock];
}

- (void)cancelReport
{
    [self.restClient cancelAllRequests];
    [self.downloadTask cancel];
    [self removeReportAtPath:self.temporaryDirectory];
}

#pragma mark - Private API
- (void)preparePathsForName:(NSString *)name fileExtension:(NSString *)fileExtension
{
    NSString *tempName = [NSString stringWithFormat:@"Temp_%@", name];
    self.temporaryDirectory = [JMSavedResources pathToReportDirectoryWithName:tempName
                                                                       format:fileExtension];

    self.originalDirectory = [JMSavedResources pathToReportDirectoryWithName:name
                                                                      format:fileExtension];
}

- (void)downloadReportWithName:(NSString *)reportName
                 fileExtension:(NSString *)fileExtension
                    completion:(void(^)(NSError *error))completion
{
    [JMUtils showNetworkActivityIndicator];
    
    [self downloadResourceFromURLString:[self outputResourceURL]
                             completion:@weakself(^(NSURL *location, NSURLResponse *response, NSError *error)) {
                                 if (!error) {
                                     // save report to disk
                                     NSURL *reportLocation = [self reportLocationForPath:self.temporaryDirectory withFileExtention:fileExtension];
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
                                             NSURL *attachmentLocation = [self attachmentLocationForPath:self.temporaryDirectory withName:attachmentName];
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
    self.downloadTask = [session downloadTaskWithRequest:request
                                                            completionHandler:@weakself(^(NSURL *location, NSURLResponse *response, NSError *error)) {
                                                                [JMUtils hideNetworkActivityIndicator];
                                                                if (error) {
                                                                    [self cancelReport];
                                                                }
                                                                if (completion) {
                                                                    completion(location, response, error);
                                                                }
                                                            } @weakselfend];
    [self.downloadTask resume];
}

- (void)downloadThumbnailForReportWithName:(NSString *)reportName
                             fileExtension:(NSString *)fileExtension
                         resourceURLString:(NSString *)resourceURLString
{
    [self downloadResourceFromURLString:resourceURLString
                             completion:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                 if (!error) {
                                     NSURL *thumbnailLocation = [self thumbnailLocationForPath:self.originalDirectory];
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
    [[NSFileManager defaultManager] moveItemAtURL:fromLocation
                                            toURL:toLocation
                                            error:&error];
    return error;
}

- (NSError *)moveResourceFromPath:(NSString *)fromPath toPath:(NSString *)toPath
{
    NSError *error;
    [[NSFileManager defaultManager] moveItemAtPath:fromPath
                                            toPath:toPath
                                             error:&error];
    return error;
}

- (NSError *)removeReportAtPath:(NSString *)path
{
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    return error;
}

- (NSError *)createLocationAtPath:(NSString *)path
{
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:path
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    return error;
}

- (NSURL *)reportLocationForPath:(NSString *)path withFileExtention:(NSString *)format
{
    NSString *fullPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", kJMReportFilename, format]];
    NSURL *reportLocation = [NSURL fileURLWithPath:fullPath];
    return reportLocation;
}

- (NSURL *)attachmentLocationForPath:(NSString *)path withName:(NSString *)attachmentName
{
    NSString *fullPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", kJMAttachmentPrefix, attachmentName]];
    NSURL *reportLocation = [NSURL fileURLWithPath:fullPath];
    return reportLocation;
}

- (NSURL *)thumbnailLocationForPath:(NSString *)path
{
    NSString *fullPath = [path stringByAppendingPathComponent:kJMThumbnailImageFileName];
    NSURL *reportLocation = [NSURL fileURLWithPath:fullPath];
    return reportLocation;
}

#pragma mark - Helpers
- (void)fetchOutputResourceURLForReportWithFileExtension:(NSString *)format
                                              completion:(void(^)(BOOL success, NSError *error))completion
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
//    self.reportExecutor.shouldExecuteAsync = YES;
//
//    self.reportExecutor.interactive = NO;
//    self.reportExecutor.attachmentsPrefix = kJMAttachmentPrefix;
    self.reportExecutor.format = format;
    self.reportExecutor.pagesRange = self.pagesRange;

    [self.reportExecutor executeWithCompletion:@weakself(^(JSReportExecutionResponse *executionResponse, NSError *executionError)) {
        if (executionResponse) {
            self.requestExecution = executionResponse;
            [self.reportExecutor exportWithCompletion:@weakself(^(JSExportExecutionResponse *exportResponse, NSError *exportError)) {
                if (exportResponse) {
                    self.exportExecution = exportResponse;
                    NSLog(@"executionID: %@", self.requestExecution.requestId);
                    NSLog(@"exeportID: %@", self.exportExecution.uuid);
                    if (completion) {
                        completion(YES, nil);
                    }
                } else {
                    if (completion) {
                        completion(NO, exportError);
                    }
                }
            }@weakselfend];
        } else {
            if (completion) {
                completion(NO, executionError);
            }
        }
    }@weakselfend];
}

- (BOOL)isExistSavedReportWithName:(NSString *)name fileExtension:(NSString *)fileExtension
{
    BOOL isExistInDB = ![JMSavedResources isAvailableReportName:name
                                                     format:fileExtension];
    BOOL isExistInFS = [[NSFileManager defaultManager] fileExistsAtPath:self.originalDirectory];
    return isExistInFS || isExistInDB;
}

@end
