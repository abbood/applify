
#import "MainViewController.h"
#import "UIButton+SnapAdditions.h"
#import "Game.h"
#import "AnimatedGif.h"
#import "Simple_PlayerViewController.h"

@interface MainViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *sImageView;
@property (nonatomic, weak) IBOutlet UIImageView *nImageView;
@property (nonatomic, weak) IBOutlet UIImageView *aImageView;
@property (nonatomic, weak) IBOutlet UIImageView *pImageView;
@property (nonatomic, weak) IBOutlet UIImageView *jokerImageView;

@property (nonatomic, weak) IBOutlet UIButton *hostGameButton;
@property (nonatomic, weak) IBOutlet UIButton *joinGameButton;
@property (nonatomic, weak) IBOutlet UIButton *singlePlayerGameButton;
@end

@implementation MainViewController
{
	BOOL _buttonsEnabled;
    BOOL _performAnimations;
}

@synthesize sImageView = _sImageView;
@synthesize nImageView = _nImageView;
@synthesize aImageView = _aImageView;
@synthesize pImageView = _pImageView;
@synthesize jokerImageView = _jokerImageView;

@synthesize hostGameButton = _hostGameButton;
@synthesize joinGameButton = _joinGameButton;
@synthesize singlePlayerGameButton = _singlePlayerGameButton;

@synthesize timer = _timer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		_performAnimations = YES;
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
	[self.hostGameButton rw_applySnapStyle];
	[self.joinGameButton rw_applySnapStyle];
	[self.singlePlayerGameButton rw_applySnapStyle];    
    NSURL* firstUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"loading-spinner" ofType:@"gif"]];
    UIImageView * firstAnimation = [AnimatedGif getAnimationForGifAtUrl: firstUrl];
    [spinner addSubview:firstAnimation];
        
}




- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"I AM MAIN VIEW AND I WILL APPEAR!");
	[super viewWillAppear:animated];
    
    JoinViewController *controller = [[JoinViewController alloc] initWithNibName:@"JoinViewController" bundle:nil];
    controller.delegate = self;
    controller.mainview=self;
    
    [self presentViewController:controller animated:NO completion:nil];
	
}

- (void)viewDidAppear:(BOOL)animated
{
    
	[super viewDidAppear:animated];
    
	if (_performAnimations)
		[self performIntroAnimation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return FALSE;
}

- (IBAction)hostGameAction:(id)sender
{
	if (_buttonsEnabled)
	{
		[self performExitAnimationWithCompletionBlock:^(BOOL finished)
         {	
             HostViewController *controller = [[HostViewController alloc] initWithNibName:@"HostViewController" bundle:nil];
             
            // [[self navigationController ]pushViewController:controller animated:YES];
             
             controller.delegate = self;
             
             [self presentViewController:controller animated:NO completion:nil];
         }];
	}
}

- (IBAction)joinGameAction:(id)sender
{
	if (_buttonsEnabled)
	{
		[self performExitAnimationWithCompletionBlock:^(BOOL finished)
         {
             JoinViewController *controller = [[JoinViewController alloc] initWithNibName:@"JoinViewController" bundle:nil];
             controller.delegate = self;
            [self presentViewController:controller animated:NO completion:nil];
         }];
	}
}

- (IBAction)singlePlayerGameAction:(id)sender
{
    if (_buttonsEnabled)
	{
		[self performExitAnimationWithCompletionBlock:^(BOOL finished)
         {
             GameViewController *controller = [[GameViewController alloc] initWithNibName:@"GameViewController" bundle:nil];
             controller.delegate = self;
             
             [self presentViewController:controller animated:NO completion:nil];
         }];
	}

}

- (void)prepareForIntroAnimation
{
	self.sImageView.hidden = YES;
	self.nImageView.hidden = YES;
	self.aImageView.hidden = YES;
	self.pImageView.hidden = YES;
	self.jokerImageView.hidden = YES;
    
    self.hostGameButton.alpha = 0.0f;
	self.joinGameButton.alpha = 0.0f;
	self.singlePlayerGameButton.alpha = 0.0f;
    
	_buttonsEnabled = NO;
}

- (void)performIntroAnimation
{
	self.sImageView.hidden = NO;
	self.nImageView.hidden = NO;
	self.aImageView.hidden = NO;
	self.pImageView.hidden = NO;
	self.jokerImageView.hidden = NO;
    
	CGPoint point = CGPointMake(self.view.bounds.size.width / 2.0f, self.view.bounds.size.height * 2.0f);
    
	self.sImageView.center = point;
	self.nImageView.center = point;
	self.aImageView.center = point;
	self.pImageView.center = point;
	self.jokerImageView.center = point;
    
	[UIView animateWithDuration:0.65f
                          delay:0.5f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         self.sImageView.center = CGPointMake(80.0f, 108.0f);
         self.sImageView.transform = CGAffineTransformMakeRotation(-0.22f);
         
         self.nImageView.center = CGPointMake(160.0f, 93.0f);
         self.nImageView.transform = CGAffineTransformMakeRotation(-0.1f);
         
         self.aImageView.center = CGPointMake(240.0f, 88.0f);
         
         self.pImageView.center = CGPointMake(320.0f, 93.0f);
         self.pImageView.transform = CGAffineTransformMakeRotation(0.1f);
         
         self.jokerImageView.center = CGPointMake(400.0f, 108.0f);
         self.jokerImageView.transform = CGAffineTransformMakeRotation(0.22f);
     }
                     completion:nil];
    
    [UIView animateWithDuration:0.5f
                          delay:1.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         self.hostGameButton.alpha = 1.0f;
         self.joinGameButton.alpha = 1.0f;
         self.singlePlayerGameButton.alpha = 1.0f;
     }
                     completion:^(BOOL finished)
     {
         _buttonsEnabled = YES;
     }];
    
}

- (void)performExitAnimationWithCompletionBlock:(void (^)(BOOL))block
{
	_buttonsEnabled = NO;
    
	[UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         self.sImageView.center = self.aImageView.center;
         self.sImageView.transform = self.aImageView.transform;
         
         self.nImageView.center = self.aImageView.center;
         self.nImageView.transform = self.aImageView.transform;
         
         self.pImageView.center = self.aImageView.center;
         self.pImageView.transform = self.aImageView.transform;
         
         self.jokerImageView.center = self.aImageView.center;
         self.jokerImageView.transform = self.aImageView.transform;
     }
                     completion:^(BOOL finished)
     {
         CGPoint point = CGPointMake(self.aImageView.center.x, self.view.frame.size.height * -2.0f);
         
         [UIView animateWithDuration:1.0f
                               delay:0.0f
                             options:UIViewAnimationOptionCurveEaseOut
                          animations:^
          {
              self.sImageView.center = point;
              self.nImageView.center = point;
              self.aImageView.center = point;
              self.pImageView.center = point;
              self.jokerImageView.center = point;
          }
                          completion:block];
         
         [UIView animateWithDuration:0.3f
                               delay:0.3f
                             options:UIViewAnimationOptionCurveEaseOut
                          animations:^
          {
              self.hostGameButton.alpha = 0.0f;
              self.joinGameButton.alpha = 0.0f;
              self.singlePlayerGameButton.alpha = 0.0f;
          }
                          completion:nil];
     }];
}

#pragma mark - HostViewControllerDelegate

- (void)hostViewControllerDidCancel:(HostViewController *)controller
{
	[self dismissViewControllerAnimated:NO completion:nil];
}

- (void)hostViewController:(HostViewController *)controller didEndSessionWithReason:(QuitReason)reason
{
	if (reason == QuitReasonNoNetwork)
	{
		[self showNoNetworkAlert];
	}
}


- (void)hostViewController:(HostViewController *)controller
      startGameWithSession:(GKSession *)session
                playerName:(NSString *)name
                   clients:(NSArray *)clients
{
    NSLog(@"----------------------------\n");
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);

    NSLog(@"hostViewController\n");
	_performAnimations = NO;
    
	//[self dismissViewControllerAnimated:NO completion:^
     //{
         _performAnimations = YES;
         
         [self startGameWithBlockhost:^(Game *game)
          {
               game.hostViewController=controller;
              [game setHostViewController:controller];
              [game startServerGameWithSession:session playerName:name clients:clients];
              // we need the controller to get the music files the user selected

          }];
};//];
//}

- (void)hostViewController:(HostViewController *)controller broadcastMusicWithSession:(GKSession *)session playerName:(NSString *)name clients:(NSArray *)clients;
{
    NSLog(@"----------------------------\n");
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);

    _performAnimations = NO;
    
	[self dismissViewControllerAnimated:NO completion:^
     {
         GameViewController *gameViewController = [[GameViewController alloc] initWithNibName:@"GameViewController" bundle:nil];
         gameViewController.delegate = self;
         
         [self presentViewController:gameViewController animated:NO completion:^
          {
              Game *game = [[Game alloc] init];
              gameViewController.game = game;
              game.delegate = gameViewController;              
              
              [game broadcastServerMusicWithSession:session playerName:name clients:clients];                                          
          }];     
     }];            
}

#pragma mark - JoinViewControllerDelegate

- (void)joinViewControllerDidCancel:(JoinViewController *)controller
{
	[self dismissViewControllerAnimated:NO completion:nil];
}

- (void)joinViewController:(JoinViewController *)controller didDisconnectWithReason:(QuitReason)reason
{
	if (reason == QuitReasonNoNetwork)
	{
		[self showNoNetworkAlert];
	}
	else if (reason == QuitReasonConnectionDropped)
	{
		[self dismissViewControllerAnimated:NO completion:^
         {
             [self showDisconnectedAlert];
         }];
	}
}

- (void)joinViewController:(JoinViewController *)controller startGameWithSession:(GKSession *)session playerName:(NSString *)name server:(NSString *)peerID
{
	_performAnimations = NO;
    
	//[self dismissViewControllerAnimated:NO completion:^
    {
         _performAnimations = YES;
         
         [self startGameWithBlock:^(Game *game)
          {
              [game startClientGameWithSession:session playerName:name server:peerID];
          }];
    };//];
}

#pragma mark - GameViewControllerDelegate

- (void)gameViewController:(GameViewController *)controller didQuitWithReason:(QuitReason)reason
{
	[self dismissViewControllerAnimated:NO completion:^
     {
         if (reason == QuitReasonConnectionDropped)
         {
             [self showDisconnectedAlert];
         }
     }];
}

- (void)gameViewController:(GameViewController *)controller switchToViewController:(UIViewController *)viewController
{
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - Alerts

- (void)showNoNetworkAlert
{
	UIAlertView *alertView = [[UIAlertView alloc] 
                              initWithTitle:NSLocalizedString(@"No Network", @"No network alert title")
                              message:NSLocalizedString(@"To use multiplayer, please enable Bluetooth or Wi-Fi in your device's Settings.", @"No network alert message")
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"Button: OK")
                              otherButtonTitles:nil];
    
	[alertView show];
}

- (void)showDisconnectedAlert
{
	UIAlertView *alertView = [[UIAlertView alloc] 
                              initWithTitle:NSLocalizedString(@"Disconnected", @"Client disconnected alert title")
                              message:NSLocalizedString(@"You were disconnected from the game.", @"Client disconnected alert message")
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"Button: OK")
                              otherButtonTitles:nil];
    
	[alertView show];
}

#pragma mark - Misc

- (void)startGameWithBlock:(void (^)(Game *))block
{
    NSLog(@"----------------------------\n");
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);

	GameViewController *gameViewController = [[GameViewController alloc] initWithNibName:@"GameViewController" bundle:nil];
	gameViewController.delegate = self;
    
    self.gamecontroller=gameViewController;
     [self presentViewController:self.gamecontroller animated:NO completion:nil];
	//[self presentViewController:gameViewController animated:NO completion:^
     {
         
         Game *game = [[Game alloc] init];
         gameViewController.game = game;
         game.delegate = gameViewController;
         block(game);
         
     };//];
}

- (void)startGameWithBlockhost:(void (^)(Game *))block
{
    NSLog(@"----------------------------\n");
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);

	GameViewController *gameViewController = [[GameViewController alloc] initWithNibName:@"GameViewController" bundle:nil];
    self.gamecontroller=gameViewController;
    
    gameViewController.delegate = self;
        {
          Game *game = [[Game alloc] init];
         gameViewController.game = game;
         game.delegate = gameViewController;
         block(game);
    };
   
}




#pragma mark - Delloc

- (void)dealloc
{
#ifdef DEBUG
	NSLog(@"dealloc %@", self);
#endif
}




@end
