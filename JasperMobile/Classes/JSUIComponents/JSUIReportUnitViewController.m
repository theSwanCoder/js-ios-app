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
//  JSUIReportUnitViewController.m
//  Jaspersoft Corporation
//

#import "JSUIReportUnitViewController.h"
#import "JSUILoadingView.h"
#import "UIAlertView+LocalizedAlert.h"

@interface JSUIReportUnitViewController()

@property (nonatomic, retain) NSString *tempDirectory;

@end

@implementation JSUIReportUnitViewController

@synthesize descriptor = _descriptor;
@synthesize parameters = _parameters; 
@synthesize previousController = _previousController;
@synthesize reportClient = _reportClient;
@synthesize format = _format;
@synthesize myContentView = _myContentView;
@synthesize scrollView = _scrollView;
@synthesize toolbar = _toolbar;
@synthesize pagesButton = _pagesButton;
@synthesize webView = _webViev;
@synthesize label = _label;
@synthesize backgroundView = _backgroundView;
@synthesize tempDirectory = _tempDirectory;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return true;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		self.descriptor = nil;
		reportLoaded = NO;
        myPageRef = nil;
		self.myContentView = nil;
        self.format = @"PDF";
	}
	return self;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    // fix the view area...
    if (self.scrollView != nil) {
        CGRect pagingScrollViewFrame =  [[UIScreen mainScreen] bounds];
        CGRect screenBounds =  [[UIScreen mainScreen] bounds];
        
        if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            pagingScrollViewFrame.origin.x -= 10;
            pagingScrollViewFrame.size.height = screenBounds.size.width - 20;
            pagingScrollViewFrame.size.width = screenBounds.size.height + (2 * 10);    
        } else {
            pagingScrollViewFrame.origin.x -= 10;
            pagingScrollViewFrame.size.width += (2 * 10);
        }
        
        self.scrollView.frame = pagingScrollViewFrame;
        CGRect pageRect = CGRectIntegral(CGPDFPageGetBoxRect(myPageRef, kCGPDFCropBox));
        CGFloat xScale = (pagingScrollViewFrame.size.width - 20.0) / pageRect.size.width;
        self.scrollView.zoomScale = xScale;
        self.scrollView.contentOffset = CGPointMake(0.0,0.0);
    }
}

//
// As the view appears, we trigger the fetcher to load the resource (if it is not on out cache...)
//
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	if (self.descriptor != nil)
	{
		[self performSelector:@selector(executeReport) withObject:nil afterDelay:0.0];
	}
	
}

- (void)executeReport {
	reportLoaded = false;
	
	if ([self reportClient] == nil) return;
	
	if ([self descriptor] != nil) {
		// Load the busy view
        
        [JSUILoadingView showCancelableAllRequestsLoadingInView:self.view restClient:self.reportClient cancelBlock:^{
            [self.previousController dismissModalViewControllerAnimated:YES];
        }];
        
        [self.reportClient runReport:self.descriptor.uriString reportParams:self.parameters format:self.format delegate:self];
    }
}

-(void)fileRequestFinished:(NSString *)path {	
	NSFileManager *myFM = [NSFileManager defaultManager];
	
	if ( [myFM isReadableFileAtPath:path] )
	{
        
        currentPage = 1;
		if ([self.format isEqualToString: @"PDF"])
		{
			
			myDocumentRef = CGPDFDocumentCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:path]);
			
			myPageRef = CGPDFDocumentGetPage(myDocumentRef, currentPage);
			CGRect pageRect = CGRectIntegral(CGPDFPageGetBoxRect(myPageRef, kCGPDFCropBox));
			
			CGRect pagingScrollViewFrame =  [[UIScreen mainScreen] bounds];
			pagingScrollViewFrame.origin.x -= 10;
			pagingScrollViewFrame.size.height += 20;
			pagingScrollViewFrame.origin.y = 10;
			pagingScrollViewFrame.size.width += (2 * 10);
			
			
			self.scrollView =[[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
			self.scrollView.delegate = self;
			[self setMaxMinZoomScalesForCurrentBounds:self.scrollView page: pageRect.size];			
			[self.toolbar removeFromSuperview];
			[self.view addSubview:self.scrollView];
			[self.view addSubview:self.toolbar];
			
			
			[self.view.layer setNeedsLayout];
			self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
			[JSUILoadingView hideLoadingView];
			
		} else if ([self.format isEqualToString: @"HTML"] && [[path pathExtension] isEqualToString:@"html"]) {
            
            NSMutableString *html = [NSMutableString stringWithContentsOfFile:path encoding: NSUTF8StringEncoding error: nil];
            [html replaceOccurrencesOfString:@"http://localhost:8080/jasperserver-pro" withString:self.reportClient.serverProfile.serverUrl options: NSLiteralSearch range: NSMakeRange(0, [html length])];
            [html replaceOccurrencesOfString:@"dataFormat: 'xml'," withString:@"dataFormat: 'xml',renderer: 'javascript'," options: NSLiteralSearch range: NSMakeRange(0, [html length])];
            [html replaceOccurrencesOfString:@"if(typeof(printRequest) === 'function') printRequest();" withString:@"" options: NSLiteralSearch range: NSMakeRange(0, [html length])];
            [html writeToFile:path atomically:TRUE encoding:NSUTF8StringEncoding error:nil];
                        
            [self.webView setScalesPageToFit:true];
            [self.webView setHidden:FALSE];
            [self.webView setDelegate:self];
			[self.webView loadRequest: [NSURLRequest requestWithURL: [NSURL fileURLWithPath:path]]];
            [JSUILoadingView hideLoadingView];
		}
        [self updatePage];
	}
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
}

- (void)setMaxMinZoomScalesForCurrentBounds:(UIScrollView *)sv page:(CGSize)pageSize
{
    CGSize boundsSize = self.view.frame.size;
    
    // calculate min/max zoomscale
    CGFloat xScale = boundsSize.width / pageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / pageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
    // maximum zoom scale to 0.5.
    CGFloat maxScale = 3.0 / [[UIScreen mainScreen] scale];
    
    // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.) 
    if (minScale > maxScale) {
        minScale = maxScale;
    }
    
    sv.maximumZoomScale = maxScale;
    sv.minimumZoomScale = minScale;
}

- (void)requestFinished:(JSOperationResult *)res {
    if (res.error != nil) {
        NSString *msg = [res.error localizedDescription];
        
        if (res.statusCode == 400 && [res.MIMEType isEqualToString:@"text/html"]) {
            msg = @"error.incorrectrequest.dialog.msg";
        }
        
        [[UIAlertView localizedAlert:@"error.readingresponse.dialog.msg" 
                             message:msg
                            delegate:self 
                   cancelButtonTitle:@"dialog.button.ok"
                   otherButtonTitles:nil] show];
	} else {
        JSReportDescriptor *report = [res.objects objectAtIndex:0];        
		uuid  = [report uuid];
		pages = [report.totalPages integerValue];
		
		if (pages > 0)
		{			
			// download all the files...
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *documentsDirectory = [paths objectAtIndex:0];
//            self.tempDirectory = [documentsDirectory stringByAppendingPathComponent:];
			self.tempDirectory = [documentsDirectory stringByAppendingPathComponent: [report uuid]];
			
			NSFileManager *fileManager = [NSFileManager defaultManager];
			
			if (![fileManager fileExistsAtPath:self.tempDirectory])
			{
				[fileManager createDirectoryAtPath:self.tempDirectory withIntermediateDirectories: YES attributes: nil error:NULL];
			}
            
            __block NSInteger downloadedAttachments = 0;
            NSInteger attSize = [self.format isEqualToString:@"PDF"] ? 1 : report.attachments.count;
            NSString *mainFileName = @"";
            
			for (JSReportAttachment *attachment in report.attachments) {
				NSString *fileName = attachment.name;
				NSString *fileType = attachment.type;
                
                if ([self.format isEqualToString:@"PDF"] && ![fileType isEqualToString:@"application/pdf"]) {
                    continue;
                }
                
				// We don't use cache here for now....
                NSString *extension = @""; // use default extension.,,
				if ( [fileType isEqualToString: @"text/html"])
				{
					extension = @".html";
				}
				else if ( [fileType isEqualToString: @"application/images"])
				{
					extension = @"";
				}
                else if ( [fileType isEqualToString: @"application/pdf"])
				{
					extension = @".pdf";
				}
				
				// the path to write file
				NSString *resourceFile = [self.tempDirectory stringByAppendingPathComponent: [NSString stringWithFormat:@"%@%@",fileName, extension]]; //self.descriptor.name
                
                if ([extension isEqualToString:@".pdf"] || [extension isEqualToString:@".html"]) {
                    mainFileName = resourceFile;
                }
                
                [self.reportClient reportFile:uuid fileName:fileName path:resourceFile usingBlock:^(JSRequest *request) {
                    // Disable timeout interval for getting files
                    request.timeoutInterval = 0;
                    request.finishedBlock = ^(JSOperationResult *result) {
                        downloadedAttachments++;
                        
                        if (downloadedAttachments == attSize) {
                            [self fileRequestFinished:mainFileName];
                        }
                    };
                }];
			}
            
			if ([[res.objects objectAtIndex:0] attachments].count == 0) {
				UIAlertView *uiView = [[UIAlertView alloc] initWithTitle:@"" message:@"The report had some problems..." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[uiView show];
                
			}
			else {
				return;
			}
		}
		else {
			UIAlertView *uiView = [[UIAlertView alloc] initWithTitle:@"" message:@"The report is empty" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[uiView show];
		}
	}
	
	[JSUILoadingView hideLoadingView];
}


- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
	if (currentPage > 0)
	{
        CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
        CGContextFillRect(ctx, CGContextGetClipBoundingBox(ctx));
        CGContextTranslateCTM(ctx, 0.0, layer.bounds.size.height);
        CGContextScaleCTM(ctx, 1.0, -1.0);
        myPageRef = CGPDFDocumentGetPage(myDocumentRef, currentPage);	
        
        CGContextConcatCTM(ctx, CGPDFPageGetDrawingTransform(myPageRef, kCGPDFCropBox, layer.bounds, 0, true));
        CGContextDrawPDFPage(ctx, myPageRef);
	}
	else {
		[super drawLayer:layer inContext:ctx];
	}
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.myContentView;
}

-(IBAction)nextPage:(id)sender
{
	if (currentPage < pages)
	{
		currentPage++;
		[self updatePage];
	}
}

-(IBAction)prevPage:(id)sender
{
	if (currentPage > 1)
	{
		currentPage--;
		[self updatePage];
	}
}


- (IBAction)close:(id)sender
{
    for (int i = 0; i < self.scrollView.subviews.count; i++) {
        UIView *sub = [self.scrollView.subviews objectAtIndex:i];
        [sub removeFromSuperview];
        sub = nil;
    }
    self.scrollView = nil;
    [self.previousController dismissModalViewControllerAnimated:true];
}

- (void)updatePage
{
    
    if ([self.format isEqualToString:@"HTML"])
    {
        int scrollXPosition = [[self.webView stringByEvaluatingJavaScriptFromString:@"window.pageXOffset"] intValue];
        
        int documentPage = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.offsetHeight"] intValue];
        
        int pageSize = (int)((1.0 *documentPage)/(1.0 *pages));
        [self.webView stringByEvaluatingJavaScriptFromString: [NSString  stringWithFormat:@"window.scrollTo(%d,%d);", scrollXPosition,(currentPage - 1) * pageSize]];
        
    }
    
	// 1. read scroll position and scale...
	float zoomScale = self.scrollView.zoomScale;
	CGPoint offset = self.scrollView.contentOffset;
	
	[self.pagesButton setTitle: [NSString stringWithFormat:@"%d/%d",currentPage, pages]];
    
	myPageRef = CGPDFDocumentGetPage(myDocumentRef, currentPage);	
	CGRect pageRect = CGRectIntegral(CGPDFPageGetBoxRect(myPageRef, kCGPDFCropBox));
	
	UIView *oldPageView = self.myContentView;
	CATiledLayer *tiledLayer = [CATiledLayer layer];
	tiledLayer.delegate = self;
	tiledLayer.tileSize = CGSizeMake(1024.0, 1024.0);
	tiledLayer.levelsOfDetail = 1000;
	tiledLayer.levelsOfDetailBias = 1000;
	tiledLayer.frame = pageRect;
	
	pageRect.origin.x += 10;
	pageRect.size.width += 40;
	self.myContentView = [[UIView alloc] initWithFrame:pageRect];
	[self.myContentView.layer addSublayer:tiledLayer];
	[self.scrollView addSubview:self.myContentView];	
	if (oldPageView != nil) {
		[oldPageView removeFromSuperview];
	}
	self.scrollView.contentOffset = offset;	
	[self.scrollView setNeedsLayout];
	self.scrollView.zoomScale = zoomScale;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSFileManager *manager = [[NSFileManager alloc] init];
    
    if ([manager fileExistsAtPath:self.tempDirectory]) {
        [manager removeItemAtPath:self.tempDirectory error:nil];
    }
}

@end
