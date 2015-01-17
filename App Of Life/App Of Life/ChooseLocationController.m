//
//  ChooseLocationController.m
//  App Of Life
//
//  Created by David Kopala on 1/11/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import "ChooseLocationController.h"
#import "NewGroupController.h"

@interface ChooseLocationController () {
    GMSMapView *_mapView;
    GMSMarker *marker;
    
    BOOL transmitData;
    double latitude;
    double longitude;
}

@end

@implementation ChooseLocationController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect size = self.boundaries.frame;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-105
                                                            longitude:40
                                                                 zoom:5];
    _mapView = [GMSMapView mapWithFrame:size camera:camera];
    _mapView.delegate = self;
    _mapView.settings.compassButton = YES;
    _mapView.settings.myLocationButton = YES;
    _mapView.myLocationEnabled = YES;
    [self.view addSubview:_mapView];
    transmitData = NO;
}

-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    latitude = coordinate.latitude;
    longitude = coordinate.longitude;
    marker = [GMSMarker markerWithPosition:coordinate];
    marker.title = @"Postition";
    marker.snippet = [NSString stringWithFormat:@"Latitude: %f, Longitude: %f", latitude, longitude];
    marker.map = _mapView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButton:(id)sender {
    [self performSegueWithIdentifier:@"back" sender:self];
}

- (IBAction)doneButton:(id)sender {
    transmitData = YES;
    [self performSegueWithIdentifier:@"back" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (transmitData) {
        NewGroupController *destination = [segue destinationViewController];
        [destination setLatitude:[NSString stringWithFormat:@"%f", latitude]];
        [destination setLongitude:[NSString stringWithFormat:@"%f", longitude]];
    }
}

@end
