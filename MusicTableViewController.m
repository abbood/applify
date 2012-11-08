#import "MusicTableViewController.h"
#import "MainViewController.h"
#import "PlayListTableCell.h"
@implementation MusicTableViewController

static NSString *kCellIdentifier = @"Cell";

@synthesize delegate;					// The main view controller is the delegate for this class.
@synthesize mediaItemCollectionTable;	// The table shown in this class's view.
@synthesize addMusicButton;
@synthesize cellarray;

// The button for invoking the media item picker. Setting the title
//		programmatically supports localization.


// Configures the table view.
+(id)sharedManager
{
    
    static MusicTableViewController *sharedclass1=nil;
    if (!sharedclass1)
    {
        sharedclass1=[[super allocWithZone:nil]init];
        sharedclass1.cellarray=[[NSMutableArray alloc]init];
        
    }
    return sharedclass1;
    
}
+(id)allocWithZone:(NSZone *)zone
{
    return [self sharedManager];
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
	
    UIImage *image=[UIImage imageNamed:@"searchbarBG.png"];
    
    self.searchbar.backgroundImage  =image;
    
	[self.addMusicButton setTitle: NSLocalizedString (@"AddMusicFromTableView", @"Add button shown on table view for invoking the media item picker")];
	
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    for (NSInteger i = 0; i < 100; ++i)
    {
        [self.cellarray addObject :@"nc"];
    }
}


// When the user taps Done, invokes the delegate's method that dismisses the table view.
- (IBAction) doneShowingMusicList: (id) sender {
    
	[self.delegate musicTableViewControllerDidFinish: self];
}


// Configures and displays the media item picker.
- (IBAction) showMediaPicker: (id) sender {
    
	MPMediaPickerController *picker =
    [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio];
	
	picker.delegate						= self;
	picker.allowsPickingMultipleItems	= YES;
	picker.prompt						= NSLocalizedString (@"AddSongsPrompt", @"Prompt to user to choose some songs to play");
	
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault animated:YES];
    
	[self presentModalViewController: picker animated: YES];
    
}


// Responds to the user tapping Done after choosing music.
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection {
    
	[self dismissModalViewControllerAnimated: YES];
	[self.delegate updatePlayerQueueWithMediaCollection: mediaItemCollection];
  	[self.mediaItemCollectionTable reloadData];
    
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated:YES];
}


// Responds to the user tapping done having chosen no music.
- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {
    
	[self dismissModalViewControllerAnimated: YES];
    
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated:YES];
}



#pragma mark Table view methods________________________

// To learn about using table views, see the TableViewSuite sample code
//		and Table View Programming Guide for iPhone OS.

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger)section {
    
	HostViewController *hostViewController = (HostViewController *) self.delegate;
	MPMediaItemCollection *currentQueue = hostViewController.userMediaItemCollection;
	return [currentQueue.items count];
    
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
    
	NSInteger row = [indexPath row];
    
    
    static NSString *CellIdentifer=@"LabelCell";
    PlayListTableCell *cell=[tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%d",indexPath.row]];
    
    if (cell==nil)
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
        HostViewController *hostViewController = (HostViewController *) self.delegate;
        MPMediaItemCollection *currentQueue = hostViewController.userMediaItemCollection;
        MPMediaItem *anItem = (MPMediaItem *)[currentQueue.items objectAtIndex: row];
        if (anItem)
        {
            cell.SongName.text = [anItem valueForProperty:MPMediaItemPropertyTitle];
        }
        
        cell.row=(int*)indexPath.row;
        
        if ([self.cellarray objectAtIndex:indexPath.row ]!= @"c")
        {
            
            
            [cell.Add setImage:[UIImage imageNamed:@"speakers states2.png"] forState:UIControlStateNormal];
            
            
        }
        
        else {
            [cell.Add setSelected:YES];
            UIImage *myGradient = [UIImage imageNamed:@"Gradient.png"];
            cell.SongName.textColor = [UIColor colorWithPatternImage:myGradient];
            [cell.Add setImage:[UIImage imageNamed:@"speakers states3.png"] forState:UIControlStateSelected];
            
        }
        
    }
    //  ProgressBar.progress+=0.001;
    
    return  cell;
    
}

//	 To conform to the Human Interface Guidelines, selections should not be persistent --
//	 deselect the row after it has been selected.
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}

#pragma mark Application state management_____________
// Standard methods for managing application state.
- (void)didReceiveMemoryWarning {
    
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



@end
