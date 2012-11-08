//
//  Simple_PlayerViewController.h
//  testMPMedialtemCollection
//
//  Created by Mohammed on 11/7/12.
//  Copyright (c) 2012 Mohammed. All rights reserved.
//



#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface Simple_PlayerViewController : UIViewController <MPMediaPickerControllerDelegate, UITableViewDelegate, UITableViewDataSource,UISearchDisplayDelegate,UISearchBarDelegate> {
    UITextField *titleSearch;
    UIButton    *playPauseButton;
    UITableView *tableView;
    
    MPMusicPlayerController *player;
    MPMediaItemCollection   *collection;
    MPMediaItem             *nowPlaying;
    BOOL                    collectionModified;
    NSTimeInterval          pressStarted;
    
    UISearchDisplayController *searchDisplayController;
    UISearchDisplayController *searchBar;
    NSArray *allItems;
    NSArray *searchResults;
    
}
@property (nonatomic,retain)IBOutlet UISearchDisplayController *searchDisplayController;
@property (nonatomic,retain)IBOutlet UISearchDisplayController *searchBar;
@property (nonatomic,copy)NSMutableArray *allItems;
@property (nonatomic,copy)NSArray *searchResults;


@property (nonatomic, retain) IBOutlet UITextField *titleSearch;
@property (nonatomic, retain) IBOutlet UIButton *playPauseButton;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) MPMusicPlayerController *player;
@property (nonatomic, retain) MPMediaItemCollection *collection;
@property (nonatomic, retain) MPMediaItem *nowPlaying;

- (IBAction)doTitleSearch;
- (IBAction)showMediaPicker;
- (IBAction)backgroundClick;

- (IBAction)seekBackward;
- (IBAction)previousTrack;
- (IBAction)seekForward;
- (IBAction)nextTrack;
- (IBAction)playOrPause;
- (IBAction)removeTrack:(id)sender;

- (void)nowPlayingItemChanged:(NSNotification *)notification;
@end

