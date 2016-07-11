/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
 * http://community.jaspersoft.com/project/jaspermobile-ios
 *
 * Unless you have purchased a commercial license agreement from Jaspersoft,
 * the following license terms apply:
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/lgpl>.
 */

//
//  JMServerOptionsTests.h
//  TIBCO JasperMobile
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

/**
 @author Aleksandr Dakhno odahno@tibco.com
 @since 2.0
 */

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "JMServerOptionManager.h"
#import "JMServerProfile.h"

@interface JMServerOptionsTests : XCTestCase
@property (strong, nonatomic) JMServerProfile *serverProfile;
@end

@implementation JMServerOptionsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    // TODO: Here we shouldn't initialize JMServerProfile with 'new'.
    self.serverProfile = [JMServerProfile new];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTest {
    // TODO: create tests
    //XCTAssert(self.serverProfile.alias, @"");
}

@end
