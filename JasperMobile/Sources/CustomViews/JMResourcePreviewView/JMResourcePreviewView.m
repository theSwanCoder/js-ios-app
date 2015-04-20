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


//
//  JMResourcePreviewView.m
//  TIBCO JasperMobile
//

#import "JMResourcePreviewView.h"
#import "JSResourceLookup+Helpers.h"
#import "JMSavedResources.h"
#import "JMSavedResources+Helpers.h"
#import "JSResourceLookup+KPI.h"
#import "JMBaseKPIModel.h"
#import "JMDefaultKPIView.h"

@interface JMResourcePreviewView()
@property (nonatomic, weak) UIImageView *resourceImageView;
@property (nonatomic, weak) UIView *kpiView;
@end

@implementation JMResourcePreviewView

#pragma mark - LifeCycle
- (void)awakeFromNib
{
    [super awakeFromNib];

    UIImageView *resourceImage = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:resourceImage];
    self.resourceImageView = resourceImage;

    // TODO: create separate classes for different KPIs
//    UIView *kpiView = [[UIView alloc] initWithFrame:self.bounds];
//    [self addSubview:kpiView];
//    self.kpiView = kpiView;
//    self.kpiView.hidden = YES;
}

#pragma mark - Public API
- (void)updateResourcePreviewWithResourceLookup:(JSResourceLookup *)resourceLookup
{
    self.kpiView.frame = self.bounds;

    [self updateResourceImageWithResourceLookup:resourceLookup];
}

#pragma mark - Private API

- (void)updateResourceImageWithResourceLookup:(JSResourceLookup *)resourceLookup
{
    UIImage *resourceImage;
    if ([resourceLookup isReport]) {
        JMSavedResources *savedReport = [JMSavedResources savedReportsFromResourceLookup:resourceLookup];
        if (savedReport) {
            resourceImage = [UIImage imageNamed:[NSString stringWithFormat:@"res_type_%@", savedReport.format]];
        } else {
            resourceImage = [UIImage imageNamed:@"res_type_report"];
        }
    } else if ([resourceLookup isDashboard]) {
        resourceImage = [UIImage imageNamed:@"res_type_dashboard"];
    } else if ([resourceLookup isFolder]) {
        resourceImage = [UIImage imageNamed:@"res_type_folder"];
    }

    [self updateResourceImage:resourceImage thumbnails:NO];

    if ([JMUtils isServerVersionUpOrEqual6]) { // Thumbnails supported on server
        [self fetchKPIforResourceLookup:resourceLookup completion:^(JMBaseKPIModel *kpi) {
            if (kpi) {
                self.resourceImageView.hidden = YES;
                self.kpiView.hidden = NO;

                [self.kpiView removeFromSuperview];

                switch (kpi.widgetType) {
                    case JMKPIWidgetTypeDefault : {
                        NSLog(@"default");
                        JMDefaultKPIView *defaultKPIView = [[JMDefaultKPIView alloc] initWithFrame:self.bounds];
                        [defaultKPIView setupViewWithKPIModel:kpi];
                        [self addSubview:defaultKPIView];
                        self.kpiView = defaultKPIView;
                        break;
                    };
                    case JMKPIWidgetTypeGauge : {
                        NSLog(@"gauge");
                        break;
                    };
                    case JMKPIWidgetTypeNumber: {
                        NSLog(@"number");
                        break;
                    };
                }
            } else {
                [self fetchAndSetThumbnailWithResourceLookup:resourceLookup];
            }
        }];
    }
}

- (void)fetchAndSetThumbnailWithResourceLookup:(JSResourceLookup *)resourceLookup
{
    if ([resourceLookup isReport]) {
        JMSavedResources *savedReport = [JMSavedResources savedReportsFromResourceLookup:resourceLookup];
        if (savedReport) {
            UIImage *thumbnailImage = [savedReport thumbnailImage];
            if (thumbnailImage) {
                [self updateResourceImage:thumbnailImage thumbnails:YES];
            }
        } else {
            // TODO: Should be fixed! need replace url generation to SDK!

            NSMutableURLRequest *imageRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[resourceLookup thumbnailImageUrlString]]];
            [imageRequest setValue:@"image/jpeg" forHTTPHeaderField:@"Accept"];
            [self.resourceImageView setImageWithURLRequest:imageRequest
                                          placeholderImage:self.resourceImageView.image
                                                   success:@weakself(^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))
                                                   {
                                                       if (image) {
                                                           [self updateResourceImage:image thumbnails:YES];
                                                       }
                                                   }@weakselfend
                                                   failure:nil];
        }
    }
}

- (void)fetchKPIforResourceLookup:(JSResourceLookup *)resourceLookup completion:(void(^)(JMBaseKPIModel *kpi))completion
{
    [resourceLookup fetchKPIwithCompletion:^(JMBaseKPIModel *kpi, NSError *error) {
        if (completion) {
            completion(kpi);
        }
    }];
}

- (void)updateResourceImage:(UIImage *)image thumbnails:(BOOL)thumbnails
{
    UIImage *resourceImage = thumbnails ? [self croppedImageFromImage:image inRect:self.resourceImageView.bounds] : image;
    BOOL shouldFitImage = ((resourceImage.size.height > self.resourceImageView.frame.size.height) || (resourceImage.size.width > self.resourceImageView.frame.size.width));
    self.resourceImageView.contentMode = shouldFitImage ? UIViewContentModeScaleAspectFit : UIViewContentModeCenter;
    self.resourceImageView.backgroundColor = thumbnails ? [UIColor clearColor] : kJMResourcePreviewBackgroundColor;
    self.resourceImageView.image = resourceImage;

    self.resourceImageView.hidden = NO;
    self.kpiView.hidden = YES;
}

- (UIImage *)croppedImageFromImage:(UIImage *)image inRect:(CGRect)rect
{
    CGFloat imageWidth = image.size.width;

    CGFloat rectWidth = CGRectGetWidth(rect);
    CGFloat rectHeight = CGRectGetHeight(rect);

    CGFloat croppedOriginX = 0;
    CGFloat croppedOriginY = 0;
    CGFloat croppedWidth = imageWidth; // always equal width of image
    CGFloat croppedHeight = (imageWidth/rectWidth) * rectHeight; // changed to fill rect

    CGFloat scaleFactor = [[UIScreen mainScreen] scale];
    CGRect croppedRect = CGRectMake(croppedOriginX,
            croppedOriginY,
            croppedWidth * scaleFactor,
            croppedHeight *scaleFactor);

    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], croppedRect);
    UIImage *img = [UIImage imageWithCGImage:imageRef scale:scaleFactor orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    return img;
}


@end