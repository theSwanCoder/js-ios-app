//
//  JMDetailSettings.h
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/11/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JMDetailSettings : NSObject
@property (nonatomic, readonly) NSArray *itemsArray;

- (void) saveSettings;
@end
