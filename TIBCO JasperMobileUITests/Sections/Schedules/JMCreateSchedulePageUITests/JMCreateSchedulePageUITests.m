//
//  JMCreateSchedulePageUITests.m
//  TIBCO JasperMobile
//
// Created by Aleksandr Dakhno on 12/26/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMCreateSchedulePageUITests.h"

@implementation JMCreateSchedulePageUITests

#pragma mark - Preparing

#pragma mark - Tests

//  Default folder in 'Repository Output Folder' field
//  - Preconditions:
//      1. Login as superuser in JRS
//      2. View->Repository
//      3. Copy file '01._Geographic_Results_by_Segment_Report' from /public/Samples/Reports/
//      4. Paste to /public
//  - Steps:
//      1. Login as superuser in application
//      2. Open the Left Panel
//      3. Tap on Library
//      4. Open copied '01._Geographic_Results_by_Segment_Report'
//      5. Tap on action menu and select Schedule
//      6. Look at 'Repository Output Folder' field
//  - Expected Result:
//      1. In 'Repository Output Folder' field should be '/public'
- (void)testDefaultFolderForNewSchedule
{

}

//  User should see Create Schedule screen
//  - Preconditions:
//      1. Open the Left Panel
//      2. Tap on the 'Schedules' button
//  - Steps:
//      1. Tap on '+' create button
//      2. Select some report
//  - Expected Result:
//      1. Should appears list of reports
//      2. Should appears Create Schedule screen
- (void)testThatNewSchedulePageCanBeViewed
{

}

//  'Schedules' title
//  - Preconditions:
//      1. Open the Left Panel
//      2. Tap on the 'Schedules' button
//  - Steps:
//      1. Tap on '+' create button
//      2. Select some report
//      3. Look at screen title
//  - Expected Result:
//      1. User should see title like "Schedules"
- (void)testThatNewSchedulePageHasCorrectTitle
{

}

//  Back button in Create Schedule screen
//  - Preconditions:
//      1. Open the Left Panel
//      2. Tap on the 'Schedules' button
//  - Steps:
//      1. Tap on '+' create button
//      2. Select some report
//      3. Tap on Back button
//  - Expected Result:
//      1. Should appears Schedules screen
- (void)testThatBackButtonOnNewSchedulePageWorkCorrectly
{

}

//  Create schedule with enabled 'Start immediately' button
//  - Preconditions:
//      1. Open the Left Panel
//      2. Tap on the 'Schedules' button
//      3. Tap on '+' create button
//      4. Select some report
//  - Steps:
//      1. Change 'Output File Name'
//      2. In 'Recurrence Type' select None
//      3. Turn on 'Start immediately' button
//      4. Tap on 'Apply' button
//  - Expected Result:
//      1. Schedule should be created
- (void)testThatNewScheduleToStartImmediatelyCanBeCreated
{

}

//  Create schedule with enabled 'Start immediately' button, set 'Run at' date
//  - Preconditions:
//      1. Open the Left Panel
//      2. Tap on the 'Schedules' button
//      3. Tap on '+' create button
//      4. Select some report
//  - Steps:
//      1. Change 'Output File Name'
//      2. In 'Recurrence Type' select None
//      3. Turn off 'Start immediately' button
//      4. In 'Run at:' field set future date
//      5. Tap on 'Apply' button
//  - Expected Result:
//      1. Schedule should be created
- (void)testThatNewScheduleWithStartDateCanBeCreated
{

}

//  Create simple schedule with set 'Count', in 'Interval' field set weeks, set 'Number of Runs'
//  - Preconditions:
//      1. Open the Left Panel
//      2. Tap on the 'Schedules' button
//      3. Tap on '+' create button
//      4. Select some report
//  - Steps:
//      1. Change 'Output File Name'
//      2. In 'Recurrence Type' select Simple
//      3. In 'Count' field enter some value (for instance 3)
//      4. In 'Interval' field select Weeks
//      5. In 'Number of Runs' enter some value (for instance 10)
//      6. Tap on 'Apply' button
//  - Expected Result:
//      1. Schedule should be created
- (void)testThatNewRecurringScheduleWithNumberOfRunsCanBeCreated
{

}

//  Create simple schedule with set 'Count', in 'Interval' field set days, in 'End Date' set future date
//  - Preconditions:
//      1. Open the Left Panel
//      2. Tap on the 'Schedules' button
//      3. Tap on '+' create button
//      4. Select some report
//  - Steps:
//      1. Change 'Output File Name'
//      2. In 'Recurrence Type' select Simple
//      3. In 'Count' field enter some value (for instance 5)
//      4. In 'Interval' field select Days
//      5. In 'End Date' field select future date
//      6. Tap on 'Apply' button
//  - Expected Result:
//      1. Schedule should be created
- (void)testThatNewRecurringScheduleWithEndDateCanBeCreated
{

}

//  Create simple schedule with set 'Count', in 'Interval' field set hours, enabled 'Run Indefinitely' button
//  - Preconditions:
//      1. Open the Left Panel
//      2. Tap on the 'Schedules' button
//      3. Tap on '+' create button
//      4. Select some report
//  - Steps:
//      1. Change 'Output File Name'
//      2. In 'Recurrence Type' select Simple
//      3. In 'Count' field enter some value (for instance 5)
//      4. In 'Interval' field select Hours
//      5. Turn on 'Run Indefinitely' button
//      6. Tap on 'Apply' button
//  - Expected Result:
//      1. Schedule should be created
- (void)testThatNewRecurringScheduleWithoutEndDateCanBeCreated
{

}

//  Create calendar schedule with enabled 'Every Month' and 'Every Day' buttons, in 'Hours' and 'Minutes' set single value
//  - Preconditions:
//      1. Open the Left Panel
//      2. Tap on the 'Schedules' button
//      3. Tap on '+' create button
//      4. Select some report
//  - Steps:
//      1. Change 'Output File Name'
//      2. In 'Recurrence Type' select Calendar
//      3. Turn on 'Every Month' button
//      4. Turn on 'Every Day' button
//      5. In 'Hours' field enter some value (for instance 8)
//      6. In 'Minutes' field enter some value (for instance 15)
//      7. Tap on 'Apply' button
//  - Expected Result:
//      1. Schedule should be created
- (void)testThatNewCalendarScheduleWithSingleValuesInTimeIntervalsBeCreated
{

}

//  Create calendar schedule with disabled 'Every Month' and 'Every Day' buttons, in 'Hours' and 'Minutes' set few values
//  - Preconditions:
//      1. Open the Left Panel
//      2. Tap on the 'Schedules' button
//      3. Tap on '+' create button
//      4. Select some report
//  - Steps:
//      1. Change 'Output File Name'
//      2. In 'Recurrence Type' select Calendar
//      3. Turn off 'Every Month' button
//      4. In 'Selected Months' select desired months
//      5. Turn off 'Every Day' button
//      6. In 'Selected Days' select desired days
//      7. In 'Hours' field enter some value (for instance 8, 9, 14-17)
//      8. In 'Minutes' field enter some value (for instance 15, 30, 45)
//      9. Tap on 'Apply' button
//  - Expected Result:
//      1. Schedule should be created
- (void)testThatNewCalendarScheduleWithMultipleValuesInTimeIntervalsBeCreated
{

}

//  Create calendar schedule with disabled 'Every Month' and 'Every Day' buttons, in 'Hours' and 'Minutes' set few values, in 'End Date' set future date
//  - Preconditions:
//      1. Open the Left Panel
//      2. Tap on the 'Schedules' button
//      3. Tap on '+' create button
//      4. Select some report
//  - Steps:
//      1. Change 'Output File Name'
//      2. In 'Recurrence Type' select Calendar
//      3. Turn off 'Every Month' button
//      4. In 'Selected Months' select desired months
//      5. Turn off 'Every Day' button
//      6. In 'Selected Days' select desired days
//      7. In 'Hours' field enter some value (for instance 8, 9, 14-17)
//      8. In 'Minutes' field enter some value (for instance 15, 30, 45)
//      9. In 'End Date' field select future date
//      10. Tap on 'Apply' button
//  - Expected Result:
//      1. Schedule should be created
- (void)testThatNewCalendarScheduleWithMultipleValuesInTimeIntervalsAndEndDateBeCreated
{

}

//  Save description in old versions JRS (5.6.1, 5.6, 5.5, 6.0.1, 6.1.1)
//  - Preconditions:
//      1. Open the Left Panel
//      2. Tap on the 'Schedules' button
//      3. Tap on '+' create button
//      4. Select some report
//  - Steps:
//      1. In 'Recurrence Type' field select Simple
//      2. Enter description to 'Description' field
//      3. Tap on Apply
//      4. In Schedules list items tap on created item
//      5. Look at 'Description' field
//  - Expected Result:
//      1. Descriptions not saves in old version of JRS (5.6.1, 5.6, 5.5, 6.0.1, 6.1.1).
//      Note: Descriptions for schedule should be saved correct in JRS 6.2, 6.2.1, 6.3 and newer
- (void)testScheduleHasCorrectDescription
{

}

#pragma mark - Preconditions Helpers

#pragma mark - Cleaning Helpers

#pragma mark - Verifying

#pragma mark - General Helpers

@end