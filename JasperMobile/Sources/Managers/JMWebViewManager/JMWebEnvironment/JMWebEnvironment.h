/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
@author Oleksandr Dahno odahno@tibco.com
@since 2.4
*/

#import "JMBaseWebEnvironment.h"
#import "JMWebViewManager.h"

@interface JMWebEnvironment : JMBaseWebEnvironment
@property (nonatomic, assign) JMResourceFlowType flowType;

- (void)verifyJasperMobileEnableWithCompletion:(void (^ __nonnull)(BOOL isEnable))completion;
- (void)updateViewportScaleFactorWithValue:(CGFloat)scaleFactor;
// USE FOR TESTS ONLY
- (void)updateCookiesInWebView:(NSArray <NSHTTPCookie *>* __nonnull)cookies;
@end
