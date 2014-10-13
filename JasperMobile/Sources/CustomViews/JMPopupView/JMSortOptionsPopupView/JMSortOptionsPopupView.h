//
//  BFListPopupView.h
//  BetterInterviewsAdmin
//
//  Created by Gubariev, Oleksii on 4/7/14.
//  Copyright (c) 2014 SphereConsultingInc. All rights reserved.
//

#import "JMPopupView.h"
#import "JMResourcesListLoader.h"


@interface JMSortOptionsPopupView : JMPopupView

@property(nonatomic, assign) JMResourcesListLoaderSortBy sortBy;

@end
