/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2016 TIBCO Software, Inc. All rights reserved.
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
//  JMResourceViewerDocumentManager.m
//  TIBCO JasperMobile
//

#import "JMResourceViewerDocumentManager.h"

@interface JMResourceViewerDocumentManager() <UIDocumentInteractionControllerDelegate>
@property (nonatomic) UIDocumentInteractionController *documentController;
@end

@implementation JMResourceViewerDocumentManager

#pragma mark - Public API
- (void)showOpenInMenuForResourceWithURL:(NSURL *)URL
{
    NSAssert(self.controller != nil, @"Controller is nil");
    NSAssert(URL != nil, @"document URL is nil");
    self.documentController = [self setupDocumentControllerWithURL:URL
                                                     usingDelegate:self];

    BOOL canOpen = [self.documentController presentOpenInMenuFromBarButtonItem:self.controller.navigationItem.rightBarButtonItem
                                                                      animated:YES];
    if (!canOpen) {
        NSString *errorMessage = JMLocalizedString(@"error_openIn_message");
        NSError *error = [NSError errorWithDomain:@"dialod_title_error"
                                             code:NSNotFound
                                         userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
        [JMUtils presentAlertControllerWithError:error
                                      completion:nil];
    }
}

#pragma mark - Helpers
- (UIDocumentInteractionController *) setupDocumentControllerWithURL: (NSURL *)URL
                                                       usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate
{
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: URL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}

#pragma mark - UIDocumentInteractionControllerDelegate

@end
