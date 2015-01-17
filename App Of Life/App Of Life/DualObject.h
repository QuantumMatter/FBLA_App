//
//  DualID.h
//  App Of Life
//
//  Created by David Kopala on 1/7/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GroupObject.h"
#import "MembershipObject.h"


@interface DualObject : NSObject

@property GroupObject *group;
@property MembershipObject *membership;

@end
