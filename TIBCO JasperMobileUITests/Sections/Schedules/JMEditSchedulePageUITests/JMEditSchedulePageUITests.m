//
//  JMEditSchedulePageUITests.m
//  TIBCO JasperMobile
//
// Created by Aleksandr Dakhno on 12/26/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMEditSchedulePageUITests.h"

@implementation JMEditSchedulePageUITests

#pragma mark - Preparing

#pragma mark - Tests

//  Open Edit schedule screen
//  - Preconditions:
//      1. Open the Left Panel
//      2. Tap on the 'Schedules' button
//  - Steps:
//      1. Tap on list item in Schedules screen
//  - Expected Result:
//      1. Should appears edit schedule screen
-(void)testThatEditSchedulePageCanBeViewed
{

}

//  Back button in Edit schedule screen
//  - Preconditions:
//      1. Open the Left Panel
//      2. Tap on the 'Schedules' button
//  - Steps:
//      1. Tap on list item in Schedules screen
//      2. Tap on Back button
//  - Expected Result:
//      1. Should appears Schedules screen
- (void)testThatBackButtonOnEditSchedulePageWorkCorrectly
{

}

//  Edit schedule
//  - Preconditions:
//      1. Open the Left Panel
//      2. Tap on the 'Schedules' button
//  - Steps:
//      1. Tap on list item in Schedules screen
//      2. Make some changes
//      3. Tap on Apply button
//  - Expected Result:
//      1. Schedule should be updated and appears message 'Schedule was updated successfully'
- (void)testThatScheduleCanBeEdited
{

}

//  Edit schedule with enabled 'Start immediately' button, set 'Run at' date
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
//      6. In Schedules screen tap on created schedule
//      7. Make some changes and save
//  - Expected Result:
//      1. Schedule should be updated and appears message 'Schedule was updated successfully'
- (void)testThatNoneRecurrenceScheduleCanBeEdited
{

}

//  Edit simple schedule with set 'Count', in 'Interval' field set weeks, set 'Number of Runs'
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
//      7. In Schedules screen tap on created schedule
//      8. Make some changes and save
//  - Expected Result:
//      1. Schedule should be updated and appears message 'Schedule was updated successfully’
- (void)testThatRecurrenceScheduleCanBeEdited
{

}

//  Edit simple schedule with set 'Count', in 'Interval' field set days, in 'End Date' set future date
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
//      7. In Schedules screen tap on created schedule
//      8. Make some changes and save
//  - Expected Result:
//      1. Schedule should be updated and appears message 'Schedule was updated successfully’
- (void)testThatRecurrenceScheduleWithEndDateCanBeEdited
{

}

//  Edit simple schedule with set 'Count', in 'Interval' field set hours, enabled 'Run Indefinitely' button
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
//      7. In Schedules screen tap on created schedule
//      8. Make some changes and save
//  - Expected Result:
//      1. Schedule should be updated and appears message 'Schedule was updated successfully'
- (void)testThatRecurrenceScheduleWithoutEndDateCanBeEdited
{

}

//  Edit calendar schedule with enabled 'Every Month' and 'Every Day' buttons, in 'Hours' and 'Minutes' set single value
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
//      8. In Schedules screen tap on created schedule
//      9. Make some changes and save
//  - Expected Result:
//      1. Schedule should be updated and appears message 'Schedule was updated successfully'
- (void)testThatRecurrenceScheduleWithSingleValuesInTimeIntervalsCanBeEdited
{

}

//  Edit calendar schedule with disabled 'Every Month' and 'Every Day' buttons, in 'Hours' and 'Minutes' set few values
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
//      10. In Schedules screen tap on created schedule
//      11. Make some changes and save
//  - Expected Result:
//      1. Schedule should be updated and appears message 'Schedule was updated successfully'
- (void)testThatRecurrenceScheduleWithMultipleValuesInTimeIntervalsCanBeEdited
{

}

//  Edit calendar schedule with disabled 'Every Month' and 'Every Day' buttons, in 'Hours' and 'Minutes' set few values, in 'End Date' set future date
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
//      11. In Schedules screen tap on created schedule
//      12. Make some changes and save
//  - Expected Result:
//      1. Schedule should be updated and appears message 'Schedule was updated successfully'
- (void)testThatRecurrenceScheduleWithMultipleValuesInTimeIntervalsAndEndDateCanBeEdited
{

}

//  Edit schedule which was created on JasperServer
//  - Preconditions:
//      1. In JRS create a schedule job with set Notifications, Parameters, Output Options (ftps) (for instance use '01. Geographic Results by Segment Report')
//      2. Open the Left Panel on device
//      3. Tap on the 'Schedules' button
//  - Steps:
//      1. Tap Edit button on the created job on JRS
//      2. Change the description for current job or any other parameters
//      3. Tap apply button
//      4. Open edited schedule on JRS
//  - Expected Result:
//      1. Notifications, Parameters, Output Options (ftps) settings should not disappear when user edits scheduled job on mobile application
- (void)testThatScheduleCreatedViaWebCanBeEdited
{

}

#pragma mark - Preconditions Helpers

#pragma mark - Cleaning Helpers

#pragma mark - Verifying

#pragma mark - General Helpers

@end