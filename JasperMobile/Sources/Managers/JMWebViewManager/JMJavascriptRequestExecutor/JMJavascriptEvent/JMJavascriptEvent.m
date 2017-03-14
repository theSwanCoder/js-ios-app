/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMJavascriptEvent.h"

@interface JMJavascriptEvent()
@property (nonatomic, copy, readwrite) NSString *identifier;
@property (nonatomic, strong, readwrite) id listener;
@property (nonatomic, copy) JMJavascriptRequestCompletion callback;
@end

@implementation JMJavascriptEvent


#pragma mark - Lify Cycle

- (instancetype)initWithIdentifier:(NSString *)identifier listener:(id)listener callback:(JMJavascriptRequestCompletion)callback
{
    self = [super init];
    if (self) {
        _identifier = [identifier copy];
        _listener = listener;
        _callback = [callback copy];
    }
    return self;
}

+ (instancetype)eventWithIdentifier:(NSString *)identifier listener:(id)listener callback:(JMJavascriptRequestCompletion)callback
{
    return [[self alloc] initWithIdentifier:identifier listener:listener callback:callback];
}

#pragma mark - NSCopying + NSObject Protocol
- (NSUInteger)hash
{
    NSString *fullCommand = [NSString stringWithFormat:@"identifier:%@listener:%@", self.identifier, self.listener];
    NSUInteger hash = [fullCommand hash];
    return hash;
}

- (BOOL)isEqual:(JMJavascriptEvent *)secondEvent
{
    BOOL isIdentifiersEqual = [self.identifier isEqual:secondEvent.identifier];
    BOOL isListenerEqual = [self.listener isEqual:secondEvent.listener];
    return isIdentifiersEqual && isListenerEqual;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    JMJavascriptEvent *newEvent = (JMJavascriptEvent *) [[self class] allocWithZone:zone];
    newEvent.identifier = [self.identifier copyWithZone:zone];
    newEvent.listener = self.listener;
    return newEvent;
}

@end
