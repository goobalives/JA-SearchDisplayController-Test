//
//  JAUtility.m
//  JATest
//
//  Created by Simon Hall on 23/02/2013.
//  Copyright (c) 2013 Simon Hall. All rights reserved.
//

#import "JAUtility.h"
#import "JATest_Macros.h"

@implementation JAUtility

+ (id)sharedInstance
{
    SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (id)init
{
    self = [super init];
    if (self) {
        
        //Load saved company searches from User Preferences
        self.savedCompanySearches = [NSKeyedUnarchiver unarchiveObjectWithFile:[self createArchivePath:JASearchTypeCompany]];
        self.savedContactNameSearches = [NSKeyedUnarchiver unarchiveObjectWithFile:[self createArchivePath:JASearchTypeContactName]];
        self.savedContactKeywordSearches = [NSKeyedUnarchiver unarchiveObjectWithFile:[self createArchivePath:JASearchTypeContactKeyword]];
        
        //TODO -- put these into a dictionary "savedSearches"
        if (!self.savedCompanySearches) self.savedCompanySearches = [[NSMutableArray alloc] init];
        if (!self.savedContactNameSearches) self.savedContactNameSearches = [[NSMutableArray alloc] init];
        if (!self.savedContactKeywordSearches) self.savedContactKeywordSearches = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)saveSearch:(NSString *)searchToSave withSearchType:(JASearchType)searchType
{
    //Clean the search string before saving it -- trimmed and lowercase
    NSString *cleanSavedSearch = [[searchToSave stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    
    //Exclude nil or empty strings
    if (!(cleanSavedSearch == nil) || ([cleanSavedSearch isEqualToString:@""])) {
        
        //Filter based on searchType
        NSMutableArray *handleSavedSearch = [NSMutableArray array];
        
        switch (searchType) {
            case JASearchTypeCompany:
                handleSavedSearch = self.savedCompanySearches;
                break;
            case JASearchTypeContactName:
                handleSavedSearch = self.savedContactNameSearches;
            case JASearchTypeContactKeyword:
                handleSavedSearch = self.savedContactKeywordSearches;
            default:
                break;
        }
        
        //Duplicate exclusion
        if (![handleSavedSearch containsObject:cleanSavedSearch]) {
            //if there are 20 items in the search list then remove the last item first
            if ([handleSavedSearch count] == 20) {
                [handleSavedSearch removeLastObject];
            }
        }
        
        [handleSavedSearch insertObject:cleanSavedSearch atIndex:0];
    }
}

- (BOOL)archiveSavedSearch:(JASearchType)searchType
{
        NSArray *archiveRoot = [NSArray array];
        
        switch (searchType) {
            case JASearchTypeCompany:
                archiveRoot = self.savedCompanySearches;
                break;
            case JASearchTypeContactName:
                archiveRoot = self.savedContactNameSearches;
                break;
            case JASearchTypeContactKeyword:
                archiveRoot = self.savedContactKeywordSearches;
                break;
            default:
                break;
        }
                
        //Create the archive path
        NSString *path = [self createArchivePath:searchType];
        
        //Archive and return the success/failure
        return [NSKeyedArchiver archiveRootObject:archiveRoot toFile:path];
}


- (NSString *)createArchivePath:(JASearchType)searchType
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = documentDirectories[0];
    NSString *saveString;
    
    switch (searchType) {
        case JASearchTypeCompany:
            saveString = @"Company";
            break;
        case JASearchTypeContactName:
            saveString = @"ContactName";
            break;
        case JASearchTypeContactKeyword:
            saveString = @"ContactKeyword";
        default:
            break;
    }

    NSString *archiveFileName = [NSString stringWithFormat:@"saved%@.archive", saveString];

    return [documentDirectory stringByAppendingPathComponent:archiveFileName];
}



//Creating an array on the fly each time with a list of companies. Normally you would do once, loading the companies into a property array.
- (NSArray *)loadCompanies;
{
    NSArray *companies = @[@"Adidas International",
                           @"Adidas Group Plc",
                           @"Puma Inc.",
                           @"New Balance",
                           @"Fairweather Trading Company",
                           @"Fairview Parties and Cakes",
                           @"Fairplay Investments Limited",
                           @"LLoyds of London",
                           @"Lloyds Harris and Co.",
                           @"BBC News and Weather",
                           @"BBC News International",
                           @"BBC World Service"];
    
    return [NSArray arrayWithArray:companies];
}

- (NSDictionary *)loadContacts
{
    NSArray *names = @[@"Steven Briggs",
                       @"Harry Talcom",
                       @"Richard Harris",
                       @"Felicity Smith",
                       @"Michael Felton",
                       @"Chris Jones",
                       @"Christine Jonstone"
                       ];

    NSArray *keywords = @[@"Java",
                          @"Ruby",
                          @"Java",
                          @"iOS",
                          @"iOS",
                          @"Ruby",
                          @"iOS"];
    
    NSArray *values = [NSArray arrayWithObjects:names, keywords, nil];
    NSArray *keys   = @[@"names", @"keywords"];
    NSDictionary *contacts = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    return contacts;
}

@end



