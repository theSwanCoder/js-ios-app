/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMShareImageActivityItemProvider.h"
#import "JMLocalization.h"
#import "JMConstants.h"
#import "JMUtils.h"

NSString * const kGoogleDriveActivityType = @"com.google.Drive";

@interface JMShareImageActivityItemProvider()
@property (nonatomic, copy) UIImage *imageForSharing;
@property (nonatomic, copy) NSString *imageForSharingFilePath;
@end

@implementation JMShareImageActivityItemProvider
- (nonnull instancetype)initWithImage:(UIImage *)image
{
    self = [super initWithPlaceholderItem:image];
    if (self) {
        self.imageForSharing = image;
    }
    return self;
}

- (void)dealloc
{
    if (_imageForSharingFilePath && [[NSFileManager defaultManager] fileExistsAtPath:self.imageForSharingFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.imageForSharingFilePath error:nil];
    }
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(nullable NSString *)activityType
{
    return [NSString stringWithFormat:JMLocalizedString(@"resource_viewer_share_text"), kJMAppName];
}

- (nullable id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    if ([activityType rangeOfString:kGoogleDriveActivityType].location != NSNotFound) {
        return [NSURL fileURLWithPath:self.imageForSharingFilePath];
    } else {
        return self.imageForSharing;
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
