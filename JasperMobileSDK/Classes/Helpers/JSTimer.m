/*
 * Jaspersoft Mobile SDK
 * Copyright (C) 2001 - 2012 Jaspersoft Corporation. All rights reserved.
 * http://www.jasperforge.org/projects/mobile
 *
 * Unless you have purchased a commercial license agreement from Jaspersoft,
 * the following license terms apply:
 *
 * This program is part of Jaspersoft Mobile SDK.
 *
 * Jaspersoft Mobile SDK is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Jaspersoft Mobile SDK is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Jaspersoft Mobile. If not, see <http://www.gnu.org/licenses/>.
 */

//
//  JSTimer.m
//  RestKitDemo
//
//  Created by Vlad Zavadskii on 01.08.12.
//  Copyright (c) 2012 Jaspersoft. All rights reserved.
//

#import "JSTimer.h"

@implementation JSTimer

+ (void)time:(void(^)(void))block {
    NSDate *methodStart = [NSDate date];
    
    block();
    
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    
    NSLog(@"Execution time: %f", executionTime);
}

+ (void)time:(void(^)(void))block repeat:(NSInteger)times {
    NSDate *methodStart = [NSDate date];
    
    for (int i = times; i > 0; i--) { 
        block();
    }
    
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    
    NSLog(@"Execution time: %f", executionTime);
}

@end
