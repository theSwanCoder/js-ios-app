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
//  JMIntroModelManager.h
//  TIBCO JasperMobile
//

/**
@since 1.9
*/

#import "JMIntroModelManager.h"
#import "JMIntroModel.h"

@interface JMIntroModelManager()
@property (nonatomic, copy) NSArray *pageData;
@property (nonatomic, assign) NSInteger currentIndex;
@end

@implementation JMIntroModelManager

#pragma mark - LifeCycle
- (instancetype)init {
    self = [super init];
    if (self) {
        _currentIndex = 0;
        [self setupModel];
    }
    return self;
}

- (void)setupModel {
    JMIntroModel *stayConnectedPage = [[JMIntroModel alloc] initWithTitle:@"Stay Connected"
                                                              description:@"JasperMobile keeps you connected to\nyour business wherever you are."
                                                                    image:[UIImage imageNamed:@"stay_connect_image"]];
    JMIntroModel *instantAccessPage = [[JMIntroModel alloc] initWithTitle:@"Instant Access"
                                                              description:@"Get access to live interactive reports\ndriven from your operational applications."
                                                                    image:[UIImage imageNamed:@"instant_access_image"]];
    JMIntroModel *seemlessIntegrationPage = [[JMIntroModel alloc] initWithTitle:@"Seemless Integration"
                                                                    description:@"View and interact with your JasperReports\nServer v5.0 or greater environment."
                                                                          image:[UIImage imageNamed:@"seemless_integration_image"]];
    self.pageData = @[
            stayConnectedPage, instantAccessPage, seemlessIntegrationPage
    ];
}

- (JMIntroModel *)nextModel {
    if (self.currentIndex < [self.pageData count]) {
        return self.pageData[self.currentIndex++];
    } else {
        return nil;
    }
}

- (JMIntroModel *)modelAtIndex:(NSUInteger)index {
    return self.pageData[index];
}


#pragma mark -
- (BOOL)isLastPage {
    return (self.currentIndex == [self.pageData count]);
}

@end