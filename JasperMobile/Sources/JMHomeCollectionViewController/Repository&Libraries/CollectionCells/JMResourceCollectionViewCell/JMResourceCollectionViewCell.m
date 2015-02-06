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


NSString * kJMHorizontalResourceCell = @"JMHorizontalResourceCollectionViewCell";
NSString * kJMGridResourceCell = @"JMGridResourceCollectionViewCell";


@interface JMResourceCollectionViewCell()
@property (nonatomic, weak) IBOutlet UIImageView *resourceImage;
@property (nonatomic, weak) IBOutlet UILabel *resourceName;
@property (nonatomic, weak) IBOutlet UILabel *resourceDescription;
@property (nonatomic, weak) IBOutlet UIButton *infoButton;
@property (nonatomic, weak) JSRESTResource *resourceClient;
@property (nonatomic, weak) JSConstants *constants;

@end

@implementation JMResourceCollectionViewCell
@synthesize constants = _constants;

objection_requires(@"resourceClient", @"constants")

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [[JSObjection defaultInjector] injectDependencies:self];

    self.infoButton.tintColor = [UIColor colorFromHexString:@"#909090"];
}

- (void)setResourceLookup:(JSResourceLookup *)resourceLookup
{
    _resourceLookup = resourceLookup;
    self.resourceName.text = resourceLookup.label;
    self.resourceDescription.text = resourceLookup.resourceDescription;
    
    [self updateResourceImageWithResourceLookup:resourceLookup];
}

- (IBAction)infoButtonDidTapped:(id)sender
{
    [self.delegate infoButtonDidTappedOnCell:self];
}

- (BOOL)isFolder
{
    BOOL isFolder = [self.resourceLookup.resourceType isEqualToString:self.constants.WS_TYPE_FOLDER];
    return isFolder;
}

- (BOOL)isServerUpper6
{
    return self.resourceClient.serverInfo.versionAsFloat >= self.constants.SERVER_VERSION_CODE_AMBER_6_0_0;
}

- (NSString *)imageURLString
{
    NSString *restURI = [JSConstants sharedInstance].REST_SERVICES_V2_URI;
    NSString *resourceURI = self.resourceLookup.uri;
    return  [NSString stringWithFormat:@"%@/thumbnails%@?defaultAllowed=false", restURI, resourceURI];
}

- (void)updateResourceImageWithResourceLookup:(JSResourceLookup *)resourceLookup
{
    UIImage *resourceImage;
    
    BOOL isReport = [resourceLookup.resourceType isEqualToString:self.constants.WS_TYPE_REPORT_UNIT];
    BOOL isDashboard = [resourceLookup.resourceType isEqualToString:self.constants.WS_TYPE_DASHBOARD] || [resourceLookup.resourceType isEqualToString:self.constants.WS_TYPE_DASHBOARD_LEGACY];
    BOOL isFolder = [resourceLookup.resourceType isEqualToString:self.constants.WS_TYPE_FOLDER];
    
    if (isReport) {
        resourceImage = [UIImage imageNamed:@"res_type_report"];
        JMSavedResources *savedReport = [JMSavedResources savedReportsFromResourceLookup:resourceLookup];
        if (savedReport) {
            if ([savedReport.format isEqualToString:self.constants.CONTENT_TYPE_HTML]) {
                resourceImage = [UIImage imageNamed:@"res_type_html"];
            } else if ([savedReport.format isEqualToString:self.constants.CONTENT_TYPE_PDF]) {
                resourceImage = [UIImage imageNamed:@"res_type_pdf"];
            }
        }
    } else if (isDashboard) {
        resourceImage = [UIImage imageNamed:@"res_type_dashboard"];
    } else if (isFolder) {
        resourceImage = [UIImage imageNamed:@"res_type_folder"];
    }
    
    BOOL shouldFitImage = ((resourceImage.size.height > self.resourceImage.frame.size.height) || (resourceImage.size.width > self.resourceImage.frame.size.width));
    self.resourceImage.contentMode = shouldFitImage ? UIViewContentModeScaleAspectFit : UIViewContentModeCenter;
    self.resourceImage.backgroundColor = kJMResourcePreviewBackgroundColor;
    self.resourceImage.image = resourceImage;

    // TODO: Should be fixed! need replace url generation to SDK!
    
    if ([self isServerUpper6] && ![self isFolder]) {
        // show thumbnail
        RKObjectManager *objectManager = self.resourceClient.restKitObjectManager;
        NSURLRequest *imageRequest = [objectManager requestWithObject:nil
                                                               method:RKRequestMethodGET
                                                                 path:[self imageURLString]
                                                           parameters:nil];
        [self.resourceImage setImageWithURLRequest:imageRequest placeholderImage:self.resourceImage.image success:nil failure:nil];
    }
}

@end
