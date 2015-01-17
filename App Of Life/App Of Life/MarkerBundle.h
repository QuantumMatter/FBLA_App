//
//  MarkerBundle.h
//  App Of Life
//
//  Created by David Kopala on 1/2/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "UserObject.h"

@interface MarkerBundle : NSObject

@property UserObject *object;
@property GMSMarker *marker;

-(void) updateMarkerPosition;

@end
