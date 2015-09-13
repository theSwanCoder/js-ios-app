//
// Created by Aleksandr Dakhno on 9/13/15.
// Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

@interface JMHTMLElement : NSObject
@property (nonatomic, copy) NSString *elementType;
@property (nonatomic, strong) NSArray *childElements;
@property (nonatomic, weak) id parentElement;
@property (nonatomic, assign) NSInteger level;
@end