//
//  GroupMarker.m
//  App Of Life
//
//  Created by David Kopala on 1/3/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import "GroupMarker.h"
#import "GroupControllerViewController.h"

@implementation GroupMarker

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)go:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GroupControllerViewController *destination = [storyboard instantiateViewControllerWithIdentifier:@"GroupHomeController"];
}

@end
