//
//  MarkerBundle.m
//  App Of Life
//
//  Created by David Kopala on 1/2/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import "MarkerBundle.h"

@implementation MarkerBundle

-(void) updateMarkerPosition {
    UserObject *user = self.object;
    GMSMarker *marker = self.marker;
    //marker.position = CLLocationCoordinate2DMake(user.latitude, user.longitude);
    marker.userData = self.object;
}

@end
