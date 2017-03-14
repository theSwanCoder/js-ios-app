/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
@author Oleksandr Dahno odahno@tibco.com
@since 2.6
*/

@protocol JMResourceViewerProtocol <NSObject>
- (UIView *)contentView;
@optional
- (UIView *)topToolbarView;
- (UIView *)bottomToolbarView;
- (UIView *)warningsView;
@end
