//
//  PostCell.m
//  App Of Life
//
//  Created by David Kopala on 1/15/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import "PostCell.h"

@implementation PostCell {
    NSInteger transform;
}

- (void)awakeFromNib {
    NSString *message = self.content.text;
    CGSize test = [message sizeWithAttributes:kNilOptions];
    NSInteger baseHeight = 21;
    NSInteger baseWidth = 346;
    NSInteger adjustmentConstant = test.width / baseWidth;
    NSInteger adjustedHeight = 0;
    NSInteger evenTest = adjustmentConstant / 2;
    if (evenTest*2 == adjustmentConstant) {
        
    } else {
        adjustmentConstant +=1;
    }
    adjustedHeight = baseHeight * adjustmentConstant;
    
    transform = adjustedHeight - baseHeight;
    
    CGRect content = self.content.frame;
    content.size.height += transform;
    [self.content setFrame:content];
    
    CGRect label01 = self.label01.frame;
    label01.size.height += transform;
    [self.label01 setFrame:label01];
    
    CGRect bg = self.bg.frame;
    bg.size.height += transform;
    [self.bg setFrame:bg];
    
    CGRect view = self.frame;
    view.size.height += transform;
    [self setFrame:view];
}

-(void) setMessage:(NSString *)string {
    self.content.text = string;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    NSString *message = self.content.text;
    CGSize test = [message sizeWithAttributes:kNilOptions];
    NSInteger baseHeight = 21;
    NSInteger baseWidth = 346;
    NSInteger adjustmentConstant = test.width / baseWidth;
    NSInteger adjustedHeight = 0;
    NSInteger evenTest = adjustmentConstant / 2;
    if (evenTest*2 == adjustmentConstant) {
        
    } else {
        adjustmentConstant +=1;
    }
    adjustedHeight = baseHeight * adjustmentConstant;
    
    transform = adjustedHeight - baseHeight;
    
    CGRect content = self.content.frame;
    content.size.height += transform;
    [self.content setFrame:content];
    
    CGRect label01 = self.label01.frame;
    label01.size.height += transform;
    [self.label01 setFrame:label01];
    
    CGRect bg = self.bg.frame;
    bg.size.height += transform;
    self.bg.frame = bg;
    [self.bg setFrame:bg];
    //
    CGRect view = self.frame;
    view.size.height += transform;
    [self setFrame:view];
}

@end
