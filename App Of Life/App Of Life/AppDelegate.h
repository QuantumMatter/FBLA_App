//
//  AppDelegate.h
//  App Of Life
//
//  Created by David Kopala on 12/24/14.
//  Copyright (c) 2014 David Kopala. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserObject.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property UserObject *_currentUser;

-(UserObject *) getCurrentUser;

-(void) setCurrentUser:(UserObject*)user;

-(void) setCurrentUser:(NSString *)username password:(NSString *)password;

@end

