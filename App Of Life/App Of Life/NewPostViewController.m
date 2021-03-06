//
//  NewPostViewController.m
//  App Of Life
//
//  Created by David Kopala on 1/7/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import "NewPostViewController.h"
#import "TransitionOperator.h"
#import "UserObject.h"
#import "DBManager.h"
#import <CoreLocation/CoreLocation.h>
#import "PostViewController.h"

@interface NewPostViewController ()

@end

@implementation NewPostViewController {
    float zip;
    NSString *stringZip;
    
    NSInteger ID;
    NSString *type;
    
    UserObject *_currentUser;
    
    CLLocationManager *locationManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    [self updateCurrentUser];
    // Do any additional setup after loading the view.
}

-(void) updateCurrentUser {
    DBManager *db = [[DBManager alloc] initWithDatabaseFilename:@"userdb.sqlite"];
    NSArray *array = [db loadDataFromDB:@"Select * from user"];
    if (array.count > 0) {
        NSArray *userArray = [array objectAtIndex:0];
        NSInteger uID = [[userArray objectAtIndex:0] integerValue];
        NSString *username= [userArray objectAtIndex:1];
        double latitude = [[userArray objectAtIndex:2] doubleValue];
        double longitude = [[userArray objectAtIndex:3] doubleValue];
        if (!_currentUser) {
            _currentUser = [[UserObject alloc] init];
        }
        _currentUser.userID = uID;
        _currentUser.userName = username;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitButton:(id)sender {
    if (![type isEqualToString:@"subGroup"]) {
        [self postGeneric];
    } else {
        [self postSubGroup];
    }
    [self performSegueWithIdentifier:@"presentPostView" sender:self];
}

-(void) postGeneric {
    NSString *stringURL = @"http://24.8.58.134/david/api/PostAPI";
    NSURL *URL = [NSURL URLWithString:stringURL];
    NSString *UserID = [NSString stringWithFormat:@"%ld", _currentUser.userID];
    NSString *GroupID = @"0";
    NSString *membership = @"generic";
    NSString *message = self._inputField.text;
    message = [message stringByReplacingOccurrencesOfString:@" " withString:@"0123456789"];
    NSLog(message);
    NSString *content = @" ";
    
    //NSString *zip = [NSString  stringWithFormat:@"%f", [self getZipCode]];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            stringZip = placemark.postalCode;
        }
    }];
    
    NSDate *newDate;
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:~ NSCalendarUnitTimeZone fromDate:[NSDate date]];
    newDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    NSString *time = [NSString stringWithFormat:@"%@", newDate];
    NSLog(time);
    NSArray *timeA = [time componentsSeparatedByString:@" "];
    NSString *realTime = [NSString stringWithFormat:@"%@T%@", [timeA objectAtIndex:0], [timeA objectAtIndex:1]];
    
    NSString *stringRequest = [NSString stringWithFormat:@"UserID=%@&GroupID=%@&Membership=%@&Content=%@&Zip=%@&Message=%@&TimePosted=%@", UserID, GroupID, membership, content, @"80234", message, @"2015-04-13T17:24:00"];
    NSLog(stringRequest);
    NSData *postData = [stringRequest dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *dataLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    [request setHTTPMethod:@"POST"];
    [request setValue:dataLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn) {
        NSLog(@"Connection Successful");
    } else {
        NSLog(@"Connection Failed");
    }
}

-(void) postSubGroup {
    NSString *stringURL = @"http://24.8.58.134/david/api/PostAPI";
    NSURL *URL = [NSURL URLWithString:stringURL];
    NSString *UserID = [NSString stringWithFormat:@"%ld", _currentUser.userID];
    NSString *GroupID = [NSString stringWithFormat:@"%ld", ID];
    NSString *membership = @"subGroup";
    NSString *message = self._inputField.text;
    message = [message stringByReplacingOccurrencesOfString:@" " withString:@"0123456789"];
    NSLog(message);
    NSString *content = @" ";
    
    NSString *stringZip = @"80234";
    
    NSDate *newDate;
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:~ NSCalendarUnitTimeZone fromDate:[NSDate date]];
    newDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    NSString *time = [NSString stringWithFormat:@"%@", newDate];
    NSLog(time);
    NSArray *timeA = [time componentsSeparatedByString:@" "];
    NSString *realTime = [NSString stringWithFormat:@"%@T%@", [timeA objectAtIndex:0], [timeA objectAtIndex:1]];
    
    NSString *stringRequest = [NSString stringWithFormat:@"UserID=%@&GroupID=%@&membership=%@&content=%@&zip=%@&message=%@&TimePosted=%@", UserID, GroupID, membership, content, stringZip, message, @"2015-04-13T19:24:00"];
    NSData *postData = [stringRequest dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *dataLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    [request setHTTPMethod:@"POST"];
    [request setValue:dataLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn) {
        NSLog(@"Connection Successful");
    } else {
        NSLog(@"Connection Failed");
    }
}

-(void) setType:(NSString *)_type {
    type = _type;
}

-(void) setSubGroupID:(NSInteger)_ID {
    ID = _ID;
}

- (IBAction)presentNav:(id)sender {
    [self performSegueWithIdentifier:@"presentNav" sender:self];
}

#pragma mark - Navigation

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *controller = segue.destinationViewController;
    NSString *destinationName = NSStringFromClass([controller class]);
    if ([destinationName isEqual: @"NavViewController"]) {
        TransitionOperator *top = [[TransitionOperator alloc] init];
        UIViewController *destination = segue.destinationViewController;
        destination.transitioningDelegate = top;
        [self presentViewController:destination animated:YES completion:nil];
    } else if ([destinationName isEqualToString:@"PostViewController"]) {
        PostViewController *destination = [segue destinationViewController];
        [destination setGroupType:@"subGroup"];
        [destination setGroupID:ID];
    } else {
        return;
    }
}

-(float) getZipCode {
    CLLocationCoordinate2D cooridinate;
    cooridinate.latitude = locationManager.location.coordinate.latitude;
    cooridinate.longitude = locationManager.location.coordinate.longitude;
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSString *zipCode = [[NSString alloc] initWithString:placemark.postalCode];
            zip = [zipCode floatValue];
        }
    }];
    return zip;
    
}

@end
