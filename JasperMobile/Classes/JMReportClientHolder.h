//
//  JMReportClientHolder.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 7/18/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <jaspersoft-sdk/JSRESTReport.h>

/**
 This protocol aggregates all the information implementing object should know about
 to work with JasperServer Report Service
 */
@protocol JMReportClientHolder <NSObject>

@required
@property (nonatomic, strong) JSRESTReport *reportClient;

@end
