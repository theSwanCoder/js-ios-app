//
//  JMScheduleInfoPageUITests.m
//  TIBCO JasperMobile
//
// Created by Aleksandr Dakhno on 12/26/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMScheduleInfoPageUITests.h"

@implementation JMScheduleInfoPageUITests

#pragma mark - Preparing

#pragma mark - Tests

//  User should see Info screen
//  - Preconditions:
//      1. Open the Left Panel
//      2. Tap on the 'Schedules' button
//  - Steps:
//      1. Tap Info button on the schedule
//  - Expected Result:
//      1. User should see Info screen about the schedule
- (void)testThatScheduleInfoPageCanBeViewed
{

}

//  Back button
//  - Preconditions:
//      1. Open the Left Panel
//      2. Tap on the 'Schedules' button
//  - Steps:
//      1. Open the Left Panel
//      2. Tap on the 'Schedules' button
//  - Expected Result:
//      1. Schedules screen should appears
- (void)testThatBackButtonOnScheduleInfoPageWorkCorrectly
{

}

//  Title like name of item
//  - Preconditions:
//      1. Open the Left Panel
//      2. Tap on the 'Schedules' button
//  - Steps:
//      1. Tap Info button on the schedule
//  - Expected Result:
//      1. User should see title like name of item
- (void)testThatScheduleInfoPageHasCorrectTitle
{

}

//  Info about the schedule (Normal)
//  - Preconditions:
//      1. Open the Left Panel
//      2. Tap on the 'Schedules' button
//      3. Create schedule
//  - Steps:
//      1. Tap Info button on created schedule
//  - Expected Result:
//      1. User should see info about the schedule:
//          - Type: Schedule
//          - Version: 1
//          - Name: 01. Geographic Result by Segment ReportSchedule
//          - Description: test description
//          - Owner: superuser
//          - State: NORMAL (or PAUSED in case if schedule paused in JRS)
//          - Previous Fire Time: appropriate date
//          - Next Fire Time: appropriate date
- (void)testThatScheduleInfoPageHasCorrectInfoAboutScheduleInNormalState
{

}

//  Info about the schedule (Paused)
//  - Preconditions:
//      1. Open the Left Panel
//      2. Tap on the 'Schedules' button
//      3. Create schedule
//  - Steps:
//      1. In JRS deselect 'Enable' checkbox for created schedule
//      2. Tap Info button on edited in JRS schedule
//  - Expected Result:
//      1. User should see info about the schedule:
//          - Type: Schedule
//          - Version: 1
//          - Name: 01. Geographic Result by Segment ReportSchedule
//          - Description: test description
//          - Owner: superuser
//          - State: PAUSED
//          - Previous Fire Time: appropriate date
//          - Next Fire Time: appropriate date
- (void)testThatScheduleInfoPageHasCorrectInfoAboutScheduleInPausedState
{

}

//  Items in action menu
//  - Preconditions:
//      1. Open the Left Panel
//      2. Tap on the 'Schedules' button
//  - Steps:
//      1. Tap Info button on the schedule
//      2. Tap on action menu
//  - Expected Result:
//      1. User should see following items:
//          - Edit Values
//          - Delete
- (void)testItemsInActionMenuOnScheduleInfoPage
{

}

//  Delete dialogbox
//  - Preconditions:
//      1. Open the Left Panel
//      2. Tap on the 'Schedules' button
//  - Steps:
//      1. Tap Info button on the schedule
//      2. Tap on action menu and select 'Delete'
//  - Expected Result:
//      1. Should appears dialogbox with title "Confirmation", text message "Do you really want to delete this item?" and buttons Cancel, OK
- (void)testDeleteDialogOnScheduleInfoPage
{

}

//  Cancel deleting
//  - Preconditions:
//      1. Open the Left Panel
//      2. Tap on the 'Schedules' button
//  - Steps:
//      1. Tap Info button on the schedule
//      2. Tap on action menu and select 'Delete'
//      3. Tap on Cancel button
//  - Expected Result:
//      1. Schedule not deleted
- (void)testThatDeletingScheduleCanBeCanceled
{

}

//  Confirm deleting
//  - Preconditions:
//      1. Open the Left Panel
//      2. Tap on the 'Schedules' button
//  - Steps:
//      1. Tap Info button on the schedule
//      2. Tap on action menu and select 'Delete'
//      3. Tap on OK button
//  - Expected Result:
//      1. Schedule should be deleted
- (void)testThatDeletingScheduleCanBeConfirmed
{

}

//  Edit values in schedule
//  - Preconditions:
//      1. Open the Left Panel
//      2. Tap on the 'Schedules' button
//  - Steps:
//      1. Tap Info button on the schedule
//      2. Tap on action menu and select 'Edit Values'
//      3. Make some changes and tap on 'Apply'
//  - Expected Result:
//  1. Schedule should be updated and appears message 'Schedule was updated successfully’
- (void)testThatScheduleCanBeEditedFromInfoPage
{

}

#pragma mark - Preconditions Helpers

#pragma mark - Cleaning Helpers

#pragma mark - Verifying

#pragma mark - General Helpers

@end