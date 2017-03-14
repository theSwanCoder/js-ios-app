/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
@author Oleksandr Dahno odahno@tibco.com
@since 2.1
*/

@import UIKit;

@interface JMVisualizeManager : NSObject
@property (nonatomic, strong) NSString *visualizePath;
@property (nonatomic, strong) NSString *htmlString;
@property (nonatomic, assign) CGFloat viewportScaleFactor;
- (void)loadVisualizeJSWithCompletion:(void (^)(BOOL success, NSError *error))completion;
@end
