//
//  MembershipParser.m
//  App Of Life
//
//  Created by David Kopala on 1/15/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import "MembershipParser.h"
#import "MembershipObject.h"

@implementation MembershipParser {
    NSArray *membershipDataDictionaryArray;
    NSMutableArray *membershipDictionaryArray;
    NSMutableArray *membershipArray;
    
    BOOL finished;
}

-(NSMutableArray *) array {
    return membershipArray;
}

-(instancetype) init {
    finished = NO;
    [self A];
    return self;
}

-(BOOL) finished {
    return finished;
}

-(void) A {
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

-(void) C:(NSData *)data {
    if (!membershipDataDictionaryArray) {
        membershipDataDictionaryArray = [[NSArray alloc] init];
    }
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(dataString);
    NSError *error;
    membershipDataDictionaryArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    [self E];
}

-(void) E {
    if (!membershipDictionaryArray) {
        membershipDictionaryArray = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < [membershipDataDictionaryArray count]; i++) {
        NSDictionary *temp = [membershipDataDictionaryArray objectAtIndex:i];
        [membershipDictionaryArray addObject:temp];
    }
    [self F];
}

-(void) F {
    if (!membershipArray) {
        membershipArray = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < [membershipDictionaryArray count]; i++) {
        NSDictionary *temp = [membershipDictionaryArray objectAtIndex:i];
        
        NSInteger ID = [[temp objectForKey:@"ID"] integerValue];
        NSString *stringID = [NSString stringWithFormat:@"%ld", (long)ID];
        stringID = [stringID stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSInteger userID = [[temp objectForKey:@"UserID"] integerValue];
        NSString *stringUserID = [NSString stringWithFormat:@"%ld", (long)userID];
        stringUserID = [stringUserID stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSString *group = [temp objectForKey:@"Group"];
        group = [group stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSString *role = [temp objectForKey:@"Role"];
        role = [role stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        MembershipObject *membership;
        membership = nil;
        if (!membership) {
            membership = [[MembershipObject alloc] init];
        }
        membership.ID = stringID;
        membership.UserID = stringUserID;
        membership.Group = group;
        membership.Role = role;
        
        [membershipArray addObject:membership];
    }
    finished = YES;
}

@end
