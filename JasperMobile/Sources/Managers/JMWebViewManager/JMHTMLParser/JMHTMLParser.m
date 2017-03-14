/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMHTMLParser.h"
#import "JMHTMLScript.h"

@interface JMHTMLParser()
@property (nonatomic, strong) NSString *htmlString;
@property (nonatomic, strong) NSString *contentString;
@end

@implementation JMHTMLParser

#pragma mark - Life Cycle
- (instancetype __nullable)initWithHTMLString:(NSString * __nonnull)htmlString
{
    self = [super init];
    if (self) {
        _htmlString = htmlString;
    }
    return self;
}

+ (instancetype __nullable)parserWithHTMLString:(NSString * __nonnull)htmlString
{
    return [[self alloc] initWithHTMLString:htmlString];
}

#pragma mark - Public API
- (void)parse
{
    NSString *htmlBodyString = [self extractedBodyFromHTMLString:self.htmlString];
    NSString *contentString = [self extractedContentFromBodyString:htmlBodyString];
    NSArray *scriptStrings= [self extractedScriptsFromContentString:contentString];

    NSString *htmlBodyStringWithoutScripts = [self removeScripts:scriptStrings
                                                        fromPage:contentString];
    
    self.contentString = htmlBodyStringWithoutScripts;
    
    NSMutableArray *scripts = [NSMutableArray array];
    for (NSString *scriptString in scriptStrings) {
        [scripts addObject:[self parseScriptFromString:scriptString]];
    }
    self.scripts = scripts;
}

- (NSString *)content
{
    return self.contentString;
}

#pragma mark - Private API
- (NSString *)extractedBodyFromHTMLString:(NSString *)HTMLString
{
    NSArray *bodies = [self parsedStringsFromString:HTMLString
                                 withBeginSubstring:@"<body"
                                     toEndSubstring:@"</body>"];
    NSString *bodyString = @"";
    if (bodies.count == 1) {
        bodyString = bodies.firstObject;
    }
    return bodyString;
}

- (NSString *)extractedContentFromBodyString:(NSString *)bodyString
{
    NSArray *contents = [self parsedStringsFromString:bodyString
                                   withBeginSubstring:@"<a name=\"JR_PAGE_ANCHOR"
                                       toEndSubstring:@"</body>"];
    NSString *contentString = @"";
    if (contents.count == 1) {
        contentString = contents.firstObject;
    }
    return contentString;
}

- (NSArray *)extractedScriptsFromContentString:(NSString *)contentString
{
    NSArray *scripts = [self parsedStringsFromString:contentString
                                  withBeginSubstring:@"<script"
                                      toEndSubstring:@"</script>"];
    return scripts;
}

#pragma mark - Helpers
- (NSArray *)parsedStringsFromString:(NSString *)string
                  withBeginSubstring:(NSString *)beginSubstring
                      toEndSubstring:(NSString *)endSubstring
{
    NSMutableArray *result = [NSMutableArray array];

    NSScanner *scaner = [NSScanner scannerWithString:string];
    while (!scaner.isAtEnd) {
        NSString *bufferString;
        BOOL isFoundBeginSubstring = [scaner scanUpToString:beginSubstring intoString:NULL];
        BOOL isScanBeginSubstring = [scaner scanString:beginSubstring intoString:NULL];
        BOOL isFoundEndSubstring = [scaner scanUpToString:endSubstring intoString:&bufferString];
        if (isFoundBeginSubstring && isScanBeginSubstring && isFoundEndSubstring && !scaner.isAtEnd) {
            NSString *resultString = [NSString stringWithFormat:@"%@ %@%@", beginSubstring, bufferString, endSubstring];
            resultString = [resultString stringByReplacingOccurrencesOfString:@" >" withString:@">"];
            [result addObject:resultString];
        }
    }
    
    return result;
}

- (NSString *)removeScripts:(NSArray *)scripts fromPage:(NSString *)page
{
    NSString *pageWithoutScripts = page;
    for (NSString *script in scripts) {
        pageWithoutScripts = [pageWithoutScripts stringByReplacingOccurrencesOfString:script withString:@""];
    }

    return pageWithoutScripts;
}

- (JMHTMLScript *)parseScriptFromString:(NSString *)scriptString
{
    JMHTMLScript *script = [JMHTMLScript new];

    if ([scriptString containsString:@"src="]) {
        script.type = JMHTMLScriptTypeLink;
        NSString *pattern = @"src=[\"|'](\\s*.*)[\"|']></script>";

        NSString *value = [self parseString:scriptString withPattern:pattern];
        if (value) {
            script.value = value;
        }
    } else if ([scriptString containsString:@"__renderHighcharts"]) {
        script.type = JMHTMLScriptTypeRenderHighchart;

        NSString *pattern = @"<script\\s*.*>((\\s*\\S*)*)</script>";
        NSString *fullScript = [self parseString:scriptString withPattern:pattern];

        pattern = @"^(\\s*\\S*)[\\(]";
        NSString *scriptName = [self parseString:fullScript withPattern:pattern];

        pattern = @"\\(((\\s*\\S*)*)\\);\\s*$";
        NSString *scriptParams = [self parseString:fullScript withPattern:pattern];

        NSArray *allKeys = [self findAllKeysInJSONString:scriptParams];
        for (NSString *key in allKeys) {
            NSString *keyWithQuotes = [NSString stringWithFormat:@"\"%@\":", key];
            NSString *keyWithColon = [NSString stringWithFormat:@"%@:", key];
            scriptParams = [scriptParams stringByReplacingOccurrencesOfString:keyWithColon
                                                                   withString:keyWithQuotes];
        }

        if (scriptName && scriptParams) {
            NSError *serializeError;
            NSData *scriptParamsData = [scriptParams dataUsingEncoding:NSUTF8StringEncoding];
            id response = [NSJSONSerialization JSONObjectWithData:scriptParamsData
                                                          options:NSJSONReadingAllowFragments
                                                            error:&serializeError];
            script.value = @{
                    @"scriptName"   : scriptName,
                    @"scriptParams" : (response != nil) ? response : @{}
            };
        }
    } else {
        script.type = JMHTMLScriptTypeSource;
        NSString *pattern = @">((\\s*\\S*)*)</script>";
        NSString *value = [self parseString:scriptString withPattern:pattern];
        if (value) {
            script.value = value;
        }
    }

    return script;
}

- (NSString *)parseString:(NSString *)string withPattern:(NSString *)pattern
{
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *matches = [regex matchesInString:string
                                      options:NSMatchingReportCompletion
                                        range:NSMakeRange(0, string.length)];
    
    NSString *resultString;
    for (NSTextCheckingResult *match in matches) {
        if (match.numberOfRanges > 1) {
            NSRange matchRange = [match rangeAtIndex:1];
            if (matchRange.length > 0) {
                resultString = [string substringWithRange:matchRange];                
            }
        }
    }
    return resultString;
}

- (NSArray *)findAllKeysInJSONString:(NSString *)JSONString
{
    NSMutableArray *allKeys = [NSMutableArray array];

    [allKeys addObjectsFromArray:@[
        @"services", @"chartDimensions", @"width", @"height", @"requirejsConfig", @"renderTo", @"globalOptions"
    ]];
//    NSCharacterSet *colonSet = [NSCharacterSet characterSetWithCharactersInString:@":"];
//
//    NSScanner *scaner = [NSScanner scannerWithString:JSONString];
//    while (!scaner.isAtEnd) {
//        NSString *bufferString;
//        BOOL isFoundColon = [scaner scanUpToCharactersFromSet:colonSet intoString:&bufferString];
//        if (isFoundColon && !scaner.isAtEnd) {
//            NSUInteger colonPosition = scaner.scanLocation;
//            NSRange range = NSMakeRange(colonPosition - 1, 1);
//            NSString *beforColorCharacter = [JSONString substringWithRange:range];
//            if (![beforColorCharacter isEqualToString:@"\""]) {
//                // scan back
//                JMLog(@"bufferString: %@", bufferString);
//                if (![bufferString containsString:@"http"]) {
//                    NSString *key = [self parseString:bufferString withPattern:@"(\\w*)$"];
//                    if (key) {
//                        [allKeys addObject:key];
//                    }
//                }
//            }
//            [scaner scanString:@":" intoString:NULL];
//        }
//    }
    
    return allKeys;
}

@end
