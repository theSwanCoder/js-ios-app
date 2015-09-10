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

typedef void(^JMReportSaverCompletion)(NSError *error);
typedef void(^JMReportSaverDownloadCompletion)(BOOL sholdAddToDB);

NSString * const kJMAttachmentPrefix = @"_";
NSString * const kBackgroundSessionConfigurationIdentifier = @"kBackgroundSessionConfigurationIdentifier.save.report";
NSString * const kJMReportSaverErrorDomain = @"kJMReportSaverErrorDomain";

@interface JMReportSaver()
@property (nonatomic, weak, readonly) JMReport *report;
@property (nonatomic, strong) JMSavedResources *savedReport;
//@property (nonatomic, strong) NSString *temporaryDirectory;
//@property (nonatomic, strong) NSString *originalDirectory;
@property (nonatomic, strong) JSReportExecutionResponse *requestExecution;
@property (nonatomic, strong) JSExportExecutionResponse *exportExecution;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) JMReportExecutor *reportExecutor;
@property (nonatomic, strong) JMReportPagesRange *pagesRange;
@property (nonatomic, copy) JMReportSaverDownloadCompletion downloadCompletion;
@end

@implementation JMReportSaver

#pragma mark - Lifecycle
- (instancetype)initWithReport:(JMReport *)report
{
    self = [super init];
    if (self) {
        _report = report;
        _reportExecutor = [JMReportExecutor executorWithReport:_report];
        self.downloadCompletion = @weakself(^(BOOL shouldAddToDB)) {
            
            NSString *originalDirectory = [JMSavedResources pathToFolderForSavedReport:self.savedReport];
            NSString *temporaryDirectory = [JMSavedResources pathToTempFolderForSavedReport:self.savedReport];
            
            // move saved report from temp location to origin
            if ([self isExistSavedReport:self.savedReport]) {
                [self removeReportAtPath:originalDirectory];
            }
            
            [self moveContentFromPath:temporaryDirectory
                               toPath:originalDirectory];
            [self removeTempDirectory];
            
            // save to DB
            if (shouldAddToDB) {
                // Save thumbnail image
                NSString *thumbnailURLString = [self.restClient generateThumbnailImageUrl:self.report.resourceLookup.uri];
                [self downloadThumbnailForSavedReport:self.savedReport
                                    resourceURLString:thumbnailURLString
                                           completion:nil];
            } else {
                [self removeSavedReportFromDB];
            }
        }@weakselfend;
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
    [self createNewSavedReportWithReport:self.report
                                    name:name
                                  format:format];
    
    BOOL isPrepeared = [self preparePathsForSavedReport:self.savedReport];
    if (!isPrepeared) {
        if (completionBlock) {
            // TODO: add error of creating the paths
            NSError *error = [NSError errorWithDomain:kJMReportSaverErrorDomain
                                                 code:JMReportSaverErrorTypesUndefined
                                             userInfo:nil];
            completionBlock(nil, error);
        }
    } else {
        if (!self.pagesRange) {
            NSArray *components = [pages componentsSeparatedByString:@"-"];
            NSUInteger startPage = 0;
            NSUInteger endPage = 0;
            if (components.count == 2) {
                startPage = ((NSNumber *)components[0]).unsignedIntegerValue;
                endPage = ((NSNumber *)components[1]).unsignedIntegerValue;
            } else if (components.count == 1) {
                startPage = ((NSNumber *)components.firstObject).unsignedIntegerValue;
                endPage = ((NSNumber *)components.firstObject).unsignedIntegerValue;
            }
            self.pagesRange = [JMReportPagesRange rangeWithStartPage:startPage endPage:endPage];
        }
        
        [self fetchOutputResourceURLForReportWithFileExtension:format
                                                         pages:pages
                                                    completion:@weakself(^(BOOL success, NSError *error)) {
                                                        if (success) {
                                                            [self downloadSavedReport:self.savedReport
                                                                           completion:@weakself(^(NSError *error)) {
                                                                               if (error) {
                                                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                                                       if (completionBlock) {
                                                                                           completionBlock(nil, error);
                                                                                       }
                                                                                   });
                                                                               } else {
                                                                                   self.downloadCompletion(addToDB);
                                                                                   
                                                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                                                       if (completionBlock) {
                                                                                           completionBlock(self.savedReport, nil);
                                                                                       }
                                                                                   });
                                                                               }
                                                                           }@weakselfend];
                                                        } else {
                                                            [self cancelReport];
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
              resourcePath:(NSString *)resourcePath
                completion:(SaveReportCompletion)completion
{
    if ([format isEqualToString:[JSConstants sharedInstance].CONTENT_TYPE_PDF]) {
        
        [self createNewSavedReportWithReport:self.report
                                        name:name
                                      format:format];
        BOOL isPrepeared = [self preparePathsForSavedReport:self.savedReport];
        if (isPrepeared) {
            if (completion) {
                // TODO: add error of creating the paths
                NSError *error = [NSError errorWithDomain:kJMReportSaverErrorDomain
                                                     code:JMReportSaverErrorTypesUndefined
                                                 userInfo:nil];
                completion(nil, error);
            }
        } else {
            [self downloadSavedReport:self.savedReport
          withOutputResourceURLString:resourcePath
                           completion:@weakself(^(NSError *error)) {
                               if (error) {
                                   [self cancelReport];
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       if (completion) {
                                           completion(nil, error);
                                       }
                                   });
                               } else {
                                   self.downloadCompletion(YES);
                                   
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       if (completion) {
                                           completion(self.savedReport, nil);
                                       }
                                   });
                               }
                           }@weakselfend];
        }
    } else{
        // at the moment HTML doesn't support
    }
}

- (void)cancelReport
{
    [self.reportExecutor cancel];
    [self.downloadTask cancelByProducingResumeData:nil];
    
    NSString *temporaryDirectory = [JMSavedResources pathToFolderForSavedReport:self.savedReport];
    [self removeReportAtPath:temporaryDirectory];
    [self removeTempDirectory];
    [self removeSavedReportFromDB];
}

#pragma mark - Private API
- (void)createNewSavedReportWithReport:(JMReport *)report name:(NSString *)name format:(NSString *)format
{
    self.savedReport = [JMSavedResources addReport:report.resourceLookup withName:name format:format];
}

- (void)removeSavedReportFromDB
{
    [self.savedReport removeReport];
}

- (BOOL)preparePathsForSavedReport:(JMSavedResources *)savedReport
{
    NSString *originalDirectory = [JMSavedResources pathToFolderForSavedReport:self.savedReport];
    NSString *temporaryDirectory = [JMSavedResources pathToTempFolderForSavedReport:self.savedReport];
    
    NSError *errorOfCreationLocation = [self createLocationAtPath:originalDirectory];
    NSError *errorOfCreationTempLocation = [self createLocationAtPath:temporaryDirectory];
    BOOL isPrepared = NO;
    if ( !(errorOfCreationLocation || errorOfCreationTempLocation) ) {
        isPrepared = YES;
    }
    return isPrepared;
}

- (void)downloadSavedReport:(JMSavedResources *)savedReport completion:(JMReportSaverCompletion)completion
{
    [self downloadSavedReport:savedReport
  withOutputResourceURLString:[self outputResourceURL]
                   completion:completion];
}

- (void)downloadSavedReport:(JMSavedResources *)savedReport
withOutputResourceURLString:(NSString *)outputResourceURLString
                 completion:(JMReportSaverCompletion)completion
{
    [JMUtils showNetworkActivityIndicator];
    [self downloadResourceFromURLString:outputResourceURLString
                             completion:@weakself(^(NSURL *location, NSURLResponse *response, NSError *error)) {
                                 [JMUtils hideNetworkActivityIndicator];
                                 
                                 if (!error) {
                                     // save report to disk
                                     NSString *tempReportPath = [JMSavedResources absoluteTempPathToSavedReport:self.savedReport];
                                     NSError *error = [self moveResourceFromPath:location.path toPath:tempReportPath];
                                     if (error) {
                                         if (completion) {
                                             completion(error);
                                         }
                                     } else {
                                         // save attachments or exit
                                         if ([savedReport.format isEqualToString:[JSConstants sharedInstance].CONTENT_TYPE_PDF]) {
                                             if (completion) {
                                                 completion(nil);
                                             }
                                         } else {
                                             [self downloadAttachmentsForSavedReport:self.savedReport
                                                                          completion:@weakself(^(NSError *attError)) {
                                                                              if (completion) {
                                                                                  completion(attError);
                                                                              }
                                                                          }@weakselfend];
                                         }
                                     }
                                 }else {
                                     if (completion) {
                                         completion(error);
                                     }
                                 }
                             }@weakselfend];
}

- (void)downloadAttachmentsForSavedReport:(JMSavedResources *)savedReport completion:(JMReportSaverCompletion)completion
{
    NSMutableArray *attachmentNames = [NSMutableArray array];
    for (JSReportOutputResource *attachment in self.exportExecution.attachments) {
        [attachmentNames addObject:attachment.fileName];
    }
    
    __block NSInteger attachmentCount = attachmentNames.count;
    if (attachmentCount) {
        for (NSString *attachmentName in attachmentNames) {
            NSString *attachmentURLString = [self attachmentURLWithName:attachmentName];
            
            [JMUtils showNetworkActivityIndicator];
            [self downloadResourceFromURLString:attachmentURLString
                                     completion:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                         [JMUtils hideNetworkActivityIndicator];
                                         
                                         if (error) {
                                             if (completion) {
                                                 completion(error);
                                             }
                                         } else {
                                             NSString *attachmentPath = [self attachmentPathWithName:attachmentName];
                                             NSError *error = [self moveResourceFromPath:location.path toPath:attachmentPath];
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
    NSURL *URL = [NSURL URLWithString:resourceURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    self.downloadTask = [session downloadTaskWithRequest:request
                                       completionHandler:@weakself(^(NSURL *location, NSURLResponse *response, NSError *error)) {
                                           if (completion) {
                                               completion(location, response, error);
                                           }
                                       } @weakselfend];
    [self.downloadTask resume];
}

- (void)downloadThumbnailForSavedReport:(JMSavedResources *)savedReport
                      resourceURLString:(NSString *)resourceURLString
                             completion:(JMReportSaverCompletion)completion
{
    [self downloadResourceFromURLString:resourceURLString
                             completion:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                 if (!error) {
                                     NSString *thumbnailPath = [self thumbnailPath];
                                     [self moveResourceFromPath:location.path toPath:thumbnailPath];
                                 }
                             }];
}

#pragma mark - URI helpers
- (NSString *)exportURL
{
    return [self exportURLWithExportID:self.exportExecution.uuid];
}

- (NSString *)exportURLWithExportID:(NSString *)exportID
{
    // TODO: improve logic of making server URL
    NSString *serverURL = [self.restClient.serverProfile.serverUrl stringByAppendingString:@"/rest_v2"];
    return [serverURL stringByAppendingFormat:@"%@/%@/exports/%@/", [JSConstants sharedInstance].REST_REPORT_EXECUTION_URI,self.requestExecution.requestId, exportID];
}

- (NSString *)outputResourceURL
{
    NSString *exportID = self.exportExecution.uuid;
    // Fix for JRS version smaller 5.6.0
    if (self.restClient.serverInfo.versionAsFloat < [JSConstants sharedInstance].SERVER_VERSION_CODE_EMERALD_5_6_0) {
        exportID = [NSString stringWithFormat:@"%@;pages=%@", @"html", self.pagesRange.pagesFormat];
    }
    
    NSString *outputResourceURLString = [[self exportURLWithExportID:exportID] stringByAppendingString:@"outputResource?sessionDecorator=no&decorate=no#"];
    return outputResourceURLString;
}

- (NSString *)attachmentURLWithName:(NSString *)attachmentName
{
    return [[self exportURL] stringByAppendingFormat:@"attachments/%@", attachmentName];
}

#pragma mark - File manage helpers
- (NSError *)moveResourceFromPath:(NSString *)fromPath toPath:(NSString *)toPath
{
    NSError *error;
    [[NSFileManager defaultManager] moveItemAtPath:fromPath
                                            toPath:toPath
                                             error:&error];
    return error;
}

- (NSError *)moveContentFromPath:(NSString *)fromPath toPath:(NSString *)toPath
{
    NSError *error;
    NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fromPath error:&error];
    for (NSString *item in items) {
        NSString *itemFromPath = [fromPath stringByAppendingPathComponent:item];
        NSString *itemToPath = [toPath stringByAppendingPathComponent:item];
        [self moveResourceFromPath:itemFromPath toPath:itemToPath];
    }
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

- (NSString *)attachmentPathWithName:(NSString *)attachmentName
{
    NSString *attachmentComponent = [NSString stringWithFormat:@"%@%@", (kJMAttachmentPrefix ?: @""), attachmentName];
    NSString *temporaryDirectory = [JMSavedResources pathToTempFolderForSavedReport:self.savedReport];
    NSString *attachmentPath = [temporaryDirectory stringByAppendingPathComponent:attachmentComponent];
    return attachmentPath;
}

- (NSString *)thumbnailPath
{
    NSString *originalDirectory = [JMSavedResources pathToFolderForSavedReport:self.savedReport];
    NSString *thumbnailPath = [originalDirectory stringByAppendingPathComponent:kJMThumbnailImageFileName];
    return thumbnailPath;
}

- (void)removeTempDirectory
{
    NSString *tempDirectory = [JMSavedResources pathToTempReportsFolder];
    [self removeReportAtPath:tempDirectory];
}

#pragma mark - Helpers
- (void)fetchOutputResourceURLForReportWithFileExtension:(NSString *)format
                                                   pages:(NSString *)pages
                                              completion:(void(^)(BOOL success, NSError *error))completion
{
    self.reportExecutor.shouldExecuteAsync = YES;
    self.reportExecutor.interactive = NO;
    self.reportExecutor.attachmentsPrefix = kJMAttachmentPrefix;
    self.reportExecutor.format = format;
    self.reportExecutor.pagesRange = self.pagesRange;
    
    [self.reportExecutor executeWithCompletion:@weakself(^(JSReportExecutionResponse *executionResponse, NSError *executionError)) {
        if (executionResponse) {
            self.requestExecution = executionResponse;
            [self.reportExecutor exportWithCompletion:@weakself(^(JSExportExecutionResponse *exportResponse, NSError *exportError)) {
                if (exportResponse) {
                    self.exportExecution = exportResponse;
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

- (BOOL)isExistSavedReport:(JMSavedResources *)savedReport
{
    NSString *fileReportPath = [JMSavedResources absolutePathToSavedReport:self.savedReport];
    BOOL isExistInFS = [[NSFileManager defaultManager] fileExistsAtPath:fileReportPath];
    return isExistInFS;
}

@end
