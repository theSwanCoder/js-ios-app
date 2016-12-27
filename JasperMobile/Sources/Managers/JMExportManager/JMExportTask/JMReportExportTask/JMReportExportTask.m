/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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
//  JMReportExportTask.m
//  TIBCO JasperMobile
//


#import "JMReportExportTask.h"

@interface JMReportExportTask ()
@property (nonatomic, strong, readwrite) JSReportPagesRange *pagesRange;

@property (nonatomic, strong) JSReportSaver *reportSaver;

@end

@implementation JMReportExportTask

- (instancetype)initWithReport:(JSReport *)report name:(NSString *)name format:(NSString *)format pages:(JSReportPagesRange *)pagesRange
{
    JMExportResource *resource = [JMExportResource resourceWithResourceLookup:report.resourceLookup format:format];
    resource.resourceLookup.label = name;
    self = [super initWithResource:resource];
    if(self) {
        self.name = name;
        _pagesRange = pagesRange;
        _reportSaver = [[JSReportSaver alloc] initWithReport:report restClient:self.restClient];
    }
    return self;
}

- (void)cancel
{
    [super cancel];
    [self.reportSaver cancel];
}
#pragma mark - Overrides
- (void)main
{
    __weak typeof(self) weakSelf = self;
    [self.reportSaver saveReportWithName:self.exportResource.resourceLookup.label
                                  format:self.exportResource.format
                              pagesRange:self.pagesRange
                              completion:^(NSURL * _Nullable savedReportFolderURL, NSError * _Nullable error) {
                                  __strong typeof(self) strongSelf = weakSelf;
                                  strongSelf->_savedResourceFolderURL = savedReportFolderURL;
                                  strongSelf->_savingError = error;
                                  [strongSelf completeOperation];
                              }];
}

@end
