//
//  NewPostViewController.h
//  App Of Life
//
//  Created by David Kopala on 1/7/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewPostViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *_userPic;
@property (strong, nonatomic) IBOutlet UILabel *_usernameLabel;
@property (strong, nonatomic) IBOutlet UITextField *_inputField;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *_submitButton;

-(void) setType:(NSString *)_type;

-(void) setSubGroupID:(NSInteger) _ID;

@end
