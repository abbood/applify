//
//  TestTableCell.m
//  TestController
//
//  Created by Lion User on 29/08/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestTableCell.h"
#import "JoinViewController.h"

#import"AppDelegate.h"
#import "MainViewController.h"
#import "ReciverViewController.h"
@interface TestTableCell()
{

}




@end

@implementation TestTableCell
@synthesize Speaker;
@synthesize PhoneName;
@synthesize row;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(IBAction)SpeakerTouched:(id)sender
{
    ReciverViewController *rec=[[ReciverViewController alloc] initWithNibName:@"ReciverViewController" bundle:nil];
    JoinViewController *join=[[JoinViewController alloc]init];
    [[join navigationController]pushViewController:rec animated:YES];
//    if ([sender isSelected])
//    {
//        [sender setImage:[UIImage imageNamed:@"speakers states2.png"] forState:UIControlStateNormal];
//        [sender setSelected:NO];
//        self.PhoneName.textColor   = [UIColor darkGrayColor];
//      
//       
//           }
//    else {
//        [sender setImage:[UIImage imageNamed:@"speakers states3.png"]forState:UIControlStateSelected]; 
//        [sender
//         setSelected:YES];
//        UIImage *myGradient = [UIImage imageNamed:@"Gradient.png"];
//        self.PhoneName.textColor   = [UIColor colorWithPatternImage:myGradient];
//        JoinViewController *table=[[JoinViewController alloc]init ];
//        //table.cellarray =[[NSMutableArray alloc]init];
//        
//        [table.cellarray replaceObjectAtIndex:self.row withObject:@"c"] ;
//        
//        _matchmakingClient = [[MatchmakingClient alloc] init];
//        
//        
//        if (_matchmakingClient != nil)
//        {
//            
//            NSString *peerID = [_matchmakingClient peerIDForAvailableServerAtIndex:self.row];
//            [_matchmakingClient connectToServerWithPeerID:peerID];
//            RecevierView *controller = [[RecevierView alloc] initWithNibName:@"RecevierView" bundle:nil];
//            
//            
//            
//            
//            RecevierView *newRecevierView = [[RecevierView alloc] initWithNibName:@"RecevierView" bundle:[NSBundle mainBundle]];
//            AppDelegate *myAppDelegate=[[UIApplication sharedApplication]delegate];
//            [myAppDelegate.viewController2 pushViewController:newRecevierView                               animated:YES];
//
//        }
//             
//            }

}

-(void)highlightRow
{
    [Speaker setImage:[UIImage imageNamed:@"speakers states3.png"]forState:UIControlStateSelected];
    [Speaker setSelected:YES];
    UIImage *myGradient = [UIImage imageNamed:@"Gradient.png"];
    self.PhoneName.textColor   = [UIColor colorWithPatternImage:myGradient];
    JoinViewController *table=[[JoinViewController alloc]init ];
       
    [table.cellarray replaceObjectAtIndex:self.row withObject:@"c"] ;
    
      
    
}
@end
