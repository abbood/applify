#import "Simple_PlayerViewController.h"
#import "MPMediaItemCollection-Utils.h"
#import "PlayListTableCell.h"
#define kTableRowHeight 34

@implementation Simple_PlayerViewController
@synthesize titleSearch;
@synthesize playPauseButton;
@synthesize tableView;
@synthesize player;
@synthesize collection;
@synthesize nowPlaying;
@synthesize collectionModified;

@synthesize aSearchDisplayController;
@synthesize searchbar2;
//@synthesize allItems;
@synthesize cellarray;
@synthesize searchResults;
@synthesize hostViewController = _hostViewController;

#pragma mark -
+(id)sharedManager
{
    NSLog(@"----------------------------\n");
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    static Simple_PlayerViewController *sharedclass1=nil;
    if (!sharedclass1)
    {
        sharedclass1=[[super allocWithZone:nil]init];
        sharedclass1.cellarray=[[NSMutableArray alloc]init];
        
    }
    return sharedclass1;
    
}
+(id)allocWithZone:(NSZone *)zone
{NSLog(@"----------------------------\n");
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    return [self sharedManager];
}
- (IBAction)doTitleSearch {
    NSLog(@"----------------------------\n");
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    if ([titleSearch.text length] == 0)
        return;
    MPMediaPropertyPredicate *titlePredicate =
    [MPMediaPropertyPredicate predicateWithValue: titleSearch.text
                                     forProperty: MPMediaItemPropertyTitle
                                  comparisonType:MPMediaPredicateComparisonContains];
    
    
    MPMediaQuery *query = [[MPMediaQuery alloc] initWithFilterPredicates:[NSSet setWithObject:titlePredicate]];
    
    if ([[query items] count] > 0) {
        if (collection)
            self.collection = [collection collectionByAppendingMediaItems:[query items]];
        else {
            self.collection = [MPMediaItemCollection collectionWithItems:[query items]];
            [player setQueueWithItemCollection:self.collection];
            [player play];
        }
        
        
        collectionModified = YES;
        [self.tableView reloadData];
    }
    
    titleSearch.text = @"";
    [titleSearch resignFirstResponder];
    
}

- (IBAction)showMediaPicker {
    NSLog(@"----------------------------\n");
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    picker.delegate = self;
    [picker setAllowsPickingMultipleItems:YES];
    picker.prompt = NSLocalizedString(@"Select items to play", @"Select items to play");
    [self presentModalViewController:picker animated:YES];
    
}

- (IBAction)backgroundClick {
    NSLog(@"----------------------------\n");
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [titleSearch resignFirstResponder];
}

- (IBAction)seekBackward {
    NSLog(@"----------------------------\n");
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [player beginSeekingBackward];
    pressStarted = [NSDate timeIntervalSinceReferenceDate];
}

- (IBAction)previousTrack {
    NSLog(@"----------------------------\n");
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [player endSeeking];
    
    if (pressStarted >= [NSDate timeIntervalSinceReferenceDate] - 0.1)
        [player skipToPreviousItem];
}

- (IBAction)seekForward {
    NSLog(@"----------------------------\n");
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [player beginSeekingForward];
    pressStarted = [NSDate timeIntervalSinceReferenceDate];
}
- (IBAction)nextTrack {
    NSLog(@"----------------------------\n");
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [player endSeeking];
    if (pressStarted >= [NSDate timeIntervalSinceReferenceDate] - 0.1)
        [player skipToNextItem];
}

- (IBAction)playOrPause {
    NSLog(@"----------------------------\n");
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    if (player.playbackState == MPMusicPlaybackStatePlaying) {
        [player pause];
        [playPauseButton setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    }
    else
    {
        
        [player play];
        [playPauseButton setBackgroundImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    }

}

-(IBAction)changeViewHost:(id)sender
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)playOrPauseAtindex:(NSUInteger)sender
{NSLog(@"----------------------------\n");
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    //compare the indeces
    
    
    if (player.playbackState == MPMusicPlaybackStatePlaying)
    {
        
        [player pause];
        [playPauseButton setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    }
    else
    {
        NSUInteger index = sender;
        [self.hostViewController startBroadcastSequence];         
    }
    
    
}
//void with row number
- (void)removeTrack:(NSUInteger)sender {
    NSLog(@"----------------------------\n");
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    NSUInteger index = sender;
    MPMediaItem *itemToDelete = [collection mediaItemAtIndex:index];
    if ([itemToDelete isEqual:nowPlaying])  {
        if (!collectionModified) {
            [player skipToNextItem];
        }
        else {
            
            [player setQueueWithItemCollection:collection];
            player.nowPlayingItem = [collection mediaItemAfterItem:nowPlaying];
        }
        
    }
    MPMediaItemCollection *newCollection = [collection collectionByDeletingMediaItemAtIndex:index];
    self.collection = newCollection;
    
    collectionModified = YES;
    
    NSUInteger indices[] = {0, index};
    NSIndexPath *deletePath = [NSIndexPath indexPathWithIndexes:indices length:2];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:deletePath] withRowAnimation:UITableViewRowAnimationFade];
    
    if (newCollection == nil && player.playbackState == MPMusicPlaybackStatePlaying) {
        MPMediaItem *next = player.nowPlayingItem;
        self.collection = [MPMediaItemCollection collectionWithItems:[NSArray arrayWithObject:next]];
        [tableView reloadData];
    }
}

#pragma mark -
- (void)viewDidLoad
{NSLog(@"----------------------------\n");
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    //-----------------
    // UISearchBar *searchbar2 = [[UISearchBar alloc] initWithFrame:CGRectZero];
    searchbar2.showsScopeBar = YES;
    //[searchbar2 sizeToFit];
    searchbar2.delegate = self;
    UIImage *image=[UIImage imageNamed:@"searchbarBG1.png"];
    
    searchbar2.backgroundImage  =image;
    
    searchbar2.autocapitalizationType = UITextAutocapitalizationTypeNone;
    searchbar2.autocorrectionType = UITextAutocorrectionTypeNo;
    searchbar2.selectedScopeButtonIndex = 0;
    searchbar2.placeholder = @"Search";
    
    UISearchDisplayController *searchDC = [[UISearchDisplayController alloc] initWithSearchBar:searchbar2 contentsController: self];
    searchDC.delegate = self;
    searchDC.searchResultsDataSource = self;
    searchDC.searchResultsDelegate = self;
    self.aSearchDisplayController = searchDC;
    
    
	
	// create a filtered list that will contain products for the search results table.
	self.filteredListContent = [NSMutableArray arrayWithCapacity:[self.listContent count]];
	
	// restore search settings if they were saved in didReceiveMemoryWarning.
    if (self.savedSearchTerm)
	{
        [aSearchDisplayController setActive:self.searchWasActive];
        [aSearchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [aSearchDisplayController.searchBar setText:savedSearchTerm];
        self.savedSearchTerm = nil;
    }
	
	[self.tableView reloadData];
	self.tableView.scrollEnabled = YES;
    //self.tableView.tableHeaderView = aSearchDisplayController.searchBar;
    [aSearchDisplayController.searchBar becomeFirstResponder];
    //-----------------
    MPMusicPlayerController *thePlayer = [MPMusicPlayerController iPodMusicPlayer];
    self.player = thePlayer;
    
    
    if (player.playbackState == MPMusicPlaybackStatePlaying)
    {
        [playPauseButton setBackgroundImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        MPMediaItemCollection *newCollection = [MPMediaItemCollection collectionWithItems:[NSArray arrayWithObject:[player nowPlayingItem]]];
        self.collection = newCollection;
        //self.nowPlaying = [player nowPlayingItem];
    }
    else
    {
        [playPauseButton setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    }
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(nowPlayingItemChanged:)
                               name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                             object: player];
    
    [player beginGeneratingPlaybackNotifications];
    
    
    
    
}

- (void)viewDidUnload {
    NSLog(@"----------------------------\n");
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    self.titleSearch = nil;
    self.playPauseButton = nil;
    self.tableView = nil;
    [super viewDidUnload];
}

- (void)dealloc
{
    NSLog(@"----------------------------\n");
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self
                      name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                    object:player];
    [player endGeneratingPlaybackNotifications];
    
    
}

#pragma mark -
#pragma mark Media Picker Delegate Methods
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker
   didPickMediaItems: (MPMediaItemCollection *) theCollection {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (collection == nil)
    {
        self.collection = theCollection;
        [player setQueueWithItemCollection:collection];
        [player setNowPlayingItem:[collection firstMediaItem]];
        self.nowPlaying = [collection firstMediaItem];
        //    [player play];
        [playPauseButton setBackgroundImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    }
    else {
        self.collection = [collection collectionByAppendingCollection:theCollection];
    }
    
    collectionModified = YES;
    [self.tableView reloadData];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Player Notification Methods
- (void)nowPlayingItemChanged:(NSNotification *)notification {
    NSLog(@"----------------------------\n");
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    if (collection == nil)
    {
        MPMediaItem *nowPlayingItem = [player nowPlayingItem];
        self.collection = [collection collectionByAppendingMediaItem:nowPlayingItem];
    }
    else
    {
        
        if (collectionModified)
        {
            [player setQueueWithItemCollection:collection];
            //[player setNowPlayingItem:[collection mediaItemAfterItem:nowPlaying]];
            //[player play];
        }
        
        if (![collection containsItem:player.nowPlayingItem] && player.nowPlayingItem != nil) {
            self.collection = [collection collectionByAppendingMediaItem:player.nowPlayingItem];
        }
    }
    
    [tableView reloadData];
    self.nowPlaying = [player nowPlayingItem];
    
    if (nowPlaying == nil)
        [playPauseButton setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    else
        [playPauseButton setBackgroundImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    
    
    collectionModified = NO;
}

#pragma mark -
#pragma mark Table View Methods
- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"----------------------------\n");
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    //    NSInteger rows=0;
    //    if (tableView == self.searchDisplayController.searchResultsTableView) {
    //        rows=[self.searchResults count];
    //    }
    //    else
    //    {
    //        return [collection count];
    //    }
    //return rows;
    
    if (tableView == aSearchDisplayController.searchResultsTableView)
	{
        return [self.filteredListContent count];
    }
	else
	{
        return [collection count];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"----------------------------\n");
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    static NSString *identifier = @"Music Queue Cell";
    PlayListTableCell *cell = [theTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        
        cell = [[PlayListTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%d",indexPath.row]];
        NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"PlayListTableCell" owner:nil options:nil];
        
        for (UIView *view in views)
        {
            if([view isKindOfClass:[PlayListTableCell class]])
            {
                cell = (PlayListTableCell*)view;
            }
        }
        //        UIButton *removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //        UIImage *removeImage = [UIImage imageNamed:@"delete song states1.png"];
        //        [removeButton setBackgroundImage:removeImage forState:UIControlStateNormal];
        //        [removeButton setFrame:CGRectMake(0.0, 5.0, removeImage.size.width-25, removeImage.size.height-10)];
        //        [removeButton addTarget:self action:@selector(removeTrack:) forControlEvents:UIControlEventTouchUpInside];
        //
        //        cell.accessoryView  = removeButton;
    }
    
    if (tableView == aSearchDisplayController.searchResultsTableView)
    {
        cell.SongName.text=[self.filteredListContent objectAtIndex:indexPath.row];
    }
    else
    {
        cell.SongName.text = [collection titleForMediaItemAtIndex:[indexPath row]];
        
        
        
        if ([nowPlaying isEqual:[collection mediaItemAtIndex:[indexPath row]]])
        {
            UIImage *myGradient = [UIImage imageNamed:@"Gradient.png"];
            cell.SongName.textColor  = [UIColor colorWithPatternImage:myGradient];
            if (player.playbackState ==  MPMusicPlaybackStatePlaying)
            {
                [cell.Add setImage:[UIImage imageNamed:@"speakers states3.png"]forState:UIControlStateSelected];
                [cell.Add setSelected:YES];
                
            }
            
            
            
            
        }
        else
        {
            cell.SongName.font = [UIFont systemFontOfSize:21.0];
            cell.imageView.image = [UIImage imageNamed:@"empty.png"];
        }
        
        cell.row = [indexPath row];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"----------------------------\n");
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSLog(@"----------------------------\n");
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	[self.filteredListContent removeAllObjects]; // First clear the filtered array.
	
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
    
    listContent=[collection items];
	for (int i=0;i<[collection count];i++)
	{
        
        
        NSComparisonResult result = [[collection titleForMediaItemAtIndex:i] compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        if (result == NSOrderedSame)
        {
            [self.filteredListContent addObject:[collection titleForMediaItemAtIndex:i]];
            tableView=aSearchDisplayController.searchResultsTableView;
        }
    }
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSLog(@"----------------------------\n");
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [self filterContentForSearchText:searchString scope:
     [[aSearchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[aSearchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    NSLog(@"----------------------------\n");
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [self filterContentForSearchText:[aSearchDisplayController.searchBar text] scope:
     [[aSearchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

@end