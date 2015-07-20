//
// Created by Aleksandr Dakhno on 6/26/15.
// Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#import "JMPrintResourceVC.h"
#import "JMReportSaver.h"
#import "JMReport.h"
#import "JMCancelRequestPopup.h"
#import "JMReportPagesRange.h"
#import "JMSavedResources.h"
#import "JMSavedResources+Helpers.h"
#import "JMPrintResourceCollectionCell.h"
#import "JMLoadingCollectionViewCell.h"

NSInteger const kJMPrintResourceMaxCountDownloadPages = 5;

typedef NS_ENUM(NSInteger, JMPrintPreviewPresentationType) {
    JMPrintPreviewPresentationTypeFull = 0,
    JMPrintPreviewPresentationTypeGrid = 1
};

@interface JMPrintResourceVC() <UITextFieldDelegate, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISwitch *uiSwitch;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *pagesView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UITextField *fromTextField;
@property (weak, nonatomic) IBOutlet UITextField *toTextField;
@property (weak, nonatomic) UITextField *activeTextField;
@property (weak, nonatomic) IBOutlet UIButton *printButton;
@property (strong, nonatomic) JMReportSaver *reportSaver;
@property (assign, nonatomic) NSInteger downloadedPagesCount;
@property (strong, nonatomic) NSURL *printReportURL;
//@property (strong, nonatomic) NSString *imagesDirectoryPath;
//@property (assign, nonatomic) NSInteger previewCount;
@property (assign, nonatomic) JMPrintPreviewPresentationType presentationType;
@end

@implementation JMPrintResourceVC

#pragma mark - NSObject Life Cycle
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeTempResources];
}

#pragma mark - ViewController Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Print";

    self.fromTextField.inputAccessoryView = [self textFieldToolbar];
    self.toTextField.inputAccessoryView = [self textFieldToolbar];

    self.fromTextField.text = @(1).stringValue;
    self.toTextField.text = @(self.report.countOfPages).stringValue;
    self.reportSaver = [[JMReportSaver alloc] initWithReport:self.report];
    [self prepareJob];

    [self addKeyboardObservers];

    self.presentationType = JMPrintPreviewPresentationTypeFull;

    [self setupNavigationBar];

    [self.collectionView registerNib:[UINib nibWithNibName:kJMHorizontalLoadingCell bundle:nil]
          forCellWithReuseIdentifier:kJMHorizontalLoadingCell];
}

#pragma mark - Setups
- (void)setupNavigationBar
{
    UIImage *image;
    if (self.presentationType == JMPrintPreviewPresentationTypeFull) {
        image = [UIImage imageNamed:@"button_full_presentation"];
    } else {
        image = [UIImage imageNamed:@"grid_button"];
    }
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:image
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(changePresenationView)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
}

#pragma mark - Keyboard Observers
- (void)addKeyboardObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDisappear:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}


- (void)keyboardWillAppear:(NSNotification *)notification
{
    CGFloat animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];

    CGRect headerViewFrame = self.headerView.frame;
    CGRect pagesViewFrame = self.pagesView.frame;
    CGRect parentViewFrame = self.view.frame;

    headerViewFrame.origin.y = CGRectGetHeight(parentViewFrame) -\
                                (CGRectGetHeight(keyboardFrame) +\
                               CGRectGetHeight(headerViewFrame) +\
                                CGRectGetHeight(pagesViewFrame));

    pagesViewFrame.origin.y = CGRectGetHeight(parentViewFrame) -\
                               (CGRectGetHeight(keyboardFrame) +\
                               CGRectGetHeight(pagesViewFrame));

    [UIView animateWithDuration:animationDuration animations:^{
        self.headerView.frame = headerViewFrame;
        self.pagesView.frame = pagesViewFrame;
    } completion:^(BOOL finished) {
    }];
}

- (void)keyboardWillDisappear:(NSNotification *)notification
{
    CGFloat animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];

    CGRect headerViewFrame = self.headerView.frame;
    CGRect footerViewFrame = self.footerView.frame;
    CGRect pagesViewFrame = self.pagesView.frame;
    CGRect parentViewFrame = self.view.frame;

    headerViewFrame.origin.y = CGRectGetHeight(parentViewFrame) -\
                              (CGRectGetHeight(footerViewFrame) +\
                               CGRectGetHeight(headerViewFrame) +\
                                CGRectGetHeight(pagesViewFrame));

    pagesViewFrame.origin.y = CGRectGetHeight(parentViewFrame) -\
                             (CGRectGetHeight(footerViewFrame) +\
                               CGRectGetHeight(pagesViewFrame));

    [UIView animateWithDuration:animationDuration animations:^{
        self.headerView.frame = headerViewFrame;
        self.pagesView.frame = pagesViewFrame;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - UICollectionViewDelegate

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = self.downloadedPagesCount;
    if (self.downloadedPagesCount < self.toTextField.text.integerValue) {
        count++;
    }
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.downloadedPagesCount) {
        NSLog(@"fetchNextPages");

        NSUInteger startPage = self.downloadedPagesCount + 1;
        NSUInteger endPage = self.downloadedPagesCount + kJMPrintResourceMaxCountDownloadPages;
        if (endPage > self.toTextField.text.integerValue) {
            endPage = self.toTextField.text.integerValue;
        }
        JMReportPagesRange *pagesRange = [JMReportPagesRange rangeWithStartPage:startPage
                                                                        endPage:endPage];

        self.downloadedPagesCount = pagesRange.endPage;

        [self fetchPagesFromRange:pagesRange];

        id cell = [collectionView dequeueReusableCellWithReuseIdentifier:kJMHorizontalLoadingCell
                                                         forIndexPath:indexPath];
        return cell;
    }

    JMPrintResourceCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JMPrintResourceCollectionCell"
                                                                           forIndexPath:indexPath];
    UIImage *image = [self imageAtIndex:indexPath.row
                          directoryPath:[self tempImagesDirectoryPath]];
    if (image) {
        CGRect imageViewFrame = cell.imageView.frame;
        CGRect cellBounds = cell.bounds;
        CGFloat k = 1;
        if (image.size.height > image.size.width) {
            if (image.size.height > CGRectGetHeight(cellBounds)) {

                k = image.size.height/(CGRectGetHeight(cellBounds) - 26);

                imageViewFrame.size.width = image.size.width/k;
                imageViewFrame.size.height = image.size.height/k;

                CGFloat imageViewOriginX = CGRectGetWidth(cellBounds)/2 - CGRectGetWidth(imageViewFrame)/2;
                CGFloat imageViewOriginY = 2;
                imageViewFrame.origin = CGPointMake(imageViewOriginX, imageViewOriginY);

            }
        } else {
            if (image.size.width > CGRectGetWidth(cellBounds)) {

                k = image.size.width/(CGRectGetWidth(cellBounds) - 2);

                imageViewFrame.size.width = image.size.width/k;
                imageViewFrame.size.height = image.size.height/k;

                CGFloat imageViewOriginX = 0;
                CGFloat imageViewOriginY = (CGRectGetHeight(cellBounds) - 22)/2 - CGRectGetHeight(imageViewFrame)/2;
                imageViewFrame.origin = CGPointMake(imageViewOriginX, imageViewOriginY);

            }
        }
        cell.imageView.frame = imageViewFrame;

        cell.imageView.image = image;
        cell.imageView.hidden = NO;
        cell.titleLabel.text = [NSString stringWithFormat:@"Page: %@", @(indexPath.row + 1)];
        [cell.activityIndicator stopAnimating];
    } else {
        cell.imageView.hidden = YES;
    }
    return cell;
}

#pragma mark - UICollectionViewFlowLayoutDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout *flowLayout = (id)collectionView.collectionViewLayout;

    CGFloat itemHeight = 150.f;
    CGFloat itemWidth = 150.f;
    if (self.presentationType == JMPrintPreviewPresentationTypeFull) {
        itemHeight = 300.f;
        itemWidth = collectionView.frame.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right;
    }

    if (indexPath.row == self.downloadedPagesCount) {
        itemHeight = 80;
    }

    return CGSizeMake(itemWidth, itemHeight);
}

#pragma mark - Actions
- (IBAction)showPages:(UISwitch *)sender
{
//    CGRect webViewFrame = self.webView.frame;
    CGRect collectionViewFrame = self.collectionView.frame;
    CGRect headerViewFrame = self.headerView.frame;
    CGRect footerViewFrame = self.footerView.frame;
    CGFloat footerViewHeight = footerViewFrame.size.height;
    CGRect pagesViewFrame = self.pagesView.frame;
    CGFloat pagesViewHeight = pagesViewFrame.size.height;
    if (!sender.on) {
        NSLog(@"show pages");
        headerViewFrame.origin.y -= pagesViewHeight;
//        webViewFrame.size.height -= pagesViewHeight;
        collectionViewFrame.size.height -= pagesViewHeight;
        pagesViewFrame.origin.y -= pagesViewHeight - footerViewHeight;
    } else {
        NSLog(@"hide pages");
        headerViewFrame.origin.y += pagesViewHeight;
//        webViewFrame.size.height += pagesViewHeight;
        collectionViewFrame.size.height += pagesViewHeight;
        pagesViewFrame.origin.y += pagesViewHeight - footerViewHeight;
    }

    [UIView animateWithDuration:0.25 animations:^{
        self.headerView.frame = headerViewFrame;
//        self.webView.frame = webViewFrame;
        self.collectionView.frame = collectionViewFrame;
        self.pagesView.frame = pagesViewFrame;
    } completion:^(BOOL finished) {
    }];
}

- (void)done:(id)sender
{
    [self.activeTextField resignFirstResponder];
}

- (void)cancel:(id)sender
{
    [self.activeTextField resignFirstResponder];
}

- (IBAction)printAction:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"Update preview"]) {
        NSLog(@"update preview");
        [self.printButton setTitle:@"Print" forState:UIControlStateNormal];
        [self prepareJob];
    } else {
        [self printReport];
    }
}

- (void)printReport
{
    NSUInteger startPage = self.fromTextField.text.integerValue;
    NSUInteger endPage = self.toTextField.text.integerValue;

    JMReportPagesRange *pagesRange = [JMReportPagesRange rangeWithStartPage:startPage endPage:endPage];
    [self downloadReportWithPagesRange:pagesRange completion:^(NSString *reportURI){
        [JMCancelRequestPopup dismiss];
        NSLog(@"report saved");

        id printingItem = [NSURL fileURLWithPath:[[JMUtils applicationDocumentsDirectory] stringByAppendingPathComponent:reportURI]];

        NSLog(@"printingItem: %@", printingItem);

        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        printInfo.jobName = self.report.resourceLookup.label;
        printInfo.outputType = UIPrintInfoOutputGeneral;
        printInfo.duplex = UIPrintInfoDuplexLongEdge;

        UIPrintInteractionController *printController = [UIPrintInteractionController sharedPrintController];
        printController.printInfo = printInfo;
        printController.showsPageRange = NO;
        printController.printingItem = printingItem;

        UIPrintInteractionCompletionHandler completionHandler = @weakself(^(UIPrintInteractionController *printController, BOOL completed, NSError *error)) {
                if(error){
                    NSLog(@"FAILED! due to error in domain %@ with error code %zd", error.domain, error.code);
                } else if (completed) {
                    if ([printingItem isKindOfClass:[NSURL class]]) {
                        NSURL *fileURL = (NSURL *)printingItem;
                        NSString *directoryPath = [fileURL.path stringByDeletingLastPathComponent];
                        if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
                            [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:nil];
                        }
                    }
//                if (self.printCompletion) {
//                    self.printCompletion();
//                }
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }@weakselfend;

        dispatch_async(dispatch_get_main_queue(), ^{
            if ([JMUtils isIphone]) {
                [printController presentAnimated:YES completionHandler:completionHandler];
            } else {
                [printController presentFromRect:self.printButton.frame inView:self.view animated:YES completionHandler:completionHandler];
            }
        });
    }];



}

- (void)changePresenationView
{
    UIImage *image;
    if (self.presentationType == JMPrintPreviewPresentationTypeFull) {
        self.presentationType = JMPrintPreviewPresentationTypeGrid;
        image = [UIImage imageNamed:@"grid_button"];
    } else {
        self.presentationType = JMPrintPreviewPresentationTypeFull;
        image = [UIImage imageNamed:@"button_full_presentation"];
    }
    self.navigationItem.rightBarButtonItem.image = image;

    [self.collectionView reloadData];
}

- (void)fetchPagesFromRange:(JMReportPagesRange *)pagesRange
{
    [self downloadReportWithPagesRange:pagesRange completion:@weakself(^(NSString *reportURI)){
        NSLog(@"report saved");

        NSURL *reportURL = [NSURL fileURLWithPath:[[JMUtils applicationDocumentsDirectory] stringByAppendingPathComponent:reportURI]];

        // create a folder for images
        if (![self isExistsLocationAtPath:[self tempImagesDirectoryPath]]) {
            NSError *error = [self createLocationAtPath:[self tempImagesDirectoryPath]];
            NSLog(@"error of creation images directory: %@", error.localizedDescription);
        }

        // split pdf file on the separate images
        [self splitPDFfromURL:reportURL
              destinationPath:[self tempImagesDirectoryPath]
                   startCount:(pagesRange.startPage - 1)
                   completion:^(BOOL success) {

                       if (success) {
                           [self.collectionView reloadData];

                           // remove pdf file
                           [self removeReportAtPath:reportURL.path];
                           NSString *reportDirectoryPath = [reportURL.path stringByDeletingLastPathComponent];
                           [self removeLocationAtPath:reportDirectoryPath];
                       }
        }];
    }@weakselfend];
}

#pragma mark - Helpers
- (void)prepareJob
{
    NSUInteger startPage = self.fromTextField.text.integerValue;
    NSUInteger endPage = startPage + kJMPrintResourceMaxCountDownloadPages - 1;
    if (endPage > self.toTextField.text.integerValue) {
        endPage = self.toTextField.text.integerValue;
    }

    JMReportPagesRange *pagesRange = [JMReportPagesRange rangeWithStartPage:startPage
                                                                    endPage:endPage];

    self.downloadedPagesCount = endPage;
    [self fetchPagesFromRange:pagesRange];
}

- (void)downloadReportWithPagesRange:(JMReportPagesRange *)pagesRange completion:(void(^)(NSString *reportURI))completion
{
    NSLog(@"%@", pagesRange);
    [self.reportSaver saveReportWithName:[self tempReportName]
                                  format:[JSConstants sharedInstance].CONTENT_TYPE_PDF
                              pagesRange:pagesRange
                                 addToDB:NO
                              completion:@weakself(^(NSString *reportURI, NSError *error)) {
                                      if (error) {
                                          [self.reportSaver cancelReport];
                                          if (error.code == JSSessionExpiredErrorCode) {
                                              if (self.restClient.keepSession && [self.restClient isSessionAuthorized]) {
                                                  [self prepareJob];
                                              } else {
                                                  [JMUtils showLoginViewAnimated:YES completion:nil];
                                              }
                                          } else {
                                              [JMUtils showAlertViewWithError:error];
                                          }
                                      } else {
                                          if (completion) {
                                              completion(reportURI);
                                          }
                                      }
                                  }@weakselfend];
}

- (NSString *)tempReportName
{
    NSString *tempReportName = [[NSUUID UUID] UUIDString];
    NSLog(@"temp report name: %@", tempReportName);
    return tempReportName;
}

- (NSString *)tempImagesDirectoryPath
{
    NSString *imagesDirectoryPath = [JMSavedResources pathToReportDirectoryWithName:[self imagesDirectoryName]
                                                                             format:@"png"];
    return imagesDirectoryPath;
}

- (NSString *)imagesDirectoryName
{
    return @"Images";
}

- (void)addPagesFromURL:(NSURL *)newPartURL
{
    NSString *tempDirectoryPath = [JMSavedResources pathToReportDirectoryWithName:[self tempReportName]
                                                              format:[JSConstants sharedInstance].CONTENT_TYPE_PDF];

    [self createLocationAtPath:tempDirectoryPath];

    NSURL *tempReportURL = [self reportLocationForPath:tempDirectoryPath
                                     withFileExtention:[JSConstants sharedInstance].CONTENT_TYPE_PDF];

    [self mergeFilesWithFirstPath:self.printReportURL
                       secondPath:newPartURL
               mergedResourcePath:tempReportURL];

    NSURL *printReportFolderURL = [self reportDirectoryLocationForReportWithLocation:self.printReportURL];
    [self removeReportAtPath:self.printReportURL.path];
    [self removeReportAtPath:printReportFolderURL.path];

    NSURL *newPathFolderURL = [self reportDirectoryLocationForReportWithLocation:newPartURL];
    [self removeReportAtPath:newPartURL.path];
    [self removeReportAtPath:newPathFolderURL.path];

    self.printReportURL = tempReportURL;
}

- (void)splitPDFfromURL:(NSURL *)sourceURL destinationPath:(NSString *)imagesDirectoryPath startCount:(NSInteger)startCount completion:(void(^)(BOOL success))completion
{

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){

        CFStringRef path;
        CFURLRef url;

        path = CFStringCreateWithCString (NULL, [sourceURL.path UTF8String], kCFStringEncodingUTF8);
        url = CFURLCreateWithFileSystemPath (NULL, path, kCFURLPOSIXPathStyle, 0);

        CGPDFDocumentRef myDocument;
        myDocument = CGPDFDocumentCreateWithURL(url);

        CGPDFDocumentRef pdfRef = CGPDFDocumentCreateWithURL((__bridge CFURLRef) sourceURL);
        NSInteger numberOfPages = CGPDFDocumentGetNumberOfPages(pdfRef);

        NSLog(@"numberOfPages: %@", @(numberOfPages));
        for (NSInteger i = 1; i <= numberOfPages; i++) {
            CGPDFPageRef page = CGPDFDocumentGetPage (myDocument, i); // first page of PDF is page 1 (not zero)
            CGRect pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);

            UIGraphicsBeginImageContext(pageRect.size);
            CGContextRef currentContext = UIGraphicsGetCurrentContext();

            CGContextTranslateCTM(currentContext, 0, pageRect.size.height); //596,842 //640x960,
            CGContextScaleCTM(currentContext, 1.0, -1.0); // make sure the page is the right way up

            CGContextDrawPDFPage (currentContext, page);  // draws the page in the graphics context

            UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            NSString *imageName = [NSString stringWithFormat:@"image_%@", @(startCount + i-1)];
            NSString* imagePath = [imagesDirectoryPath stringByAppendingPathComponent: imageName];
            NSData *imageData = UIImagePNGRepresentation(image);
            [imageData writeToFile: imagePath atomically:YES];
        }

        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (completion) {
                completion(YES);
            }
        });

        CGPDFDocumentRelease(myDocument);
        CGPDFDocumentRelease(pdfRef);
        CFRelease(path);
        CFRelease(url);
    });
}

- (void)mergeFilesWithFirstPath:(NSURL *)firstPartURL
                     secondPath:(NSURL *)secondPartURL
             mergedResourcePath:(NSURL *)mergedResourceURL
{
    // File references
    CGPDFDocumentRef pdfRef1 = CGPDFDocumentCreateWithURL((__bridge CFURLRef) firstPartURL);
    CGPDFDocumentRef pdfRef2 = CGPDFDocumentCreateWithURL((__bridge CFURLRef) secondPartURL);

    // Number of pages
    NSInteger numberOfPages1 = CGPDFDocumentGetNumberOfPages(pdfRef1);
    NSInteger numberOfPages2 = CGPDFDocumentGetNumberOfPages(pdfRef2);

    // Create the output context
    CGContextRef writeContext = CGPDFContextCreateWithURL((__bridge CFURLRef)mergedResourceURL, NULL, NULL);

    // Loop variables
    CGPDFPageRef page;
    CGRect mediaBox;

    // Read the first PDF and generate the output pages
    NSLog(@"GENERATING PAGES FROM PDF 1 (%i)...", numberOfPages1);
    for (int i=1; i<=numberOfPages1; i++) {
        page = CGPDFDocumentGetPage(pdfRef1, i);
        mediaBox = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
        CGContextBeginPage(writeContext, &mediaBox);
        CGContextDrawPDFPage(writeContext, page);
        CGContextEndPage(writeContext);
    }

    // Read the second PDF and generate the output pages
    NSLog(@"GENERATING PAGES FROM PDF 2 (%i)...", numberOfPages2);
    for (int i=1; i<=numberOfPages2; i++) {
        page = CGPDFDocumentGetPage(pdfRef2, i);
        mediaBox = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
        CGContextBeginPage(writeContext, &mediaBox);
        CGContextDrawPDFPage(writeContext, page);
        CGContextEndPage(writeContext);
    }
    NSLog(@"DONE!");

    // Finalize the output file
    CGPDFContextClose(writeContext);

    // Release from memory
    CGPDFDocumentRelease(pdfRef1);
    CGPDFDocumentRelease(pdfRef2);
    CGContextRelease(writeContext);
}

- (UIImage *)imageAtIndex:(NSInteger)imageIndex directoryPath:(NSString *)directoryPath
{
    UIImage *image;
    NSString *imageName = [NSString stringWithFormat:@"image_%@", @(imageIndex)];
    NSString *imagePath = [directoryPath stringByAppendingPathComponent:imageName];
    BOOL isImageExist = [[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:NO];
    if (isImageExist) {
        image = [UIImage imageWithContentsOfFile:imagePath];
    }
    return image;
}

- (NSURL *)reportLocationForPath:(NSString *)path withFileExtention:(NSString *)format
{
    NSString *fullPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", kJMReportFilename, format]];
    NSURL *reportLocation = [NSURL fileURLWithPath:fullPath];
    return reportLocation;
}

- (NSURL *)reportDirectoryLocationForReportWithLocation:(NSURL *)reportLocation
{
    NSArray *reportLocationPathComponents = reportLocation.pathComponents;
    NSMutableArray *pathComponents = [NSMutableArray arrayWithArray:reportLocationPathComponents];
    [pathComponents removeLastObject];
    NSURL *directoryURL = [NSURL fileURLWithPathComponents:pathComponents];
    return directoryURL;
}

- (NSError *)removeReportAtPath:(NSString *)path
{
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    return error;
}

- (BOOL)isExistsLocationAtPath:(NSString *)path
{
    BOOL isDirectory;
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    if (isDirectory) {
        NSLog(@"it is directory");
    }
    return isExists;
}

- (NSError *)createLocationAtPath:(NSString *)path
{
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:path
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    return error;
}

- (NSError *)removeLocationAtPath:(NSString *)path
{
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    return error;
}

- (void)removeTempResources
{
    NSError *error = [self removeLocationAtPath:[self tempImagesDirectoryPath]];
    if (error) {
        NSLog(@"error of removing temp images directory: %@", error.localizedDescription);
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.integerValue > self.report.countOfPages) {
        // show alert
        textField.text = @(self.report.countOfPages).stringValue;
    }

    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self.printButton setTitle:@"Update preview" forState:UIControlStateNormal];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - View Helpers
- (UIToolbar *)textFieldToolbar
{
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar sizeToFit];

    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolbar setItems:@[cancel, flexibleSpace, done]];

    return toolbar;
}

@end