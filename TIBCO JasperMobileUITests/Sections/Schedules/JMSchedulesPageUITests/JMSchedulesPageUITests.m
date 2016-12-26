//
//  JMSchedulesPageUITests.m
//  TIBCO JasperMobile
//
// Created by Aleksandr Dakhno on 12/26/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMSchedulesPageUITests.h"
#import "JMBaseUITestCase+SideMenu.h"
#import "JMBaseUITestCase+SavedItems.h"

@implementation JMSchedulesPageUITests

#pragma mark - Preparing

#pragma mark - Tests

//  User should see Schedules screen
//  - Steps:
//      - Open the Left Panel
//      - Tap on the Schedules button
//  - Results:
//      - User should see Schedules screen
- (void)testThatSchedulesPageCanBeViewed
{
    [self performCommonPrecondition];
    [self verifyThatSchedulePageOnScreen];
    [self performCommonCleaning];
}

//  Left Panel button
//  - Steps:
//      - Open the Left Panel
//      - Tap on the Schedules button
//      - Open the Left Panel
//  - Results:
//      - User should see Left Panel button on the Schedules screen
- (void)testThatSideMenuCanBeViewedOnSchedulePage
{
    [self performCommonPrecondition];
    [self showSideMenuInSectionWithName:@"Schedules"];
    [self verifyThatSideMenuVisible];
    [self performCommonCleaning];
}

//  Schedules title
//  - Steps:
//      - Open the Left Panel
//      - Tap on the Schedules button
//  - Results:
//      - User should see title like "Schedules"
- (void)testThatSchedulesPageHasCorrectTitle
{
    [self performCommonPrecondition];
    [self verifyThatSchedulePageHasCorrectTitle];
    [self performCommonCleaning];
}

//  Search result
//  - Steps:
//      - Open the Left Panel
//      - Tap on the Schedules button
//      - Verify searching operation
//  - Results:
//      - User can:
//          - enter search text
//          - edit search text
//          - delete search text
//          - cancel search
//          - see result after searching
- (void)testThatSearchWorkOnSchedulesPage
{
    [self performCommonPrecondition];
    [self performPreconditionForTestingSearch];

    [self performSearchWithResults];
    [self verifyThatSearchWork];

    [self performCleaningAfterTestingSearch];
    [self performCommonCleaning];
}

//  Error message when no search result
//  - Steps:
//      - Open the Left Panel
//      - Tap on the Schedules button
//      - Enter incorrect search text
//  - Results:
//      - User can see error message 'No job is scheduled' when no search result
- (void)testThatSearchWithoutResultsWorkOnSchedulesPage
{
    [self performCommonPrecondition];
    [self performPreconditionForTestingSearch];

    [self performSearchWithoutResults];
    [self verifyThatSearchWithoutResultsWork];

    [self performCleaningAfterTestingSearch];
    [self performCommonCleaning];
}

//  Pull down to refresh all items
//  - Steps:
//      - Open the Left Panel
//      - Tap on the Schedules button
//      - Pull down to refresh
//  - Results:
//      - Schedules screen should refresh
- (void)testThatPullDownToRefreshWorkOnSchedulesPage
{
    [self performCommonPrecondition];
    [self performPreconditionForPullDownToRefresh];

    [self performPullDownToRefresh];
    [self verifyThatPullDownToRefreshWork];

    [self performCleaningAfterTestingPullDownToRefresh];
    [self performCommonCleaning];
}

//  Scroling of the list
//  - Steps:
//      - Open the Left Panel
//      - Tap on the Schedules button
//      - Scroll the list
//  - Results:
//      - Scroll should work as expected
- (void)testThatScrollingWorkOnSchedulesPage
{
    [self performCommonPrecondition];
    [self performPreconditionForScrolling];

    [self performScrolling];
    [self verifyThatScrollingWork];

    [self performCleaningAfterTestingScrolling];
    [self performCommonCleaning];
}

//  User should see only schedules items which he/she created
//  - Steps:
//      - Login as 'joeuser'
//      - Open the Left Panel
//      - Tap on the Library button
//      - Create some report schedules
//      - Login as 'superuser'
//      - Open the Left Panel
//      - Tap on the Library button
//      - Create some report schedules
//      - Login as 'jasperadmin'
//      - Open the Left Panel
//      - Tap on 'Schedules' button
//  - Results:
//      - Jasperadmin shouldn't see schedule items which superuser created, but should see schedule items which joeuser created.
//      - Joeuser can't create a schedule because joeuser has no permission to save in any folder (superuser could give joeuser access to any folder). When he tried appears error message.
//      - Superuser should see schedule items which jasperadmin or joeuser created
- (void)testThatSchedulesUserDependent
{

}

//  Default text on screen when no created schedules
//  - Steps:
//      - Open the Left Panel
//      - Tap on the Schedules button
//      - Delete all schedules (should be no schedules)
//  - Results:
//      - User can see error message 'No job is scheduled' when no created schedules there
- (void)testThatCorrectMessageVisibleWithoutSchedules
{
    [self performCommonPrecondition];
    [self verifyThatCorrectMessageVisibleWithoutSchedules];
    [self performCommonCleaning];
}

//  JRS 6.0/6.0.1/6.1: Schedules Thumbnails
//  - Steps:
//      - Open the Left Panel
//      - Tap on the Library button
//      - Tap on Info button on some report
//      - Create some schedule
//      - Open the Left Panel
//      - Tap on the 'Schedules' button
//      - Don't run the part of the reports
//      - Run the part of the reports
//  - Results:
//      - User should see default placeholder for non runned reports
//      - User should see Report Thumbnails for runned reports
- (void)testThatThumbnailsVisible
{
    //TODO: do we need this test case?
}

//  Schedule with status Normal
//  - Steps:
//      - Open the Left Panel
//      - Tap on the Schedules button
//      - Create schedule
//      - Open Schedules screen
//      - Look at status of just created schedule
//  - Results:
//      - Should be 'Status: Normal'
- (void)testThatNewScheduleHasCorrectStatus
{
    [self performCommonPrecondition];
    [self performPreconditionForTestingScheduleWithNormalStatus];

    [self verifyThatScheduleHasNormalStatus];

    [self performCleaningAfterTestingScheduleWithNormalStatus];
    [self performCommonCleaning];
}

//  Schedule with status Paused
//  - Steps:
//      - Open the Left Panel
//      - Tap on the Schedules button
//      - Create schedule
//      - In JRS deselect 'Enable' checkbox for created schedule
//      - Open Schedules screen on device
//      - Look at status of schedule
//  - Results:
//      - Should be 'Status: Paused'
- (void)testThatPausedScheduleHasCorrectStatus
{
    //TODO: do we need this test case?
}

//TODO: do we need this test cases?
//  Repeat all test cases in Library->info->Schedule
//  - Steps:
//      - Repeat all test cases from section 'Schedules' in Library->info->Schedule
//  - Results:
//      - Schedules should creates as expected

//  Repeat all test cases in Library->Report->Schedule
//  - Steps:
//      - Repeat all test cases from section 'Schedules' in Library->Report->Schedule
//  - Results:
//      - Schedules should creates as expected

#pragma mark - Preconditions Helpers
- (void)performCommonPrecondition
{

}

- (void)performPreconditionForTestingSearch
{

}

- (void)performPreconditionForPullDownToRefresh
{

}

- (void)performPreconditionForScrolling
{

}

- (void)performPreconditionForTestingScheduleWithNormalStatus
{

}

#pragma mark - Cleaning Helpers
- (void)performCommonCleaning
{

}

- (void)performCleaningAfterTestingSearch
{

}

- (void)performCleaningAfterTestingPullDownToRefresh
{

}

- (void)performCleaningAfterTestingScrolling
{

}

- (void)performCleaningAfterTestingScheduleWithNormalStatus
{

}

#pragma mark - Verifying
- (void)verifyThatSchedulePageOnScreen
{

}

- (void)verifyThatSideMenuVisible
{

}

- (void)verifyThatSchedulePageHasCorrectTitle
{

}

- (void)verifyThatSearchWork
{

}

- (void)verifyThatSearchWithoutResultsWork
{

}

- (void)verifyThatPullDownToRefreshWork
{

}

- (void)verifyThatScrollingWork
{

}

- (void)verifyThatCorrectMessageVisibleWithoutSchedules
{

}

- (void)verifyThatScheduleHasNormalStatus
{

}

#pragma mark - General Helpers
- (void)performSearchWithResults
{

}

- (void)performSearchWithoutResults
{

}

- (void)performPullDownToRefresh
{

}

- (void)performScrolling
{

}

@end