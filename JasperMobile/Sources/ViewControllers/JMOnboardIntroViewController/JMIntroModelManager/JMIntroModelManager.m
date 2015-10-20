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
//  JMIntroModelManager.h
//  TIBCO JasperMobile
//

/**
@since 1.9
*/

#import "JMIntroModelManager.h"
#import "JMIntroModel.h"
#import "JMServerProfile+Helpers.h"

@interface JMIntroModelManager()
@property (nonatomic, copy) NSArray *pageData;
@end

@implementation JMIntroModelManager

#pragma mark - LifeCycle
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupModel];
    }
    return self;
}

- (void)setupModel {
    NSString *seemlessIntegrationPageDescription = [NSString stringWithFormat:JMCustomLocalizedString(@"intro.model.thirdScreen.description", nil), [JMServerProfile minSupportedServerVersion]];

    JMIntroModel *stayConnectedPage = [[JMIntroModel alloc] initWithTitle:JMCustomLocalizedString(@"intro.model.firstScreen.title", nil)
                                                              description:JMCustomLocalizedString(@"intro.model.firstScreen.description", nil)
                                                                    image:nil];
    JMIntroModel *instantAccessPage = [[JMIntroModel alloc] initWithTitle:JMCustomLocalizedString(@"intro.model.secondScreen.title", nil)
                                                              description:JMCustomLocalizedString(@"intro.model.secondScreen.description", nil)
                                                                    image:nil];
    JMIntroModel *seemlessIntegrationPage = [[JMIntroModel alloc] initWithTitle:JMCustomLocalizedString(@"intro.model.thirdScreen.title", nil)
                                                                    description:seemlessIntegrationPageDescription
                                                                          image:nil];
    self.pageData = @[
            stayConnectedPage, instantAccessPage, seemlessIntegrationPage
    ];
}

- (JMIntroModel *)modelForIntroPage:(JMOnboardIntroPage)introPage
{
    JMIntroModel *model;
    switch (introPage) {
        case JMOnboardIntroPageWelcome: {
            break;
        }
        case JMOnboardIntroPageStayConnected: {
            model = self.pageData[0];
            break;
        }
        case JMOnboardIntroPageInstanceAccess: {
            model = self.pageData[1];
            break;
        }
        case JMOnboardIntroPageSeemlessIntegration: {
            model = self.pageData[2];
            break;
        }
    };
    return model;
}

@end