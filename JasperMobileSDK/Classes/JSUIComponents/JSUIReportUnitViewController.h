/*
 * Jaspersoft Mobile SDK
 * Copyright (C) 2001 - 2011 Jaspersoft Corporation. All rights reserved.
 * http://www.jasperforge.org/projects/mobile
 *
 * Unless you have purchased a commercial license agreement from Jaspersoft,
 * the following license terms apply:
 *
 * This program is part of Jaspersoft Mobile SDK.
 *
 * Jaspersoft Mobile SDK is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Jaspersoft Mobile SDK is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Jaspersoft Mobile. If not, see <http://www.gnu.org/licenses/>.
 */

//
//  ReportUnitViewController.h
//  Jaspersoft
//
//  Created by Giulio Toffoli on 6/7/11.
//  Copyright 2011 Jaspersoft Corp.. All rights reserved.
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
@property(nonatomic, retain) NSMutableSet *downloadQueue;
@property(nonatomic, retain) IBOutlet UIWebView *webView;
@property(nonatomic, retain) IBOutlet UILabel *label;
@property(nonatomic, retain) IBOutlet UIView  *backgroundView;

- (IBAction)nextPage:(id)sender;
- (IBAction)prevPage:(id)sender;
- (IBAction)close:(id)sender;
- (void)updatePage;
- (void)setMaxMinZoomScalesForCurrentBounds:(UIScrollView *)scrollView page:(CGSize)pageSize;

@end
