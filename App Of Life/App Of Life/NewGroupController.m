//
//  NewGroupController.m
//  App Of Life
//
//  Created by David Kopala on 1/11/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import "NewGroupController.h"

@interface NewGroupController ()

@end

@implementation NewGroupController {
    NSInteger totalDefaultRows;
    NSInteger totalRows;
    NSMutableArray *defaultRows;
    NSMutableArray *rows;
    
    NSInteger latitude;
    NSInteger longitde;
    BOOL update;
    
    NSString *stringLatitude;
    NSString *stringLongitude;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.groupsTable setDataSource:self];
    [self.groupsTable setDelegate:self];
    [self.defaultGroupsTable setDataSource:self];
    [self.defaultGroupsTable setDelegate:self];
    self.latitudeField.text = stringLatitude;
    self.longitudeField.text = stringLongitude;
}

-(void)setLongitude:(NSString *)longitude {
    stringLongitude = longitude;
}

-(void)setLatitude:(NSString *)latitude {
    stringLatitude = latitude;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButton:(id)sender {
    [self performSegueWithIdentifier:@"presentHome" sender:self];
}

- (IBAction)doneButton:(id)sender {
    [self performSegueWithIdentifier:@"presentHome" sender:self];
}

- (IBAction)mapButton:(id)sender {
    [self performSegueWithIdentifier:@"chooseLocation" sender:self];
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.groupsTable) {
        return totalRows;
    } else {
        return totalDefaultRows;
    }
}

-(NSInteger) tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return 1;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    totalRows = [tableView numberOfRowsInSection:indexPath.section];
    if (index == totalRows) {
        totalRows++;
        [tableView reloadData];
        return;
    }
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    if (tableView == self.groupsTable) {
        
    } else {
        
    }
    return cell;
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
