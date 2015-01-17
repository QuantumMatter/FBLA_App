//
//  PostViewController.h
//  App Of Life
//
//  Created by David Kopala on 1/7/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *_postTable;

-(void)setGroupType:(NSString *)groupTypeA;

-(void)setGroupID:(NSInteger)ID;


@end
