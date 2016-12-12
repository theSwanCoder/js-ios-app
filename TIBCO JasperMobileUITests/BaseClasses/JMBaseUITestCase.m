//
//  JMBaseUITestCase.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/18/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Section.h"
#import "JMBaseUITestCase+LoginPage.h"
#import "JMBaseUITestCase+Buttons.h"

#define JMUITestLocalDebugState 0

static NSString *JMUIBaseTestCaseExecutedTestNumberKey = @"JMUIBaseTestCaseExecutedTestNumberKey";

NSTimeInterval kUITestsBaseTimeout = 15;
NSTimeInterval kUITestsResourceWaitingTimeout = 60;
NSTimeInterval kUITestsElementAvailableTimeout = 3;

@implementation JMBaseUITestCase

- (void)setUp {
    [super setUp];
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    XCUIApplication *app = self.application;
    @try {
        [app launch];
    } @catch(NSException *exception) {
        NSLog(@"Exception: %@", exception);
        XCTFail(@"Failed to launch application");
    }

    if (![self shouldPerformSuperSetup]) {
        NSLog(@"Skip performing 'super' setup");
        return;
    } else {
        NSLog(@"Do performing 'super' setup");
    }

    if ([self shouldLoginBeforeStartTest]) {
        NSLog(@"Try to log in before performing tests");
        [self loginWithTestProfileIfNeed];
        [self givenThatLibraryPageOnScreen];
    } else {
        NSLog(@"Perform tests without logging in");
        XCUIElement *libraryPageView = [self libraryPageViewElement];
        if (libraryPageView.exists) {
            NSLog(@"Library page on screen");
            [self logout];
        } else {
            NSLog(@"Login page on screen");
        }
    }
}

- (void)tearDown {
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIApplication *app = self.application;
    [app terminate];
    self.application = nil;
    
    [super tearDown];
}

#pragma mark - Custom Accessors
- (XCUIApplication *)application
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    if (!_application) {
        _application = [XCUIApplication new];
    }
    return _application;
}

#pragma mark - JMBaseUITestProtocol
- (BOOL)shouldPerformSuperSetup
{
#if JMUITestLocalDebugState
    // FOR LOCAL DEBUG ONLY
    return NO;
#else
    NSInteger testsCount = [self testsCount];
    NSNumber *executedTestNumber = [[NSUserDefaults standardUserDefaults] objectForKey:JMUIBaseTestCaseExecutedTestNumberKey];
    NSInteger executedTestCount = executedTestNumber ? executedTestNumber.integerValue : 0;
    NSLog(@"Executed '%@' from '%@' tests", @(executedTestCount), @(testsCount));
    if (executedTestCount == 0) { // First execution of each test case
        [self saveExecutedTestCount:(testsCount == 1) ? 0 : ++executedTestCount];
        return YES;
    } else if (executedTestCount < testsCount - 1) { // In the middle of test case
        [self saveExecutedTestCount:++executedTestCount];
        return NO;
    } else { // Reset execution count after executing of all tests in test case
        [self saveExecutedTestCount:0];
        return NO;
    }
#endif
}

- (NSInteger)testsCount
{
    [self saveExecutedTestCount:0];
    return 1;
}

- (BOOL) shouldLoginBeforeStartTest
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    return YES;
}

- (void)saveExecutedTestCount:(NSInteger)testCount
{
    [[NSUserDefaults standardUserDefaults] setObject:@(testCount)
                                              forKey:JMUIBaseTestCaseExecutedTestNumberKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Helper Actions
// TODO: replace this method with 'tryBackToPreviousPageWithTitle:'
- (void)tryBackToPreviousPage
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self tapBackButtonWithAlternativeTitle:JMLocalizedString(@"menuitem_library_label")
                          onNavBarWithTitle:nil];
}

- (void)tryBackToPreviousPageWithTitle:(NSString *)pageTitle
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self tapBackButtonWithAlternativeTitle:pageTitle
                          onNavBarWithTitle:nil];
}

#pragma mark - Verifies - Loading Popup
- (void)givenLoadingPopupVisible
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *popup = [self waitElementMatchingType:XCUIElementTypeOther
                                            identifier:@"JMCancelRequestPopupAccessibilityId"
                                         parentElement:nil
                                   shouldBeInHierarchy:YES
                                               timeout:kUITestsResourceWaitingTimeout];
    if (!popup.exists) {
        XCTFail(@"Loading popup isn't visible");
    }
}

- (void)givenLoadingPopupNotVisible
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *popup = [self waitElementMatchingType:XCUIElementTypeOther
                                            identifier:@"JMCancelRequestPopupAccessibilityId"
                                         parentElement:nil
                                   shouldBeInHierarchy:NO
                                               timeout:kUITestsResourceWaitingTimeout];
    if (popup.exists) {
        XCTFail(@"Loading popup visible");
    }
}

@end
