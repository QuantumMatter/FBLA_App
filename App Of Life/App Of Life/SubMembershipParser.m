//
//  SubMembershipParser.m
//  App Of Life
//
//  Created by David Kopala on 1/15/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import "SubMembershipParser.h"
#import "SubMembershipObject.h"

@implementation SubMembershipParser {
    NSArray *SubMembershipDataDictionaryArray;
    NSMutableArray *SubMembershipDictionaryArray;
    NSMutableArray *SubMembershipArray;
    
    BOOL finished;
}

-(instancetype) init {
    [self A];
    return self;
}

-(NSMutableArray *) array {
    return SubMembershipArray;
}

-(BOOL) finished {
    return finished;
}

-(void) A {
    NSString *SubMembershipString = @"http://24.8.58.134/david/api/SubMembershipAPI";
    NSURL *SubMembershipURL = [NSURL URLWithString:SubMembershipString];
    NSURLRequest *SubMembershipRequest = [NSURLRequest requestWithURL:SubMembershipURL];
    [NSURLConnection sendAsynchronousRequest:SubMembershipRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *SubMembershipError) {
                               if (SubMembershipError == nil && data.length > 0) {
                                   [self C:data];
                               }
                           }];
}

-(void) C:(NSData *)data {
    if (!SubMembershipDataDictionaryArray) {
        SubMembershipDataDictionaryArray = [[NSArray alloc] init];
    }
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(dataString);
    NSError *error;
    SubMembershipDataDictionaryArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    [self E];
}

-(void) E {
    if (!SubMembershipDictionaryArray) {
        SubMembershipDictionaryArray = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < [SubMembershipDataDictionaryArray count]; i++) {
        NSDictionary *temp = [SubMembershipDataDictionaryArray objectAtIndex:i];
        [SubMembershipDictionaryArray addObject:temp];
    }
    [self F];
}

-(void) F {
    if (!SubMembershipArray) {
        SubMembershipArray = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < [SubMembershipDictionaryArray count]; i++) {
        NSDictionary *temp = [SubMembershipDictionaryArray objectAtIndex:i];
        
        NSInteger ID = [[temp objectForKey:@"ID"] integerValue];
        
        NSInteger UserID = [[temp objectForKey:@"UserID"] integerValue];
        
        NSString *Role = [temp objectForKey:@"Role"];
        Role = [Role stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSInteger subGroupID = [[temp objectForKey:@"subGroupID"] integerValue];
        
        SubMembershipObject *SubMembership;
        SubMembership = nil;
        if (!SubMembership) {
            SubMembership = [[SubMembershipObject alloc] init];
        }
        
        SubMembership.ID = ID;
        SubMembership.userID = UserID;
        SubMembership.role = Role;
        SubMembership.subGroupID = subGroupID;
        
        [SubMembershipArray addObject:SubMembership];
    }
    finished = YES;
}

@end
