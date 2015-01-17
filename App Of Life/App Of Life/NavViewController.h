//
//  NavViewController.h
//  App Of Life
//
//  Created by David Kopala on 1/2/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (retain, nonatomic) IBOutlet UITableView *membershipView;

@end
