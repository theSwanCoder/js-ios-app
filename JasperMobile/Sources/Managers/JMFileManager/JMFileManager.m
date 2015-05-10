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
//  JMFileManager.m
//  TIBCO JasperMobile
//

#import "JMFileManager.h"
#import "JMSavedResources.h"
#import "JMSavedResources+Helpers.h"

@implementation JMFileManager

#pragma mark - LifeCycle
+ (instancetype)sharedInstance
{
    static JMFileManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [self new];
    });
    return sharedMyManager;
}

#pragma mark - Public API
- (BOOL)createDirectoryForReportWithName:(NSString *)reportName
                           fileExtension:(NSString *)fileExtension
{
    NSString *directoryLocation = [self resourceDirectoryRelativeLocationWithResourceName:reportName
                                                                            fileExtension:fileExtension];

    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSURL *documentsDirectoryURL = [NSURL fileURLWithPath:documentsPath];
    NSURL *resourceURL = [documentsDirectoryURL URLByAppendingPathComponent:directoryLocation];

    NSError *error;
    BOOL isDirectoryCreated = [[NSFileManager defaultManager] createDirectoryAtURL:resourceURL
                                                       withIntermediateDirectories:YES
                                                                        attributes:nil
                                                                             error:&error];
    return isDirectoryCreated;
}

- (void)downloadReportWithName:(NSString *)reportName
                 fileExtension:(NSString *)fileExtension
                     requestId:(NSString *)requestId
                      exportId:(NSString *)exportId
               attachmentNames:(NSArray *)attachmentNames
                    completion:(void(^)(BOOL success, NSError *error))completion
{
    NSString *outputResourceURLString = [self outputResourceURLStringWithRequestId:requestId
                                                                          exportId:exportId];
    [self downloadResourceFromURLString:outputResourceURLString
                             completion:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                 if (!error) {
                                     // save report to disk
                                     NSString *reportRelativeLocation = [self resourceRelativeLocationWithResourceName:reportName
                                                                                                         fileExtension:fileExtension];
                                     [self moveResourceFromLocation:location
                                                 toRelativeLocation:reportRelativeLocation];

                                     // save attachments or exit
                                     if (attachmentNames.count > 0) {
                                         [self downloadAttachmentsForResourceWithName:reportName
                                                                        fileExtension:fileExtension
                                                                      attachmentNames:attachmentNames
                                                                            requestId:requestId
                                                                             exportId:exportId
                                                                           completion:^(BOOL success, NSError *attError) {
                                                                               if (completion) {
                                                                                   dispatch_async(dispatch_get_main_queue(), ^(void) {
                                                                                       completion(attError == nil, attError);
                                                                                   });
                                                                               }
                                                                           }];
                                     } else {
                                         if (completion) {
                                             dispatch_async(dispatch_get_main_queue(), ^(void) {
                                                 completion(YES, nil);
                                             });
                                         }
                                     }
                                 } else {
                                     if (completion) {
                                         dispatch_async(dispatch_get_main_queue(), ^(void) {
                                             completion(NO, error);
                                         });
                                     }
                                 }
                             }];
}

- (void)cancelDownloadReportWithName:(NSString *)reportName
                       fileExtension:(NSString *)fileExtension
{
    NSURLSession *session = [NSURLSession sharedSession];
    [session invalidateAndCancel];

    NSString *directoryLocation = [self resourceDirectoryRelativeLocationWithResourceName:reportName
                                                                            fileExtension:fileExtension];
    [self removeResourceFromRelativeLocation:directoryLocation];
}

- (void)downloadThumbnailForReportWithName:(NSString *)reportName
                             fileExtension:(NSString *)fileExtension
                         resourceURLString:(NSString *)resourceURLString
{
    [self downloadResourceFromURLString:resourceURLString
                             completion:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                 if (!error) {
                                     NSString *directoryLocation = [self resourceDirectoryRelativeLocationWithResourceName:reportName
                                                                                                             fileExtension:fileExtension];
                                     NSString *thumbnailRelativeLocation = [directoryLocation stringByAppendingPathComponent:kJMThumbnailImageFileName];
                                     [self moveResourceFromLocation:location
                                                 toRelativeLocation:thumbnailRelativeLocation];
                                 }
                             }];
}

- (UIImage *)thumbnailForSavedReportWithReportName:(NSString *)reportName
                                     fileExtension:(NSString *)fileExtension
{
    NSURL *thumbnailURL = [self thumbnailURLForReportWithName:reportName fileExtension:fileExtension];
    NSData *imageData = [NSData dataWithContentsOfURL:thumbnailURL];
    if (imageData) {
        return [UIImage imageWithData:imageData
                                scale:[UIScreen mainScreen].scale];
    }
    return nil;
}

- (NSURL *)thumbnailURLForReportWithName:(NSString *)reportName
                               fileExtension:(NSString *)fileExtension
{
    NSString *directoryLocation = [self resourceDirectoryRelativeLocationWithResourceName:reportName
                                                                            fileExtension:fileExtension];
    NSString *thumbnailImagePath = [directoryLocation stringByAppendingPathComponent:kJMThumbnailImageFileName];
    NSURL *documentsDirectoryURL = [NSURL fileURLWithPath:[JMUtils applicationDocumentsDirectory]];
    NSURL *resourceURL = [documentsDirectoryURL URLByAppendingPathComponent:thumbnailImagePath];
    return resourceURL;
}

#pragma mark - Resource URL helpers
- (NSString *)serverURL
{
    // TODO: improve logic of making server URL
    NSString *serverURL = [self.restClient.serverProfile.serverUrl stringByAppendingString:@"/rest_v2"];
    return serverURL;
}

- (NSString *)exportURIWithRequestId:(NSString *)requestId
                            exportId:(NSString *)exportId
{
    NSString *exportURIStringFormat = @"%@/%@/exports/%@/";
    NSString *exportURI = [[self serverURL] stringByAppendingFormat:exportURIStringFormat, [JSConstants sharedInstance].REST_REPORT_EXECUTION_URI, requestId, exportId];
    return exportURI;
}

- (NSString *)outputResourceURLStringWithRequestId:(NSString *)requestId
                                          exportId:(NSString *)exportId
{
    NSString *outputResourceQueryString = @"outputResource?sessionDecorator=no&decorate=no#";
    NSString *outputResourceURLString = [[self exportURIWithRequestId:requestId
                                                            exportId:exportId] stringByAppendingString:outputResourceQueryString];
    return outputResourceURLString;
}

- (NSString *)attachmentURLStringWithRequestId:(NSString *)requestId
                                      exportId:(NSString *)exportId
                                attachmentName:(NSString *)attachmentName
{
    NSString *attachmentQueryString = @"attachments/%@";
    NSString *attachmentURLString = [[self exportURIWithRequestId:requestId
                                                        exportId:exportId] stringByAppendingFormat:attachmentQueryString, attachmentName];
    return attachmentURLString;
}

#pragma mark - File manage helpers
- (void)moveResourceFromLocation:(NSURL *)fromLocation toRelativeLocation:(NSString *)relativeLocation
{
    NSURL *documentsDirectoryURL = [NSURL fileURLWithPath:[JMUtils applicationDocumentsDirectory]];
    NSURL *resourceURL = [documentsDirectoryURL URLByAppendingPathComponent:relativeLocation];

    [[NSFileManager defaultManager] removeItemAtURL:resourceURL error:nil];

    NSError *error;
    BOOL isMoved = [[NSFileManager defaultManager] moveItemAtURL:fromLocation
                                                           toURL:resourceURL
                                                           error:&error];
    if (!isMoved) {
        NSLog(@"error: %@", error.localizedDescription);
    } else {
        NSLog(@"success moved");
    }
}

- (void)removeResourceFromRelativeLocation:(NSString *)relativeLocation
{
    NSURL *documentsDirectoryURL = [NSURL fileURLWithPath:[JMUtils applicationDocumentsDirectory]];
    NSURL *resourceURL = [documentsDirectoryURL URLByAppendingPathComponent:relativeLocation];
    [[NSFileManager defaultManager] removeItemAtURL:resourceURL error:nil];
}

- (NSString *)resourceDirectoryRelativeLocationWithResourceName:(NSString *)resourceName fileExtension:(NSString *)fileExtension
{
    NSString *relativeLocation = [kJMReportsDirectory stringByAppendingPathComponent:[resourceName stringByAppendingPathExtension:fileExtension]];
    return relativeLocation;
}

- (NSString *)resourceRelativeLocationWithResourceName:(NSString *)resourceName
                                         fileExtension:(NSString *)fileExtension
{
    NSString *directoryLocation = [self resourceDirectoryRelativeLocationWithResourceName:resourceName
                                                                            fileExtension:fileExtension];
    NSString *resourceRelativeLocation = [NSString stringWithFormat:@"%@/%@.%@", directoryLocation, kJMReportFilename, fileExtension];
    return resourceRelativeLocation;
}

- (NSString *)attachmentRelativeLocationWithResourceName:(NSString *)resourceName
                                           fileExtension:(NSString *)fileExtension
                                          attachmentName:(NSString *)attachmentName
{
    NSString *directoryLocation = [self resourceDirectoryRelativeLocationWithResourceName:resourceName
                                                                            fileExtension:fileExtension];
    NSString *attachmentRelativeLocation = [NSString stringWithFormat:@"%@/_%@", directoryLocation, attachmentName];

    return attachmentRelativeLocation;
}

#pragma mark - Network calls
- (void)downloadResourceFromURLString:(NSString *)resourceURLString
                           completion:(void(^)(NSURL *location, NSURLResponse *response, NSError *error))completion
{
    NSURL *URL = [NSURL URLWithString:resourceURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request
                                                            completionHandler:completion];

    [downloadTask resume];
}

- (void)downloadAttachmentsForResourceWithName:(NSString *)resourceName
                                 fileExtension:(NSString *)fileExtension
                               attachmentNames:(NSArray *)attachmentNames
                                     requestId:(NSString *)requestId
                                      exportId:(NSString *)exportId
                                    completion:(void(^)(BOOL success, NSError *error))completion
{
    __block NSInteger attachmentCount = attachmentNames.count;
    for (NSString *attachmentName in attachmentNames) {
        NSString *attachmentURLString = [self attachmentURLStringWithRequestId:requestId
                                                                      exportId:exportId
                                                                attachmentName:attachmentName];
        [self downloadResourceFromURLString:attachmentURLString
                                 completion:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                     if (!error) {
                                         NSString *attachmentRelativeLocation = [self attachmentRelativeLocationWithResourceName:resourceName
                                                                                                                   fileExtension:fileExtension
                                                                                                                  attachmentName:attachmentName];
                                         [self moveResourceFromLocation:location
                                                     toRelativeLocation:attachmentRelativeLocation];
                                         if (--attachmentCount == 0) {
                                             if (completion) {
                                                 dispatch_async(dispatch_get_main_queue(), ^(void) {
                                                     completion(YES, nil);
                                                 });
                                             }
                                         }
                                     } else {
                                         NSURLSession *session = [NSURLSession sharedSession];
                                         [session invalidateAndCancel];
                                         if (completion) {
                                             dispatch_async(dispatch_get_main_queue(), ^(void) {
                                                 completion(NO, error);
                                             });
                                         }
                                     }
                                 }];
    }
}

@end