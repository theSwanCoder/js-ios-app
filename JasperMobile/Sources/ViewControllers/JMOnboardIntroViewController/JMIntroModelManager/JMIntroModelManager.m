/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMIntroModelManager.h"
#import "JMIntroModel.h"
#import "JMServerProfile+Helpers.h"
#import "JMLocalization.h"
#import "JMConstants.h"
#import "JMUtils.h"

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

    NSString *description = [NSString stringWithFormat:JMLocalizedString(@"intro_model_firstScreen_description"), kJMAppName];
    JMIntroModel *stayConnectedPage = [[JMIntroModel alloc] initWithTitle:JMLocalizedString(@"intro_model_firstScreen_title")
                                                              description:description
                                                                    image:nil];
    JMIntroModel *instantAccessPage = [[JMIntroModel alloc] initWithTitle:JMLocalizedString(@"intro_model_secondScreen_title")
                                                              description:JMLocalizedString(@"intro_model_secondScreen_description")
                                                                    image:nil];

    description = [NSString stringWithFormat:JMLocalizedString(@"intro_model_thirdScreen_description"), [JMUtils minSupportedServerVersion]];
    JMIntroModel *seemlessIntegrationPage = [[JMIntroModel alloc] initWithTitle:JMLocalizedString(@"intro_model_thirdScreen_title")
                                                                    description:description
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
