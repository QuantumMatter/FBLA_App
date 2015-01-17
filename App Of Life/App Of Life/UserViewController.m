//
//  UserViewController.m
//  App Of Life
//
//  Created by David Kopala on 1/7/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import "UserViewController.h"
#import "TransitionOperator.h"
#import "UserObject.h"

@interface UserViewController () {
    UserObject *_previewUser;
    NSInteger _ID;
}

@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)setUser:(UserObject *)user {
    _previewUser = user;
    _ID = user.userID;
}

-(void)setUseID:(NSInteger)ID {
    _ID = ID;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)presentNav:(id)sender {
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
    } else {
        return;
    }
}

@end
