//
//  NewGroupController.h
//  App Of Life
//
//  Created by David Kopala on 1/11/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewGroupController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (strong, nonatomic) IBOutlet UIImageView *groupImage;
@property (strong, nonatomic) IBOutlet UITextField *latitudeField;
@property (strong, nonatomic) IBOutlet UITextField *longitudeField;
@property (strong, nonatomic) IBOutlet UIButton *mapButton;
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITableView *groupsTable;
@property (strong, nonatomic) IBOutlet UITableView *defaultGroupsTable;

-(void)setLatitude:(NSString *)latitude;

-(void)setLongitude:(NSString *)longitude;

@end
