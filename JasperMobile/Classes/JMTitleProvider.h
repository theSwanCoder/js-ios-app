//
//  JMTitleProvider.h
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/28/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JMTitleProvider <NSObject>
@optional
- (NSString *) titleForMenuLabel;
@end
