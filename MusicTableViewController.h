
#import <MediaPlayer/MediaPlayer.h>

@protocol MusicTableViewControllerDelegate; // forward declaration


@interface MusicTableViewController : UIViewController <MPMediaPickerControllerDelegate, UITableViewDelegate,UITableViewDataSource> {
    
	__weak id <MusicTableViewControllerDelegate>	delegate;
	IBOutlet UITableView					*mediaItemCollectionTable;
	IBOutlet UIBarButtonItem				*addMusicButton;
    
    
}

@property (weak) id <MusicTableViewControllerDelegate>	delegate;
@property (nonatomic, retain) UITableView							*mediaItemCollectionTable;
@property (nonatomic, retain) UIBarButtonItem						*addMusicButton;
@property (nonatomic,retain) IBOutlet UISearchBar *searchbar;
@property (nonatomic,retain)NSMutableArray *cellarray;


- (IBAction) showMediaPicker: (id) sender;
- (IBAction) doneShowingMusicList: (id) sender;

@end



@protocol MusicTableViewControllerDelegate

// implemented in MainViewController.m
- (void) musicTableViewControllerDidFinish: (MusicTableViewController *) controller;
- (void) updatePlayerQueueWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection;

@end

