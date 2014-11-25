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


#import "JMLoadingImageView.h"
#import "UIColor+RGBComponent.h"


@interface JMLoadingImageView () <NSURLConnectionDataDelegate>
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end


@implementation JMLoadingImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setDefaults];
}

- (void) setDefaults
{
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activityIndicator.center = self.center;
    [self addSubview:self.activityIndicator];
}

#pragma mark -
#pragma mark - Properties
- (void)setImage:(UIImage *)image
{
    UIViewContentMode contentMode = UIViewContentModeScaleAspectFit;
    if ((image.size.height < self.frame.size.height) && (image.size.width < self.frame.size.width)) {
        contentMode = UIViewContentModeCenter;
    }
    self.contentMode = contentMode;
    [super setImage:image];
}

- (void)setImageUrl:(NSString *)imageUrl
{
    _imageUrl = imageUrl;
    if (imageUrl && [imageUrl length]) {
        if ([[_imageUrl lastPathComponent] isEqualToString:_imageUrl]) {
            self.image = [UIImage imageNamed:_imageUrl];
        } else {
            [self.activityIndicator startAnimating];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSURL *url = [NSURL URLWithString:imageUrl];
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10.0];
                [request addValue:@"image/jpeg" forHTTPHeaderField:kJSRequestResponceType];
                
                NSCachedURLResponse *cachedResponce = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)[cachedResponce response];
                NSData *loadedData = nil;

                if (httpResponse && [[httpResponse MIMEType] hasPrefix:@"image"] && httpResponse.statusCode == 200) {
                    loadedData = [cachedResponce data];
                } else {
                    loadedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&httpResponse error:nil];
                }

                dispatch_async(dispatch_get_main_queue(), @weakself(^(void)) {
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    [self.activityIndicator performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
                    if (loadedData && [[httpResponse MIMEType] hasPrefix:@"image"] && httpResponse.statusCode == 200) {
                        self.image = [[UIImage alloc] initWithData:loadedData];
                        self.backgroundColor = [UIColor clearColor];
                        NSCachedURLResponse *loadedCachedResponce = [[NSCachedURLResponse alloc] initWithResponse:httpResponse data:loadedData];
                        [[NSURLCache sharedURLCache] storeCachedResponse:loadedCachedResponce forRequest:request];

                    }
                }@weakselfend);
            });
        }
    }
}

@end
