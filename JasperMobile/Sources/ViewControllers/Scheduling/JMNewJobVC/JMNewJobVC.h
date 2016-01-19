//
// Created by Aleksandr Dakhno on 11/30/15.
// Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

@interface JMNewJobVC : JMBaseViewController
@property (nonatomic, strong) JSResourceLookup *resourceLookup;
@property (nonatomic, copy) void(^exitBlock)(void);
@end