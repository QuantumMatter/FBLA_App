//
//  UserViewController.h
//  App Of Life
//
//  Created by David Kopala on 1/7/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserObject.h"

@interface UserViewController : UIViewController

-(void) setUser:(UserObject *)user;

-(void)setUseID:(NSInteger)ID;

@end
