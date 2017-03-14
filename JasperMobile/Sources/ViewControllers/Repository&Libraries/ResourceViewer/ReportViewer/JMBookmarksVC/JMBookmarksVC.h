/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

@import UIKit;
#import "JMBaseViewController.h"
@class JSReportBookmark;

@interface JMBookmarksVC : JMBaseViewController
@property (nonatomic, copy) NSArray <JSReportBookmark *>* __nonnull bookmarks;
@property (nonatomic, copy) void(^__nonnull exitBlock)(JSReportBookmark * __nonnull selectedBookmark);
@end
