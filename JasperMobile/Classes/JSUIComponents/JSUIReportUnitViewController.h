/*
 * JasperMobile for iOS
 * Copyright (C) 2005 - 2012 Jaspersoft Corporation. All rights reserved.
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
//  JSUIReportUnitViewController.h
//  Jaspersoft Corporation
//

#import <jaspersoft-sdk/JaspersoftSDK.h>
#import "JSResourceDescriptor+Helpers.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface JSUIReportUnitViewController : UIViewController  <JSRequestDelegate, UIScrollViewDelegate, UIWebViewDelegate> {
	// Execution id
	NSString *uuid;
	NSInteger pages;
	NSInteger currentPage;
	BOOL reportLoaded;

	// PDF viewer
    CGPDFDocumentRef myDocumentRef;
    CGPDFPageRef myPageRef;
}

@property(nonatomic, retain) NSDictionary *parameters;
@property(nonatomic, retain) JSResourceDescriptor *descriptor;
@property(nonatomic, retain) JSRESTReport *reportClient;
@property(nonatomic, retain) UIViewController *previousController;
@property(nonatomic, retain) NSString *format;
@property(nonatomic, retain) UIView *myContentView;
@property(nonatomic, retain) UIScrollView* scrollView;
@property(nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *pagesButton;
@property(nonatomic, retain) IBOutlet UIWebView *webView;
@property(nonatomic, retain) IBOutlet UILabel *label;
@property(nonatomic, retain) IBOutlet UIView  *backgroundView;

- (IBAction)nextPage:(id)sender;
- (IBAction)prevPage:(id)sender;
- (IBAction)close:(id)sender;
- (void)updatePage;
- (void)setMaxMinZoomScalesForCurrentBounds:(UIScrollView *)scrollView page:(CGSize)pageSize;

@end
