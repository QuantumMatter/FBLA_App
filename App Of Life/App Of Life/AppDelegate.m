//
//  AppDelegate.m
//  App Of Life
//
//  Created by David Kopala on 12/24/14.
//  Copyright (c) 2014 David Kopala. All rights reserved.
//

#import "AppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GMSServices provideAPIKey:@"AIzaSyBxEDr9ukfi-F_BNbZqbXhsZ_N_Rl_y1ak"];
    self._currentUser = [[UserObject alloc] init];
    return YES;
}

-(UserObject *) getCurrentUser {
    return self._currentUser;
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
            testingUser.latitude = latitude;
            testingUser.longitude = longitude;
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
}

@end
