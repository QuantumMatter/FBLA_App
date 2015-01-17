//
//  PostParser.m
//  App Of Life
//
//  Created by David Kopala on 1/15/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import "PostParser.h"
#import "PostObject.h"

@implementation PostParser {
    NSArray *postDataDictionaryArray;
    NSMutableArray *postDictionaryArray;
    NSMutableArray *postArray;
    
    BOOL finished;
}

-(instancetype) init {
    [self A];
    return self;
}

-(NSMutableArray *) array {
    return postArray;
}

-(BOOL) finished {
    return finished;
}

-(void) A {
    NSString *postString = @"http://24.8.58.134/david/api/postAPI";
    NSURL *postURL = [NSURL URLWithString:postString];
    NSURLRequest *postRequest = [NSURLRequest requestWithURL:postURL];
    [NSURLConnection sendAsynchronousRequest:postRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError == nil && data.length > 0) {
                                   [self C:data];
                               }
                           }];
}

-(void) C:(NSData *)data {
    if (!postDataDictionaryArray) {
        postDataDictionaryArray = [[NSArray alloc] init];
    }
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(dataString);
    NSError *error;
    postDataDictionaryArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    [self E];
}

-(void) E {
    if (!postDictionaryArray) {
        postDictionaryArray = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < [postDataDictionaryArray count]; i++) {
        NSDictionary *temp = [postDataDictionaryArray objectAtIndex:i];
        [postDictionaryArray addObject:temp];
    }
    [self F];
}

-(void) F {
    if (!postArray) {
        postArray = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < [postDictionaryArray count]; i++) {
        NSDictionary *temp = [postDictionaryArray objectAtIndex:i];
        
        NSInteger ID = [[temp objectForKey:@"ID"] integerValue];
        
        NSInteger UserID = [[temp objectForKey:@"UserID"] integerValue];
        
        NSString *membership = [temp objectForKey:@"Membership"];
        membership = [membership stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSInteger GroupID = [[temp objectForKey:@"GroupID"] integerValue];
        
        NSString *Message = [temp objectForKey:@"Message"];
        Message = [Message stringByReplacingOccurrencesOfString:@" " withString:@""];
        Message = [Message stringByReplacingOccurrencesOfString:@"0123456789" withString:@" "];
        
        /*NSString *Content = [temp objectForKey:@"Content"];
        Content = [Content stringByReplacingOccurrencesOfString:@" " withString:@""];*/
        
        NSInteger Zip = [[temp objectForKey:@"Zip"] integerValue];
        
        PostObject *post;
        post = nil;
        if (!post) {
            post = [[PostObject alloc] init];
        }
        
        post.ID = ID;
        post.UserID = UserID;
        post.membership = membership;
        post.GroupID = GroupID;
        post.message = Message;
        post.content = @"";
        post.zip = &Zip;
        
        [postArray addObject:post];
    }
    finished = YES;
}

@end
