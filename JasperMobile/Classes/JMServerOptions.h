//
//  JMServerOptions.h
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/24/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMServerProfile.h"
#import "JMServerOption.h"

@interface JMServerOptions : NSObject

@property (nonatomic, strong) JMServerProfile *serverProfile;
@property (nonatomic, readonly) NSArray *optionsArray;

- (id)initWithServerProfile:(JMServerProfile *)serverProfile;

- (BOOL) saveChanges;
- (void) discardChanges;
@end
