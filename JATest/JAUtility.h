//
//  JAUtility.h
//  JATest
//
//  Created by Simon Hall on 23/02/2013.
//  Copyright (c) 2013 Simon Hall. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JASearchType) {
    JASearchTypeCompany,
    JASearchTypeContactName,
    JASearchTypeContactKeyword
};

@interface JAUtility : NSObject

@property (nonatomic, strong) NSMutableArray *savedCompanySearches;
@property (nonatomic, strong) NSMutableArray *savedContactNameSearches;
@property (nonatomic, strong) NSMutableArray *savedContactKeywordSearches;

+ (id)sharedInstance;
- (NSArray *)loadCompanies;
- (NSArray *)loadContacts;
- (void)saveSearch:(NSString *)searchToSave withSearchType:(JASearchType)searchType;
- (BOOL)archiveSavedSearch:(JASearchType)searchType;

@end
