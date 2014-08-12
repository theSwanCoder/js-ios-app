//
//  JMSettingsItem.h
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/10/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JMSettingsItem : NSObject
@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong) id        valueSettings;
@property (nonatomic, assign) NSRange   availableRange;
@property (nonatomic, strong) NSString *cellIdentifier;

@end
