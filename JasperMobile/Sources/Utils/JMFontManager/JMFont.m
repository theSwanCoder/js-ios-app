//
//  JMFont.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 8/29/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMFont.h"

@implementation JMFont

+ (UIFont *)navigationBarTitleFont
{
    return [JMUtils isIphone] ? [UIFont boldSystemFontOfSize:14] : [UIFont boldSystemFontOfSize:17];
}

+ (UIFont *)navigationItemsFont
{
    return [JMUtils isIphone] ? [UIFont systemFontOfSize:14] : [UIFont systemFontOfSize:17];
}

+ (UIFont *)tableViewCellTitleFont
{
    return [JMUtils isIphone] ? [UIFont systemFontOfSize:14] : [UIFont systemFontOfSize:17];
}

+ (UIFont *)tableViewCellDetailFont
{
    return [JMUtils isIphone] ? [UIFont systemFontOfSize:14] : [UIFont systemFontOfSize:17];
}

+ (UIFont *)tableViewCellDetailErrorFont
{
    return [JMUtils isIphone] ? [UIFont italicSystemFontOfSize:12] : [UIFont italicSystemFontOfSize:16];
}

+ (UIFont *)resourcesActivityTitleFont
{
    return [JMUtils isIphone] ? [UIFont italicSystemFontOfSize:20] : [UIFont italicSystemFontOfSize:30];
}

@end
