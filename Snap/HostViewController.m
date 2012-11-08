//
//  HostViewController.m
//  Snap
//
//  Created by Ray Wenderlich on 5/24/12.
//  Copyright (c) 2012 Hollance. All rights reserved.
//

#import "HostViewController.h"
#import "UIButton+SnapAdditions.h"
#import "UIFont+SnapAdditions.h"
#import "PeerCell.h"
#import "MainViewController.h"
#import "TestTableCell.h"

@interface HostViewController ()
@property (nonatomic, weak) IBOutlet UILabel *headingLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *startButton;
@property (nonatomic, weak) IBOutlet UIButton *broadcastMusicButton;

@property (nonatomic,retain) UIButton *Plus;
@property (nonatomic,retain) UIButton *List;
@property (nonatomic,retain) UIButton *Speaker;
//
@property (nonatomic,retain) UITableView *Table;
@end

@implementation HostViewController
{
	MatchmakingServer *_matchmakingServer;
    QuitReason _quitReason;
}

@synthesize headingLabel = _headingLabel;
@synthesize nameLabel = _nameLabel;
@synthesize nameTextField = _nameTextField;
@synthesize statusLabel = _statusLabel;
@synthesize tableView = _tableView;
@synthesize startButton = _startButton;
@synthesize broadcastMusicButton = _broadcastMusicButton;
@synthesize delegate = _delegate;

@synthesize userMediaItemCollection;
@synthesize playedMusicOnce;			// A flag indicating if the user has played iPod library music at least one time
//		since application launch.
@synthesize musicPlayer;				// the music player, which plays media items from the iPod library

@synthesize timer;
@synthesize Plus;
@synthesize List;
@synthesize cellarray;
@synthesize Table;
@synthesize Play;
@synthesize Pre;
@synthesize Next;
@synthesize Volume;
@synthesize listData;
@synthesize SongImage;
@synthesize SongName;
@synthesize AlbumName;
@synthesize SongDuration;
@synthesize ProgressBar;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    [self setupApplicationAudio];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.nameTextField action:@selector(resignFirstResponder)];
	gestureRecognizer.cancelsTouchesInView = NO;
	[self.view addGestureRecognizer:gestureRecognizer];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    
	if (_matchmakingServer == nil)
	{
		_matchmakingServer = [[MatchmakingServer alloc] init];
		_matchmakingServer.maxClients = 3;
        _matchmakingServer.delegate = self;
		[_matchmakingServer startAcceptingConnectionsForSessionID:SESSION_ID];
        [self.tableView reloadData];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return FALSE;
}

- (IBAction)startAction:(id)sender
{
    NSLog(@"----------------------------\n");
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
	if (_matchmakingServer != nil && [_matchmakingServer connectedClientCount] > 0)
	{
		NSString *name = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if ([name length] == 0)
			name = _matchmakingServer.session.displayName;
        
		[_matchmakingServer stopAcceptingConnections];
        
		[self.delegate hostViewController:self
                     startGameWithSession:_matchmakingServer.session
                               playerName:name
                                  clients:_matchmakingServer.connectedClients
         ];
	}
}






- (IBAction)exitAction:(id)sender
{
	_quitReason = QuitReasonUserQuit;
	[_matchmakingServer endSession];
	[self.delegate hostViewControllerDidCancel:self];
}


#pragma mark Music control________________________________

- (IBAction)addMusic:(id)sender
{
    // if the user has already chosen some music, display that list
	if (userMediaItemCollection) {
        MusicTableViewController *controller = [[MusicTableViewController alloc] initWithNibName: @"MusicTableView" bundle: nil];
        controller.delegate = self;
        
        controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController: controller animated: YES];
        // else, if no music is chosen yet, display the media item picker
	} else {
		MPMediaPickerController *picker =
        [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
		
		picker.delegate						= self;
		picker.allowsPickingMultipleItems	= YES;
		picker.prompt						= NSLocalizedString (@"Add songs to play", "Prompt in media item picker");
		
		// The media item picker uses the default UI style, so it needs a default-style
		//		status bar to match it visually
		[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault animated: YES];
		
		[self presentModalViewController: picker animated: YES];
	}
}

// Invoked by the delegate of the media item picker when the user is finished picking music.
//		The delegate is either this class or the table view controller, depending on the
//		state of the application.
- (void) updatePlayerQueueWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection {
    
	// Configure the music player, but only if the user chose at least one song to play
	if (mediaItemCollection) {
        
		// If there's no playback queue yet...
		if (userMediaItemCollection == nil) {
			// apply the new media item collection as a playback queue for the music player
			[self setUserMediaItemCollection: mediaItemCollection];
            
			[musicPlayer setQueueWithItemCollection: userMediaItemCollection];
			[self setPlayedMusicOnce: YES];
            //	[musicPlayer play];
            
            // Obtain the music player's state so it can then be
            //		restored after updating the playback queue.
		} else {
            
			// Take note of whether or not the music player is playing. If it is
			//		it needs to be started again at the end of this method.
			BOOL wasPlaying = NO;
			if (musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
				wasPlaying = YES;
			}
			
			// Save the now-playing item and its current playback time.
			MPMediaItem *nowPlayingItem			= musicPlayer.nowPlayingItem;
			NSTimeInterval currentPlaybackTime	= musicPlayer.currentPlaybackTime;
            
			// Combine the previously-existing media item collection with the new one
			NSMutableArray *combinedMediaItems	= [[userMediaItemCollection items] mutableCopy];
			NSArray *newMediaItems				= [mediaItemCollection items];
			[combinedMediaItems addObjectsFromArray: newMediaItems];
			
			[self setUserMediaItemCollection: [MPMediaItemCollection collectionWithItems: (NSArray *) combinedMediaItems]];
            
            
			// Apply the new media item collection as a playback queue for the music player.
			[musicPlayer setQueueWithItemCollection: userMediaItemCollection];
			
			// Restore the now-playing item and its current playback time.
			musicPlayer.nowPlayingItem			= nowPlayingItem;
			musicPlayer.currentPlaybackTime		= currentPlaybackTime;
			
			// If the music player was playing, get it playing again.
			if (wasPlaying) {
				[musicPlayer play];
			}
		}
        /*
         // Finally, because the music player now has a playback queue, ensure that
         //		the music play/pause button in the Navigation bar is enabled.
         navigationBar.topItem.leftBarButtonItem.enabled = YES;
         
         [addOrShowMusicButton	setTitle: NSLocalizedString (@"Show Music", @"Alternate title for 'Add Music' button, after user has chosen some music")
         forState: UIControlStateNormal];*/
	}
}

// If the music player was paused, leave it paused. If it was playing, it will continue to
//		play on its own. The music player state is "stopped" only if the previous list of songs
//		had finished or if this is the first time the user has chosen songs after app
//		launch--in which case, invoke play.
- (void) restorePlaybackState {
    
	if (musicPlayer.playbackState == MPMusicPlaybackStateStopped && userMediaItemCollection) {
        
        /*	[addOrShowMusicButton	setTitle: NSLocalizedString (@"Show Music", @"Alternate title for 'Add Music' button, after user has chosen some music")
         forState: UIControlStateNormal];*/
		
		if (playedMusicOnce == NO) {
            
			[self setPlayedMusicOnce: YES];
			[musicPlayer play];
		}
	}
    
}



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (_matchmakingServer != nil)
		return [_matchmakingServer connectedClientCount];
	else
		return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    UIImage *myImage=[UIImage imageNamed:@"HeaderBackground.png"];
    UIImageView *imageView=[[UIImageView alloc]initWithImage:myImage];
    imageView.frame=CGRectMake(0,0,tableView.frame.size.width, 30);
    
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    detailLabel.backgroundColor = [UIColor clearColor];
    detailLabel.textColor = [UIColor whiteColor];
    detailLabel.text = @"Connect To Speakers...";
    detailLabel.font = [UIFont systemFontOfSize:16];
    detailLabel.frame = CGRectMake(10,2,230,30);
    
    UIActivityIndicatorView *indicatorView=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicatorView.frame=CGRectMake(tableView.frame.size.width-30, 0, 3, 30);
    [headerView addSubview:imageView];
    [headerView addSubview:detailLabel];
    [headerView addSubview:indicatorView];
    [indicatorView startAnimating];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    TestTableCell *cell=[tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%d",indexPath.row]];
    
    if (cell==nil)
    {
        cell = [[TestTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%d",indexPath.row]];
        
        NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"TestTableCell" owner:nil options:nil];
        
        for (UIView *view in views)
        {
            if([view isKindOfClass:[TestTableCell class]])
            {
                cell = (TestTableCell*)view;
            }
        }
        
        cell.row=(int*)indexPath.row;
        NSString *peerID = [_matchmakingServer peerIDForConnectedClientAtIndex:indexPath.row];
        cell.PhoneName.text =  [_matchmakingServer displayNameForPeerID:peerID];
        
        
        if ([self.cellarray objectAtIndex:indexPath.row ]!= @"c")
        {
            
            [cell.Speaker setImage:[UIImage imageNamed:@"speakers states2.png"] forState:UIControlStateNormal];
            
        }
        
        else
        {
            [cell.Speaker setSelected:YES];
            UIImage *myGradient = [UIImage imageNamed:@"Gradient.png"];
            cell.PhoneName.textColor = [UIColor colorWithPatternImage:myGradient];
            [cell.Speaker setImage:[UIImage imageNamed:@"speakers states3.png"] forState:UIControlStateSelected];
            
        }
        
    }
    ProgressBar.progress+=0.001;
    
    return  cell;
}

#pragma mark - UITableViewDelegate

//- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	return YES;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *peerID2 = [_matchmakingServer peerIDForConnectedClientAtIndex:indexPath.row];
    NSLog(@"PeerID2 :%@",peerID2);
    //    Packet *packet=[[Packet alloc]initWithType:PacketTypeChangeView];
    //
    //    Game *game=[[Game alloc]init];
    //    [game sendPacketToClient:packet peerID:peerID2];
    NSError *error;
    Packet *packet = [Packet packetWithType:PacketTypeChangeView];
    NSData *data = [packet data];
    if (![_matchmakingServer.session sendData:data
                                      toPeers:[NSArray arrayWithObject:peerID2]
                                 withDataMode:GKSendDataUnreliable
                                        error:&error]) {
        NSLog(@"Error sending data to clients: %@", error);
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return NO;
}

#pragma mark - MatchmakingServerDelegate

- (void)matchmakingServer:(MatchmakingServer *)server clientDidConnect:(NSString *)peerID
{
    
	[self.tableView reloadData];
}

- (void)matchmakingServer:(MatchmakingServer *)server clientDidDisconnect:(NSString *)peerID
{
	[self.tableView reloadData];
}

- (void)matchmakingServerSessionDidEnd:(MatchmakingServer *)server
{
	_matchmakingServer.delegate = nil;
	_matchmakingServer = nil;
	[self.tableView reloadData];
	[self.delegate hostViewController:self didEndSessionWithReason:_quitReason];
}

- (void)matchmakingServerNoNetwork:(MatchmakingServer *)session
{
	_quitReason = QuitReasonNoNetwork;
}

- (void)dealloc
{
#ifdef DEBUG
	NSLog(@"dealloc %@", self);
#endif
}

#pragma mark Media item picker delegate methods________

// Invoked when the user taps the Done button in the media item picker after having chosen
//		one or more media items to play.
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection {
    
	// Dismiss the media item picker.
	[self dismissModalViewControllerAnimated: YES];
	
	// Apply the chosen songs to the music player's queue.
	[self updatePlayerQueueWithMediaCollection: mediaItemCollection];
    
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated: YES];
}

// Invoked when the user taps the Done button in the media item picker having chosen zero
//		media items to play
- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {
    
	[self dismissModalViewControllerAnimated: YES];
	
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated: YES];
}

#pragma mark Table view delegate methods________________

// Invoked when the user taps the Done button in the table view.
- (void) musicTableViewControllerDidFinish: (MusicTableViewController *) controller {
	
	[self dismissModalViewControllerAnimated: YES];
	[self restorePlaybackState];
}

#pragma mark Application setup____________________________

#if TARGET_IPHONE_SIMULATOR
#warning *** Simulator mode: iPod library access works only when running on a device.
#endif

- (void) setupApplicationAudio {
	
	// Gets the file system path to the sound to play.
    //	NSString *soundFilePath = [[NSBundle mainBundle]	pathForResource:	@"sound"
    //                                                            ofType:				@"caf"];
    /*
     // Converts the sound's file path to an NSURL object
     NSURL *newURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
     self.soundFileURL = newURL;
     [newURL release];*/
    
	// Registers this class as the delegate of the audio session.
	[[AVAudioSession sharedInstance] setDelegate: self];
	
	// The AmbientSound category allows application audio to mix with Media Player
	// audio. The category also indicates that application audio should stop playing
	// if the Ring/Siilent switch is set to "silent" or the screen locks.
	[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: nil];
    /*
     // Use this code instead to allow the app sound to continue to play when the screen is locked.
     [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
     
     UInt32 doSetProperty = 0;
     AudioSessionSetProperty (
     kAudioSessionProperty_OverrideCategoryMixWithOthers,
     sizeof (doSetProperty),
     &doSetProperty
     );
     */
    
	// Registers the audio route change listener callback function
    /*	AudioSessionAddPropertyListener (
     kAudioSessionProperty_AudioRouteChange,
     audioRouteChangeListenerCallback,
     self
     );
     */
	// Activates the audio session.
	
	NSError *activationError = nil;
	[[AVAudioSession sharedInstance] setActive: YES error: &activationError];
    /*
     // Instantiates the AVAudioPlayer object, initializing it with the sound
     AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: soundFileURL error: nil];
     self.appSoundPlayer = newPlayer;
     [newPlayer release];
     
     // "Preparing to play" attaches to the audio hardware and ensures that playback
     //		starts quickly when the user taps Play
     [appSoundPlayer prepareToPlay];
     [appSoundPlayer setVolume: 1.0];
     [appSoundPlayer setDelegate: self];*/
    
    
    // Instantiate the music player. If you specied the iPod music player in the Settings app,
	//		honor the current state of the built-in iPod app.
	if ([self useiPodPlayer]) {
        
		[self setMusicPlayer: [MPMusicPlayerController iPodMusicPlayer]];
		
		if ([musicPlayer nowPlayingItem]) {
            
            //	navigationBar.topItem.leftBarButtonItem.enabled = YES;
			
			// Update the UI to reflect the now-playing item.
            //	[self handle_NowPlayingItemChanged: nil];
			
            //	if ([musicPlayer playbackState] == MPMusicPlaybackStatePaused) {
            //		navigationBar.topItem.leftBarButtonItem = playBarButton;
            //	}
		}
		
	} else {
        
		[self setMusicPlayer: [MPMusicPlayerController applicationMusicPlayer]];
		
		// By default, an application music player takes on the shuffle and repeat modes
		//		of the built-in iPod app. Here they are both turned off.
		[musicPlayer setShuffleMode: MPMusicShuffleModeOff];
		[musicPlayer setRepeatMode: MPMusicRepeatModeNone];
	}
    
}

// To learn about the Settings bundle and user preferences, see User Defaults Programming Topics
//		for Cocoa and "The Settings Bundle" in iPhone Application Programming Guide

// Returns whether or not to use the iPod music player instead of the application music player.
- (BOOL) useiPodPlayer {
    
    //	if ([[NSUserDefaults standardUserDefaults] boolForKey: PLAYER_TYPE_PREF_KEY]) {
    return YES;		
    //	} else {
    //		return NO;
    //	}		
}


@end