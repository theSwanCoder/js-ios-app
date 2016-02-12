//
//  JMLibraryUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/11/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import <XCTest/XCTest.h>

NSString *const kJMTestProfileURL = @"http://192.168.88.55:8088/jasperserver-pro-62";
NSString *const kJMTestProfileName = @"Test Profile";

@interface JMLibraryUITests : XCTestCase
@property(nonatomic, strong) XCUIApplication *application;
@end

@implementation JMLibraryUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
//    [[[XCUIApplication alloc] init] launch];

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    
    self.application = [[XCUIApplication alloc] init];
    [self.application launch];
    [self createTestProfile];
    [self loginWithTestProfile];
}

- (void)createTestProfile
{
    [self.application.textFields[@"Server"] tap];
    [self.application.navigationBars[@"Server Profiles"].buttons[@"add item"] tap];
    
    XCUIElement *doneButton = self.application.toolbars.buttons[@"Done"];
    XCUIElement *saveButton = self.application.buttons[@"Save"];
    XCUIElement *securityWarningAlert = self.application.alerts[@"Warning"];
    XCUIElement *securityWarningAlertOkButton = securityWarningAlert.collectionViews.buttons[@"ok"];
    
    XCUIElementQuery *tablesQuery = self.application.tables;
    
    // Find Profile Name TextField
    XCUIElement *profileNameTextFieldElement = tablesQuery.textFields[@"Profile name"];
    [profileNameTextFieldElement tap];
    [profileNameTextFieldElement typeText:kJMTestProfileName];
    
    //[doneButton tap];
    
    // Find Profile URL TextField
    XCUIElement *profileURLTextFieldElement = tablesQuery.textFields[@"Server address"];
    [profileURLTextFieldElement tap];
    [profileURLTextFieldElement typeText:kJMTestProfileURL];
    
    [doneButton tap];
    [saveButton tap];
    
    [securityWarningAlertOkButton tap];
    
    // Select Test Profile
    XCUIElement *testProfile = self.application.collectionViews.staticTexts[@"Test Profile"];
    [testProfile tap];
}

- (void)loginWithTestProfile
{
    XCUIElement *usernameTextField = self.application.textFields[@"Username"];
    [usernameTextField tap];
    [usernameTextField typeText:@"superuser"];
    
    XCUIElement *passwordSecureTextField = self.application.secureTextFields[@"Password"];
    [passwordSecureTextField tap];
    [passwordSecureTextField typeText:@"superuser"];
    
    [self.application.buttons[@"Done"] tap];
    [self.application.buttons[@"Login"] tap];
}

- (void)logout
{
    [self.application.navigationBars[@"Library"].buttons[@"menu icon"] tap];
    [self.application.tables.staticTexts[@"Log Out"] tap];
}

- (void)removeTestProfile
{
    [self.application.textFields[@"Server"] tap];
    
    XCUIElement *testProfile = self.application.collectionViews.staticTexts[@"Test Profile"];
    [testProfile pressForDuration:1.1];
    [self.application.menuItems[@"Delete"] tap];
    
    XCUIElement *confirmationAlert = self.application.alerts[@"Confirmation"];
    XCUIElement *deleteButton = confirmationAlert.collectionViews.buttons[@"Delete"];
    [deleteButton tap];
    
    XCUIElement *backButton = [[[self.application.navigationBars[@"Server Profiles"] childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Back"] elementBoundByIndex:0];
    [backButton tap];
}

- (void)testServerProfile
{
    
}

- (void)tearDown {
    [self logout];
    [self removeTestProfile];
    self.application = nil;
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

@end
