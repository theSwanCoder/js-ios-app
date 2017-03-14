/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
@author Oleksandr Dahno odahno@tibco.com
@since 2.6
*/

@import UIKit;

@class JMBaseResourceView;

@interface JMResourceViewerExternalScreenManager : NSObject
- (void)showContentOnTV;
- (void)backContentOnDevice;
// Methods for overriding in child
- (JMBaseResourceView *)resourceView; // Should override
- (void)handleExternalScreenWillBeDestroy;
- (void)handleContentIsOnExternalScreen;
- (void)handleContentIsOnDevice;
@end
