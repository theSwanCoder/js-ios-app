/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMResourceViewerHyperlinksManager.h"
#import "JMReportViewerVC.h"
#import "JMResource.h"
#import "JMReportViewerConfigurator.h"
#import "JMWebEnvironment.h"
#import "JMHyperlink.h"
#import "JMResourceViewerStateManager.h"
#import "JMResourceViewerDocumentManager.h"
#import "JMUtils.h"
#import "NSObject+Additions.h"

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
            [self handleOpenRemoteAnchor:hyperlink];
            break;
        }
        case JMHyperlinkTypeRemotePage: {
            [self handleOpenRemotePage:hyperlink];
            break;
        }
        case JMHyperlinkTypeAdHocExecution: {
            [self handleAdhocExecution:hyperlink];
            break;
        }
    }
}

- (void)reset
{
    [self removeResourceWithURL:self.tempResourceURL];
}

#pragma mark - Handlers

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
            JMReportViewerVC *reportViewController = [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:[resource resourceViewerVCIdentifier]];
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
            JMReportViewerVC *reportViewController = [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:[resource resourceViewerVCIdentifier]];
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
                                [strongSelf.delegate hyperlinksManager:strongSelf willOpenLocalResourceFromURL:location];
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

- (void)handleOpenRemotePage:(JMHyperlink *)hypelink
{
    NSString *URLString = [self constructURLStringForFileViewWithURIString:hypelink.href];
    if ([self.delegate respondsToSelector:@selector(hyperlinksManager:willOpenURL:)]) {
        [self.delegate hyperlinksManager:self willOpenURL:[NSURL URLWithString:URLString]];
    }
}

- (void)handleOpenRemoteAnchor:(JMHyperlink *)hypelink
{
    NSString *URLString = [self constructURLStringForFileViewWithURIString:hypelink.href];
    if ([self.delegate respondsToSelector:@selector(hyperlinksManager:willOpenURL:)]) {
        [self.delegate hyperlinksManager:self willOpenURL:[NSURL URLWithString:URLString]];
    }
}

- (void)handleOpenReference:(JMHyperlink *)hyperlink
{
    if ([self.delegate respondsToSelector:@selector(hyperlinksManager:willOpenURL:)]) {
        [self.delegate hyperlinksManager:self willOpenURL:[NSURL URLWithString:hyperlink.href]];
    }
}

- (void)handleAdhocExecution:(JMHyperlink *)hyperlink
{
    NSString *href = hyperlink.href;
    if ([self isLocalResource:[NSURL URLWithString:href]]) {
        if ([self isViewerRequestWithURL:[NSURL URLWithString:href]]) {
            href = [self constructNondecoratedURLStringFromURLString:href];
        }
    }

    NSURL *url = [NSURL URLWithString:href];

    if ([self.delegate respondsToSelector:@selector(hyperlinksManager:willOpenURL:)]) {
        [self.delegate hyperlinksManager:self willOpenURL:url];
    }
}

#pragma mark - Helpers

- (BOOL)isLocalResource:(NSURL *)URL
{
    BOOL isLocalResource = NO;
    NSURL *serverURL = [NSURL URLWithString:self.restClient.serverProfile.serverUrl];
    if ([URL.host isEqualToString:serverURL.host]) {
        isLocalResource = YES;
    }
    return isLocalResource;
}

- (BOOL)isViewerRequestWithURL:(NSURL *)URL
{
    BOOL isViewerRequestWithURL = [URL.absoluteString containsString:@"viewer.html"];
    return isViewerRequestWithURL;
}

- (NSString *)constructNondecoratedURLStringFromURLString:(NSString *)URLString
{
    NSString *result = URLString;
    NSString *nondecorationParametersString = @"_opt=true&sessionDecorator=no&decorate=no";
    NSURL *url = [NSURL URLWithString:URLString];
    NSString *fragment = [NSString stringWithFormat:@"#%@", url.fragment];
    result = [result stringByReplacingOccurrencesOfString:fragment withString:@""];
    result = [result stringByAppendingFormat:@"&%@%@", nondecorationParametersString, fragment];
    return result;
}

- (NSString *)constructURLStringForFileViewWithURIString:(NSString *)URISting
{
    NSString *href = URISting;
    NSString *prefix = [href substringWithRange:NSMakeRange(0, 1)];
    if ([prefix isEqualToString:@"."]) {
        href = [href stringByReplacingOccurrencesOfString:@"./" withString:@"/"];
    }
    NSString *fullURLString = [self.restClient.serverProfile.serverUrl stringByAppendingString:href];
    JMLog(@"full url string: %@", fullURLString);
    return fullURLString;
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
