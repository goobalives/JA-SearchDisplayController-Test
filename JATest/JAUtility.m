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
        self.savedCompanySearches = [NSKeyedUnarchiver unarchiveObjectWithFile:[self createArchivePath:JASEARCHTYPECOMPANY]];
        self.savedContactNameSearches = [NSKeyedUnarchiver unarchiveObjectWithFile:[self createArchivePath:JASEARCHTYPECONTACTNAME]];
        self.savedContactKeywordSearches = [NSKeyedUnarchiver unarchiveObjectWithFile:[self createArchivePath:JASEARCHTYPECONTACTKEYWORD]];
        
        //TODO -- put these into a dictionary "savedSearches"
        if (!self.savedCompanySearches) self.savedCompanySearches = [[NSMutableArray alloc] init];
        if (!self.savedContactNameSearches) self.savedContactNameSearches = [[NSMutableArray alloc] init];
        if (!self.savedContactKeywordSearches) self.savedContactKeywordSearches = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)popSavedSearch:(NSString *)savedSearch withSearchType:(NSString *)searchType
{
    //Clean the search string before saving it -- trimmed and lowercase
    NSString *cleanSavedSearch = [[savedSearch stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    
    //Exclude nil or empty strings
    if (!(cleanSavedSearch == nil) || ([cleanSavedSearch isEqualToString:@""])) {
        
        //Filter based on searchType
        if ([searchType isEqualToString:JASEARCHTYPECOMPANY]) {
            [self handleSearch:@"savedCompanySearches" withString:cleanSavedSearch];
        }
        else if ([searchType isEqualToString:JASEARCHTYPECONTACTNAME]) {
            [self handleSearch:@"savedContactNameSearches" withString:cleanSavedSearch];
        }
        else {
            [self handleSearch:@"savedContactKeywordSearches" withString:cleanSavedSearch];
        }
    }
}

- (void)handleSearch:(NSString *)searchSelector withString:(NSString *)cleanString
{
    SEL selector = NSSelectorFromString(searchSelector);
    
    if ([self respondsToSelector:selector]) {
        //Duplicate exclusion
        if (![[self performSelector:selector] containsObject:cleanString]) {
            //if there are 20 items in the search list then remove the last item first
            if ([[self performSelector:selector] count] == 20)
                    [[self performSelector:selector] removeLastObject];
            [[self performSelector:selector] insertObject:cleanString atIndex:0];
        }
    }
}

- (BOOL)archiveSavedSearch:(NSString *)searchType
{
    if (searchType) {
        
        NSArray *archiveRoot = [NSArray array];
        
        if ([searchType isEqualToString:JASEARCHTYPECOMPANY])
            archiveRoot = self.savedCompanySearches;
        else if ([searchType isEqualToString:JASEARCHTYPECONTACTNAME])
            archiveRoot = self.savedContactNameSearches;
        else if ([searchType isEqualToString:JASEARCHTYPECONTACTKEYWORD])
            archiveRoot = self.savedContactKeywordSearches;
        else
            return false;
        
        //Create the archive path
        NSString *path = [self createArchivePath:searchType];
        
        //Archive and return the success/failure
        return [NSKeyedArchiver archiveRootObject:archiveRoot toFile:path];
    }
    
    return false;
}


- (NSString *)createArchivePath:(NSString *)searchType
{
    if (searchType) {
        NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = documentDirectories[0];
        NSString *archiveFileName = [NSString stringWithFormat:@"saved%@.archive", searchType];
        return [documentDirectory stringByAppendingPathComponent:archiveFileName];
    }
    return nil;
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



