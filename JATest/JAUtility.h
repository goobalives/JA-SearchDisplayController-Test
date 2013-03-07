//
//  JAUtility.h
//  JATest
//
//  Created by Simon Hall on 23/02/2013.
//  Copyright (c) 2013 Simon Hall. All rights reserved.
//

#import <Foundation/Foundation.h>

#define JASEARCHTYPECOMPANY @"Company"
#define JASEARCHTYPECONTACTNAME @"Contact-Name"
#define JASEARCHTYPECONTACTKEYWORD @"Contact-Keyword"

@interface JAUtility : NSObject

@property (nonatomic, strong) NSMutableArray *savedCompanySearches;
@property (nonatomic, strong) NSMutableArray *savedContactNameSearches;
@property (nonatomic, strong) NSMutableArray *savedContactKeywordSearches;

+ (id)sharedInstance;

- (BOOL)archiveSavedSearch:(NSString *)searchItem;
- (void)popSavedSearch:(NSString *)savedSearch withSearchType:(NSString *)searchType;

- (NSArray *)loadCompanies;
- (NSArray *)loadContacts;

@end
