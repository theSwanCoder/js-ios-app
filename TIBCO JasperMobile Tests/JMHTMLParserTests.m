//
//  JMHTMLParserTests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 3/18/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JMHTMLParser.h"

NSString * const kTestJMHTMLParserBodyPattern = @"<body\\s*.*>((\\s*.*)*)<\\/body>";
NSString * const kTestJMHTMLParserContentPattern = @"(<a name=\"JR_PAGE_ANCHOR(\\s*\\S*)*)<\\/td><\\/tr>\\s*<\\/table>";
NSString * const kTestJMHTMLParserScriptPattern = @"(<script\\s*.*>(\\s*\\w*)*<\\/script>)";
NSString * const kTestJMHTMLParserScriptContentPattern = @"<script\\s*.*>((\\s*.*)*)<\\/script>";

@protocol JMHTMLParserPrivate
- (NSString *)parseString:(NSString *)string withPattern:(NSString *)pattern;
- (NSString *)replaceStringWithPattern:(NSString *)pattern inString:(NSString *)string;
- (NSArray *)parsedStringsFromString:(NSString *)string withPattern:(NSString *)pattern;
- (NSArray *)parsedStringsFromString:(NSString *)string withBeginSubstring:(NSString *)begingSubstring toEndSubstring:(NSString *)endSubstring;
- (NSArray *)findAllKeysInJSONString:(NSString *)JSONString;
@end

@interface JMHTMLParser(Private) <JMHTMLParserPrivate>
@end

@interface JMHTMLParserTests : XCTestCase
@property(nonatomic, strong) JMHTMLParser *parser;
@property(nonatomic, strong) NSString *testHTMLString;
@end

@implementation JMHTMLParserTests

- (void)setUp {
    [super setUp];

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *htmlPath = [bundle pathForResource:@"testPage" ofType:@"html"];
    self.testHTMLString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    self.parser = [JMHTMLParser parserWithHTMLString:self.testHTMLString];
}

- (void)tearDown {
    self.parser = nil;
    [super tearDown];
}

#pragma mark - Tests of Body Extracting
- (void)testThatParserCanExtractBodyFromHTMLWithEmptyBody
{
    NSString *htmlString = @"<html><head></head><body></body></hmtl>";
    NSArray *bodies = [self.parser parsedStringsFromString:htmlString
                                         withBeginSubstring:@"<body"
                                             toEndSubstring:@"</body>"];
    XCTAssert(bodies.count == 1, @"should be array with 1 body, but we have: %@", @(bodies.count));
}

- (void)testThatParserCanExtractBodyFromHTMLWithBodyWhichHaveSomePropertiesAndWithoutContent
{
    NSString *htmlString = @"<html><head></head><body a></body></hmtl>";
    NSArray *bodies = [self.parser parsedStringsFromString:htmlString
                                        withBeginSubstring:@"<body"
                                            toEndSubstring:@"</body>"];
    XCTAssert(bodies.count == 1, @"should be array with 1 body, but we have: %@", @(bodies.count));
}

- (void)testThatParserCanExtractBodyFromHTMLWithBodyWhichHaveSomePropertiesAndWithContent
{
    NSString *htmlString = @"<html><head></head><body a>some content</body></hmtl>";
    NSArray *bodies = [self.parser parsedStringsFromString:htmlString
                                        withBeginSubstring:@"<body"
                                            toEndSubstring:@"</body>"];
    XCTAssert(bodies.count == 1, @"should be array with 1 body, but we have: %@", @(bodies.count));
}

- (void)testThatParserFailedIfBodyTagsAbsent
{
    NSString *htmlString = @"<html><head></head></hmtl>";
    NSArray *bodies = [self.parser parsedStringsFromString:htmlString
                                        withBeginSubstring:@"<body"
                                            toEndSubstring:@"</body>"];
    XCTAssert(bodies.count == 0, @"should be array without body, but we have: %@", @(bodies.count));
}

- (void)testThatParserFailedIfOnlyOpenBodyTagAbsent
{
    NSString *htmlString = @"<html><head></head></body></hmtl>";
    NSArray *bodies = [self.parser parsedStringsFromString:htmlString
                                        withBeginSubstring:@"<body"
                                            toEndSubstring:@"</body>"];
    XCTAssert(bodies.count == 0, @"should be array without body, but we have: %@", @(bodies.count));
}

- (void)testThatParserFailedIfOnlyCloseBodyTagAbsent
{
    NSString *htmlString = @"<html><head></head><body></hmtl>";
    NSArray *bodies = [self.parser parsedStringsFromString:htmlString
                                        withBeginSubstring:@"<body"
                                            toEndSubstring:@"</body>"];
    XCTAssert(bodies.count == 0, @"should be array without body, but we have: %@", @(bodies.count));
}

#pragma mark - Tests of Content Extracting
- (void)testThatParserCanExtractContentFromBody
{
    NSString *allBodyString = @"<td align=\"center\">\n    <a name=\"JR_PAGE_ANCHOR_0_1\"></a>\n    <table class=\"jrPage\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"empty-cells: show; width: 612px; border-collapse: separate; background-color: white;\">\n    <tr valign=\"top\" style=\"height:0\"> &nbsp;</td></tr>\n    </table>";
    NSArray *contents = [self.parser parsedStringsFromString:allBodyString
                                        withBeginSubstring:@"<a name=\"JR_PAGE_ANCHOR"
                                            toEndSubstring:@"&nbsp;"];
    XCTAssert(contents.count == 1, @"should be array with 1 content, but we have: %@", @(contents.count));
}

- (void)testThatParserFailedWhenContentAbsent
{
    NSString *allBodyString = @"";
    NSArray *contents = [self.parser parsedStringsFromString:allBodyString
                                          withBeginSubstring:@"<a name=\"JR_PAGE_ANCHOR"
                                              toEndSubstring:@"&nbsp;"];
    XCTAssert(contents.count == 0, @"should be array without content, but we have: %@", @(contents.count));
}

#pragma mark - Tests of Scripts Extracting
- (void)testThatParserCanExtractOneScriptWithoutPropertiesAndScriptContentAsArray
{
    NSString *contentString = @"<a></a><script>content</script><a></a>";
    NSArray *scripts = [self.parser parsedStringsFromString:contentString
                                         withBeginSubstring:@"<script"
                                             toEndSubstring:@"</script>"];
    XCTAssert(scripts.count == 1, @"should be array with one script");
}

- (void)testThatParserCanExtractOneScriptWithSrcPropertyAndScriptContentAsArray
{
    NSString *contentString = @"<a></a><script src=\"src\">content</script><a></a>";
    NSArray *scripts = [self.parser parsedStringsFromString:contentString
                                         withBeginSubstring:@"<script"
                                             toEndSubstring:@"</script>"];
    XCTAssert(scripts.count == 1, @"should be array with 1 script, but we have: %@", @(scripts.count));
}

- (void)testThatParserCanExtractThreeScriptsWithSrcPropertyAndScriptContentAsArray
{
    NSString *contentString = @"<a>\n    </a>\n    <script>\n    content\n    </script>\n\n    <a>\n    </a>\n    <script src=\"src\">\n    content\n    </script>\n    <a></a>\n    <script src=\"src\">\n    content fasdf\n    asdfas\n    </script>\n    <a>\n    </a>";
    NSArray *scripts = [self.parser parsedStringsFromString:contentString
                                         withBeginSubstring:@"<script"
                                             toEndSubstring:@"</script>"];
    XCTAssert(scripts.count == 3, @"should be array with 3 scripts, but we have: %@", @(scripts.count));
}

#pragma mark - Tests of Scripts Content Extracting
//- (void)testThatOneKeyWithoutQuotesCanBeFound
//{
//    NSString *JSONString = @"{key: {\"key1\": \"value\"}}";
//    NSArray *allKeys = [self.parser findAllKeysInJSONString:JSONString];
//    NSLog(@"allKeys: %@", allKeys);
//    XCTAssert(allKeys.count == 1, @"should be array with 1 key, but we have: %@", @(allKeys.count));
//}

//- (void)testThatOneKeyWithoutQuotesCanBeFoundWithWhitespaces
//{
//    NSString *JSONString = @"{ \n\rkey: {\"key1\": \"value\"}}";
//    NSArray *allKeys = [self.parser findAllKeysInJSONString:JSONString];
//    NSLog(@"allKeys: %@", allKeys);
//    XCTAssert(allKeys.count == 1, @"should be array with 1 key, but we have: %@", @(allKeys.count));
//}

//- (void)testThatAllKeysWithoutQuotesCanBeFoundFromTestJSON
//{
//    // should be 6 keys
//    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
//    NSString *jsonPath = [bundle pathForResource:@"testJSON" ofType:@""];
//    NSString *JSONString = [NSString stringWithContentsOfFile:jsonPath encoding:NSUTF8StringEncoding error:nil];
//
//    NSArray *allKeys = [self.parser findAllKeysInJSONString:JSONString];
//    XCTAssert(allKeys.count == 6, @"should be array without keys, but we have: %@", @(allKeys.count));
//}

#pragma mark - Performance

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        [self.parser parse];
    }];
}

@end
