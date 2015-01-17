//
//  UserManager.h
//  App Of Life
//
//  Created by David Kopala on 1/4/15.
//  Copyright (c) 2015 David Kopala. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface UserManager : NSObject

@property (nonatomic, strong) NSString *documentsDirectory;

@property (nonatomic, strong) NSString *databaseFilename;

@property (nonatomic, strong) NSMutableArray *arrResults;

@property (nonatomic, strong) NSMutableArray *arrayColumnNames;

@property (nonatomic) int affectedRows;

@property (nonatomic) long long lastInsertedRowID;

-(void) runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable;

-(void)copyDatabaseIntoDocumentsDirectory;

-(instancetype) initWithDatabaseFileName:(NSString *)dbFilename;

-(NSArray *) loadDataFromDB:(NSString *)query;

-(void)executeQuery:(NSString *)query;

@end
