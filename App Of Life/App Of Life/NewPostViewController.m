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

@interface NewPostViewController ()

@end

@implementation NewPostViewController {
    NSInteger ID;
    NSString *type;
    
    UserObject *_currentUser;
}

- (void)viewDidLoad {
    [super viewDidLoad];
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
        _currentUser.latitude = latitude;
        _currentUser.longitude = longitude;
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
    NSString *zip = @"0";
    NSString *time = @"2015-01-15T17:52";
    //NSString *time = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    NSString *stringRequest = [NSString stringWithFormat:@"UserID=%@&GroupID=%@&Membership=%@&Content=%@&Zip=%@&Message=%@&TimePosted=%@", UserID, GroupID, membership, content, zip, message, time];
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
    message = [message stringByReplacingOccurrencesOfString:@" " withString:@"&*%^"];
    NSString *content = @"__";
    NSString *zip = @"__";
    NSString *stringRequest = [NSString stringWithFormat:@"UserID=%@&GroupID=%@&membership=%@&content=%@&zip=%@&message=%@", UserID, GroupID, membership, content, zip, message];
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
    } else {
        return;
    }
}

@end
