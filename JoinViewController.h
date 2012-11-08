
#import "MatchmakingClient.h"
@class MainViewController;
@class JoinViewController;

@protocol JoinViewControllerDelegate <NSObject>

- (void)joinViewControllerDidCancel:(JoinViewController *)controller;
- (void)joinViewController:(JoinViewController *)controller didDisconnectWithReason:(QuitReason)reason;
- (void)joinViewController:(JoinViewController *)controller startGameWithSession:(GKSession *)session playerName:(NSString *)name server:(NSString *)peerID;

@end

@interface JoinViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, MatchmakingClientDelegate>
{
    IBOutlet UIImageView *spinner;
    UIAlertView *alert;
    
    //
    
    
}

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

@property (weak, nonatomic) IBOutlet UIButton *btn;

@property (nonatomic,retain)MainViewController *mainview;

@property (nonatomic, weak) id <JoinViewControllerDelegate> delegate;
-(IBAction)clickbtn:(id)sender;
-(void)recevierView;

//

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
