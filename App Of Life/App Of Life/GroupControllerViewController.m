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
#import "DualObject.h"
#import "SubGroupObject.h"
#import "SubMembershipObject.h"
#import "DBManager.h"
#import "PostViewController.h"
#import "SubGroupParser.h"
#import "SubMembershipParser.h"

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
    
    BOOL isMember;
    
    NSArray *initToolBar;
    
    SubGroupParser *sgParser;
    SubMembershipParser *smParser;
    NSTimer *timer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self._collectionView.delegate = self;
    self._collectionView.dataSource = self;
    [self._collectionView registerNib:[UINib nibWithNibName:@"FullEducationCell" bundle:nil] forCellWithReuseIdentifier:@"fullCell"];
    [self._collectionView registerNib:[UINib nibWithNibName:@"HalfEducationCell" bundle:nil] forCellWithReuseIdentifier:@"halfCell"];
    halfSize = CGSizeMake(175, 175);
    fullSize = CGSizeMake(375, 175);
    [self getCurrentUser];
    currentCell = -1;
    isMember = NO;
    currentCell = -1;
    currentCellCount = 0;
    
    sgParser = [[SubGroupParser alloc] init];
    smParser = [[SubMembershipParser alloc] init];
    timer = [[NSTimer alloc] init];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(A) userInfo:nil repeats:YES];
    
    [self A];
}

-(void) setButton {
    if (!initToolBar) {
        initToolBar = [self.toolBar items];
    }
    NSMutableArray *Items = [initToolBar mutableCopy];
    if (isMember) {
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
    if (isMember) {
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
            NSLog(@"Error Occured Durring Connection");
        }
        [self A];
    } else {
        
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
        _currentUser.latitude = latitude;
        _currentUser.longitude = longitude;
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
    } else {
        [timer invalidate];
        currentCell = -1;
        currentCellCount = 0;
        [self._collectionView reloadData];
    }
}

/*-(void) A {
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
                
                NSInteger intID = [[tempB objectForKey:@"ID"] integerValue];
                NSString *ID = [NSString stringWithFormat:@"%ld", intID];
                membership.ID = ID;
                membership.UserID = currentStringID;
                membership.Group = IDA;
                membership.Role = role;
                [membershipArray addObject:membership];
                
                dual.group = group;
                dual.membership = membership;
                [dualArray addObject:dual];
                
                isMember = YES;
            }
        }
    }
    [self setButton];
}

-(void) G {
    subGroupArray = nil;
    subGroupDictionaryArray = nil;
    subGroupDataDictionaryArray = nil;
    subMembershipArray = nil;
    subMembershipDictionaryArray = nil;
    subMembershipDataDictionaryArray = nil;
    subDualArray = nil;
    NSString *groupString = @"http://24.8.58.134/david/api/subGroupAPI";
    NSURL *groupURL = [NSURL URLWithString:groupString];
    NSURLRequest *groupRequest = [NSURLRequest requestWithURL:groupURL];
    [NSURLConnection sendAsynchronousRequest:groupRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError == nil && data.length > 0) {
                                   [self H:data];
                               }
                           }];
    
    NSString *membershipString = @"http://24.8.58.134/david/api/subMembershipAPI";
    NSURL *membershipURL = [NSURL URLWithString:membershipString];
    NSURLRequest *membershipRequest = [NSURLRequest requestWithURL:membershipURL];
    [NSURLConnection sendAsynchronousRequest:membershipRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError == nil && data.length > 0) {
                                   [self I:data];
                               }
                           }];
}

-(void) H:(NSData *)data {
    if (!subGroupDataDictionaryArray) {
        subGroupDataDictionaryArray = [[NSArray alloc] init];
    }
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"subGroup: %@", dataString);
    NSError *error;
    subGroupDataDictionaryArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    [self J];
}

-(void) I:(NSData *)data {
    if (!subMembershipDataDictionaryArray) {
        subMembershipDataDictionaryArray = [[NSArray alloc] init];
    }
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"subMembership: %@", dataString);
    NSError *error;
    subMembershipDataDictionaryArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    [self K];
}

-(void) J {
    if (!subGroupDictionaryArray) {
        subGroupDictionaryArray = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < [subGroupDataDictionaryArray count]; i++) {
        NSDictionary *temp = [subGroupDataDictionaryArray objectAtIndex:i];
        [subGroupDictionaryArray addObject:temp];
    }
    subGroupOK = YES;
    if (subGroupOK && subMembershipOK) {
        [self L];
    }
}

-(void) K {
    if (!subMembershipDictionaryArray) {
        subMembershipDictionaryArray = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < [subMembershipDataDictionaryArray count]; i++) {
        NSDictionary *temp = [subMembershipDataDictionaryArray objectAtIndex:i];
        [subMembershipDictionaryArray addObject:temp];
    }
    subMembershipOK = YES;
    if (subGroupOK && subMembershipOK) {
        [self L];
    }
}

-(void) L {
    if (!subGroupArray) {
        subGroupArray = [[NSMutableArray alloc] init];
    } if (!subMembershipArray) {
        subMembershipArray = [[NSMutableArray alloc] init];
    }
    for (int A = 0; A < [subGroupDictionaryArray count]; A++) {
        for (int B = 0; B < [subMembershipDictionaryArray count]; B++) {
            NSDictionary *tempGroup = [subGroupDictionaryArray objectAtIndex:A];
            NSDictionary *tempMembership = [subMembershipDictionaryArray objectAtIndex:B];
            NSInteger parentGroupID = [[tempGroup objectForKey:@"parentGroupID"] integerValue];
            if (parentGroupID == groupID) {
                NSInteger testUserID = [[tempMembership objectForKey:@"UserID"] integerValue];
                if (testUserID == _currentUser.userID) {
                    NSInteger testSubID = [[tempMembership objectForKey:@"subGroupID"] integerValue];
                    NSInteger subGroupID = [[tempGroup objectForKey:@"ID"] integerValue];
                    if (testSubID == subGroupID) {
                        NSString *name = [tempGroup objectForKey:@"Name"];
                        NSInteger pic = [[tempGroup objectForKey:@"pic"] integerValue];
                        NSInteger ID = [[tempMembership objectForKey:@"ID"] integerValue];
                        NSString *role = [tempMembership objectForKey:@"Role"];
                        
                        SubGroupObject *subGroup;
                        subGroup = nil;
                        if (!subGroup) {
                            subGroup = [[SubGroupObject alloc] init];
                        }
                        
                        subGroup.ID = subGroupID;
                        subGroup.name = name;
                        subGroup.groupID = parentGroupID;
                        subGroup.pic = pic;
                        
                        [subGroupArray addObject:subGroup];
                        
                        SubMembershipObject *subMembership;
                        subMembership = nil;
                        if (!subMembership) {
                            subMembership = [[SubMembershipObject alloc] init];
                        }
                        
                        subMembership.ID = ID;
                        subMembership.subGroupID = subGroupID;
                        subMembership.userID = _currentUser.userID;
                        subMembership.role = role;
                        
                        [subMembershipArray addObject:subMembership];
                    }
                }
            }
        }
    }
    membershipCount = [subMembershipArray count];
    currentCell = -1;
    currentCellCount = 0;
    [self._collectionView reloadData];
}*/

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
    } else if ([segue.identifier isEqualToString:@"presentViewController"]) {
        PostViewController *destination = [segue destinationViewController];
        [destination setGroupID:destinationPostID];
        [destination setGroupType:@"subGroup"];
    } else {
        return;
    }
}

@end
