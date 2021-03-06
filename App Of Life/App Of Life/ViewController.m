//
//  ViewController.m
//  App Of Life
//
//  Created by David Kopala on 12/24/14.
//  Copyright (c) 2014 David Kopala. All rights reserved.
//

#import "ViewController.h"
#import "TransitionOperator.h"
#import <GoogleMaps/GoogleMaps.h>
#import "UserObject.h"
#import "MarkerBundle.h"
#import "InfoWindow.h"
#import "GroupMarker.h"
#import "NavViewController.h"
#import "AppDelegate.h"
#import "GroupObject.h"
#import "GroupParser.h"
#import "UserParser.h"
#import "GroupControllerViewController.h"
#import "UserViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "LocationParser.h"
#import "DBManager.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIButton *displaySelection;
@property (strong, nonatomic) IBOutlet UIButton *selectionButton;
@property (strong, nonatomic) IBOutlet UILabel *bounds;

@end

@implementation ViewController {
    float zip;
    
    GMSMapView *mapView;
    NSMutableDictionary *markerDictionary;
    NSTimer *timer;
    NSTimer *timer02;
    
    NSMutableArray *groupArray;
    GroupObject *destinationGroupObject;
    UserObject *destinationUser;
    
    GroupParser *gParser;
    
    CLLocationManager *locationManager;
    
    UserParser *userParser;
    NSMutableArray *userArray;
    
    LocationParser *locationParser;
    NSMutableArray *locationArray;
    NSTimer *checkUser;
    
    NSMutableArray *userLocations;
    
    UserObject *_currentUser;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    
    _currentUser = [self getCurrentUser];
    [self rotateButton];
    [self loadGroups];
    CGRect origin = self.bounds.frame;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:locationManager.location.coordinate.latitude
                                                            longitude:locationManager.location.coordinate.longitude
                                                                 zoom:10
                                                              bearing:10
                                                         viewingAngle:5];
    mapView = [GMSMapView mapWithFrame:origin camera:camera];
    mapView.mapType = kGMSTypeNormal;
    mapView.delegate = self;
    mapView.myLocationEnabled = YES;
    mapView.settings.myLocationButton = YES;
    mapView.settings.compassButton = YES;
    [self.view addSubview:mapView];
    mapView.layer.zPosition = 1;
    self.title = @"App Of Life";
    markerDictionary = [[NSMutableDictionary alloc] init];
    timer = [[NSTimer alloc] init];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(loadUsers) userInfo:nil repeats:YES];
    gParser = [[GroupParser alloc] init];
    timer02 = [[NSTimer alloc] init];
    timer02 = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(loadGroups) userInfo:nil repeats:YES];
    _currentUser = [[UserObject alloc] init];
    _currentUser = [self getCurrentUser];
}

-(void) loadGroups {
    if (!groupArray) {
        groupArray = [[NSMutableArray alloc] init];
        groupArray = [gParser array];
    } else {
        [timer02 invalidate];
        [self loadGroupMarkers];
    }
}

-(void) loadGroupMarkers {
    for (int i = 0; i < [groupArray count]; i++) {
        GroupObject *group;
        group = nil;
        if (!group) {
            group = [[GroupObject alloc] init];
        }
        
        group = [groupArray objectAtIndex:i];
        GMSMarker *marker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(group.latitude, group.longitude)];
        marker.userData = group;
        marker.map = mapView;
    }
}

-(IBAction)loadUsers:(id)sender {
    [self loadUsers];
}

-(void) loadUsers {
    userParser = [[UserParser alloc] init];
    locationParser = [[LocationParser alloc] init];
    checkUser = [[NSTimer alloc] init];
    checkUser = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkUserDB) userInfo:nil repeats:YES];
}

-(void) checkUserDB {
    if ([userParser finished] && [locationParser finished]) {
        [checkUser invalidate];
        [self loadUserMarkers];
    } else {
        
    }
}

-(void) loadUserMarkers {
    locationArray = [locationParser array];
    userArray = [userParser array];
    
    userLocations = nil;
    if (!userLocations) {
        userLocations = [[NSMutableArray alloc] init];
    }
    
    for (LocationObject *location in locationArray) {
        if (location.active) {
            for (UserObject *user in userArray) {
                if ((location.userID == user.userID) && (user.userID != _currentUser.userID)) {
                    GMSMarker *marker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(location.latitude, location.longitude)];
                    [marker setUserData:user];
                    [userLocations addObject:marker];
                }
            }
        }
    }
    for (GMSMarker *marker in userLocations) {
        marker.map = mapView;
    }
}

-(UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    GroupMarker *_view = [[[NSBundle mainBundle] loadNibNamed:@"GroupMarker" owner:self options:nil] objectAtIndex:0];
    NSString *className = NSStringFromClass([marker.userData class]);
    if ([className isEqualToString:@"GroupObject"]) {
        GroupObject *group = marker.userData;
        _view.title.text = group.Name;
    } else if ([className isEqualToString:@"UserObject"]) {
        UserObject *user = marker.userData;
        _view.title.text = user.userName;
    }
    return _view;
}

-(void) mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    NSString *string = NSStringFromClass([marker.userData class]);
    if ([string isEqualToString:@"UserObject"]) {
        destinationUser = marker.userData;
        [self performSegueWithIdentifier:@"presentUserView" sender:self];
    } else if ([string isEqualToString:@"GroupObject"]) {
        destinationGroupObject = marker.userData;
        [self performSegueWithIdentifier:@"presentGroup" sender:self];
    } else {
        return;
    }
}

-(void) updateMarker:(UserObject *)user {
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker = [markerDictionary objectForKey:[NSString stringWithFormat:@"%ld", (long)user.userID]];
    //marker.position = CLLocationCoordinate2DMake(user.latitude, user.longitude);
    marker.layer.zPosition = 10;
    marker.map = mapView;
}

-(void)rotateButton{
    [self.selectionButton setTransform:CGAffineTransformMakeRotation(M_PI/2)];
    self.selectionButton.layer.zPosition = 2;
    self.displaySelection.layer.zPosition = 2;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)presentNavigation:(id)sender {
    [self performSegueWithIdentifier:@"presentNav" sender:self];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *controller = segue.destinationViewController;
    NSString *destinationName = NSStringFromClass([controller class]);
    if ([destinationName isEqual: @"NavViewController"]) {
        TransitionOperator *top = [[TransitionOperator alloc] init];
        UIViewController *destination = segue.destinationViewController;
        destination.transitioningDelegate = top;
        [self presentViewController:destination animated:YES completion:nil];
    } else if ([segue.identifier isEqualToString:@"presentGroup"]) {
        GroupControllerViewController *destination = [segue destinationViewController];
        NSInteger ID = destinationGroupObject.ID;
        [destination setGroupID:ID];
    } else if ([segue.identifier isEqualToString:@"presentUserView"]) {
        UserViewController *destination = [segue destinationViewController];
        [destination setUser:destinationUser];
    } else {
        return;
    }
}

-(NSInteger) getZipCode {
    zip = -1;
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

-(void) viewDidDisappear:(BOOL)animated {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
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
        if (_currentUser) {
            _currentUser = [[UserObject alloc] init];
        }
        _currentUser.userID = uID;
        _currentUser.userName = username;
        return _currentUser;
    }
    return nil;
}

@end
