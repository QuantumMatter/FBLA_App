//
//  PostViewController.m
//  App Of Life
//
//  Created by David Kopala on 1/7/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import "PostViewController.h"
#import "TransitionOperator.h"
#import "PostCell.h"
#import "PostObject.h"
#import "PostParser.h"
#import "UserParser.h"
#import "UserObject.h"
#import "ConnectionObject.h"
#import "ConnectionParser.h"
#import "SubGroupObject.h"
#import "SubGroupParser.h"
#import "SubMembershipParser.h"
#import "SubMembershipObject.h"
#import "DBManager.h"

@interface PostViewController () {
    NSInteger groupID;
    NSString *groupType;
    
    NSMutableArray *postArray;
    NSMutableArray *userArray;
    NSMutableArray *connectionArray;
    NSMutableArray *subMembershipArray;
    NSMutableArray *subGroupArray;
    
    NSMutableArray *applicablePosts;
    NSMutableArray *applicableConnections;
    NSMutableArray *applicableMemberships;
    
    BOOL update;
    UserObject *_currentUser;
    
    NSTimer *timer;
    
    PostParser *parse;
    UserParser *uParser;
    ConnectionParser *cParser;
    SubMembershipParser *smParser;
    SubGroupParser *sbParser;
}

@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    update = YES;
    [self._postTable setDataSource:self];
    [self._postTable setDelegate:self];
    
    applicablePosts = [[NSMutableArray alloc] init];
    applicableMemberships = [[NSMutableArray alloc] init];
    applicableConnections = [[NSMutableArray alloc] init];
    
    timer = [[NSTimer alloc] init];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(setArrays) userInfo:nil repeats:YES];
    
    [self updateApplicableMembership];
    [self updateCurrentUser];
    [self updateApplicableConnections];
    [self updateApplicablePosts];
    
    parse = [[PostParser alloc] init];
    uParser = [[UserParser alloc] init];
    cParser = [[ConnectionParser alloc] init];
    smParser = [[SubMembershipParser alloc] init];
    sbParser = [[SubGroupParser alloc] init];
}

-(void) setArrays {
    if (subGroupArray == nil) {
        
        subGroupArray = [[NSMutableArray alloc] init];
        subGroupArray = [sbParser array];
        
    } else if (postArray == nil) {
        postArray = [[NSMutableArray alloc] init];
        postArray = [parse array];
    } else if (userArray == nil) {
        userArray = [[NSMutableArray alloc] init];
        userArray = [uParser array];
    } else if (connectionArray == nil) {
        connectionArray = [[NSMutableArray alloc] init];
        connectionArray = [cParser array];
    } else if (subMembershipArray == nil) {
        subMembershipArray = [[NSMutableArray alloc] init];
        subMembershipArray = [smParser array];
    } else {
        [timer invalidate];
        [self updateApplicableConnections];
        [self updateApplicableMembership];
        [self updateApplicablePosts];
        [self._postTable reloadData];
    }
}

-(void) setGroupID:(NSInteger)ID {
    groupID = ID;
}

-(void) setGroupType:(NSString *)groupTypeA {
    groupType = groupTypeA;
}

- (IBAction)addPost:(id)sender {
    [self performSegueWithIdentifier:@"presentNewPostView" sender:self];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!postArray) {
        return 0;
    }
    return [applicablePosts count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifer = @"myCell";
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PostCell" owner:self options:kNilOptions] objectAtIndex:0];
    }
    PostObject *post;
    post = nil;
    if (!post) {
        post = [[PostObject alloc] init];
    }
    post = [applicablePosts objectAtIndex: [applicablePosts count] - (indexPath.row + 1)];
    [cell setMessage:post.message];
    cell.Name.text = @"Test";
    cell.image.image = [UIImage imageNamed:@"OK"];
    [cell.content sizeToFit];
    [cell.content setNumberOfLines:0];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void) updateApplicableMembership {
    if ([groupType isEqualToString:@"subGroup"]) {
        for (int membershipPosition = 0; membershipPosition < [subMembershipArray count]; membershipPosition++) {
            SubMembershipObject *membership;
            membership = nil;
            if (!membership) {
                membership = [[SubMembershipObject alloc] init];
            }
            membership = [subMembershipArray objectAtIndex:membershipPosition];
            
            if (membership.userID == _currentUser.userID) {
                if (membership.subGroupID == groupID) {
                    [applicableMemberships addObject:membership];
                }
            }
        }
    }
}

-(void) updateApplicableConnections {
    for (int connectionPosition = 0; connectionPosition < [connectionArray count]; connectionPosition++) {
        ConnectionObject *conn;
        conn = nil;
        if (!conn) {
            conn = [[ConnectionObject alloc] init];
        }
        conn = [connectionArray objectAtIndex:connectionPosition];
        
        if (conn.UserID == _currentUser.userID) {
            [applicableConnections addObject:conn];
        }
    }
}

-(void) updateApplicablePosts {
    if (!applicableMemberships) {
        return;
    }
    if (!postArray) {
        return;
    }
    if ([groupType isEqualToString:@"subGroup"]) {
        for (int postPosition = 0; postPosition < [postArray count]; postPosition++) {
            for (int membershipPosition = 0; membershipPosition < [applicableMemberships count]; membershipPosition++) {
                PostObject *post;
                post = nil;
                if (!post) {
                    post = [[PostObject alloc] init];
                }
                post = [postArray objectAtIndex:postPosition];
                
                if ([post.membership isEqualToString:@"subGroup"]) {
                    if (post.GroupID == groupID) {
                        [applicablePosts addObject:post];
                    }
                }
            }
        }
    } else {
        for (int A = 0; A < [postArray count];  A++) {
            
            PostObject *post;
            post = nil;
            if (!post) {
                post = [[PostObject alloc] init];
            }
            post = [postArray objectAtIndex:A];
            
            if (post.UserID == _currentUser.userID) {
                [applicablePosts addObject:post];
            }
            
            for (int B = 0; B < [applicableConnections count]; B++) {
                
                ConnectionObject *conn;
                conn = nil;
                if (!conn) {
                    conn = [[ConnectionObject alloc] init];
                }
                conn = [applicableConnections objectAtIndex:B];
                
                if ((post.UserID == conn.ConenctionID) || (post.UserID == _currentUser.userID)) {
                    [applicablePosts addObject:post];
                }
            }
        }
    }
    [self._postTable reloadData];
}

@end
