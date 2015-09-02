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
#import "JMReportManager.h"

NSString * const kJMReportIsMutlipageDidChangedNotification = @"kJMReportIsMutlipageDidChangedNotification";
NSString * const kJMReportCountOfPagesDidChangeNotification = @"kJMReportCountOfPagesDidChangeNotification";
NSString * const kJMReportCurrentPageDidChangeNotification = @"kJMReportCurrentPageDidChangeNotification";

@interface JMReport()
@property (nonatomic, strong) NSMutableArray *availableReportOptions;
// setters
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
@synthesize activeReportOption = _activeReportOption;
@dynamic reportOptions;
@dynamic reportURI;


#pragma mark - LifeCycle
- (instancetype)initWithResourceLookup:(JSResourceLookup *)resourceLookup
{
    self = [super init];
    if (self) {
        _resourceLookup = resourceLookup;
        
        [self restoreDefaultState];
        
        _isReportEmpty = YES;
    }
    return self;
}

+ (instancetype)reportWithResourceLookup:(JSResourceLookup *)resourceLookup
{
    return [[self alloc] initWithResourceLookup:resourceLookup];
}


#pragma mark - Custom accessors
- (void)setIsMultiPageReport:(BOOL)isMultiPageReport
{
    _isMultiPageReport = isMultiPageReport;
    [self postNotificationMultipageReport];
}

- (void)setCountOfPages:(NSInteger)countOfPages
{
    _countOfPages = countOfPages;
    [self postNotificationCountOfPages];
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    _currentPage = currentPage;
    [self postNotificationCurrentPageChanged];
}

- (NSArray *)reportOptions
{
    return self.availableReportOptions;
}

- (JMExtendedReportOption *)activeReportOption
{
    if (_activeReportOption) {
        return _activeReportOption;
    }
    return [self.reportOptions firstObject];
}


- (void)setActiveReportOption:(JMExtendedReportOption *)activeReportOption
{
    _activeReportOption = activeReportOption;
    _reportParameters = nil;
}

- (NSString *)reportURI
{
    if ([self.activeReportOption.reportOption.uri length]) {
        return self.activeReportOption.reportOption.uri;
    }
    return self.resourceLookup.uri;
}

- (NSArray *)reportParameters
{
    if (!_reportParameters) {
//        if ([self.reportOptions indexOfObject:self.activeReportOption] == NSNotFound) {
            _reportParameters = [JMReportManager reportParametersFromInputControls:self.activeReportOption.inputControls];
//        }
    }
    return _reportParameters;
}


#pragma mark - Public API

- (void)generateReportOptionsWithInputControls:(NSArray *)inputControls;
{
    if ([inputControls count]) {
        _isReportWithInputControls = YES;
        JMExtendedReportOption *defaultReportOption = [JMExtendedReportOption defaultReportOption];
        defaultReportOption.inputControls = [[NSArray alloc] initWithArray:inputControls copyItems:YES];
        self.availableReportOptions = [@[defaultReportOption] mutableCopy];
        _reportParameters = nil;
    }
}

- (void)addReportOptions:(NSArray *)reportOptions
{
    [self.availableReportOptions addObjectsFromArray:reportOptions];
}

- (void)removeReportOption:(JMExtendedReportOption *)reportOption
{
    [self.availableReportOptions removeObject:reportOption];
}

- (void)updateReportParameters:(NSArray *)reportParameters
{
    _reportParameters = [reportParameters copy];
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
    
    self.isReportEmpty = countOfPages == 0 || countOfPages == NSNotFound;
    self.countOfPages = countOfPages;
    
    if (countOfPages != NSNotFound) {
        self.isMultiPageReport = countOfPages > 1;
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
    self.isReportEmpty = NO;
    self.isMultiPageReport = isMultiPageReport;
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

- (void)postNotificationCurrentPageChanged
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMReportCurrentPageDidChangeNotification
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
- (NSString *)description
{
    NSString *description = [NSString stringWithFormat:@"\nReport: %@\ncount of pages: %@\nisEmpty: %@", self.resourceLookup.label, @(self.countOfPages), @(self.isReportEmpty)];
    return description;
}

@end
