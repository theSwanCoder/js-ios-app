//
//  JMDetailSettingsItem.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/10/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMDetailSettingsItem.h"

@implementation JMDetailSettingsItem
- (id)init{
    self = [super init];
    if (self) {
        self.availableRange = NSMakeRange(0, 1000);
    }
    return self;
}

- (void)saveSettings{
    [[NSUserDefaults standardUserDefaults] setObject:self.valueString forKey:self.keyString];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
