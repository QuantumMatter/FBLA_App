//
//  SignInController.m
//  App Of Life
//
//  Created by David Kopala on 1/4/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import "SignInController.h"
#import "UserObject.h"
#import "AppDelegate.h"
#import "UserManager.h"
#import "DBManager.h"

@interface SignInController ()
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UIButton *signUpButton;
@property (strong, nonatomic) IBOutlet UIButton *signInButton;
@property (strong, nonatomic) IBOutlet UIImageView *_imageView;

@end

@implementation SignInController {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signUp:(id)sender {
    [self performSegueWithIdentifier:@"presentSignUp" sender:self];
}

- (IBAction)signIn:(id)sender {
    [self signIn];
}

/*-(void) checkCredentials:(NSString *)username password:(NSString *)password {
    user = [[UserObject alloc] init];
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
}*/

-(UserObject *)checkDB:(NSData *)data username:(NSString *)username password:(NSString *)password {
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
            return testingUser;
        } else {
            
        }
    }
    return nil;
}

-(void) signIn {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    [self checkUser:username password:password];
    /*if (user.userName != nil) {
        self.userManager = [[UserManager alloc] initWithDatabaseFileName:@"userdb.sqlite"];
        NSArray *currentDB = [self.userManager loadDataFromDB:@"Select * from user"];
        if (currentDB.count > 0) {
            
        } else {
            NSInteger uID = user.userID;
            double latitude = user.latitude;
            double longitude = user.longitude;
            NSString *query = [NSString stringWithFormat:@"insert into user values(%ld, %@, %f, %f)", (long)uID, username, latitude, longitude];
            [self.userManager executeQuery:query];
            if (self.userManager.affectedRows != 0) {
                NSLog(@"Query was executed successfully. Rows Affected: %d", self.userManager.affectedRows);
            } else {
                NSLog(@"Error when registering user");
            }
        }
    }*/
}

-(void) registerUser:(UserObject *)user {
    NSInteger uID = user.userID;
    NSString *username = user.userName;
    double latitude = user.latitude;
    double longitude = user.longitude;
    self.userManager = [[DBManager alloc] initWithDatabaseFilename:@"userdb.sqlite"];
    NSArray *currentDB = [self.userManager loadDataFromDB:@"Select * from user"];
    if (currentDB.count > 0) {
        NSString *query = [NSString stringWithFormat:@"Update user Set userID = %ld, username = '%@', latitude = %f, longitude = %f where rowID = 1", (long)uID, username, latitude, longitude];
        NSLog(@"Query: %@", query);
        [self.userManager executeQuery:query];
        if (self.userManager.affectedRows != 0) {
            NSLog(@"Query completed successfully");
        } else {
            NSLog(@"Error occured during query");
        }
    } else {
        NSString *query = [NSString stringWithFormat:@"Insert into user values(%ld, '%@', %f, %f)", (long)uID, username, latitude, longitude];
        NSLog(@"Query: %@", query);
        [self.userManager executeQuery:query];
        if (self.userManager.affectedRows != 0) {
            NSLog(@"Query completed successfully");
        } else {
            NSLog(@"Error occured during query");
        }
    }
    [self performSegueWithIdentifier:@"presentHome" sender:self];
}

-(void) checkUser:(NSString *)username password:(NSString *)password {
    UserObject *realUser;
    realUser = [[UserObject alloc] init];
    NSString *stringURL = @"http://24.8.58.134/david/api/UserAPI";
    NSURL *url = [NSURL URLWithString:stringURL];
    NSURLRequest *requset = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:requset
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError == nil && data.length > 0) {
                                   NSError *error;
                                   NSArray *userArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                   for (int i = 0; i < userArray.count; i++) {
                                       NSDictionary *testing = [userArray objectAtIndex:i];
                                       NSString *testUsername = [testing objectForKey:@"Username"];
                                       NSString *testPassword = [testing objectForKey:@"Password"];
                                       testUsername = [testUsername stringByReplacingOccurrencesOfString:@" " withString:@""];
                                       testPassword = [testPassword stringByReplacingOccurrencesOfString:@" " withString:@""];
                                       BOOL name = [username isEqualToString:testUsername];
                                       BOOL pass = [password isEqualToString:testPassword];
                                       if (name && pass) {
                                           realUser.userID = [[testing objectForKey:@"ID"] integerValue];
                                           realUser.userName = username;
                                           realUser.latitude = [[testing objectForKey:@"Latitude"] doubleValue];
                                           realUser.longitude = [[testing objectForKey:@"Longitude"] doubleValue];
                                           [self registerUser:realUser];
                                       }
                                   }
                               }
                           }];
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
