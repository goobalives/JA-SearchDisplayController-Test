//
//  JAContactsViewController.m
//  JATest
//
//  Created by Simon Hall on 01/03/2013.
//  Copyright (c) 2013 Simon Hall. All rights reserved.
//

#import "JAContactsViewController.h"
#import "JAUtility.h"
#import "JAPastSearchCell.h"
#import "JANormalSearchCell.h"

@interface JAContactsViewController ()

@property (nonatomic, strong) NSDictionary *allContacts;
@property (nonatomic, strong) NSString *searchType;
@property (nonatomic, strong) NSMutableArray *filteredContacts;
@property (nonatomic, strong) NSMutableArray *filteredPastNameSearches;
@property (nonatomic, strong) NSMutableArray *filteredPastKeywordSearches;
@property (nonatomic, assign) BOOL loadPreviousSearches;
@property (nonatomic, strong) UISearchDisplayController *searchController;

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation JAContactsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //show the scope bar
    [self.searchBar setShowsScopeBar:YES];
    [self.searchBar setScopeButtonTitles:@[JACONTACTSCOPETITLENAME, JACONTACTSCOPETITLEKEYWORD]];
    [self.searchBar setSelectedScopeButtonIndex:0];
    self.searchType = JASEARCHTYPECONTACTNAME;
    
    //load the contacts dictionary
    self.allContacts = [[[JAUtility sharedInstance] loadContacts] mutableCopy];

    //set the previousSeaches flag if there are past searches
    if ([[JAUtility sharedInstance] savedContactNameSearches] > 0)
        self.loadPreviousSearches= YES;
    
    //set up the search display controller
    UISearchDisplayController *searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    searchController.delegate = self;
    searchController.searchResultsDataSource = self;
    searchController.searchResultsDelegate = self;
    self.searchController = searchController;
    
    //set the responder to the keypad
    [self.searchBar becomeFirstResponder];
}

#pragma mark - UISearchBar Delegates
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //Turn off the previous searches flag to direct the tableView to the datasource of filtered searches required by the Search Display Controller
    if (self.loadPreviousSearches)
        self.loadPreviousSearches = NO;
        
    //Find the contact using the entered search text
    self.filteredContacts = [self findContact:searchBar.text];

    //Remove the keypad
    [searchBar resignFirstResponder];
    
    //Realod the tableView data and keep the scopebar showing
    [self.tableView reloadData];
    [self.searchBar setShowsScopeBar:YES];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    //Keep the scopeBar showing
    [self.searchBar setShowsScopeBar:YES];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    //if there are saved searches then cancelling will load them again.
    if (([[[JAUtility sharedInstance] savedContactNameSearches] count] > 0) ||
        ([[[JAUtility sharedInstance] savedContactKeywordSearches] count] > 0)) {

        self.loadPreviousSearches = YES;
        [self.tableView reloadData];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    //Turn off the previous searches flag to direct the tableView to the datasource of filtered searches required by the Search Display Controller
    if (self.loadPreviousSearches) self.loadPreviousSearches = NO;
    
    NSArray *arr = [NSArray array];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];

    //Filter by Contact Name
    if ([self.searchType isEqualToString:JASEARCHTYPECONTACTNAME]) {
        //Create a filtered array of past Contact Name searches
        arr = [[JAUtility sharedInstance] savedContactNameSearches];
        self.filteredPastNameSearches = [[arr filteredArrayUsingPredicate:predicate] mutableCopy];
        if ([self.filteredPastNameSearches count] > 0)
            [self.searchController.searchResultsTableView reloadData];
    }
    else {
        //Filter by Contact Keyword
        arr = [[JAUtility sharedInstance] savedContactKeywordSearches];
        self.filteredPastKeywordSearches = [[arr filteredArrayUsingPredicate:predicate] mutableCopy];
        if ([self.filteredPastKeywordSearches count] > 0)
            [self.searchController.searchResultsTableView reloadData];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    if (![searchBar.text isEqualToString:@""]) {
    
        //Save the new search to the list of saved searches -- save either the Name or the Keyword
        NSString *cleanString = [[searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
        
        //Find the Contacts then save the search
        self.filteredContacts = [self findContact:cleanString];
        [[JAUtility sharedInstance] popSavedSearch:cleanString withSearchType:self.searchType];
    }
    
    //Turn the search display controller to inactive.
    [self.searchController setActive:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    //set the searchType iVar based on the scope
    self.searchType = ([searchBar selectedScopeButtonIndex] == 0) ? JASEARCHTYPECONTACTNAME : JASEARCHTYPECONTACTKEYWORD;
    
    //if there is a search string, then re-search using other scope
    if (self.searchBar.text) {
        [self findContact:searchBar.text];
        [self.tableView reloadData];
    };    
}

#pragma mark - UITableviewDataSource Conformance

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchController.searchResultsTableView) {
        return ([self.searchType isEqualToString:JASEARCHTYPECONTACTNAME]) ? [self.filteredPastNameSearches count] : [self.filteredPastKeywordSearches count];
    } else {
        if (self.loadPreviousSearches) {
            return ([self.searchType isEqualToString:JASEARCHTYPECONTACTNAME]) ? [[[JAUtility sharedInstance] savedContactNameSearches] count] : [[[JAUtility sharedInstance] savedContactKeywordSearches] count];
        } else {
            return [self.filteredContacts count];
        }
    }

    return 0;
    }

-(UITableViewCell *)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *savedContact = nil;
    
    //Loading previous searches
    if (self.loadPreviousSearches) {
        
        JAPastSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JAPastSearchCell"];
        if (!cell)
            cell = [[JAPastSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JAPastSearchCell"];
        
        //put the description of the saved contact in the cell. Could be either the first name or the last name. Trim leading space if last name.
        if ([self.searchType isEqualToString:JASEARCHTYPECONTACTNAME])
            savedContact = [[[JAUtility sharedInstance] savedContactNameSearches] objectAtIndex:indexPath.row];
        else
            savedContact = [[[JAUtility sharedInstance] savedContactKeywordSearches] objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [savedContact.description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        return cell;
    }
    
    //Dynamic keystroke search through previous searches using the Search Display Controller Results TableView
    if (tableView == self.searchController.searchResultsTableView) {
        JAPastSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JAPastSearchCell"];
        if (!cell)
            cell = [[JAPastSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JAPastSearchCell"];
        
        if ([self.searchType isEqualToString:JASEARCHTYPECONTACTNAME])
            savedContact = [self.filteredPastNameSearches objectAtIndex:indexPath.row];
        else
            savedContact = [self.filteredPastKeywordSearches objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [savedContact.description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        return cell;
    }
    else {
        //Displaying the results of a normal contact search
        JANormalSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JANormalSearchCell"];
        if (!cell)
            cell = [[JANormalSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JANormalSearchCell"];
        
        cell.textLabel.text = [self.filteredContacts[indexPath.row] description];
        
        return cell;
    }
}

#pragma mark - UITableviewDelegate Conformance

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (self.tableView == tableView) {
        //Normal tableview
        if ([[self.tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[JANormalSearchCell class]]) {
            //Load the detail view
            [self performSegueWithIdentifier:@"showContactDetails" sender:tableView];
        } else {
            //Switch off the previous searches flag to direct the tableView to the datasource of filtered searches
            if (self.loadPreviousSearches) self.loadPreviousSearches = NO;

            //Get the search string from the selected cell
            NSString *searchString = [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text;
            
            //Find the matching contacts and reload the tableView
            self.filteredContacts = [self findContact:searchString];
            [self.tableView reloadData];
        }
    } else {
        //De-activate the search results view then search for the contacts from the selected row.
        [self.searchController setActive:NO animated:YES];
        
        self.filteredContacts = [self findContact:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
        [self.tableView reloadData];
    }
}


#pragma mark - Storyboarding

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[segue destinationViewController] setTitle:[sender cellForRowAtIndexPath:[sender indexPathForSelectedRow]].textLabel.text];
}

#pragma mark - Private Methods

- (NSMutableArray *)findContact:(NSString *)searchString
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchString];

    //split the dictionary into arrays of names and keywords
    NSArray *names = [self.allContacts objectForKey:@"names"];
    NSArray *keywords  = [self.allContacts objectForKey:@"keywords"];
    NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
    
    if ([self.searchType isEqualToString:JASEARCHTYPECONTACTNAME]) {
        //find the contacts by name
        filteredArray = [[names filteredArrayUsingPredicate:predicate] mutableCopy];
    } else {
        //find the contacts by keyword -- get an array of indexes
        NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:searchString options:NSRegularExpressionCaseInsensitive error:nil];
        
        for (int i = 0; i < [keywords count]; i++) {
            NSString *keyword = [keywords objectAtIndex:i];
            NSArray *matches = [regEx matchesInString:keyword options:0 range:NSMakeRange(0, keyword.length)];
            if ([matches count]) {
                //use the current index to find the contact name -- add it to the filteredArray
                [filteredArray addObject:[names objectAtIndex:i]];
            }
        }
    }
    
    return filteredArray;
}

@end
