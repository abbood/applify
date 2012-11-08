#import "UIFont+SnapAdditions.h"
#import "HostViewController.h"
#import "JoinViewController.h"
#import "GameViewController.h"

@interface MainViewController : UIViewController <HostViewControllerDelegate, JoinViewControllerDelegate, GameViewControllerDelegate>
{
    IBOutlet UIImageView *spinner;
}

@property (nonatomic, strong) Timer * timer;

@property (nonatomic,retain)GameViewController *gamecontroller;


@end
