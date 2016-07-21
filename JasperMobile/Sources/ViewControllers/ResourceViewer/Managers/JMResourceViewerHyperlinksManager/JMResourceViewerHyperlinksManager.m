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
//  JMResourceViewerHyperlinksManager.h
//  TIBCO JasperMobile
//

#import "JMResourceViewerHyperlinksManager.h"
#import "JMReportViewerVC.h"
#import "JMResource.h"
#import "JMReportViewerConfigurator.h"
#import "JMWebEnvironment.h"
#import "JMHyperlink.h"
#import "JMResourceViewerStateManager.h"
#import "JMResourceViewerDocumentManager.h"

@interface JMResourceViewerHyperlinksManager()
@property (nonatomic, strong) NSURL *tempResourceURL;
@end

@implementation JMResourceViewerHyperlinksManager

#pragma mark - Public API

- (void)handleHyperlink:(JMHyperlink *)hyperlink
{
    switch (hyperlink.type) {
        case JMHyperlinkTypeReportExecution: {
            [self handleReportExecution:hyperlink];
            break;
        }
        case JMHyperlinkTypeReportExecutionDestination: {
            [self handleReportExecutionDestination:hyperlink];
            break;
        }
        case JMHyperlinkTypeReportExecutionOutput: {
            [self handleReportExecutionOutput:hyperlink];
            break;
        }
        case JMHyperlinkTypeLocalAnchor: {
            break;
        }
        case JMHyperlinkTypeLocalPage: {
            break;
        }
        case JMHyperlinkTypeReference: {
            [self handleOpenReference:hyperlink];
            break;
        }
        case JMHyperlinkTypeRemoteAnchor: {
            [self handleOpenReference:hyperlink];
            break;
        }
        case JMHyperlinkTypeRemotePage: {
            [self handleOpenReference:hyperlink];
            break;
        }
    }
}

- (void)reset
{
    [self removeResourceWithURL:self.tempResourceURL];
}

#pragma mark - Helpers

- (void)handleReportExecution:(JMHyperlink *)hyperlink
{
    __weak __typeof(self) weakSelf = self;
    [self fetchResourceLookupForURI:hyperlink.href completion:^(JSResourceLookup *resourceLookup, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (error) {
            if (strongSelf.errorBlock) {
                strongSelf.errorBlock(error);
            }
        } else {
            if (!resourceLookup) {
                JMLog(@"There is no resource lookup");
                return;
            }
            JMResource *resource  = [JMResource resourceWithResourceLookup:resourceLookup];
            JMReportViewerVC *reportViewController = [strongSelf.controller.storyboard instantiateViewControllerWithIdentifier:[resource resourceViewerVCIdentifier]];
            reportViewController.configurator = [JMUtils reportViewerConfiguratorNonReusableWebView];
            reportViewController.resource = resource;
            reportViewController.initialReportParameters = hyperlink.parameters;
            [strongSelf.controller.navigationController pushViewController:reportViewController animated:YES];
        }
    }];
}

- (void)handleReportExecutionDestination:(JMHyperlink *)hyperlink
{
    __weak __typeof(self) weakSelf = self;
    [self fetchResourceLookupForURI:hyperlink.href completion:^(JSResourceLookup *resourceLookup, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (error) {
            if (strongSelf.errorBlock) {
                strongSelf.errorBlock(error);
            }
        } else {
            if (!resourceLookup) {
                JMLog(@"There is no resource lookup");
                return;
            }
            JMResource *resource  = [JMResource resourceWithResourceLookup:resourceLookup];
            JMReportViewerVC *reportViewController = [strongSelf.controller.storyboard instantiateViewControllerWithIdentifier:[resource resourceViewerVCIdentifier]];
            reportViewController.configurator = [JMUtils reportViewerConfiguratorNonReusableWebView];
            reportViewController.resource = resource;
            reportViewController.initialReportParameters = hyperlink.parameters;
            reportViewController.initialDestination = hyperlink.destination;
            [strongSelf.controller.navigationController pushViewController:reportViewController animated:YES];
        }
    }];
}

- (void)handleReportExecutionOutput:(JMHyperlink *)hyperlink
{
    NSArray *outputs = hyperlink.outputFormats;
    if (outputs.count == 0) {
        return;
    }

    if (outputs.count > 1) {
        // TODO: how handle this case?
        return;
    }

    __weak __typeof(self) weakSelf = self;
    [self fetchResourceLookupForURI:hyperlink.href completion:^(JSResourceLookup *resourceLookup, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (error) {
            if (strongSelf.errorBlock) {
                strongSelf.errorBlock(error);
            }
        } else {
            if (!resourceLookup) {
                JMLog(@"There is no resource lookup");
                return;
            }
            __weak __typeof(self) weakSelf = strongSelf;
            JMResource *resource  = [JMResource resourceWithResourceLookup:resourceLookup];
            [strongSelf fetchReportExportWithResource:resource format:outputs.firstObject completion:^(NSURL *location, NSError *error) {
                __typeof(self) strongSelf = weakSelf;
                if (error) {
                    if (strongSelf.errorBlock) {
                        strongSelf.errorBlock(error);
                    }
                } else {
                    if (location) {
                        if ([strongSelf isFormatSupported:outputs.firstObject]) {
                            strongSelf.tempResourceURL = location;
                            if ([strongSelf.delegate respondsToSelector:@selector(hyperlinksManager:willOpenLocalResourceFromURL:)]) {
                                [strongSelf.delegate hyperlinksManager:strongSelf willOpenURL:location];
                            }
                        } else {
                            if ([strongSelf.delegate respondsToSelector:@selector(hyperlinksManager:needShowOpenInMenuForLocalResourceFromURL:)]) {
                                [strongSelf.delegate hyperlinksManager:strongSelf needShowOpenInMenuForLocalResourceFromURL:location];
                            }
                        }
                    } else {
                        JMLog(@"There is no location of exported report");
                    }
                }
            }];
        }
    }];
}

- (void)handleOpenReference:(JMHyperlink *)hyperlink
{
    if ([self.delegate respondsToSelector:@selector(hyperlinksManager:willOpenURL:)]) {
        [self.delegate hyperlinksManager:self willOpenURL:[NSURL URLWithString:hyperlink.href]];
    }
}

- (NSArray *)supportedFormats
{
    return @[@"pdf", @"html", @"xls"];
}

- (BOOL)isFormatSupported:(NSString *)format
{
    BOOL isFormatSupported = NO;
    for (NSString *supportedFormat in [self supportedFormats]) {
        if ([supportedFormat isEqualToString:[format lowercaseString]]) {
            isFormatSupported = YES;
            break;
        }
    }
    return isFormatSupported;
}

#pragma mark - Network API
- (void)fetchResourceLookupForURI:(NSString * __nonnull)resourceURI completion:(void(^ __nonnull)(JSResourceLookup * __nullable resourceLookup, NSError * __nullable error))completion
{
    NSAssert(resourceURI != nil, @"Resource URI is nil");
    NSAssert(completion != nil, @"Completion is nil");

    [self showLoading];
    __weak __typeof(self) weakSelf = self;
    [self.restClient resourceLookupForURI:resourceURI
                             resourceType:kJS_WS_TYPE_REPORT_UNIT
                               modelClass:[JSResourceLookup class]
                          completionBlock:^(JSOperationResult *result) {
                              __typeof(self) strongSelf = weakSelf;
                              [strongSelf hideLoading];
                              if (result.error) {
                                  completion(nil, result.error);
                              } else {
                                  JSResourceLookup *resourceLookup = [result.objects firstObject];
                                  if (resourceLookup) {
                                      resourceLookup.resourceType = kJS_WS_TYPE_REPORT_UNIT;
                                      completion(resourceLookup, nil);
                                  } else {
                                      // TODO: need error?
                                      completion(nil, nil);
                                  }
                              }
                          }];
}

- (void)fetchReportExportWithResource:(JMResource *)resource format:(NSString *)format completion:(void(^)(NSURL *location, NSError *error))completion
{
    JSReportSaver *reportSaver = [[JSReportSaver alloc] initWithReport:[resource modelOfResource]
                                                            restClient:self.restClient];

    NSString *reportName = [self tempReportName];
    [self showLoading];
    __weak __typeof(self) weakSelf = self;
    [reportSaver saveReportWithName:reportName
                             format:format
                         pagesRange:[JSReportPagesRange allPagesRange]
                         completion:^(NSURL * _Nullable savedReportURL, NSError * _Nullable error) {
                             __typeof(self) strongSelf = weakSelf;
                             [strongSelf hideLoading];
                             if (error) {
                                 completion(nil, error);
                             } else {
                                 if (savedReportURL) {
                                     NSString *fullReportName = [reportName stringByAppendingPathExtension:format];
                                    completion([savedReportURL URLByAppendingPathComponent:fullReportName], nil);
                                 } else {
                                     // TODO: need error?
                                     completion(nil, nil);
                                 };
                             }
                         }];
}

#pragma mark - Saver Helper
- (NSString *)tempReportName
{
    return [[NSUUID UUID] UUIDString];
}

- (void)removeResourceWithURL:(NSURL *)resourceURL
{
    NSString *directoryPath = [resourceURL.path stringByDeletingLastPathComponent];
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:nil];
    }
}

- (void)showLoading
{
    if ([self.delegate respondsToSelector:@selector(hyperlinksManagerNeedShowLoading:)]) {
        [self.delegate hyperlinksManagerNeedShowLoading:self];
    }
}

- (void)hideLoading
{
    if ([self.delegate respondsToSelector:@selector(hyperlinksManagerNeedHideLoading:)]) {
        [self.delegate hyperlinksManagerNeedHideLoading:self];
    }
}

@end