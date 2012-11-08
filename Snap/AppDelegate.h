
@class MainViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
-(void)recevierController;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainViewController *viewController;
@property(nonatomic,readonly,retain) UINavigationController  *viewController2;

@property (nonatomic,retain)UINavigationController *navController;
@end

