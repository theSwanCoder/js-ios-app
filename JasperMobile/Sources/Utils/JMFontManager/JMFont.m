/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
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
    return [JMUtils isIphone] ? [UIFont italicSystemFontOfSize:10] : [UIFont italicSystemFontOfSize:16];
}

+ (UIFont *)resourcesActivityTitleFont
{
    return [JMUtils isIphone] ? [UIFont systemFontOfSize:20] : [UIFont systemFontOfSize:30];
}

@end
