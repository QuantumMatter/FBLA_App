//
//  GroupParser.m
//  App Of Life
//
//  Created by David Kopala on 1/15/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import "GroupParser.h"
#import "GroupObject.h"

@implementation GroupParser {
    NSArray *GroupDataDictionaryArray;
    NSMutableArray *GroupDictionaryArray;
    NSMutableArray *GroupArray;
    
    BOOL finished;
}

-(NSMutableArray *) array {
    return GroupArray;
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
    NSString *GroupString = @"http://24.8.58.134/david/api/GroupAPI";
    NSURL *GroupURL = [NSURL URLWithString:GroupString];
    NSURLRequest *GroupRequest = [NSURLRequest requestWithURL:GroupURL];
    [NSURLConnection sendAsynchronousRequest:GroupRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError == nil && data.length > 0) {
                                   [self C:data];
                               }
                           }];
}

-(void) C:(NSData *)data {
    if (!GroupDataDictionaryArray) {
        GroupDataDictionaryArray = [[NSArray alloc] init];
    }
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(dataString);
    NSError *error;
    GroupDataDictionaryArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    [self E];
}

-(void) E {
    if (!GroupDictionaryArray) {
        GroupDictionaryArray = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < [GroupDataDictionaryArray count]; i++) {
        NSDictionary *temp = [GroupDataDictionaryArray objectAtIndex:i];
        [GroupDictionaryArray addObject:temp];
    }
    [self F];
}

-(void) F {
    if (!GroupArray) {
        GroupArray = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < [GroupDictionaryArray count]; i++) {
        NSDictionary *temp = [GroupDictionaryArray objectAtIndex:i];
        
        NSInteger ID = [[temp objectForKey:@"ID"] integerValue];
        NSString *stringID = [NSString stringWithFormat:@"%ld", (long)ID];
        stringID = [stringID stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSString *Name = [temp objectForKey:@"Name"];
        Name = [Name stringByReplacingOccurrencesOfString:@" " withString:@""];
        Name = [Name stringByReplacingOccurrencesOfString:@"0123456789" withString:@" "];
        
        double latitude = [[temp objectForKey:@"latitude"] doubleValue];
        double longitude = [[temp objectForKey:@"longitude"] doubleValue];
        
        GroupObject *Group;
        Group = nil;
        if (!Group) {
            Group = [[GroupObject alloc] init];
        }
        
        Group.ID = ID;
        Group.Name = Name;
        Group.latitude = latitude;
        Group.longitude = longitude;
        
        [GroupArray addObject:Group];
    }
    finished = YES;
}

@end