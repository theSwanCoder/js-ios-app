/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
@author Oleksandr Dahno odahno@tibco.com
@since 2.6
*/

#import <UIKit/UIKit.h>

@class JMReportViewerVC;
@class JMHyperlink;
@protocol JMResourceViewerHyperlinksManagerDelegate;

@interface JMResourceViewerHyperlinksManager : NSObject
@property (nonatomic, weak) UIViewController * __nullable controller;
@property (nonatomic, weak) id<JMResourceViewerHyperlinksManagerDelegate> __nullable delegate;
@property (nonatomic, copy) void(^ __nullable errorBlock)(NSError * __nonnull);
- (void)handleHyperlink:(JMHyperlink *__nonnull)hyperlink;
- (void)reset;
@end

@protocol JMResourceViewerHyperlinksManagerDelegate <NSObject>
- (void)hyperlinksManagerNeedShowLoading:(JMResourceViewerHyperlinksManager *__nullable)manager;
- (void)hyperlinksManagerNeedHideLoading:(JMResourceViewerHyperlinksManager *__nullable)manager;
- (void)hyperlinksManager:(JMResourceViewerHyperlinksManager *__nullable)manager willOpenURL:(NSURL *__nullable)URL;
- (void)hyperlinksManager:(JMResourceViewerHyperlinksManager *__nullable)manager willOpenLocalResourceFromURL:(NSURL *__nullable)URL;
- (void)hyperlinksManager:(JMResourceViewerHyperlinksManager *__nullable)manager needShowOpenInMenuForLocalResourceFromURL:(NSURL *__nullable)URL;
@end
