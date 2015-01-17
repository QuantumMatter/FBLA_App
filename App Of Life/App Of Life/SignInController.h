//
//  SignInController.h
//  App Of Life
//
//  Created by David Kopala on 1/4/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserManager.h"
#import "DBManager.h"

@interface SignInController : UIViewController

@property (nonatomic, strong) DBManager *userManager;

@end
