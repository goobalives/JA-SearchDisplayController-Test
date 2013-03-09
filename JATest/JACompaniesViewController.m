//
//  JAViewController.m
//  JATest
//
//  Created by Simon Hall on 23/02/2013.
//  Copyright (c) 2013 Simon Hall. All rights reserved.
//

#import "JACompaniesViewController.h"

@interface JAViewController ()

@property (nonatomic, assign) BOOL loadPreviousSearches;
@property (nonatomic) JASearchType searchType;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) NSMutableArray *filteredPastSearches;
@property (nonatomic, strong) NSMutableArray *filteredCompanies;

// nonatomic first
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation JAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set the title of the nav bar
    [[self navigationItem]setTitle:@"Companies"];
    
    //set the previousSeaches flag if there are past searches
    if ([[[JAUtility sharedInstance] savedCompanySearches] count] > 0)
        self.loadPreviousSearches= YES;
    
    //set up the search display controller
    UISearchDisplayController *searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    searchController.delegate = self;
    searchController.searchResultsDataSource = self;
    searchController.searchResultsDelegate = self;
    
    self.searchController = searchController;
    
    //set the searchType
    self.searchType = JASearchTypeCompany;
}

#pragma mark - Search Bar Delegates

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{        
    //Turn off the previous searches flag to direct the tableView to the datasource of filtered searches required by the Search Display Controller
    if (self.loadPreviousSearches)
        self.loadPreviousSearches = NO;
    
    //Create the predicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
    
    //Create a filtered array
    self.filteredPastSearches = [[[[JAUtility sharedInstance] savedCompanySearches] filteredArrayUsingPredicate:predicate] mutableCopy];
    
    if ([self.filteredPastSearches count] > 0)
        [self.searchController.searchResultsTableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    //if there are saved searches then cancelling will load them again.
    if ([[[JAUtility sharedInstance] savedCompanySearches] count] > 0)
        self.loadPreviousSearches = YES;
    
    [self.tableView reloadData];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    //User wishes to search on the entered search text, not any past searches
    //If the searchBar text belongs to a past search, then don't add it to the past search array.
 
    //If user presses cancel button, don't try an add an empty search to saved searches
    if (![searchBar.text isEqualToString:@""]) {
    
        //retrieve the matching companies using the search string
        NSString *findString = [searchBar text];
        self.filteredCompanies = [self findCompany:findString];
        
        //Save the new search to the list of saved searches
        [[JAUtility sharedInstance] saveSearch:searchBar.text withSearchType:JASearchTypeCompany];
    }
    
    //Turn the search display controller to inactive.
    [self.searchController setActive:NO animated:YES];
    [self.tableView reloadData];
}

#pragma mark - UITableviewDataSource Conformance

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Three datasources:

    //1. Filtered list of saved searches -- updated when text changes (Search Display Results TableView)
    //2. Full list of saved searches -- unarchived and loaded at start (Normal TableView)
    //3. Filtered list of companies -- that match a previous search or text entered manually.
    
    //use isEqual
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.filteredPastSearches.count; //1.
    } else {
        if (self.loadPreviousSearches) {
            return [[[JAUtility sharedInstance] savedCompanySearches] count]; //2.
        } else {
            return self.filteredCompanies.count; //3.
        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //  If loading previous search items -- order is important here, since pressing cancel also ends editing (and calls the delegate searchBarTextDidEndEditing. self.loadPreviousSearches is set in the cancel method BEFORE the searchBarTextDidEndEditing is called.
    
    if (self.loadPreviousSearches) {
        
        //this is required here since there is no prototype cell for the search display results tableview.
        [tableView registerNib:[UINib nibWithNibName:@"JAPastSearchCell" bundle:nil] forCellReuseIdentifier:@"JAPastSearchCell"];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JAPastSearchCell" forIndexPath:indexPath];
        cell.textLabel.text = [[[JAUtility sharedInstance] savedCompanySearches] objectAtIndex:indexPath.row];
        return cell;
    }
    
    //  If the user is typing out keys to match a previous search, then the search display controller will be running the results view
    if (tableView == self.searchController.searchResultsTableView) {
        
        //this is required here since there is no prototype cell for the search display results tableview.
        [tableView registerNib:[UINib nibWithNibName:@"JAPastSearchCell" bundle:nil] forCellReuseIdentifier:@"JAPastSearchCell"];

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JAPastSearchCell" forIndexPath:indexPath];
        cell.textLabel.text = self.filteredPastSearches[indexPath.row];
        return cell;
        
    } else {
        
    //  If the cell is a past search item then recall/instantiate the sub-class
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JANormalSearchCell" forIndexPath:indexPath];
        cell.textLabel.text = self.filteredCompanies[indexPath.row]; //use new indexing notation
        return cell;
        
    }
}

#pragma mark - UITableviewDelegate Conformance

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        
        //  If we're in the normal tableview either the past searches are showing OR the a list of filtered companies is showing. Use the class of the cell to determine what to do.
        
        //Switch off the previous searches flag to direct the tableView to the datasource of filtered searches
        if (self.loadPreviousSearches) self.loadPreviousSearches = NO;

        //Run a search against the list of companies. The search is proxied here using the JAUtility class.
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell.reuseIdentifier isEqualToString:@"JAPastSearchCell"]) {
            [self matchCompanyAndDisplayResults:tableView forSelectedRow:indexPath];
        } else {
            // Perform the segue.
        }
        
    } else {
        //When the user selects a cell here, they are selecting a previous search or bypassing a previous search.
        //The previous search is then used in the networked lookup. The search is proxied here using the JAUtility class.
        
        //De-activate the search results view then search for the companies from the selected row.
        [self.searchController setActive:NO animated:YES];
        [self matchCompanyAndDisplayResults:tableView forSelectedRow:indexPath];
    }
}

#pragma mark - Storyboarding

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Filter the segue
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    if ([segue.identifier isEqualToString:@"ShowCompanyDetails"]) {
        if ([segue.destinationViewController respondsToSelector:@selector(setTitle:)]) {
            [segue.destinationViewController setTitle:self.filteredCompanies[indexPath.row]];
        }
    }
}

#pragma mark - Private Methods

- (void)matchCompanyAndDisplayResults:(UITableView *)tableView forSelectedRow:(NSIndexPath *)indexPath
{
    NSString *findString = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    NSString *trimmedString = [findString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.filteredCompanies = [self findCompany:trimmedString];
    
    [self.tableView reloadData];
}

- (NSMutableArray *)findCompany:(NSString *)searchString
{
    //proxy the getting of a company
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchString];
    
    return [[[[JAUtility sharedInstance] loadCompanies] filteredArrayUsingPredicate:predicate] mutableCopy];
}

@end
