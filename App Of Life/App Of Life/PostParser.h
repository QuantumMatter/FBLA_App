//
//  PostParser.h
//  App Of Life
//
//  Created by David Kopala on 1/15/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostParser : NSObject

-(instancetype) init;

-(NSMutableArray *) array;

-(BOOL) finished;

@end
