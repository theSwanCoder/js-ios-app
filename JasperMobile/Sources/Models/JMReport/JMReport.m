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
//  JMReport.h
//  TIBCO JasperMobile
//

#import "JMReport.h"

NSString * const kJMReportIsMutlipageDidChangedNotification = @"kJMReportIsMutlipageDidChangedNotification";
NSString * const kJMReportCountOfPagesDidChangeNotification = @"kJMReportCountOfPagesDidChangeNotification";

@interface JMReport()
@property (nonatomic, copy, readwrite) NSArray *inputControls;
@property (nonatomic, copy, readwrite) NSString *reportURI;
// setters
@property (nonatomic, strong, readwrite) JSResourceLookup *resourceLookup;
@property (nonatomic, assign, readwrite) NSInteger currentPage;
@property (nonatomic, assign, readwrite) NSInteger countOfPages;
@property (nonatomic, assign, readwrite) BOOL isMultiPageReport;
@property (nonatomic, assign, readwrite) BOOL isReportWithInputControls;
@property (nonatomic, assign, readwrite) BOOL isReportEmpty;
@property (nonatomic, strong, readwrite) NSString *requestId;
@property (nonatomic, assign, readwrite) BOOL isReportAlreadyLoaded;

// html
@property (nonatomic, copy, readwrite) NSString *HTMLString;
@property (nonatomic, copy, readwrite) NSString *baseURLString;
// cache
@property (nonatomic, strong) NSMutableDictionary *cachedPages;
@property (nonatomic, copy, readwrite) NSArray *reportParameters;
@end

@implementation JMReport

#pragma mark - LifeCycle
- (instancetype)initWithResource:(JSResourceLookup *)resourceLookup
                   inputControls:(NSArray *)inputControls
{
    self = [super init];
    if (self) {
        _resourceLookup = resourceLookup;
        _reportURI = resourceLookup.uri;
        
        [self updateInputControls:inputControls];
        
        [self restoreDefaultState];
        
        _isInputControlsLoaded = NO;
        _isReportEmpty = NO;
    }
    return self;
}

+ (instancetype)reportWithResource:(JSResourceLookup *)resourceLookup
                     inputControls:(NSArray *)inputControl
{
    return [[self alloc] initWithResource:resourceLookup inputControls:inputControl];
}

#pragma mark - Public API
- (void)updateInputControls:(NSArray *)inputControls
{   
    _inputControls = [inputControls copy];
    if (inputControls && inputControls.count) {
        _isReportWithInputControls = YES;
    } else {
        _isReportWithInputControls = NO;
    }
    
    self.reportParameters = nil;
}

- (void)updateCurrentPage:(NSInteger)currentPage
{
    if (self.currentPage == currentPage) {
        return;
    }
    
    self.currentPage = currentPage;
}

- (void)updateCountOfPages:(NSInteger)countOfPages
{
    if (self.countOfPages == countOfPages) {
        return;
    }
    
    if (countOfPages == 0) {
        self.isReportEmpty = YES;
    } else {
        self.isReportEmpty = NO;
    }
    
    self.countOfPages = countOfPages;
    [self postNotificationCountOfPages];
    
    if (countOfPages != NSNotFound) {
        self.isMultiPageReport = countOfPages > 1;
        [self postNotificationMultipageReport];
    }
}

- (void)updateHTMLString:(NSString *)HTMLString
            baseURLSring:(NSString *)baseURLString
{
    self.HTMLString = HTMLString;
    self.baseURLString = baseURLString;
    
    self.isReportAlreadyLoaded = (HTMLString.length > 0);
}

- (void)updateRequestId:(NSString *)requestId
{
    self.requestId = requestId;
}

- (void)updateIsMultiPageReport:(BOOL)isMultiPageReport
{
    self.isMultiPageReport = isMultiPageReport;
    [self postNotificationMultipageReport];
}

- (NSArray *)reportParameters
{
    if (!_reportParameters) {
        _reportParameters = [self reportParametersFromInputControls:self.inputControls];
    }
    return _reportParameters;
}

#pragma mark - Cache pages
- (void)cacheHTMLString:(NSString *)HTMLString forPageNumber:(NSInteger)pageNumber
{
    self.cachedPages[@(pageNumber)] = HTMLString;
}

- (NSDictionary *)cachedReportPages
{
    return [self.cachedPages copy];
}

- (void)clearCachedReportPages;
{
    self.cachedPages = [@{} mutableCopy];
}

#pragma mark - Notifications
- (void)postNotificationMultipageReport
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMReportIsMutlipageDidChangedNotification
                                                        object:self];
}

- (void)postNotificationCountOfPages
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMReportCountOfPagesDidChangeNotification
                                                        object:self];
}

#pragma mark - Restore default state
- (void)restoreDefaultState
{
    [self clearCachedReportPages];

    self.HTMLString = nil;
    self.baseURLString = nil;
    self.currentPage = NSNotFound;
    self.countOfPages = NSNotFound;
    self.isMultiPageReport = NO;
    self.isReportEmpty = YES;
    self.reportParameters = nil;
    self.requestId = nil;
}

#pragma mark - Helpers
- (NSArray *)reportParametersFromInputControls:(NSArray *)inputControls
{
    NSMutableArray *parameters = [NSMutableArray array];
    for (JSInputControlDescriptor *inputControlDescriptor in inputControls) {
        [parameters addObject:[[JSReportParameter alloc] initWithName:inputControlDescriptor.uuid
                                                                value:inputControlDescriptor.selectedValues]];
    }
    return [parameters copy];
}

- (void)updateInputControlsWithReportParameters:(NSDictionary *)reportParameters
{
    
    for (JSInputControlDescriptor *description in self.inputControls) {
        JSInputControlState *inputState = description.state;
        NSString *value = reportParameters[inputState.uuid];
        for (JSInputControlOption *option in description.state.options) {
            if ([value isEqualToString:option.value]) {
                option.selected = @"true";
            } else {
                option.selected = @"false";
            }
        }
    }    
}

@end