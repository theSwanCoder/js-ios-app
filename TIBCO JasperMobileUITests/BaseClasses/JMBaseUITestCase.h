/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import <XCTest/XCTest.h>
#import "JMUITestConstants.h"
#import "JMLocalization.h"

extern NSTimeInterval kUITestsBaseTimeout;
extern NSTimeInterval kUITestsResourceLoadingTimeout;
extern NSTimeInterval kUITestsElementAvailableTimeout;

@protocol JMBaseUITestProtocol <NSObject>
- (BOOL)shouldPerformSuperSetup; // This need for ability to skip some steps and improve time of tests execution
- (NSInteger)testsCount;
- (BOOL)shouldLoginBeforeStartTest;
@end

@interface JMBaseUITestCase : XCTestCase <JMBaseUITestProtocol>
@property(nonatomic, strong) XCUIApplication *application;

- (void)tryBackToPreviousPage;
- (void)tryBackToPreviousPageWithTitle:(NSString *)pageTitle;

//
- (void)givenLoadingPopupVisible;
- (void)givenLoadingPopupNotVisible;

- (void)performTestFailedWithErrorMessage:(NSString *)message logMessage:(NSString *)logMessage;

@end
