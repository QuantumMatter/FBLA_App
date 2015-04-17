//
//  LocationParser.m
//  App Of Life
//
//  Created by David Kopala on 4/16/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import "LocationParser.h"
#import "LocationObject.h"

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
        
        LocationObject *location;
        location = nil;
        
        if (!location) {
            location = [[LocationObject alloc] init];
        }
        
        location.ID = ID;
        location.userID = ID;
        location.longitude = longitude;
        location.latitude = latitude;
        
        [LocationArray addObject:location];
    }
    finished = YES;
}

@end
