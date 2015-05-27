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
//  JMPrintResourceViewController.m
//  TIBCO JasperMobile
//

#import "JMPrintResourceViewController.h"

@interface JMPrintResourceViewController ()
@property (nonatomic, strong) JSResourceLookup *resourceLookup;
@property (nonatomic, strong) id printingItem;

@property (nonatomic, weak) IBOutlet UIButton *printButton;
@end

@implementation JMPrintResourceViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.printButton setTitle:JMCustomLocalizedString(@"action.title.print", nil)
                      forState:UIControlStateNormal];
}

- (void)printForResourceLookup:(JSResourceLookup *)resourceLookup withWebView:(UIWebView *)webView
{
    self.resourceLookup = resourceLookup;
    
    UIGraphicsBeginImageContextWithOptions(webView.bounds.size, webView.opaque, 0.0);
    [webView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.printingItem = viewImage;
}

- (IBAction)printButtonTapped:(id)sender
{
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.jobName = self.resourceLookup.label;
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.duplex = UIPrintInfoDuplexLongEdge;

    UIPrintInteractionController *printController = [UIPrintInteractionController sharedPrintController];
    printController.printInfo = printInfo;
    printController.showsPageRange = NO;
    
    printController.printingItem = self.printingItem;
    
    UIPrintInteractionCompletionHandler completionHandler =
    ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        if(!completed && error){
            NSLog(@"FAILED! due to error in domain %@ with error code %u", error.domain, error.code);
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    };
    
    if ([JMUtils isIphone]) {
        [printController presentAnimated:YES completionHandler:completionHandler];
    } else {
        [printController presentFromRect:self.printButton.frame inView:self.view animated:YES completionHandler:completionHandler];
    }
}

@end
