//
//  NavViewController.m
//  App Of Life
//
//  Created by David Kopala on 1/2/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import "NavViewController.h"
#import "MyCustomCell.h"
#import "UserObject.h"
#import "AppDelegate.h"
#import "DBManager.h"
#import "GroupControllerViewController.h"
#import "MembershipObject.h"
#import "GroupObject.h"
#import "DualObject.h"
#import "LocationParser.h"

@interface NavViewController ()
@property (strong, nonatomic) IBOutlet UIButton *userButton;

@end

@implementation NavViewController {
    //Add Group Alert Resources
    UITextField *textField;
    NSString *responseText;
    
    UserObject *_currentUser;
    
    //Navigation Resources
    NSInteger path;
    
    //Parsing Resources
    NSArray *groupDataDictionaryArray;
    NSMutableArray *groupDictionaryArray;
    NSArray *membershipDataDictionaryArray;
    NSMutableArray *membershipDictionaryArray;
    BOOL groupOK;
    BOOL membershipOK;
    NSMutableArray *membershipArray;
    NSMutableArray *groupArray;
    NSMutableArray *dualArray;
    
    //Table Resources
    NSInteger index;
    
    LocationParser *locationParser;
}

- (IBAction)userButton:(id)sender {
    if (!_currentUser.userName) {
        [self performSegueWithIdentifier:@"presentSignIn" sender:self];
    } else {
        [self signOut];
    }
}

- (IBAction)addGroup:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Group" message:@"Please enter group code below" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Submit", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    textField = [alert textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardAppearanceDark;
    textField.placeholder = @"Group Code";
    alert.delegate = self;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString:@"Error"]) {
        return;
    }
    if (!responseText) {
        responseText = [[NSString alloc] init];
    }
    responseText = textField.text;
    [self addGroups];
}

-(void) addGroups{
    for (NSUInteger i = 0; i < [groupDataDictionaryArray count]; i++) {
        NSDictionary *tempDict = [groupDataDictionaryArray objectAtIndex:i];
        NSInteger gID = [[tempDict objectForKey:@"ID"] integerValue];
        NSString *gIDs = [NSString stringWithFormat:@"%ld", (long)gID];
        if ([gIDs isEqualToString:responseText]) {
            for (int a = 0; a < [groupArray count]; a++) {
                GroupObject *group;
                group = nil;
                if (!group) {
                    group = [[GroupObject alloc] init];
                }
                group = [groupArray objectAtIndex:a];
                
                NSString *stringID = [NSString stringWithFormat:@"%ld", (long)group.ID];
                if ([responseText isEqualToString:stringID]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:@"You are already sign up for this group"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil, nil];
                    [alert show];
                    return;
                }
            }
            DBManager *db = [[DBManager alloc] initWithDatabaseFilename:@"userdb.sqlite"];
            NSArray *temp = [db loadDataFromDB:@"Select * from user"];
            if ([temp count] > 0) {
                NSArray *user = [temp objectAtIndex:0];
                NSInteger uID = [[user objectAtIndex:0] integerValue];
                NSString *postRequst = [NSString stringWithFormat:@"UserID=%ld&Group=%@&Role=User", (long)uID, responseText];
                NSData *postData = [postRequst dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
                NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init ];
                NSString *stringURL = @"http://24.8.58.134/david/api/MembershipAPI";
                [request setURL:[NSURL URLWithString:stringURL]];
                [request setHTTPMethod:@"POST"];
                [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                [request setHTTPBody:postData];
                NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
                if (connection) {
                    NSLog(@"Connection Successful");
                    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(A) userInfo:nil repeats:NO];
                } else {
                    NSLog(@"Connection Could Not Be Made");
                }
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please sign in to add a group" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
    }
    membershipArray = nil;
    if (!membershipArray) {
        membershipArray = [[NSMutableArray alloc] init];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.membershipView.delegate = self;
    self.membershipView.dataSource = self;
    [self getCurrentUser];
    locationParser = [[LocationParser alloc] init];
    [self A];
}

-(void) getCurrentUser {
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
        [self.userButton setTitle:@"Sign Out" forState:UIControlStateNormal];
    } else {
        [self.userButton setTitle:@"Sign In" forState:UIControlStateNormal];
    }
}

-(void) updateUserButton {
    if (!_currentUser.userName) {
        [self.userButton setTitle:@"Sign In" forState:UIControlStateNormal];
    } else {
        [self.userButton setTitle:@"Sign Out" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    if (_currentUser.userName) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = _currentUser.userName;
                break;
                
            case 1:
                cell.textLabel.text = @"Home";
                break;
                
            case 2:
                cell.textLabel.text = @"Posts";
                break;
                
            default:
                NSLog(@"defaultCell Called");
                NSInteger place = indexPath.row;
                if (place == [membershipArray count] + 3) {
                    cell.textLabel.text = @"Add Group";
                    return cell;
                }
                NSString *title;
                GroupObject *group;
                group = nil;
                NSUInteger num = indexPath.row - 3;
                if (!group) {
                    group = [[GroupObject alloc] init];
                }
                group = [groupArray objectAtIndex:num];
                title = group.Name;
                cell.textLabel.text = title;
                break;
        }
    } else {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Home";
                break;
                
            case 1:
                cell.textLabel.text = @"Sign In";
                break;
                
            case 2:
                cell.textLabel.text = @"Sign Up";
                break;
                
            default:
                break;
        }
    }
    return cell;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!_currentUser.userName) {
        return 2;
    } else {
        return [membershipArray count] + 4;
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!_currentUser.userName) {
        switch (indexPath.row) {
            case 0:
                [self performSegueWithIdentifier:@"presentHome" sender:self];
                break;
                
            case 1:
                [self performSegueWithIdentifier:@"presentSignIn" sender:self];
                break;
                
            case 2:
                [self performSegueWithIdentifier:@"presentSignUp" sender:self];
            default:
                break;
        }
    } else {
        switch (indexPath.row) {
            case 0:
                [self performSegueWithIdentifier:@"presentUserView" sender:self];
                
            case 1:
                [self performSegueWithIdentifier:@"presentHome" sender:self];
                break;
                
            case 2:
                [self performSegueWithIdentifier:@"presentPostView" sender:self];
                break;
                
            default:
                NSLog(@"");
                NSInteger place = indexPath.row;
                if (place == [membershipArray count] + 3) {
                    [self performSegueWithIdentifier:@"presentNewGroup" sender:self];
                    break;
                }
                index = indexPath.row -3;
                [self performSegueWithIdentifier:@"presentGroup" sender:self];
                break;
        }
    }
}

-(void) signOut {
    DBManager *db = [[DBManager alloc] initWithDatabaseFilename:@"userdb.sqlite"];
    [db executeQuery:@"Delete from user where rowID like 1"];
    UserObject *temp = _currentUser;
    _currentUser = nil;
    [self updateUserButton];
    [self.membershipView reloadData];
    [locationParser deactivateUserFromUser:temp];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"segueIdentifier: %@", [segue identifier]);
    if ([[segue identifier] isEqualToString:@"presentGroup"]) {
        GroupControllerViewController *groupView = [segue destinationViewController];
        GroupObject *group;
        group = nil;
        if (!group) {
            group = [[GroupObject alloc] init];
        }
        group = [groupArray objectAtIndex:index];
        NSString *ID = [NSString stringWithFormat:@"%ld", (long)group.ID];
        NSInteger groupID = [ID integerValue];
        [groupView setGroupID:groupID];
        [groupView setGroupName:group.Name];
    }
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void) A {
    groupArray = nil;
    groupDictionaryArray = nil;
    groupDataDictionaryArray = nil;
    membershipArray = nil;
    membershipDictionaryArray = nil;
    membershipDataDictionaryArray = nil;
    dualArray = nil;
    NSString *groupString = @"http://24.8.58.134/david/api/GroupApi";
    NSURL *groupURL = [NSURL URLWithString:groupString];
    NSURLRequest *groupRequest = [NSURLRequest requestWithURL:groupURL];
    [NSURLConnection sendAsynchronousRequest:groupRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError == nil && data.length > 0) {
                                   [self B:data];
                               }
                           }];
    
    NSString *membershipString = @"http://24.8.58.134/david/api/MembershipAPI";
    NSURL *membershipURL = [NSURL URLWithString:membershipString];
    NSURLRequest *membershipRequest = [NSURLRequest requestWithURL:membershipURL];
    [NSURLConnection sendAsynchronousRequest:membershipRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError == nil && data.length > 0) {
                                   [self C:data];
                               }
                           }];
}

-(void) B:(NSData *)data {
    if (!groupDataDictionaryArray) {
        groupDataDictionaryArray = [[NSArray alloc] init];
    }
    NSError *error;
    groupDataDictionaryArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    [self D];
}

-(void) C:(NSData *)data {
    if (!membershipDataDictionaryArray) {
        membershipDataDictionaryArray = [[NSArray alloc] init];
    }
    NSError *error;
    membershipDataDictionaryArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    [self E];
}

-(void) D {
    if (!groupDictionaryArray) {
        groupDictionaryArray = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < [groupDataDictionaryArray count]; i++) {
        NSDictionary *temp = [groupDataDictionaryArray objectAtIndex:i];
        [groupDictionaryArray addObject:temp];
    }
    groupOK = YES;
    if (groupOK && membershipOK) {
        [self F];
    }
}

-(void) E {
    if (!membershipDictionaryArray) {
        membershipDictionaryArray = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < [membershipDataDictionaryArray count]; i++) {
        NSDictionary *temp = [membershipDataDictionaryArray objectAtIndex:i];
        [membershipDictionaryArray addObject:temp];
    }
    membershipOK = YES;
    if (groupOK && membershipOK) {
        [self F];
    }
}

-(void) F {
    if (!groupArray) {
        groupArray = [[NSMutableArray alloc] init];
    } if (!membershipArray) {
        membershipArray = [[NSMutableArray alloc] init];
    }
    NSInteger currentUserID = _currentUser.userID;
    NSString *currentStringID = [NSString stringWithFormat:@"%ld", (long)currentUserID];
    currentStringID = [currentStringID stringByReplacingOccurrencesOfString:@" " withString:@""];
    for (int A = 0; A < [groupDictionaryArray count]; A++) {
        NSDictionary *tempA = [groupDictionaryArray objectAtIndex:A];
        //IDA - Group.ID
        NSInteger temp = [[tempA objectForKey:@"ID"] integerValue];
        NSString *IDA = [NSString stringWithFormat:@"%ld", (long)temp];
        IDA = [IDA stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *nameA = [tempA objectForKey:@"Name"];
        nameA = [nameA stringByReplacingOccurrencesOfString:@" " withString:@""];
        nameA = [nameA stringByReplacingOccurrencesOfString:@"0123456789" withString:@" "];
        for (int B = 0; B < [membershipDictionaryArray count]; B++) {
            NSDictionary *tempB = [membershipDictionaryArray objectAtIndex:B];
            //IDB - Membership.UserID
            NSInteger tempC = [[tempB objectForKey:@"UserID"] integerValue];
            NSString *IDB = [NSString stringWithFormat:@"%ld", (long)tempC];
            IDB = [IDB stringByReplacingOccurrencesOfString:@" " withString:@""];
            //NameB - Group ID(Name)
            NSString *nameB = [tempB objectForKey:@"Group"];
            nameB = [nameB stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSString *role = [tempB objectForKey:@"Role"];
            role = [role stringByReplacingOccurrencesOfString:@" " withString:@""];
            if ([currentStringID isEqualToString:IDB] && [IDA isEqualToString:nameB]) {
                GroupObject *group;
                group = nil;
                if (!group) {
                    group = [[GroupObject alloc] init];
                }
                
                MembershipObject *membership;
                membership = nil;
                if (!membership) {
                    membership = [[MembershipObject alloc] init];
                }
                
                DualObject *dual;
                dual = nil;
                if (!dual) {
                    dual = [[DualObject alloc] init];
                }
                dualArray = nil;
                if (!dualArray) {
                    dualArray = [[NSMutableArray alloc] init];
                }
                
                group.ID = IDA;
                group.Name = nameA;
                group.latitude = 0;
                group.latitude = 0;
                [groupArray addObject:group];
                
                membership.ID = IDB;
                membership.UserID = currentStringID;
                membership.Group = IDA;
                membership.Role = role;
                [membershipArray addObject:membership];
                
                dual.group = group;
                dual.membership = membership;
                [dualArray addObject:dual];
            }
        }
    }
    [self G];
}

-(void) G {
    for (int i = 0; i < [dualArray count];  i++) {
        MembershipObject *membership;
        membership = nil;
        if (!membership) {
            membership = [[MembershipObject alloc] init];
        }
        
        GroupObject *group;
        group = nil;
        if (!group) {
            group = [[GroupObject alloc] init];
        }
    }
    [self.membershipView reloadData];
}

@end
