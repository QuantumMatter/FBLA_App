//
//  SignUpController.m
//  App Of Life
//
//  Created by David Kopala on 1/4/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import "SignUpController.h"
#import "AppDelegate.h"

@interface SignUpController ()

@property (strong, nonatomic) IBOutlet UITextField *firstNameField;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameField;
@property (strong, nonatomic) IBOutlet UIImageView *_imageView;

@end

@implementation SignUpController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signIn:(id)sender {
    [self performSegueWithIdentifier:@"presentSignIn" sender:self];
}

- (IBAction)signUp:(id)sender {
    [self performSegueWithIdentifier:@"presentHome" sender:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
