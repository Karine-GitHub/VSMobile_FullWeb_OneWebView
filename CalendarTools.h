//
//  CalendarTools.h
//  VsMobile_FullWeb_OneWebview
//
//  Created by admin on 8/29/14.
//  Copyright (c) 2014 admin. All rights reserved.
//
// https://gist.github.com/martinsik/5115383
//

#import <Foundation/Foundation.h>

@interface CalendarTools : NSObject

+ (void)requestAccess:(void (^)(BOOL granted, NSError *error))success;
+ (BOOL)addEventAt:(NSDate*)eventDate withTitle:(NSString*)title inLocation:(NSString*)location;

@end
