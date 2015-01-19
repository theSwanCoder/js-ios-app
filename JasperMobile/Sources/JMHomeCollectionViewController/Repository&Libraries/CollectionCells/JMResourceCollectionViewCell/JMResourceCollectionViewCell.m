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
#import "JMLoadingImageView.h"
#import "JMServerProfile+Helpers.h"

NSString * kJMHorizontalResourceCell = @"JMHorizontalResourceCollectionViewCell";
NSString * kJMGridResourceCell = @"JMGridResourceCollectionViewCell";


@interface JMResourceCollectionViewCell()
@property (nonatomic, weak) IBOutlet JMLoadingImageView *resourceImage;
@property (nonatomic, weak) IBOutlet UILabel *resourceName;
@property (nonatomic, weak) IBOutlet UILabel *resourceDescription;
@property (nonatomic, weak) IBOutlet UIButton *infoButton;

@property (nonatomic, weak) JSConstants *constants;

@end

@implementation JMResourceCollectionViewCell
@synthesize constants = _constants;

objection_requires(@"constants")

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
    
    UIImage *resourceImage = nil;
    
    if ([resourceLookup.resourceType isEqualToString:self.constants.WS_TYPE_REPORT_UNIT]) {
        resourceImage = [UIImage imageNamed:@"res_type_report"];
        JMSavedResources *savedReport = [JMSavedResources savedReportsFromResourceLookup:resourceLookup];
        if (savedReport) {
            if ([savedReport.format isEqualToString:self.constants.CONTENT_TYPE_HTML]) {
                resourceImage = [UIImage imageNamed:@"res_type_html"];
            } else if ([savedReport.format isEqualToString:self.constants.CONTENT_TYPE_PDF]) {
                resourceImage = [UIImage imageNamed:@"res_type_pdf"];
            }
        }
    } else if ([resourceLookup.resourceType isEqualToString:self.constants.WS_TYPE_DASHBOARD] || [resourceLookup.resourceType isEqualToString:self.constants.WS_TYPE_DASHBOARD_LEGACY]) {
        resourceImage = [UIImage imageNamed:@"res_type_dashboard"];
    } else if ([resourceLookup.resourceType isEqualToString:self.constants.WS_TYPE_FOLDER]) {
        resourceImage = [UIImage imageNamed:@"res_type_folder"];
    }
    
    self.resourceImage.image = resourceImage;
    self.resourceImage.backgroundColor = kJMResourcePreviewBackgroundColor;

    // TO DO: Should be fixed! need replace url generation to SDK!
    JSObjectionInjector *injector = [JSObjection defaultInjector];
    JSRESTResource *resourceClient = [injector getObject:[JSRESTResource class]];
    BOOL isFolder = [resourceLookup.resourceType isEqualToString:self.constants.WS_TYPE_FOLDER];
    BOOL isServerUpper6 = resourceClient.serverInfo.versionAsFloat >= self.constants.SERVER_VERSION_CODE_AMBER_6_0_0;
    if (!isFolder && isServerUpper6) {
        NSString *serverURL = [JMServerProfile activeServerProfile].serverUrl;
        NSString *restURI = [JSConstants sharedInstance].REST_SERVICES_V2_URI;
        NSString *resourceURI = resourceLookup.uri;
        self.resourceImage.imageUrl = [NSString stringWithFormat:@"%@%@/thumbnails%@?defaultAllowed=false", serverURL, restURI, resourceURI];
    }
}

- (IBAction)infoButtonDidTapped:(id)sender
{
    [self.delegate infoButtonDidTappedOnCell:self];
}
@end
