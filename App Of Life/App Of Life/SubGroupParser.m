//
//  SubGroupParser.m
//  App Of Life
//
//  Created by David Kopala on 1/15/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import "SubGroupParser.h"
#import "SubGroupObject.h"

@implementation SubGroupParser {
    NSArray *SubGroupDataDictionaryArray;
    NSMutableArray *SubGroupDictionaryArray;
    NSMutableArray *SubGroupArray;
    
    BOOL finished;
}

-(instancetype) init {
    [self A];
    finished = NO;
    return self;
}

-(NSMutableArray *) array {
    return SubGroupArray;
}

-(BOOL) finished {
    return finished;
}

-(void) A {
    NSString *SubGroupString = @"http://24.8.58.134/david/api/SubGroupAPI";
    NSURL *SubGroupURL = [NSURL URLWithString:SubGroupString];
    NSURLRequest *SubGroupRequest = [NSURLRequest requestWithURL:SubGroupURL];
    [NSURLConnection sendAsynchronousRequest:SubGroupRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *SubGroupError) {
                               if (SubGroupError == nil && data.length > 0) {
                                   [self C:data];
                               }
                           }];
}

-(void) C:(NSData *)data {
    if (!SubGroupDataDictionaryArray) {
        SubGroupDataDictionaryArray = [[NSArray alloc] init];
    }
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(dataString);
    NSError *error;
    SubGroupDataDictionaryArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    [self E];
}

-(void) E {
    if (!SubGroupDictionaryArray) {
        SubGroupDictionaryArray = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < [SubGroupDataDictionaryArray count]; i++) {
        NSDictionary *temp = [SubGroupDataDictionaryArray objectAtIndex:i];
        [SubGroupDictionaryArray addObject:temp];
    }
    [self F];
}

-(void) F {
    if (!SubGroupArray) {
        SubGroupArray = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < [SubGroupDictionaryArray count]; i++) {
        NSDictionary *temp = [SubGroupDictionaryArray objectAtIndex:i];
        
        NSInteger ID = [[temp objectForKey:@"ID"] integerValue];
        
        NSString *Name = [temp objectForKey:@"Name"];
        Name = [Name stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSInteger parentGroupID = [[temp objectForKey:@"parentGroupID"] integerValue];
        
        NSInteger Pic = [[temp objectForKey:@"pic"] integerValue];
        
        SubGroupObject *SubGroup;
        SubGroup = nil;
        if (!SubGroup) {
            SubGroup = [[SubGroupObject alloc] init];
        }
        
        SubGroup.ID = ID;
        SubGroup.name = Name;
        SubGroup.groupID = parentGroupID;
        SubGroup.pic = Pic;
        
        [SubGroupArray addObject:SubGroup];
    }
    finished = YES;
}

@end
