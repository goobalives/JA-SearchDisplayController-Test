//
// JA-SearchDisplayController-Test
//
// Description:
// 
// When user starts the app any saved searches (Companies, Contacts by Name and Keyword) are loaded.
// User selects Company or Contact tab.
// Search Bar first responder is set.
// User starts typing and an auto-filter of past searches is activated. Incremental results are displayed in the search display controllers results tableview.
// User can select a past search --> search results are shown if they exist. If there are no search results, the search is saved. If there are search results, and the search doesn't exist yet, it is also saved.
// When the user closes the app, searches are archived to disk.

// Notes:

// Uses a singleton called JAUtility to provide a shared instance to the application.
// JAUtility shared instance is used to archive and unarchive saved searches.
// JAUtility shared instance is used to load a bunch of sample Companies, Contacts and Keywords (to proxy the network interface)
// JAUtility shared instance maintains the current state of searches for Companies, Contacts and Keywords.

// The application has a tabbar controller with two view controllers: Companies and Contacts.
// Within Contacts there is searching scope: Name and Keyword.

// No abstract Search Controller class has been implemented -- this is the most obvious improvement/upgrade.
// In Contacts view controller, the search display controller was set up programmatically -- as an exercise.
// Interestingly, none of the SearchDisplayController delegate methods were implemented to get this to work.

