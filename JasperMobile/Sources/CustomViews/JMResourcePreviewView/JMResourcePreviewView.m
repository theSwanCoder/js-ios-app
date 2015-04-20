//
// Created by Aleksandr Dakhno on 4/17/15.
// Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#import "JMResourcePreviewView.h"
#import "JSResourceLookup+Helpers.h"
#import "JMSavedResources.h"
#import "JMSavedResources+Helpers.h"
#import "JSResourceLookup+KPI.h"

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
    UIView *kpiView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:kpiView];
    self.kpiView = kpiView;
    self.kpiView.hidden = YES;
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
        [self fetchKPIforResourceLookup:resourceLookup completion:^(NSDictionary *kpi) {
            if (kpi) {
                // clean kpiView
                [self.kpiView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

                NSLog(@"has kpi: %@", kpi);
                self.resourceImageView.hidden = YES;
                self.kpiView.hidden = NO;

                CGFloat value = ((NSNumber *)kpi[@"value"]).floatValue;
                CGFloat target = ((NSNumber *)kpi[@"target"]).floatValue;
                NSString *title = (NSString *)kpi[@"title"];

                // show kpi
                NSString *imageName = @"kpi_arrow_down";

                if (value > target) {
                    imageName = @"kpi_arrow_up";
                }

                self.kpiView.backgroundColor = [UIColor colorWithRed:24/255.0f green:27/255.0f blue:31/255.0f alpha:1.0];
                UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
                CGRect arrowImageFrame = arrowImageView.frame;
                CGFloat arrowImageOriginX = 0.9 * CGRectGetWidth(self.kpiView.frame) - CGRectGetWidth(arrowImageFrame);
                CGFloat arrowImageOriginY = 0.1 * CGRectGetHeight(self.kpiView.frame);
                arrowImageFrame.origin = CGPointMake(arrowImageOriginX, arrowImageOriginY);
                arrowImageView.frame = arrowImageFrame;
                [self.kpiView addSubview:arrowImageView];

                NSString *indicatorValue = [NSString stringWithFormat:@"%.0f %%", (value * 100) / target];
                CGFloat indicatorLabelOriginX = 0.1 * CGRectGetWidth(self.kpiView.frame);
                CGFloat indicatorLabelOriginY = 0.3 * CGRectGetHeight(self.kpiView.frame);
                CGFloat indicatorLabelWidth = 0.8 * CGRectGetWidth(self.kpiView.frame);
                CGFloat indicatorLabelHeight = 0.7 * CGRectGetHeight(self.kpiView.frame);
                CGRect indicatorLabelFrame = CGRectMake(indicatorLabelOriginX, indicatorLabelOriginY, indicatorLabelWidth, indicatorLabelHeight);
                UILabel *indicatorLabel = [[UILabel alloc] initWithFrame:indicatorLabelFrame];
                indicatorLabel.text = indicatorValue;
                indicatorLabel.textColor = [UIColor whiteColor];
                indicatorLabel.font = [UIFont boldSystemFontOfSize:23];
                [self.kpiView addSubview:indicatorLabel];
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

- (void)fetchKPIforResourceLookup:(JSResourceLookup *)resourceLookup completion:(void(^)(NSDictionary *kpi))completion
{
    [resourceLookup fetchKPIwithCompletion:^(NSDictionary *kpi, NSError *error) {
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