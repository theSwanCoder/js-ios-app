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


#import "JMResourceCollectionViewCell.h"
#import "JMSavedResources+Helpers.h"
#import "JMServerProfile+Helpers.h"
#import "UIImageView+AFNetworking.h"
#import "RKObjectManager.h"

#import "JSResourceLookup+Helpers.h"

NSString * kJMHorizontalResourceCell = @"JMHorizontalResourceCollectionViewCell";
NSString * kJMGridResourceCell = @"JMGridResourceCollectionViewCell";


@interface JMResourceCollectionViewCell()
@property (nonatomic, weak) IBOutlet UIImageView *resourceImage;
@property (nonatomic, weak) IBOutlet UILabel *resourceName;
@property (nonatomic, weak) IBOutlet UILabel *resourceDescription;
@property (nonatomic, weak) IBOutlet UIButton *infoButton;
@property (nonatomic, readwrite) UIImage *thumbnailImage;
@end

@implementation JMResourceCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    self.infoButton.tintColor = [UIColor colorFromHexString:@"#909090"];
}

- (void)setResourceLookup:(JSResourceLookup *)resourceLookup
{
    _resourceLookup = resourceLookup;
    self.resourceName.text = resourceLookup.label;
    self.resourceDescription.text = resourceLookup.resourceDescription;
    self.thumbnailImage = nil;
    [self updateResourceImage];
    
    // Add file extension for saved items
    if ([self.resourceLookup isSavedReport]) {
        JMSavedResources *savedReport = [JMSavedResources savedReportsFromResourceLookup:self.resourceLookup];
        self.resourceName.text = [resourceLookup.label stringByAppendingPathExtension:savedReport.format];
    }
}

- (IBAction)infoButtonDidTapped:(id)sender
{
    [self.delegate infoButtonDidTappedOnCell:self];
}

- (void)updateResourceImage
{
    UIImage *resourceImage;
    if ([self.resourceLookup isReport]) {
        resourceImage = [UIImage imageNamed:@"res_type_report"];
        if ([JMUtils isServerVersionUpOrEqual6]) { // Thumbnails supported on server
            NSMutableURLRequest *imageRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self.resourceLookup thumbnailImageUrlString]]];
            [imageRequest setValue:@"image/jpeg" forHTTPHeaderField:@"Accept"];
            [self.resourceImage setImageWithURLRequest:imageRequest placeholderImage:resourceImage success:@weakself(^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)) {
                if (image) {
                    self.thumbnailImage = image;
                    [self updateResourceImage:self.thumbnailImage thumbnails:YES];
                }
            } @weakselfend failure:nil];
        }
    } else if ([self.resourceLookup isSavedReport]) {
//        JMSavedResources *savedReport = [JMSavedResources savedReportsFromResourceLookup:self.resourceLookup];
//        self.thumbnailImage = [savedReport thumbnailImage];
//        resourceImage = [UIImage imageNamed:[NSString stringWithFormat:@"res_type_%@", savedReport.format]];

        // We temporary disabled showing thumbnails of saved items
        resourceImage = [UIImage imageNamed:@"res_type_report"];
        JMSavedResources *savedReport = [JMSavedResources savedReportsFromResourceLookup:self.resourceLookup];
        if (savedReport) {
            if ([savedReport.format isEqualToString:[JSConstants sharedInstance].CONTENT_TYPE_HTML]) {
                resourceImage = [UIImage imageNamed:@"res_type_html"];
            } else if ([savedReport.format isEqualToString:[JSConstants sharedInstance].CONTENT_TYPE_PDF]) {
                resourceImage = [UIImage imageNamed:@"res_type_pdf"];
            }
        }
    } else if ([self.resourceLookup isDashboard]) {
        resourceImage = [UIImage imageNamed:@"res_type_dashboard"];
    } else if ([self.resourceLookup isFolder]) {
        resourceImage = [UIImage imageNamed:@"res_type_folder"];
    }
    
    if (resourceImage || _thumbnailImage) {
        [self updateResourceImage:_thumbnailImage ?:resourceImage thumbnails:!!_thumbnailImage];
    }
    // TODO: Should be fixed! need replace url generation to SDK!
}

- (void)updateResourceImage:(UIImage *)image thumbnails:(BOOL)thumbnails
{
    UIImage *resourceImage = thumbnails ? [self cropedImageFromImage:image inRect:self.resourceImage.bounds] : image;
    BOOL shouldFitImage = ((resourceImage.size.height > self.resourceImage.frame.size.height) || (resourceImage.size.width > self.resourceImage.frame.size.width));
    self.resourceImage.contentMode = shouldFitImage ? UIViewContentModeScaleAspectFit : UIViewContentModeCenter;
    self.resourceImage.backgroundColor = thumbnails ? [UIColor clearColor] : kJMResourcePreviewBackgroundColor;
    self.resourceImage.image = resourceImage;
}

- (UIImage *)cropedImageFromImage:(UIImage *)image inRect:(CGRect)rect
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
