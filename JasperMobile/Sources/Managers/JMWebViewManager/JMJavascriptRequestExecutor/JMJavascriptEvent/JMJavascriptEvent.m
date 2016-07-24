/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2016 TIBCO Software, Inc. All rights reserved.
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
//  JMJavascriptEvent.h
//  TIBCO JasperMobile
//

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