//
//  ConnectionParser.m
//  App Of Life
//
//  Created by David Kopala on 1/15/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import "ConnectionParser.h"
#import "ConnectionObject.h"

@implementation ConnectionParser {
    NSArray *ConnectionDataDictionaryArray;
    NSMutableArray *ConnectionDictionaryArray;
    NSMutableArray *ConnectionArray;
    
    BOOL finished;
}

-(instancetype) init {
    [self A];
    return self;
}

-(NSMutableArray *) array {
    return ConnectionArray;
}

-(BOOL) finished {
    return finished;
}

-(void) A {
    NSString *ConnectionString = @"http://24.8.58.134/david/api/ConnectionAPI";
    NSURL *ConnectionURL = [NSURL URLWithString:ConnectionString];
    NSURLRequest *ConnectionRequest = [NSURLRequest requestWithURL:ConnectionURL];
    [NSURLConnection sendAsynchronousRequest:ConnectionRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError == nil && data.length > 0) {
                                   [self C:data];
                               }
                           }];
}

-(void) C:(NSData *)data {
    if (!ConnectionDataDictionaryArray) {
        ConnectionDataDictionaryArray = [[NSArray alloc] init];
    }
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(dataString);
    NSError *error;
    ConnectionDataDictionaryArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    [self E];
}

-(void) E {
    if (!ConnectionDictionaryArray) {
        ConnectionDictionaryArray = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < [ConnectionDataDictionaryArray count]; i++) {
        NSDictionary *temp = [ConnectionDataDictionaryArray objectAtIndex:i];
        [ConnectionDictionaryArray addObject:temp];
    }
    [self F];
}

-(void) F {
    if (!ConnectionArray) {
        ConnectionArray = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < [ConnectionDictionaryArray count]; i++) {
        NSDictionary *temp = [ConnectionDictionaryArray objectAtIndex:i];
        
        NSInteger ID = [[temp objectForKey:@"ID"] integerValue];
        
        NSInteger UserID = [[temp objectForKey:@"UserID"] integerValue];
        
        NSInteger ConnectionID = [[temp objectForKey:@"ConnectionID"] integerValue];
        
        ConnectionObject *Connection;
        Connection = nil;
        if (!Connection) {
            Connection = [[ConnectionObject alloc] init];
        }
        
        Connection.ID = ID;
        Connection.UserID = UserID;
        Connection.ConenctionID = ConnectionID;
        
        [ConnectionArray addObject:Connection];
    }
    finished = YES;
}

@end
