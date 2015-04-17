//
//  LocationParser.h
//  App Of Life
//
//  Created by David Kopala on 4/16/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationObject.h"

@interface LocationParser : NSObject

-(instancetype) init;

-(NSMutableArray *) array;

-(BOOL) finished;

-(void) updateLocationFromObject:(LocationObject *)object;

-(void) updateLocationFromID:(NSInteger *)ID Latitude:(double)Latitude Longitude:(double)longitude UserID:(NSInteger *)UserID;

@end
