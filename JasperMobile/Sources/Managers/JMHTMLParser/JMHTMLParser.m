//
// Created by Aleksandr Dakhno on 9/13/15.
// Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#import "JMHTMLParser.h"

@interface JMHTMLParser() <NSXMLParserDelegate>
@property (nonatomic, strong) NSXMLParser *parser;
@end

@implementation JMHTMLParser

#pragma mark - Public API
- (void)parseHTMLString:(NSString *)HTMLString
{
    NSData *data = [HTMLString dataUsingEncoding:NSUTF8StringEncoding];
    self.parser = [[NSXMLParser alloc] initWithData:data];
    self.parser.delegate = self;

    BOOL success = [self.parser parse];
    NSLog(@"parse start success: %@", success ? @"YES" : @"NO");
}

#pragma mark - NSXMLParserDelegate
- (void) parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
     attributes:(NSDictionary *)attributeDict
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSLog(@"elementName: %@", elementName);
    NSLog(@"namespaceURI: %@", namespaceURI);
    NSLog(@"qName: %@", qName);
    NSLog(@"attributeDict: %@", attributeDict);
}

- (void) parser:(NSXMLParser *)parser
        parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSLog(@"error: %@", parseError.localizedDescription);
}

- (void) parser:(NSXMLParser *)parser
foundCharacters:(NSString *)string
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSLog(@"string: %@", string);
}

- (void) parser:(NSXMLParser *)parser
  didEndElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSLog(@"elementName: %@", elementName);
    NSLog(@"namespaceURI: %@", namespaceURI);
    NSLog(@"qName: %@", qName);
}


@end