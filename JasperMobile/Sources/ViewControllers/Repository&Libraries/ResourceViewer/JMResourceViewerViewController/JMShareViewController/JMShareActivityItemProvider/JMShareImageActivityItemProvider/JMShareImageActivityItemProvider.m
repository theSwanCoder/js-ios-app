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
//  JMShareImageActivityItemProvider.m
//  TIBCO JasperMobile
//

#import "JMShareImageActivityItemProvider.h"

NSString * const kSkypeActivityType = @"com.skype";
NSString * const kWhatsAppActivityType = @"net.whatsapp";

@interface JMShareImageActivityItemProvider()
@property (nonatomic, copy) UIImage *imageForSharing;
@property (nonatomic, copy) NSString *imageForSharingFilePath;
@end

@implementation JMShareImageActivityItemProvider
- (nonnull instancetype)initWithImage:(UIImage *)image
{
    NSString *jmActivity = [NSBundle mainBundle].bundleIdentifier;
    jmActivity = [jmActivity stringByAppendingPathExtension:@"image"];
    self = [super initWithPlaceholderItem:jmActivity];
    if (self) {
        self.imageForSharing = image;
    }
    return self;
}

- (nullable id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    if ([activityType rangeOfString:kSkypeActivityType].location != NSNotFound ||
        [activityType rangeOfString:kWhatsAppActivityType].location != NSNotFound) {
        return nil;
    } else {
        return [NSString stringWithFormat:JMCustomLocalizedString(@"resource_viewer_share_text", nil), kJMAppName];
    }
}

- (NSString *)imageForSharingFilePath {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _imageForSharingFilePath = [[JMUtils applicationDocumentsDirectory] stringByAppendingPathComponent:@"image.png"];
        
        NSData *imageData = UIImagePNGRepresentation(self.imageForSharing);
        [imageData writeToFile:_imageForSharingFilePath atomically:YES];

    });
    return _imageForSharingFilePath;
}
@end
