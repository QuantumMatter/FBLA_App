//
//  AppDelegate.m
//  App Of Life
//
//  Created by David Kopala on 12/24/14.
//  Copyright (c) 2014 David Kopala. All rights reserved.
//

#import "AppDelegate.h"
#import "LocationParser.h"
#import <GoogleMaps/GoogleMaps.h>
#import "DBManager.h"
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate ()

@end

@implementation AppDelegate {
    NSTimer *updateLocation;
    NSInteger locationID;
    NSInteger *userID;
    LocationParser *locationParser;
    NSMutableArray *locationArray;
    
    CLLocationManager *locationManager;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GMSServices provideAPIKey:@"AIzaSyBxEDr9ukfi-F_BNbZqbXhsZ_N_Rl_y1ak"];
    locationID = -1;
    self._currentUser = [[UserObject alloc] init];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    [self startUpdatingLocation];
    return YES;
}

-(void) startUpdatingLocation {
    if (!updateLocation) {
        updateLocation = [[NSTimer alloc] init];
        updateLocation = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateUserLocation) userInfo:nil repeats:YES];
    }
}

-(void) updateUserLocation {
    if (!locationParser) {
        locationParser = [[LocationParser alloc] init];
    }
    if (!userID) {
        UserObject *temp = [self getCurrentUser];
        if (temp) {
            userID = temp.userID;
        } else {
            return;
        }
    }
    if (locationID == -1) {//ERROR
        locationArray = [locationParser array];
    }
    for (int i = 0; i < [locationArray count]; i++) {
        LocationObject *location = [locationArray objectAtIndex:i];
        if (location.userID == userID) {
            locationID = location.ID;
            break;
        }
    }
    [locationParser updateLocationFromID:locationID //Ignore
                                Latitude:locationManager.location.coordinate.latitude
                               Longitude:locationManager.location.coordinate.longitude
                                  UserID:userID
                                  Active:YES];
    [locationManager startUpdatingLocation];
    userID = nil;
    locationID = -1;
}

-(void) stopUpdatingLocation {
    if (updateLocation) {
        [updateLocation invalidate];
        updateLocation = nil;
    }
    [locationParser updateLocationFromID:locationID //Ignore
                                Latitude:locationManager.location.coordinate.latitude
                               Longitude:locationManager.location.coordinate.longitude
                                  UserID:userID
                                  Active:NO];
    [locationManager stopUpdatingLocation];
}

-(UserObject *) getCurrentUser {
    DBManager *db = [[DBManager alloc] initWithDatabaseFilename:@"userdb.sqlite"];
    NSArray *array = [db loadDataFromDB:@"Select * from user"];
    if ([array count] > 0) {
        NSArray *userArray = [array objectAtIndex:0];
        NSInteger uID = [[userArray objectAtIndex:0] integerValue];
        NSString *username= [userArray objectAtIndex:1];
        double latitude = [[userArray objectAtIndex:2] doubleValue];
        double longitude = [[userArray objectAtIndex:3] doubleValue];
        if (!self._currentUser) {
            self._currentUser = [[UserObject alloc] init];
        }
        self._currentUser.userID = uID;
        self._currentUser.userName = username;
        return self._currentUser;
    }
    return nil;
}

-(void) setCurrentUser:(UserObject *)user {
    self._currentUser = user;
}

-(void) setCurrentUser:(NSString *)username password:(NSString *)password {
    NSString *stringURL = @"http://24.8.58.134/david/api/UserAPI";
    NSURL *url = [NSURL URLWithString:stringURL];
    NSURLRequest *requset = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:requset
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError == nil && data.length > 0) {
                                   [self checkDB:data username:username password:password];
                               }
                           }];
}

-(void)checkDB:(NSData *)data username:(NSString *)username password:(NSString *)password {
    NSError *error;
    NSArray *userArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"userArray: %@", userArray);
    for (int i = 0; i < [userArray count]; i++) {
        NSDictionary *test = [userArray objectAtIndex:i];
        NSString *testName = [test objectForKey:@"Username"];
        NSString *testPassword = [test objectForKey:@"Password"];
        testName = [testName stringByReplacingOccurrencesOfString:@" " withString:@""];
        testPassword = [testPassword stringByReplacingOccurrencesOfString:@" " withString:@""];
        BOOL name = nil;
        name = [username isEqualToString:testName];
        BOOL pass = nil;
        pass = [password isEqualToString:testPassword];
        if (name && pass) {
            NSInteger uID = [[test objectForKey:@"ID"] integerValue];
            double latitude = [[test objectForKey:@"Latitude"] doubleValue];
            double longitude = [[test objectForKey:@"Longitude"] doubleValue];
            UserObject *testingUser = [[UserObject alloc] init];
            testingUser.userID = uID;
            testingUser.userName = testName;
            [[AppDelegate alloc] setCurrentUser:testingUser];
        } else {
            
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [locationParser deactivateUserFromUser:[self getCurrentUser]];
}

@end
