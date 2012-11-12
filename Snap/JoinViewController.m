
#import "JoinViewController.h"
#import "PeerCell.h"
#import "UIFont+SnapAdditions.h"
#import "AnimatedGif.h"
#import "TestTableCell.h"
#import "MainViewController.h"
#import "ReciverViewController.h"
#import "Game.h"

@interface JoinViewController ()
{
    IBOutlet UIButton *Plus;
    IBOutlet UIButton *List;
    IBOutlet UITableView *Table;
    
    
}
@property (nonatomic, weak) IBOutlet UILabel *headingLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
//
@property (nonatomic,retain) UIButton *Plus;
@property (nonatomic,retain) UIButton *List;
@property (nonatomic,retain) UIButton *Speaker;
//
@property (nonatomic,retain) UITableView *Table;
@property (nonatomic, strong) IBOutlet UIView *waitView;
@property (nonatomic, strong) IBOutlet UIView *testView;
@property (nonatomic, weak) IBOutlet UILabel *waitLabel;


@end

@implementation JoinViewController
{
	MatchmakingClient *_matchmakingClient;
	QuitReason _quitReason;
}

@synthesize btn = _btn;
@synthesize delegate = _delegate;
@synthesize headingLabel = _headingLabel;
@synthesize nameLabel = _nameLabel;
@synthesize nameTextField = _nameTextField;
@synthesize statusLabel = _statusLabel;
@synthesize tableView = _tableView;
@synthesize waitView = _waitView;
@synthesize testView;
@synthesize waitLabel = _waitLabel;
@synthesize timer;
@synthesize Speaker;
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

+(id)sharedManager
{
    
    static JoinViewController *sharedclass1=nil;
    if (!sharedclass1)
    {
        sharedclass1=[[super allocWithZone:nil]init];
        sharedclass1.cellarray=[[NSMutableArray alloc]init];
        
    }
    return sharedclass1;
    
}

+(id)allocWithZone:(NSZone *)zone
{
    return [self sharedManager];
}

-(IBAction)Playtouched:(id)sender
{
    
    if ([sender isSelected])
    {
        [sender setImage:[UIImage imageNamed:@"player-navigation-states-play-touched.png"] forState:UIControlStateNormal];
        [sender setSelected:NO];
        UIImage *myGradient = [UIImage imageNamed:@"Gradient.png"];
        self.ProgressBar.backgroundColor   = [UIColor colorWithPatternImage:myGradient];
        
        [timer invalidate];
        timer=nil;
        
    }
    else {
        [sender setImage:[UIImage imageNamed:@"player-navigation-states-pause-touched.png"]forState:UIControlStateSelected];
        [sender
         setSelected:YES];
        UIImage *myGradient = [UIImage imageNamed:@"Gradient.png"];
        self.ProgressBar.backgroundColor   = [UIColor colorWithPatternImage:myGradient];
        
        
        timer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgressBar) userInfo:nil repeats:YES];
        
    }
    
    
    
    
}
-(void)recevierView
{
    
    JoinViewController *controller = [[JoinViewController alloc] initWithNibName:@"JoinViewController" bundle:nil];
    controller.delegate = self;
    
    [self presentViewController:controller animated:NO completion:nil];
}
-(IBAction)Plustouched:(id)sender
{
    if ([sender isSelected])
    {
        [sender setImage:[UIImage imageNamed:@"Plus states1.png"] forState:UIControlStateNormal];
        [sender setSelected:NO];
        
    }
    else
    {
        [sender setImage:[UIImage imageNamed:@"Plus states2.png"]forState:UIControlStateSelected];
        [sender
         setSelected:YES];
        MusicTableViewController *newEnterNameController = [[MusicTableViewController alloc] initWithNibName:@"MusicTableViewController" bundle:[NSBundle mainBundle]];
        [[self navigationController] pushViewController:newEnterNameController animated:YES];
    }
    
}
-(void)changeview
{
    MusicTableViewController *newEnterNameController = [[MusicTableViewController alloc] initWithNibName:@"MusicTableViewController" bundle:[NSBundle mainBundle]];
    [[self navigationController] pushViewController:newEnterNameController animated:YES];
    
}
-(IBAction)Listtouched:(id)sender
{
    if ([sender isSelected])
    {
        [sender setImage:[UIImage imageNamed:@"list states1.png"] forState:UIControlStateNormal];
        [sender setSelected:NO];
        
    }
    else
    {
        MusicTableViewController *newEnterNameController = [[MusicTableViewController alloc] initWithNibName:@"MusicTableViewController" bundle:[NSBundle mainBundle]];
        [[self navigationController] pushViewController:newEnterNameController animated:YES];
        
        [sender setImage:[UIImage imageNamed:@"list states2.png"]forState:UIControlStateSelected];
        [sender
         setSelected:YES];
    }
    
}

-(IBAction)Pretouched:(id)sender
{
    if ([sender isSelected])
    {
        [sender setImage:[UIImage imageNamed:@"Back.png"] forState:UIControlStateNormal];
        [sender setSelected:NO];
        
    }
    else
    {
        
        
        [sender setImage:[UIImage imageNamed:@"player-navigation-states-previous-touched.png"]forState:UIControlStateSelected];
        [sender
         setSelected:YES];
    }
    
    
}
-(IBAction)Nexttouched:(id)sender
{
    
    if ([sender isSelected])
    {
        [sender setImage:[UIImage imageNamed:@"next.png"] forState:UIControlStateNormal];
        [sender setSelected:NO];
        
    }
    else
    {
        [Pre setImage:[UIImage imageNamed:@"Back.png"] forState:UIControlStateNormal];
        [Play setImage:[UIImage imageNamed:@"player-navigation-states-pause-touched.png"] forState:UIControlStateNormal];
        
        [sender setImage:[UIImage imageNamed:@"player-navigation-states-next-touched.png"]forState:UIControlStateSelected];
        [sender
         setSelected:YES];
    }
    
}

-(IBAction)Volumetouched:(id)sender
{
    if ([sender isSelected])
    {
        [sender setImage:[UIImage imageNamed:@"player-navigation-states-speaker-touched.png"] forState:UIControlStateNormal];
        [sender setSelected:NO];
        
    }
    else
    {
        [sender setImage:[UIImage imageNamed:@"player-navigation-states-speaker-active-touched.png"]forState:UIControlStateSelected];
        [sender
         setSelected:YES];
    }
    
    
}

//- (void)dealloc
//{
//	#ifdef DEBUG
//	NSLog(@"dealloc %@", self);
//	#endif
//}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    NSOperationQueue *queue=[NSOperationQueue new];
    
    NSInvocationOperation *operation=[[NSInvocationOperation alloc]initWithTarget:self
                                                                         selector:@selector(MainGui)
                                                                           object:nil];
    [queue addOperation:operation];
    
    NSInvocationOperation *operation2=[[NSInvocationOperation alloc]initWithTarget:self
                                                                          selector:@selector(callavaiablserver)
                                                                            object:nil];
    [queue addOperation:operation2];
    
    NSURL* firstUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                              pathForResource:@"loading-spinner"
                                              ofType:@"gif"]];
    
    UIImageView * firstAnimation = [AnimatedGif getAnimationForGifAtUrl: firstUrl];
    [spinner addSubview:firstAnimation];
    Game *game=[[Game alloc]init];
    game.joinviewcontroller=self;
    
}

- (void)viewDidUnload
{
    [self setBtn:nil];
	[super viewDidUnload];
	self.waitView = nil;
    
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    NSLog(@"%@", [NSThread callStackSymbols]);
	if (_matchmakingClient == nil)
	{
		_quitReason = QuitReasonConnectionDropped;
        //[self performSelector:@selector( MainGui) withObject:nil afterDelay:10];
		_matchmakingClient = [[MatchmakingClient alloc] init];
		_matchmakingClient.delegate = self;
		[_matchmakingClient startSearchingForServersWithSessionID:SESSION_ID];
        NSLog(@"avaliable server count:%d",[_matchmakingClient availableServerCount]);
		self.nameTextField.placeholder = _matchmakingClient.session.displayName;
		[self.tableView reloadData];        
	}
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return FALSE;
}

- (IBAction)exitAction:(id)sender
{
	_quitReason = QuitReasonUserQuit;
	[_matchmakingClient disconnectFromServer];
	[self.delegate joinViewControllerDidCancel:self];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (_matchmakingClient != nil)
    {
        for (NSInteger i = 0; i < [_matchmakingClient availableServerCount]; ++i)
        {
            [self.cellarray addObject :@"nc"];
        }
        return [_matchmakingClient availableServerCount];
    }
    
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
    self.Table.separatorColor=[UIColor lightGrayColor];
    [headerView addSubview:imageView];
    [headerView addSubview:detailLabel];
    [headerView addSubview:indicatorView];
    [indicatorView startAnimating];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifer=@"LabelCell";
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
        [cell.Speaker setHidden:YES];
        [cell.Pending setHidden:NO];
        cell.userInteractionEnabled = NO;

        NSString *peerID = [_matchmakingClient peerIDForAvailableServerAtIndex:indexPath.row];
        cell.PhoneName.text = [_matchmakingClient displayNameForPeerID:peerID];
        
		[_matchmakingClient connectToServerWithPeerID:peerID];
        
        if ([self.cellarray objectAtIndex:indexPath.row ]!= @"c")
        {
            
            
            [cell.Speaker setImage:[UIImage imageNamed:@"speakers states2.png"] forState:UIControlStateNormal];
            
            
        }
        
        else {
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

/*- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
	/*if (_matchmakingClient != nil)
	{
		NSString *peerID = [_matchmakingClient peerIDForAvailableServerAtIndex:indexPath.row];
		[_matchmakingClient connectToServerWithPeerID:peerID];
        
        
        
        
	}
}
*/
#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return NO;
}

#pragma mark - MatchmakingClientDelegate

- (void)matchmakingClient:(MatchmakingClient *)client serverBecameAvailable:(NSString *)peerID
{
	[self.tableView reloadData];
}

- (void)matchmakingClient:(MatchmakingClient *)client serverBecameUnavailable:(NSString *)peerID
{
	[self.tableView reloadData];
}

- (void)matchmakingClient:(MatchmakingClient *)client didConnectToServer:(NSString *)peerID
{
	NSString *name = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([name length] == 0)
		name = _matchmakingClient.session.displayName;
    
    [self.delegate joinViewController:self startGameWithSession:_matchmakingClient.session playerName:name server:peerID];
    
    
    
}

- (void)matchmakingClient:(MatchmakingClient *)client didDisconnectFromServer:(NSString *)peerID
{
	_matchmakingClient.delegate = nil;
	_matchmakingClient = nil;
	[self.tableView reloadData];
	[self.delegate joinViewController:self didDisconnectWithReason:_quitReason];
}

- (void)matchmakingClientNoNetwork:(MatchmakingClient *)client
{
	_quitReason = QuitReasonNoNetwork;
}
-(NSInteger)callavaiablserver
{
    return [_matchmakingClient availableServerCount];
}
int counter=100;
bool isFound=FALSE;
int fserverCount=0;
-(void)MainGui
{
    NSLog(@"%@", [NSThread callStackSymbols]);
    while (counter!=0 && fserverCount==0)
    {
        //spinner image
        spinner.hidden=false;
        //start search && chech the server count;
        
        fserverCount=[_matchmakingClient availableServerCount];
        NSLog(@"Number of peers:%d",fserverCount);
        if (counter==1)
        {
            NSLog(@"timer =0");
            //hide spinner
            [spinner setHidden:YES];
            //alert view error message
            alert = [[UIAlertView alloc] initWithTitle:nil
                                               message:@"No device found \n Make sure bluetooth is activated and the devices are within range."
                                              delegate:self
                                     cancelButtonTitle:@"Tap to retry"
                                     otherButtonTitles:@"Host",nil];
            
            
            [alert show];
            return;            
            
        }
        counter--;
        NSLog(@"%d\n",counter);
    }
    [self.view addSubview:self.waitView];
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex

{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Tap to retry"])
    {
        counter=5;
        [spinner setHidden:FALSE];
        [self performSelector:@selector( MainGui) withObject:nil afterDelay:1];
    }
    if ([title isEqualToString:@"Host"])
    {
        
        HostViewController *host=[[HostViewController alloc]initWithNibName:@"HostViewController" bundle:nil];
        host.delegate=self.mainview;
        host.mainview=self.mainview;
        [self presentViewController:host animated:YES completion:nil];
    }
}

@end
