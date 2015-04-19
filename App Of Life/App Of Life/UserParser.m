//
//  UserParser.m
//  App Of Life
//
//  Created by David Kopala on 1/15/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import "UserParser.h"
#import "UserObject.h"

@implementation UserParser {
    NSArray *UserDataDictionaryArray;
    NSMutableArray *UserDictionaryArray;
    NSMutableArray *UserArray;
    
    BOOL finished;
}

-(NSMutableArray *) array {
    return UserArray;
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
    NSString *UserString = @"http://24.8.58.134/david/api/UserAPI";
    NSURL *UserURL = [NSURL URLWithString:UserString];
    NSURLRequest *UserRequest = [NSURLRequest requestWithURL:UserURL];
    [NSURLConnection sendAsynchronousRequest:UserRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError == nil && data.length > 0) {
                                   [self C:data];
                               }
                           }];
}

-(void) C:(NSData *)data {
    if (!UserDataDictionaryArray) {
        UserDataDictionaryArray = [[NSArray alloc] init];
    }
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(dataString);
    NSError *error;
    UserDataDictionaryArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    [self E];
}

-(void) E {
    if (!UserDictionaryArray) {
        UserDictionaryArray = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < [UserDataDictionaryArray count]; i++) {
        NSDictionary *temp = [UserDataDictionaryArray objectAtIndex:i];
        [UserDictionaryArray addObject:temp];
    }
    [self F];
}

-(void) F {
    if (!UserArray) {
        UserArray = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < [UserDictionaryArray count]; i++) {
        NSDictionary *temp = [UserDictionaryArray objectAtIndex:i];
        
        NSInteger ID = [[temp objectForKey:@"ID"] integerValue];
        
        NSString *Username = [temp objectForKey:@"Username"];
        Username = [Username stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        UserObject *User;
        User = nil;
        if (!User) {
            User = [[UserObject alloc] init];
        }
        
        User.userID = ID;
        User.userName = Username;
        
        [UserArray addObject:User];
    }
    finished = YES;
}

@end
