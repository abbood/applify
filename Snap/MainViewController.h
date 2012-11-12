#import "UIFont+SnapAdditions.h"
#import "HostViewController.h"
#import "JoinViewController.h"
#import "GameViewController.h"
#import "Simple_PlayerViewController.h"
@interface MainViewController : UIViewController <HostViewControllerDelegate, JoinViewControllerDelegate, GameViewControllerDelegate, Simple_PlayerViewControllerDelegate>
{
    IBOutlet UIImageView *spinner;
}

@property (nonatomic, strong) Timer * timer;

@property (nonatomic,retain)GameViewController *gamecontroller;


@end
