//
//  JMDetailSettingsItem.h
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/10/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JMDetailSettingsItem : NSObject
@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong) NSString *valueString;
@property (nonatomic, strong) NSString *keyString;
@property (nonatomic, assign) NSRange   availableRange;

- (void) saveSettings;

@end
