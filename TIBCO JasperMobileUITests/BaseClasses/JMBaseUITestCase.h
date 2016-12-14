//
//  JMBaseUITestCase.h
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/18/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

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

@end
