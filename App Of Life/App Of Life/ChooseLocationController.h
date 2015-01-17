//
//  ChooseLocationController.h
//  App Of Life
//
//  Created by David Kopala on 1/11/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface ChooseLocationController : UIViewController<GMSMapViewDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (strong, nonatomic) IBOutlet UILabel *boundaries;

@end
