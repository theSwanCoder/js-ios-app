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
//  JMContentResourceLoader.m
//  TIBCO JasperMobile
//


#import "JMContentResourceLoader.h"
#import "JMWebEnvironment.h"
#import "JMSavedResources+Helpers.h"

@interface JMContentResourceLoader ()
@property (nonatomic, strong, readwrite) JSContentResource *contentResource;
@property (nonatomic, strong, readwrite) JMSavedResources *savedResource;
@property (nonatomic, strong, readwrite) NSURL *contentResourceURL;
@property (nonatomic, weak) JMWebEnvironment *webEnvironment;
@property (nonatomic, copy, readwrite) JSRESTBase *restClient;

@end

@implementation JMContentResourceLoader
- (instancetype)initWithRESTClient:(JSRESTBase *)restClient
                    webEnvironment:(JMWebEnvironment *)webEnvironment
{
    self = [super init];
    if (self) {
        NSAssert(restClient != nil, @"Parameter for rest client is nil");
        NSAssert([webEnvironment isKindOfClass:[JMWebEnvironment class]], @"WebEnvironment isn't correct class");
        _restClient = [restClient copy];
    }
    return self;
}

+ (instancetype)loaderWithRESTClient:(JSRESTBase *)restClient
                      webEnvironment:(JMWebEnvironment *)webEnvironment
{
    return [[self alloc] initWithRESTClient:restClient
                             webEnvironment:webEnvironment];
}

- (void)loadContentResourceForResource:(JMResource *)resource
                            completion:(void (^)(NSURL *baseURL, NSError *error))completion
{
    if (resource.type == JMResourceTypeFile) {
        [self showRemoteResource:resource withCompletion:completion];
    } else {
        [self showSavedResource:resource withCompletion:completion];
    }
}

- (void)showSavedResource:(JMResource *)resource
           withCompletion:(void (^)(NSURL *baseURL, NSError *error))completion
{
    JMSavedResources *savedResources = [JMSavedResources savedResourceFromResource:resource];
    NSString *reportDirectory = [JMSavedResources pathToFolderForSavedResource:savedResources];
    NSString *tempReportDirectory = [self tempReportDirectory];
    
    NSError *error = nil;
    if ([[NSFileManager defaultManager] copyItemAtPath:reportDirectory toPath:tempReportDirectory error:&error]) {
        self.savedResource = savedResources;
        self.contentResource = (JSContentResource *)resource.resourceLookup;

        NSString *tempReportPath = [tempReportDirectory stringByAppendingPathComponent:[self.savedResource.label stringByAppendingPathExtension:self.savedResource.format]];
        self.contentResourceURL = [NSURL fileURLWithPath:tempReportPath];
        if (completion) {
            completion(nil, nil);
        }
    }
    if (error && completion) {
        completion(nil, error);
    }
}

- (void)showRemoteResource:(JMResource *)resource
            withCompletion:(void (^)(NSURL *baseURL, NSError *error))completion
{
    __typeof(self) weakSelf = self;
    [self.restClient contentResourceWithResourceLookup:resource.resourceLookup
                                            completion:^(JSContentResource *contentResource, NSError *error) {
                                                __typeof(self) strongSelf = weakSelf;
                                                if (error) {
                                                    if (completion) {
                                                        completion(nil, error);
                                                    }
                                                } else {
                                                    if ([strongSelf isSupportedResource:contentResource]) {
                                                        NSString *resourcePath = [NSString stringWithFormat:@"%@/rest_v2/resources%@", strongSelf.restClient.serverProfile.serverUrl, contentResource.uri];
                                                        NSString *tempReportDirectory = [strongSelf tempReportDirectory];
                                                        NSString *tempReportPath = [tempReportDirectory stringByAppendingPathComponent:contentResource.label];
                                                        
                                                        __typeof(self) weakSelf = strongSelf;
                                                        [JSReportSaver downloadResourceWithRestClient:strongSelf.restClient
                                                                                        fromURLString:resourcePath
                                                                                      destinationPath:tempReportPath
                                                                                           completion:^(NSError *error) {
                                                                                               __typeof(self) strongSelf = weakSelf;
                                                                                               if (error) {
                                                                                                   if (completion) {
                                                                                                       completion(nil, error);
                                                                                                   }
                                                                                               } else {
                                                                                                   strongSelf.contentResourceURL = [NSURL fileURLWithPath:tempReportPath];
                                                                                                   strongSelf.contentResource = contentResource;

                                                                                                   NSString *baseURLString = [NSString stringWithFormat:@"%@/fileview/fileview/%@", strongSelf.restClient.serverProfile.serverUrl, contentResource.uri];
                                                                                                   
                                                                                                   if (completion) {
                                                                                                       completion([NSURL URLWithString:baseURLString], nil);
                                                                                                   }
                                                                                               }
                                                                                           }];
                                                    } else {
                                                        NSError *unsupportedFormatError = [NSError errorWithDomain:@"dialod_title_error" code:0 userInfo:@{NSLocalizedDescriptionKey : @"savedreport_viewer_format_not_supported"}];
                                                        if (completion) {
                                                            completion(nil, unsupportedFormatError);
                                                        }
                                                    }
                                                }
                                            }];
}

- (void)cancel
{
    [self.restClient cancelAllRequests];
    [self removeTempResource];
}

#pragma mark - Helpers
- (void)removeTempResource
{
    NSString *directoryPath = [self.contentResourceURL.path stringByDeletingLastPathComponent];
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:nil];
    }
}

- (BOOL)isSupportedResource:(JSContentResource *)resource
{
    BOOL isHTML = [resource.fileFormat isEqualToString:kJS_CONTENT_TYPE_HTML];
    BOOL isPDF = [resource.fileFormat isEqualToString:kJS_CONTENT_TYPE_PDF];
    BOOL isXLS = [resource.fileFormat isEqualToString:kJS_CONTENT_TYPE_XLS];
    BOOL isXLSX = [resource.fileFormat isEqualToString:kJS_CONTENT_TYPE_XLSX];
    BOOL isIMG = [resource.fileFormat isEqualToString:kJS_CONTENT_TYPE_IMG];
    return isHTML || isPDF || isXLS || isXLSX || isIMG;
}

- (NSString *)tempReportDirectory
{
    NSString *tempAppDirectory = NSTemporaryDirectory();
    NSString *tempReportDirectory = [tempAppDirectory stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    return tempReportDirectory;
}

@end
