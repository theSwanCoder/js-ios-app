/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
@author Oleksandr Dahno odahno@tibco.com
@since 2.6
*/

#import <Foundation/Foundation.h>

@class JMBaseResourceView;

typedef NS_ENUM(NSInteger, JMResourceViewerToolbarState) {
    JMResourceViewerToolbarStateInitial,
    JMResourceViewerToolbarStateTopVisible,
    JMResourceViewerToolbarStateTopHidden,
    JMResourceViewerToolbarStateBottomVisible,
    JMResourceViewerToolbarStateBottomHidden
};

@interface JMResourceViewerToolbarsHelper : NSObject
@property (nonatomic, assign, readonly) JMResourceViewerToolbarState state;
@property (nonatomic, weak) JMBaseResourceView *view;
- (void)updatePageForToolbarState:(JMResourceViewerToolbarState)toolbarState;
@end
