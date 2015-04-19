//
//  LocationParser.m
//  App Of Life
//
//  Created by David Kopala on 4/16/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import "LocationParser.h"
#import "LocationObject.h"
#import "UserObject.h"

@implementation LocationParser{
    NSArray *UserDataDictionaryArray;
    NSMutableArray *UserDictionaryArray;
    NSMutableArray *LocationArray;
    
    BOOL finished;
}

-(NSMutableArray *) array {
    return LocationArray;
}

-(instancetype) init {
    finished = NO;
    [self A];
    return self;
}

-(void) deactivateUserFromUser:(UserObject *)user {
    if (user) {
        for (LocationObject *location in LocationArray) {
            if (location.userID == user.userID) {
                [self deactivateUserFromLocation:location];
                return;
            }
        }
    }
}

-(void) deactivateUserFromLocation:(LocationObject *)location{
    location.active = NO;
    [self updateLocationFromObject:location];
}

-(void) updateLocationFromID:(NSInteger)ID Latitude:(double)Latitude Longitude:(double)Longitude UserID:(NSInteger)UserID Active:(BOOL)Active {
    NSString *stringURL = [NSString stringWithFormat:@"http://24.8.58.134/david/api/LocationAPI/%ld", (long) ID];
    NSURL *url = [NSURL URLWithString:stringURL];
    NSString *act;
    if (Active) {
        act = [NSString stringWithFormat:@"1"];
    } else {
        act = [NSString stringWithFormat:@"0"];
    }
    NSString *requestString = [NSString stringWithFormat:@"ID=%ld&UserID=%ld&Latitude=%f&Longitude=%f&Active=%@", (long)ID, (long)UserID, Latitude, Longitude, act];
    NSData *data = [requestString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *dataLength = [NSString stringWithFormat:@"%lu", (unsigned long)[data length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"PUT"];
    [request setValue:dataLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection) {
        NSLog(@"Connection Successful - PUT");
    } else {
        NSLog(@"Connection Failed - PUT");
    }

    
}

-(void) updateLocationFromObject:(LocationObject *)object {
    [self updateLocationFromID:object.ID
                      Latitude:object.latitude
                     Longitude:object.longitude
                        UserID:object.userID
                        Active:object.active];
}

-(BOOL) finished {
    return finished;
}

-(void) A {
    NSString *UserString = @"http://24.8.58.134/david/api/LocationAPI";
    NSURL *UserURL = [NSURL URLWithString:UserString];
    NSURLRequest *UserRequest = [NSURLRequest requestWithURL:UserURL];
    [NSURLConnection sendAsynchronousRequest:UserRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError == nil && data.length > 0) {
                                   [self C:data];
                               }
                           }];
}

-(void) C:(NSData *)data {
    if (!UserDataDictionaryArray) {
        UserDataDictionaryArray = [[NSArray alloc] init];
    }
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(dataString);
    NSError *error;
    UserDataDictionaryArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    [self E];
}

-(void) E {
    if (!UserDictionaryArray) {
        UserDictionaryArray = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < [UserDataDictionaryArray count]; i++) {
        NSDictionary *temp = [UserDataDictionaryArray objectAtIndex:i];
        [UserDictionaryArray addObject:temp];
    }
    [self F];
}

-(void) F {
    if (!LocationArray) {
        LocationArray = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < [UserDictionaryArray count]; i++) {
        NSDictionary *temp = [UserDictionaryArray objectAtIndex:i];
        
        NSInteger ID = [[temp objectForKey:@"ID"] integerValue];
        
        double latitude = [[temp objectForKey:@"Latitude"] doubleValue];
        double longitude = [[temp objectForKey:@"Longitude"] doubleValue];
        
        NSInteger userID = [[temp objectForKey:@"UserID"] integerValue];
        
        NSInteger act = [[temp objectForKey:@"Active"] integerValue];
        
        bool active;
        
        if (act == 0) {
            active = false;
        } else {
            active = true;
        }
        
        LocationObject *location;
        location = nil;
        
        if (!location) {
            location = [[LocationObject alloc] init];
        }
        
        location.ID = ID;
        location.userID = userID;
        location.longitude = longitude;
        location.latitude = latitude;
        location.active = active;
        
        [LocationArray addObject:location];
    }
    finished = YES;
}

@end
