//
//  JMScheduleManagerTests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/10/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JaspersoftSDK.h"
#import "JMScheduleManager.h"

@interface JMScheduleManagerTests : XCTestCase
@property(nonatomic, strong) JSScheduleMetadata *scheduleMetadata;
@end

@implementation JMScheduleManagerTests

- (void)setUp {
    [super setUp];
    
//    self.scheduleMetadata = [self createTestScheduleMetadata];
    NSLog(@"scheduleMetadata: %@", self.scheduleMetadata);
    //{"baseOutputFilename":"03._Store_Segment_Performance_Report","outputFormats":{"outputFormat":["PDF"]},"source":{"reportUnitURI":"/public/Samples/Reports/03._Store_Segment_Performance_Report"},"trigger":{"simpleTrigger":{"timezone":"Europe/Helsinki","occurrenceCount":1,"startType":2,"recurrenceInterval":null,"recurrenceIntervalUnit":null,"endDate":null,"startDate":"2016-03-31 10:00"}},"outputTimeZone":"Europe/Helsinki","repositoryDestination":{"overwriteFiles":true,"sequentialFilenames":false,"folderURI":"/public/Samples/Reports","saveToRepository":true,"timestampPattern":null,"outputFTPInfo":{"type":"ftp","port":21,"folderPath":null,"password":null,"propertiesMap":{},"serverName":null,"userName":null}},"label":"03._Store_Segment_Performance_Report","description":"description"}
    
    
}

- (void)tearDown {
    self.scheduleMetadata = nil;
    [super tearDown];
}

#pragma mark - Tests Public API
//- (void)testThatNewScheduleWithSimpleTriggerCanBeCreatedFromTestMetadata
//{
//    XCTestExpectation *expectation = [self expectationWithDescription:@"Create New Schedule Expectation"];
//
//    [[JMScheduleManager sharedManager] createScheduleWithData:self.scheduleMetadata
//                                                   completion:^(JSScheduleMetadata *newScheduleMetadata, NSError *error) {
//                                                       [expectation fulfill];
//                                                       if (!newScheduleMetadata) {
//                                                           XCTAssertFalse(error, @"Create New Schedule Error");
//                                                       }
//                                                   }];
//
//    [self waitForExpectationsWithTimeout:120.0 handler:^(NSError *error) {
//        if (error) {
//            NSLog(@"Timeout Error: %@", error);
//            XCTAssertNil(error);
//        }
//    }];
//}

#pragma mark - Helpers
//- (JSScheduleMetadata *)createTestScheduleMetadata
//{
//    JSScheduleMetadata *scheduleMetadata = [JSScheduleMetadata new];
//    
//    scheduleMetadata.folderURI = @"/public/Samples/Reports";
//    scheduleMetadata.reportUnitURI = @"/public/Samples/Reports/03._Store_Segment_Performance_Report";
//    scheduleMetadata.label = @"03._Store_Segment_Performance_Report";
//    scheduleMetadata.baseOutputFilename = @"03._Store_Segment_Performance_Report";
//    scheduleMetadata.outputFormats = @[@"PDF"];
//    scheduleMetadata.outputTimeZone = [self currentTimeZone];
//    
//    JSScheduleSimpleTrigger *simpleTrigger = [self simpleTrigger];
//    scheduleMetadata.trigger = @{
//                                 @(JSScheduleTriggerTypeSimple) : simpleTrigger
//                                 };
//    return scheduleMetadata;
//}

- (NSString *)currentTimeZone
{
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    NSString *localTimeZoneName = localTimeZone.name;
    return localTimeZoneName;
}

- (JSScheduleSimpleTrigger *)simpleTrigger
{
    JSScheduleSimpleTrigger *simpleTrigger = [JSScheduleSimpleTrigger new];
    simpleTrigger.startType = JSScheduleTriggerStartTypeAtDate;
    simpleTrigger.occurrenceCount = @1;
    simpleTrigger.startDate = [NSDate dateWithTimeIntervalSinceNow:10*24*60*60];
    simpleTrigger.endDate = nil;
    simpleTrigger.timezone = [self currentTimeZone];
    simpleTrigger.recurrenceIntervalUnit = JSScheduleSimpleTriggerRecurrenceIntervalTypeNone;
    return simpleTrigger;
}

@end
