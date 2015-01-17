//
//  PostObject.h
//  App Of Life
//
//  Created by David Kopala on 1/16/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostObject : NSObject

@property NSInteger ID;
@property NSInteger UserID;
@property NSString *membership;
@property NSInteger GroupID;
@property NSString *message;
@property NSString *content;
@property NSInteger *Zip;

@end
