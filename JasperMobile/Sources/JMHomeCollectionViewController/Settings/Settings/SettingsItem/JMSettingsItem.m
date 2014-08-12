//
//  JMSettingsItem.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/10/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMSettingsItem.h"

@implementation JMSettingsItem
- (id)init{
    self = [super init];
    if (self) {
        self.availableRange = NSMakeRange(0, 1000);
    }
    return self;
}

@end
