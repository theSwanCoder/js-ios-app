/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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
        
        __weak typeof(self)weakSelf = self;
        self.downloadCompletion = ^(BOOL shouldAddToDB) {
            __strong typeof(self)strongSelf = weakSelf;
            
            NSString *originalDirectory = [JMSavedResources pathToFolderForSavedReport:strongSelf.savedReport];
            NSString *temporaryDirectory = [JMSavedResources pathToTempFolderForSavedReport:strongSelf.savedReport];
            
            // move saved report from temp location to origin
            if ([strongSelf isExistSavedReport:strongSelf.savedReport]) {
                [strongSelf removeReportAtPath:originalDirectory];
                [strongSelf createLocationAtPath:originalDirectory];
            }
            
            [strongSelf moveContentFromPath:temporaryDirectory
                                     toPath:originalDirectory];
            [strongSelf removeTempDirectory];
            
            // save to DB
            if (shouldAddToDB) {
                // Save thumbnail image
                NSString *thumbnailURLString = [strongSelf.restClient generateThumbnailImageUrl:strongSelf.report.resourceLookup.uri];
                [strongSelf downloadThumbnailForSavedReport:strongSelf.savedReport
                                          resourceURLString:thumbnailURLString
                                                 completion:nil];
            }
        };
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
        
        [self createPagesRangeFromPagesString:pages];
        
        __weak typeof(self)weakSelf = self;
        [self fetchOutputResourceURLForReportWithFileExtension:format
                                                         pages:pages
                                                    completion:^(BOOL success, NSError *error) {
                                                        __strong typeof(self)strongSelf = weakSelf;
                                                        if (success) {
                                                            __weak typeof(self)weakSelf = strongSelf;
                                                            [strongSelf downloadSavedReport:strongSelf.savedReport
                                                                                 completion:^(NSError *downloadError) {
                                                                                     __strong typeof(self)strongSelf = weakSelf;
                                                                                     if (downloadError) {
                                                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                                                             if (completionBlock) {
                                                                                                 completionBlock(nil, downloadError);
                                                                                             }
                                                                                         });
                                                                                     } else {
                                                                                         strongSelf.downloadCompletion(addToDB);
                                                                                         
                                                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                                                             if (completionBlock) {
                                                                                                 completionBlock(strongSelf.savedReport, nil);
                                                                                             }
                                                                                         });
                                                                                     }
                                                                                 }];
                                                        } else {
                                                            [strongSelf cancelReport];
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                if (completionBlock) {
                                                                    completionBlock(nil, error);
                                                                }
                                                            });
                                                        }
                                                    }];
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
        if (!isPrepeared) {
            if (completion) {
                // TODO: add error of creating the paths
                NSError *error = [NSError errorWithDomain:kJMReportSaverErrorDomain
                                                     code:JMReportSaverErrorTypesUndefined
                                                 userInfo:nil];
                completion(nil, error);
            }
        } else {
            __weak typeof(self)weakSelf = self;
            [self downloadSavedReport:self.savedReport
          withOutputResourceURLString:resourcePath
                           completion:^(NSError *error) {
                               __strong typeof(self)strongSelf = weakSelf;
                               
                               if (error) {
                                   [strongSelf cancelReport];
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       if (completion) {
                                           completion(nil, error);
                                       }
                                   });
                               } else {
                                   strongSelf.downloadCompletion(YES);
                                   
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       if (completion) {
                                           completion(strongSelf.savedReport, nil);
                                       }
                                   });
                               }
                           }];
        }
    } else{
        // at the moment HTML doesn't support
    }
}

- (void)downloadResourceFromURL:(NSURL *)url completion:(void(^)(NSString *resourcePath, NSError *error))completion {

    if (!completion) {
        return;
    }

    [JMUtils showNetworkActivityIndicator];

    __weak typeof(self) weakSelf = self;
    [self downloadResourceFromURLString:url.absoluteString
                             completion:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                 [JMUtils hideNetworkActivityIndicator];

                                 __strong typeof(self) strongSelf = weakSelf;

                                 if (!error) {
                                     NSString *tempDirectory = [JMSavedResources pathToTempReportsFolder];
                                     NSString *resourceName = url.lastPathComponent;
                                     NSString *tempReportPath = [NSString stringWithFormat:@"%@/%@", tempDirectory, resourceName];
                                     NSError *moveError = [strongSelf moveResourceFromPath:location.path toPath:tempReportPath];
                                     if (moveError) {
                                         completion(nil, moveError);
                                     } else {
                                         completion(tempReportPath, nil);
                                     }
                                 } else {
                                     completion(nil, error);
                                 }

                             }];
}

- (void)cancelReport
{
    [self.reportExecutor cancel];
    [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData){
    }];
    [self.savedReport removeFromDB];
    [self removeTempDirectory];
}

#pragma mark - Private API
- (void)createNewSavedReportWithReport:(JMReport *)report name:(NSString *)name format:(NSString *)format
{
    self.savedReport = [JMSavedResources addReport:report.resourceLookup withName:name format:format];
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
    
    __weak typeof(self)weakSelf = self;
    [self downloadResourceFromURLString:outputResourceURLString
                             completion:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                 __strong typeof(self)strongSelf = weakSelf;

                                 [JMUtils hideNetworkActivityIndicator];
                                 
                                 if (!error) {
                                     // save report to disk
                                     NSString *tempReportPath = [JMSavedResources absoluteTempPathToSavedReport:strongSelf.savedReport];
                                     NSError *moveError = [strongSelf moveResourceFromPath:location.path toPath:tempReportPath];
                                     if (moveError) {
                                         if (completion) {
                                             completion(moveError);
                                         }
                                     } else {
                                         // save attachments or exit
                                         if ([savedReport.format isEqualToString:[JSConstants sharedInstance].CONTENT_TYPE_PDF]) {
                                             if (completion) {
                                                 completion(nil);
                                             }
                                         } else {
                                             [strongSelf downloadAttachmentsForSavedReport:strongSelf.savedReport
                                                                          completion:completion];
                                         }
                                     }
                                 }else {
                                     if (completion) {
                                         completion(error);
                                     }
                                 }
                             }];
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
            __weak typeof(self)weakSelf = self;
            [self downloadResourceFromURLString:attachmentURLString
                                     completion:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                         __strong typeof(self)strongSelf = weakSelf;

                                         [JMUtils hideNetworkActivityIndicator];
                                         
                                         if (error) {
                                             if (completion) {
                                                 completion(error);
                                             }
                                         } else {
                                             NSString *attachmentPath = [strongSelf attachmentPathWithName:attachmentName];
                                             NSError *moveError = [strongSelf moveResourceFromPath:location.path toPath:attachmentPath];
                                             if (moveError) {
                                                 if (completion) {
                                                     completion(moveError);
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
                                       completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                           if (completion) {
                                               completion(location, response, error);
                                           }
                                       }];
    [self.downloadTask resume];
}

- (void)downloadThumbnailForSavedReport:(JMSavedResources *)savedReport
                      resourceURLString:(NSString *)resourceURLString
                             completion:(JMReportSaverCompletion)completion
{
    __weak typeof(self)weakSelf = self;
    [self downloadResourceFromURLString:resourceURLString
                             completion:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                 __strong typeof(self)strongSelf = weakSelf;
                                 if (!error) {
                                     NSString *thumbnailPath = [strongSelf thumbnailPath];
                                     [strongSelf moveResourceFromPath:location.path toPath:thumbnailPath];
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
        exportID = [NSString stringWithFormat:@"%@;pages=%@;", self.savedReport.format, self.pagesRange.pagesFormat];
        NSString *attachmentPrefix = kJMAttachmentPrefix;
        exportID = [exportID stringByAppendingFormat:@"attachmentsPrefix=%@;", attachmentPrefix];
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
    NSString *tempDirectory = [JMSavedResources pathToTempFolderForSavedReport:self.savedReport];

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
    
    __weak typeof (self) weakSelf = self;
    [self.reportExecutor executeWithCompletion:^(JSReportExecutionResponse *executionResponse, NSError *executionError) {
        __strong typeof(self)strongSelf = weakSelf;
        if (executionResponse) {
            self.requestExecution = executionResponse;

            __weak typeof (self) weakSelf = strongSelf;
            [self.reportExecutor exportWithCompletion:^(JSExportExecutionResponse *exportResponse, NSError *exportError) {
                __strong typeof(self)strongSelf = weakSelf;
                if (exportResponse) {
                    strongSelf.exportExecution = exportResponse;
                    if (completion) {
                        completion(YES, nil);
                    }
                } else {
                    if (completion) {
                        completion(NO, exportError);
                    }
                }
            }];
        } else {
            if (completion) {
                completion(NO, executionError);
            }
        }
    }];
}

- (BOOL)isExistSavedReport:(JMSavedResources *)savedReport
{
    NSString *fileReportPath = [JMSavedResources absolutePathToSavedReport:self.savedReport];
    BOOL isExistInFS = [[NSFileManager defaultManager] fileExistsAtPath:fileReportPath];
    return isExistInFS;
}

- (void)createPagesRangeFromPagesString:(NSString *)pages
{
    NSArray *components = [pages componentsSeparatedByString:@"-"];
    NSUInteger startPage = 0;
    NSUInteger endPage = 0;
    if (components.count == 2) {
        startPage = ((NSString *)components[0]).integerValue;
        endPage = ((NSString *)components[1]).integerValue;
    } else if (components.count == 1) {
        startPage = endPage = (NSUInteger) ((NSString *)components.firstObject).integerValue;
    }
    
    self.pagesRange = [JMReportPagesRange rangeWithStartPage:startPage endPage:endPage];
}

@end
