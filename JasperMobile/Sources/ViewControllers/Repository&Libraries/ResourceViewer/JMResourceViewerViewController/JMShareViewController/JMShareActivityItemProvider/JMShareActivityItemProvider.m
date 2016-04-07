/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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
//  JMResourceViewerViewController.h
//  TIBCO JasperMobile
//

#import "JMShareActivityItemProvider.h"

NSString * const kSkypeActivityType = @"com.skype";

@implementation JMShareActivityItemProvider
- (nonnull instancetype)init
{
    NSString *jmActivity = [NSBundle mainBundle].bundleIdentifier;
    self = [super initWithPlaceholderItem:jmActivity];
    return self;
}

- (nullable id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    if ([activityType rangeOfString:kSkypeActivityType].location != NSNotFound ) {
        return nil;
    } else {
        return [NSString stringWithFormat:JMCustomLocalizedString(@"resource_viewer_share_text", nil), kJMAppName];
    }
}
@end
