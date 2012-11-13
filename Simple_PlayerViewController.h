//
//  Simple_PlayerViewController.h
//  testMPMedialtemCollection
//
//  Created by Mohammed on 11/7/12.
//  Copyright (c) 2012 Mohammed. All rights reserved.
//



#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "HostViewController.h"

@class MainViewController;
@class HostViewController;
@protocol Simple_PlayerViewControllerDelegate <NSObject>



@end

@interface Simple_PlayerViewController : UIViewController <MPMediaPickerControllerDelegate, UITableViewDelegate, UITableViewDataSource,UISearchDisplayDelegate,UISearchBarDelegate> {
    UITextField *titleSearch;
    UIButton    *playPauseButton;
    UITableView *tableView;
    
    MPMusicPlayerController *player;
    MPMediaItemCollection   *collection;
    MPMediaItem             *nowPlaying;
    BOOL                    collectionModified;
    NSTimeInterval          pressStarted;
    
    
    NSArray *allItems;
    NSArray *searchResults;
    
    
    NSArray			*listContent;			// The master content.
    NSMutableArray	*filteredListContent;	// The content filtered as a result of a
    NSString		*savedSearchTerm;
    NSInteger		savedScopeButtonIndex;
    BOOL			searchWasActive;
    UISearchDisplayController *aSearchDisplayController;
    UISearchBar *searchbar2;
    
}


@property (nonatomic,copy)NSMutableArray *allItems;
@property (nonatomic,copy)NSArray *searchResults;


@property (nonatomic, retain) IBOutlet UITextField *titleSearch;
@property (nonatomic, retain) IBOutlet UIButton *playPauseButton;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *cellarray;
@property (nonatomic, retain) MPMusicPlayerController *player;
@property (nonatomic, retain) MPMediaItemCollection *collection;
@property (nonatomic, retain) MPMediaItem *nowPlaying;


@property (nonatomic, retain) NSArray *listContent;
@property (nonatomic, retain) NSMutableArray *filteredListContent;
@property (nonatomic, retain) IBOutlet UISearchDisplayController *aSearchDisplayController;
@property (nonatomic, retain) IBOutlet UISearchBar *searchbar2;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;
@property (nonatomic)BOOL collectionModified;
@property (nonatomic, weak) id <Simple_PlayerViewControllerDelegate> delegate;
@property (nonatomic,retain)MainViewController *mainview;
@property (nonatomic, strong) HostViewController *hostViewController;



+(id)sharedManager;
- (IBAction)doTitleSearch;
- (IBAction)showMediaPicker;
- (IBAction)backgroundClick;

- (IBAction)seekBackward;
- (IBAction)previousTrack;
- (IBAction)seekForward;
- (IBAction)nextTrack;
- (IBAction)playOrPause;
-(IBAction)changeViewHost:(id)sender;
- (void)removeTrack:(NSUInteger)sender;
-(void)playOrPauseAtindex:(NSUInteger)sender;
- (void)nowPlayingItemChanged:(NSNotification *)notification;
@end

