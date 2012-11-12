//
//  HostViewController.h
//  Snap
//
//  Created by Ray Wenderlich on 5/24/12.
//  Copyright (c) 2012 Hollance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "MatchmakingServer.h"
#import "MusicTableViewController.h"
#import "TestTableCell.h"
#import "Game.h"

@class HostViewController;
@class Game;

@protocol HostViewControllerDelegate <NSObject>

- (void)hostViewControllerDidCancel:(HostViewController *)controller;
- (void)hostViewController:(HostViewController *)controller didEndSessionWithReason:(QuitReason)reason;
- (void)hostViewController:(HostViewController *)controller startGameWithSession:(GKSession *)session playerName:(NSString *)name clients:(NSArray *)clients;

- (void)hostViewController:(HostViewController *)controller broadcastMusicWithSession:(GKSession *)session playerName:(NSString *)name clients:(NSArray *)clients;
- (void)changeView_playList:(HostViewController *)self;

@end

@interface HostViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, MatchmakingServerDelegate, MPMediaPickerControllerDelegate, MusicTableViewControllerDelegate, AVAudioPlayerDelegate,UIAlertViewDelegate> {
    MPMediaItemCollection		*userMediaItemCollection;
  	MPMusicPlayerController		*musicPlayer;
    
}

@property (nonatomic, weak) id <HostViewControllerDelegate> delegate;
@property (nonatomic, retain)	MPMediaItemCollection	*userMediaItemCollection;
@property (readwrite)			BOOL					playedMusicOnce;
@property (nonatomic, retain)	MPMusicPlayerController	*musicPlayer;

@property (nonatomic,retain)NSArray *listData;
@property (nonatomic,retain)NSTimer *timer;
@property (nonatomic,retain)NSMutableArray *cellarray;
@property (nonatomic,retain)IBOutlet UIButton *Play;
@property (nonatomic,retain)IBOutlet UIButton *Next;
@property (nonatomic,retain)IBOutlet UIButton *Pre;
@property (nonatomic,retain)IBOutlet UIButton *Volume;
@property (nonatomic,retain)IBOutlet UIImage *SongImage;
@property (nonatomic,retain)IBOutlet UILabel *SongName;
@property (nonatomic,retain)IBOutlet UILabel *AlbumName;
@property (nonatomic,retain)IBOutlet UILabel *SongDuration;
@property(nonatomic,retain)IBOutlet UIProgressView *ProgressBar;
@property (nonatomic, strong)TestTableCell *cell;
@property (nonatomic, strong)Game *game;
@property (nonatomic,retain)MainViewController *mainview;
- (IBAction)startAction:(id)sender;
- (IBAction)addMusic:(id)sender;
- (IBAction)changeView_playList:(id)sender;

+(id)sharedManager;
-(IBAction)Playtouched:(id)sender;
-(IBAction)Nexttouched:(id)sender;
-(IBAction)Pretouched:(id)sender;
-(IBAction)Volumetouched:(id)sender;
-(IBAction)Plustouched:(id)sender;
-(IBAction)Listtouched:(id)sender;
-(IBAction)Speakertouched:(id)sender;
-(void)updateProgressBar;
-(void)pauseProgressBar;
-(void)changeview;
@end
