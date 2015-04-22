//
//  GroupControllerViewController.m
//  App Of Life
//
//  Created by David Kopala on 1/4/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import "GroupControllerViewController.h"
#import "TransitionOperator.h"
#import "FullEducationCell.h"
#import "HalfEducationCell.h"
#import "UserObject.h"
#import "MembershipObject.h"
#import "GroupObject.h"
#import "GroupParser.h"
#import "DualObject.h"
#import "SubGroupObject.h"
#import "SubMembershipObject.h"
#import "DBManager.h"
#import "PostViewController.h"
#import "SubGroupParser.h"
#import "SubMembershipParser.h"
#import "MembershipParser.h"

@interface GroupControllerViewController () {
    NSArray *indexArray;
}

@property (strong, nonatomic) IBOutlet UICollectionView *_collectionView;

@end

@implementation GroupControllerViewController {
    CGSize halfSize;
    CGSize fullSize;
    NSInteger groupID;
    NSString *groupName;
    
    UserObject *_currentUser;
    
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
    
    NSArray *subGroupDataDictionaryArray;
    NSMutableArray *subGroupDictionaryArray;
    NSArray *subMembershipDataDictionaryArray;
    NSMutableArray *subMembershipDictionaryArray;
    BOOL subGroupOK;
    BOOL subMembershipOK;
    NSMutableArray *subMembershipArray;
    NSMutableArray *subGroupArray;
    NSMutableArray *subDualArray;
    
    NSMutableArray *dataArray;
    
    NSMutableArray *flowArray;
    
    NSMutableArray *interGroup;
    NSMutableArray *interMembership;
    
    NSInteger membershipCount;
    NSInteger currentCellCount;
    
    NSInteger currentCell;
    
    NSInteger destinationPostID;
    
    UITextField *textField;
    
    NSArray *initToolBar;
    
    SubGroupParser *sgParser;
    SubMembershipParser *smParser;
    MembershipParser *membershipParser;
    NSTimer *timer;
    
    GroupParser *groupParser;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    sgParser = [[SubGroupParser alloc] init];
    smParser = [[SubMembershipParser alloc] init];
    membershipParser = [[MembershipParser alloc] init];
    groupParser = [[GroupParser alloc] init];
    self._collectionView.delegate = self;
    self._collectionView.dataSource = self;
    [self._collectionView registerNib:[UINib nibWithNibName:@"FullEducationCell" bundle:nil] forCellWithReuseIdentifier:@"fullCell"];
    [self._collectionView registerNib:[UINib nibWithNibName:@"HalfEducationCell" bundle:nil] forCellWithReuseIdentifier:@"halfCell"];
    halfSize = CGSizeMake(175, 175);
    fullSize = CGSizeMake(375, 175);
    [self getCurrentUser];
    currentCell = -1;
    currentCell = -1;
    currentCellCount = 0;
    
    timer = [[NSTimer alloc] init];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(A) userInfo:nil repeats:YES];
}

-(void) setGroupName:(NSString *)group {
    groupName = group;
}

-(void) updateID {
    for (GroupObject *group in [groupParser array]) {
        if ([group.Name isEqualToString:groupName]) {
            groupID = group.ID;
        }
    }
}

-(BOOL) isMember {
    for (MembershipObject *membershipObject in [membershipParser array]) {
        if (([membershipObject.Group integerValue] == groupID) && ([membershipObject.UserID integerValue] == _currentUser.userID)) {
            return true;
        }
    }
    return false;
}

-(void) setButton {
    if (!initToolBar) {
        initToolBar = [self.toolBar items];
    }
    NSMutableArray *Items = [initToolBar mutableCopy];
    if ([self isMember]) {
        UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(addRemoveGroup)];
        [Items addObject:btn];
    } else {
        UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addRemoveGroup)];
        [Items addObject:btn];
    }
    for (int i = 0; i < [groupArray count]; i++) {
        GroupObject *group = [groupArray objectAtIndex:i];
        NSString *stringID = [NSString stringWithFormat:@"%ld", (long)groupID];
        NSString *stringTestID = [NSString stringWithFormat:@"%ld", (long)group.ID];
        if ([stringTestID isEqualToString:stringID]) {
            groupName = group.Name;
        }
    }
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] init];
    btn.title = groupName;
    btn.tintColor = [UIColor blackColor];
    [Items insertObject:btn atIndex:2];
    [self.toolBar setItems:Items];
}

-(void) addRemoveGroup {
    if ([self isMember]) {
        NSString *memID;
        for (int i = 0; i < [membershipArray count]; i++) {
            MembershipObject *member = [membershipArray objectAtIndex:i];
            NSString *membershipID = member.ID;
            NSString *testUserID = member.UserID;
            NSString *testGroupID = member.Group;
            NSString *currentUserID = [NSString stringWithFormat:@"%ld", (long)_currentUser.userID];
            if ([testUserID isEqualToString:currentUserID]) {
                NSString *stringID = [NSString stringWithFormat:@"%ld", (long)groupID];
                if ([testGroupID isEqualToString:stringID]) {
                    memID = membershipID;
                }
            }
        }
        NSString *stringURL = [NSString stringWithFormat:@"http://24.8.58.134/david/api/membershipAPI/%@", memID];
        NSURL *url = [NSURL URLWithString:stringURL];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        [request setHTTPMethod:@"DELETE"];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (connection) {
            NSLog(@"Connection Completed Successfully");
        } else {
            NSLog(@"Error Occured During Connection");
        }
        [self A];
    } else {
        NSString *stringURL = [NSString stringWithFormat:@"http://24.8.58.134/david/api/MembershipAPI"];
        NSURL *URL = [NSURL URLWithString:stringURL];
        NSString *stringRequest = [NSString stringWithFormat:@"Group=%ld&Role=User&UserID=%ld", (long)groupID, (long)_currentUser.userID];
        NSData *data = [stringRequest dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *dataLength = [NSString stringWithFormat:@"%lu", (unsigned long)[data length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        [request setURL:URL];
        [request setHTTPMethod:@"POST"];
        [request setValue:dataLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:data];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (connection) {
            NSLog(@"Connection Successful - PUT");
        } else {
            NSLog(@"Connection Failed - PUT");
        }
    }
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
    } else {
        for (int i = 0; i < [subGroupDataDictionaryArray count]; i++) {
            NSDictionary *temp = [subGroupDataDictionaryArray objectAtIndex:i];
            NSInteger testParentGroupID = [[temp objectForKey:@"parentGroupID"] integerValue];
            if (testParentGroupID == groupID) {
                NSInteger testIntID = [[temp objectForKey:@"ID"] integerValue];
                NSString *testID = [NSString stringWithFormat:@"%ld", testIntID];
                NSString *ID = textField.text;
                if ([testID isEqualToString:ID]) {
                    NSString *stringURL = @"http://24.8.58.134/david/api/subMembershipAPI";
                    NSURL *url = [NSURL URLWithString:stringURL];
                    NSString *stringData = [NSString stringWithFormat:@"Role=User&UserID=%ld&subGroupID=%@", (long)_currentUser.userID, ID];
                    NSData *data = [stringData dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
                    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[data length]];
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                    [request setURL:url];
                    [request setHTTPMethod:@"POST"];
                    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:data];
                    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
                    if (connection) {
                        NSLog(@"Connection Completed Successfull");
                    } else {
                        NSLog(@"Error Occured During Connection");
                    }
                }
            }
        }
    }
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
    }
}


-(void) setLayout {
    membershipCount = [subMembershipArray count];
    if (membershipCount != 0) {
        [self._collectionView reloadData];
    }
}

-(void) A {
    if (subMembershipArray == nil) {
        subMembershipArray = [[NSMutableArray alloc] init];
        subMembershipArray = [smParser array];
    } else if (subGroupArray == nil) {
        subGroupArray = [[NSMutableArray alloc] init];
        subGroupArray = [sgParser array];
    } else if (membershipArray == nil) {
        membershipArray = [membershipParser array];
    } else if(groupArray == nil){
        groupArray = [groupParser array];
    } else {
        [self updateID];
        [self setButton];
        [timer invalidate];
        currentCell = -1;
        currentCellCount = 0;
        [self._collectionView reloadData];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setGroupID:(NSInteger)giD {
    groupID = giD;
}

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 15;
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (!flowArray) {
        flowArray = [[NSMutableArray alloc] init];
    }
    NSInteger room = membershipCount - currentCellCount + 2;
    if (room > 0) {
        if (section == 0 | section == 1) {
            if (section == 0) {
                currentCellCount += 1;
                return 1;
            } else {
                currentCellCount += 2;
                return 2;
            }
        } else {
            NSInteger overflow = room - 4;
            if (overflow > 0) {
                NSInteger num;
                num = arc4random_uniform(4);
                if (num == 0) {
                    num = 2;
                }
                currentCellCount += num;
                NSLog(@"randomNum:, %ld", (long)num);
                currentCellCount += num;
                return num;
            } else {
                currentCellCount += room;
                return room;
            }
        }
    } else {
        return 0;
    }
}

-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    indexArray = nil;
    if (!indexArray) {
        indexArray = [[NSArray alloc] initWithObjects:indexPath, nil];
    }
    currentCell++;
    NSInteger section = [indexPath section];
    NSString *type;
    NSInteger count = [subMembershipArray count];
    if (section == 0 | section == 1) {
        if (section == 0) {
            type = @"full";
        } else {
            type = @"half";
        }
    } else {
        NSInteger num1 = [collectionView numberOfItemsInSection:[indexPath section]];
        NSInteger num2 = num1 / 2;
        num2 = num2 * 2;
        if (num1 == num2) {
            type = @"half";
        } else {
            type = @"full";
        }
    } if ([type isEqualToString:@"full"]) {
        FullEducationCell *cell = [self fullCell:collectionView indexPath:indexPath];
        if (section == 0) {
            cell.text.text = @"Home";
            return cell;
        }
        if (currentCell == count + 1) {
            cell.text.text = @"Add Group";
            return cell;
        } else {
            SubGroupObject *name = [subGroupArray objectAtIndex:currentCell - 1];
            cell.text.text = name.name;
            return cell;
        }
    } else {
        HalfEducationCell *cell = [self halfCell:collectionView indexPath:indexPath];
        if (currentCell == count + 1) {
            cell.text.text = @"Add Group";
        } else {
            SubGroupObject *name = [subGroupArray objectAtIndex:currentCell - 1];
            cell.text.text = name.name;
        }
        return cell;
    }
}

-(HalfEducationCell *)halfCell:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    HalfEducationCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"halfCell" forIndexPath:indexPath];
    return cell;
}

-(FullEducationCell *) fullCell:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    FullEducationCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"fullCell" forIndexPath:indexPath];
    return cell;
}

- (IBAction)presentNav:(id)sender {
    [self performSegueWithIdentifier:@"presentNav" sender:self];
}

-(CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = [indexPath section];
    if (section == 0 | section == 1) {
        if (section == 0) {
            return fullSize;
        } else {
            return halfSize;
        }
    } else {
        NSInteger num1 = [self._collectionView numberOfItemsInSection:section];
        NSInteger num2 = num1/2;
        num2 = 2 * num2;
        if (num1 == num2) {
            return halfSize;
        } else {
            return fullSize;
        }
    }
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (int i = 0; i < [subGroupArray count]; i++) {
        SubGroupObject *subGroup;
        subGroup = nil;
        if (!subGroup) {
            subGroup = [[SubGroupObject alloc] init];
        }
        subGroup = [subGroupArray objectAtIndex:i];
        UICollectionViewCell *test = [collectionView cellForItemAtIndexPath:indexPath];
        NSString *class = NSStringFromClass([test class]);
        if ([class isEqualToString:@"FullEducationCell"]) {
            FullEducationCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            NSString *testName = cell.text.text;\
            NSString *name = subGroup.name;
            if ([name isEqualToString:testName]) {
                if ([name isEqualToString:@"Calendar"]) {
                    
                } else {
                    destinationPostID = subGroup.ID;
                    [self performSegueWithIdentifier:@"presentPostView" sender:self];
                }
            }  else if ([testName isEqualToString:@"Add Group"]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Group"
                                                                message:@"Enter Group ID Below"
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"OK", nil];
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                textField = [alert textFieldAtIndex:0];
                textField.placeholder = @"Group ID";
                [alert show];
            }
        } else {
            HalfEducationCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            NSString *testName = cell.text.text;
            NSString *name = subGroup.name;
            if ([name isEqualToString:testName]) {
                if ([name isEqualToString:@"Calendar"]) {
                    
                } else {
                    destinationPostID = subGroup.ID;
                    [self performSegueWithIdentifier:@"presentPostView" sender:self];
                }
            } else if ([testName isEqualToString:@"Add Group"]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Group"
                                                                message:@"Enter Group ID Below"
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"OK", nil];
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                textField = [alert textFieldAtIndex:0];
                textField.placeholder = @"Group ID";
                [alert show];
            }
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"presentNav"]) {
        TransitionOperator *top = [[TransitionOperator alloc] init];
        UIViewController *destination = segue.destinationViewController;
        destination.transitioningDelegate = top;
        [self presentViewController:destination animated:YES completion:nil];
    } else if ([segue.identifier isEqualToString:@"presentPostView"]) {
        PostViewController *destination = [segue destinationViewController];
        [destination setGroupID:destinationPostID];
        [destination setGroupType:@"subGroup"];
    } else {
        return;
    }
}

@end
