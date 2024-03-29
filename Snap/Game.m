//
//  Game.m
//  Snap
//
//  Created by Ray Wenderlich on 5/25/12.
//  Copyright (c) 2012 Hollance. All rights reserved.
//

#import "Game.h"
#import "Packet.h"
#import "AudioFile.h"
#import "PacketSignInResponse.h"
#import "PacketMusic.h"
#import "PacketAudioBuffer.h"
#import "NSData+SnapAdditions.h"
#import "AudioStreamer.h"
#import "PacketServerReady.h"
#import "PacketClientPrimed.h"
#import "PacketPlayMusicNow.h"
#import "PacketRecieved.h"
#import "PacketRingBufferGettingFull.h"

#import "ServerProfiler.h"
#import "ClientProfiler.h"



@implementation Game
{


    
	GKSession *_session;
	NSString *_serverPeerID;
	NSString *_localPlayerName;
    Player *_localPlayerObj;
    
    
    NSMutableDictionary *_players;
    AudioStreamBasicDescription _format;    
    
    
    UInt32 _bufferByteSize;
    UInt32 _numPacketsToRead;
    
    double _serverDelayTime;
    
    pthread_mutex_t broadCastMutex;			
    pthread_cond_t broadCastCondition;      
    
    NSTimer *sampleBroadcastTimer;
    NSString * assetOnAirID;
    AVAssetReaderTrackOutput *readerOutput;
    
    char * packet; 
    char * packetDescriptions;
    
    NSLock *broadcastLock;
    
}

@synthesize delegate = _delegate;
@synthesize isServer = _isServer;
@synthesize streamer;
@synthesize hostViewController;
@synthesize audioConverterSettings = _audioConverterSettings;

@synthesize queue;
@synthesize operations;
@synthesize operationsQueue;

@synthesize currentSong;

@synthesize broadCastState = _broadCastState;





//@synthesize player;


- (id)init
{
	if ((self = [super init]))
	{
		_players = [NSMutableDictionary dictionaryWithCapacity:4];
	}
	return self;
}

- (void)dealloc
{
     //NSLog(@"dealloc %@", self);
}

#pragma mark - Game Logic

- (void)startClientGameWithSession:(GKSession *)session playerName:(NSString *)name server:(NSString *)peerID
{
	self.isServer = NO;
    
	_session = session;
	_session.available = NO;
	_session.delegate = self;
	[_session setDataReceiveHandler:self withContext:nil];
    
	_serverPeerID = peerID;
	_localPlayerName = name;
    
	_state = GameStateWaitingForSignIn;
    
	[self.delegate gameWaitingForServerReady:self];
}

- (void)startServerGameWithSession:(GKSession *)session playerName:(NSString *)name clients:(NSArray *)clients
{
	self.isServer = YES;
    
	_session = session;
    // we are still available.. b/c clients can still connect
//	_session.available = NO;
	_session.delegate = self;
	[_session setDataReceiveHandler:self withContext:nil];    
    
	[self.delegate gameWaitingForClientsReady:self];
    
    // Create the Player object for the server.
    // this is the server element (note, in an ns immutable array there is no guaranteed ordering 
    // so we can't just assume the server is the first element.
	Player *player = [[Player alloc] init];                          
	player.name = name;
	player.peerID = _session.peerID;
	player.position = PlayerPositionBottom;
    player.isServer = true;          
    
	[_players setObject:player forKey:player.peerID];
    hostViewController.game = self;
    _state = GameStateWaitingForJoinResponse;
    
}

- (void)quitGameWithReason:(QuitReason)reason
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
    
	_state = GameStateQuitting;
    
	if (reason == QuitReasonUserQuit)
	{
		if (self.isServer)
		{
            NSLog(@"server about to send quit packet");
			Packet *packet = [Packet packetWithType:PacketTypeServerQuit];
//            packet.sendReliably = NO;
			[self sendPacketToAllClients:packet];
            [hostViewController.musicPlayer stop];
            _broadCastState = BroadCastStateStopped;
		}
		else
		{
			Packet *packet = [Packet packetWithType:PacketTypeClientQuit];
			[self sendPacketToServer:packet];
		}
	}
    
	[_session disconnectFromAllPeers];
	_session.delegate = nil;
	_session = nil;
    
	[self.delegate game:self didQuitWithReason:reason];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex

{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"OK"])
    {
        NSLog(@"ClIENT: sending PacketTypeJoinResponse to server");
        Packet *packet = [Packet packetWithType:PacketTypeJoinResponse];
        [self sendPacketToServer:packet];
        GameViewController *controller = [[GameViewController alloc] initWithNibName:@"GameViewController" bundle:nil];
        controller.delegate = self.hostViewController.mainview;
        
        [self.hostViewController presentViewController:controller animated:NO completion:nil];
        // show the soundSpeaker view
        
    }
}

- (void)clientReceivedPacket:(Packet *)packet
{
    Packet * recievedPacket = packet;
    
	switch (recievedPacket.packetType)
	{
            
        case PacketTypeJoinRequest:
        {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Applify"
                                      message:@"Would like to connect to your speaker"
                                      delegate:self
                                      cancelButtonTitle:@"Don't Allow"
                                      otherButtonTitles:@"OK",nil];
            
            [alertView show];
            
            
        }
        break;
            
		case PacketTypeSignInRequest:
        {
            NSLog(@"CLIENT: received sign in request");
            
			if (_state == GameStateWaitingForSignIn)
			{   
                NSLog(@"CLIENT:.. in a state where it's waiting for sign in, SENDING SIGN IN RESPONSE");
				_state = GameStateWaitingForReady;
                
				Packet *packet = [PacketSignInResponse packetWithPlayerName:_localPlayerName];
				[self sendPacketToServer:packet];
			}	else {
                NSLog(@"CLIENT:.. OOOPS! in a state where it's *not* waiting for sign in");
            }
        }
        break;
                                                 
        case PacketTypeServerReady:
        {
            NSLog(@"CLIENT: received PacketTypeServerReady");
			if (_state == GameStateWaitingForReady)
			{
            NSLog(@"CLIENT:.. in a state where it is  GameStateWaitingForReady");                
				_players = ((PacketServerReady *)packet).players;
                
                //identify this client first
                for (NSString * peerID in [_players allKeys]) {
                    Player *player = [_players objectForKey:peerID];
                    if ([player.name  isEqualToString:_localPlayerName]) {
                        _localPlayerObj = player;                     
                        // initalize the packet profiler for this client/player
                        _localPlayerObj.packetProfiler = [NSMutableArray arrayWithCapacity:kNumAQBufs];
                    }                        
                }
                
                _format = ((PacketServerReady *)packet).asbd;
                
                CalculateBytesForTime(_format, 0.5, &_bufferByteSize, &_numPacketsToRead);                 
                
                [self changeRelativePositionsOfPlayers];
                
                streamer.state = AS_BUFFERING;
                
                [self setUpStreamer:_localPlayerObj];
                
                NSLog(@"CLIENT: sending PacketTypeClientReady to server");
				Packet *packet = [Packet packetWithType:PacketTypeClientReady];
				[self sendPacketToServer:packet];                				                
                
				 //NSLog(@"the players are: %@", _players);
			} else {
             NSLog(@"CLIENT:OOPS! IT'S NOT in a state where it is  GameStateWaitingForReady");   
            }
        }
		break;
                                    
        case PacketTypeAudioBuffer:
        {

            lastAudioPacketTimeStamp = [Timer getCurTime];;

            UInt32 PackNumber = ((PacketAudioBuffer *)recievedPacket).packetNumber;
            if (numProfilePackets < kNumAQBufs) {
                Packet *packet = [PacketRecieved packetWithNumber:PackNumber];
                [self sendPacketToServer:packet];
                
                numProfilePackets++;
            }
            
            NSLog(@"Client: just received an audio buffer packet number %lu!", PackNumber);
            
            [self appendToRingBuffer: packet];
            
        }
        break;
            
        case PacketTypePlayMusicNow:
        {
            NSLog(@"just received a play now packet!");
            pthread_mutex_lock(&streamer->queueBuffersMutex);                        
            
            streamer->state = AS_READY_TO_PLAY;
            
            pthread_cond_signal(&streamer->queueBufferReadyCondition);
            pthread_mutex_unlock(&streamer->queueBuffersMutex);
        }
        break;
            
        case PacketTypeServerQuit:
        {
            NSLog(@"CLIENT received packet server quit");
            streamer->state = AS_STOPPED;

        }
        break;
            
        case PacketTypeEndOfSong:
        {
            NSLog(@"CLIENT received packet PacketTypeEndOfSong");
            isHostAtEndOfSong = YES;
            
        }
        break;
            
		
        default:
			 NSLog(@"Client received unexpected packet: %@", packet);
			break;
	}
        
}



-(void)startClientPlayBack
{
    NSLog(@"CLIENT: in startClientPlayBack");
    Packet *packet = [Packet packetWithType:PacketTypePlayMusicNow];
    [self sendPacketToServer:packet];
    
    
 //   CFDateRef dateNow;
   // CFDateRef startDate = CFDateCreate(NULL, streamer->startTime);
 /*   while(true) {
        dateNow = CFDateCreate(NULL, [Timer getCurTime]);
        if (CFDateCompare(dateNow, startDate,NULL) >= 0)   // ie both times are equal 
                                                           // or we are past startDate
        {*/
          //  NSLog(@"now is the time!");
           // NSLog(@"CLIENT: we just got a PacketTypePlayMusicNow before going in lock");
            
            pthread_mutex_lock(&streamer->queueBuffersMutex);            
            
//            NSLog(@"client:we just got the order to play music!");
            
            streamer->state = AS_READY_TO_PLAY;
            
            pthread_cond_signal(&streamer->queueBufferReadyCondition);
            pthread_mutex_unlock(&streamer->queueBuffersMutex);  
         //   break;
   /*     } else {
         //   NSLog(@"CLIENT: now isn't the time.. skip");
        }*/
   // }    
}


// we only use time here as a guideline
// we're really trying to get somewhere between 16K and 64K buffers, but not allocate too much if we don't need it/*
void CalculateBytesForTime(AudioStreamBasicDescription inDesc, Float64 inSeconds, UInt32 *outBufferSize, UInt32 *outNumPackets)
{
    
    // we need to calculate how many packets we read at a time, and how big a buffer we need.
    // we base this on the size of the packets in the file and an approximate duration for each buffer.
    //
    // first check to see what the max size of a packet is, if it is bigger than our default
    // allocation size, that needs to become larger
    
    // we don't have access to file packet size, so we just default it to maxBufferSize
    UInt32 maxPacketSize = 0x10000;
    
    static const int maxBufferSize = 0x10000; // limit size to 64K
    static const int minBufferSize = 0x4000; // limit size to 16K
    
    if (inDesc.mFramesPerPacket) {
        Float64 numPacketsForTime = inDesc.mSampleRate / inDesc.mFramesPerPacket * inSeconds;
        *outBufferSize = numPacketsForTime * maxPacketSize;
    } else {
        // if frames per packet is zero, then the codec has no predictable packet == time
        // so we can't tailor this (we don't know how many Packets represent a time period
        // we'll just return a default buffer size
        *outBufferSize = maxBufferSize > maxPacketSize ? maxBufferSize : maxPacketSize;
    }
    
    // we're going to limit our size to our default
    if (*outBufferSize > maxBufferSize && *outBufferSize > maxPacketSize)
        *outBufferSize = maxBufferSize;
    else {
        // also make sure we're not too small - we don't want to go the disk for too small chunks
        if (*outBufferSize < minBufferSize)
            *outBufferSize = minBufferSize;
    }
    *outNumPackets = *outBufferSize / maxPacketSize;
}



- (void)appendToRingBuffer:(Packet *)packet
{               
    NSLog(@"we are in append to ring buffer");
    // look at the @synchronized explanation in streamer::readFromRingBuffer
    // we basically sync with the streamer reading from the audio buffer
    //@synchronized(streamer) {
        int32_t length = ((PacketAudioBuffer *)packet).totalSize;
        
        void *writePointer;
        bytesAvailableToWrite = [ringBuffer lengthAvailableToWriteReturningPointer:&writePointer];  
        
        float spaceRemaining =  (float)bytesAvailableToWrite/(float)ringBufferCapacity;
        if (_localPlayerObj.isServer)
            NSLog(@"SERVER: this is space remaining(%f) = bytesAvailableToWrite(%lu)/ringBufferCapacity(%lu)",spaceRemaining, bytesAvailableToWrite, ringBufferCapacity);
        else
            NSLog(@"CLIENT: this is space remaining(%f) = bytesAvailableToWrite(%lu)/ringBufferCapacity(%lu)",spaceRemaining, bytesAvailableToWrite, ringBufferCapacity);
    
    
   /*     if (spaceRemaining < .70 && _broadCastState == BroadCastStateInProgress) {
            // if we have less than 10% remaining on ring buffer
            NSLog(@"CLIENT: ring buffer getting full on batch %lu, with space remaining %f percent",ringBufferBatchNumber, (spaceRemaining * 100));
            Packet *packet = [PacketRingBufferGettingFull packetWithBatchNumber:ringBufferBatchNumber++];            
            [self sendPacketToServerUnreliable:packet]; 
            _broadCastState = BroadCastStatePaused;
        } /*else if (spaceRemaining > .70 && _state == GameStateBroadCastPaused) {
            NSLog(@"CLIENT: ring buffer getting clear on batch %lu, with space remaining %f percent",ringBufferBatchNumber, (spaceRemaining * 100));
            Packet *packet = [Packet packetWithType:PacketTypeRingBufferGettingClear];
            [self sendPacketToServerUnreliable:packet];
            _broadCastState = BroadCastStateInProgress;
        }*/

        
        if (length > bytesAvailableToWrite) {
             NSLog(@"MAIN: ERROR: WE DON'T HAVE ENOUGH MEMORY IN RING BUFFER TO WRITE!");
            return;
        }
        
         NSLog(@"MAIN: we are appending %d bytes to ring buffer",length);
         NSLog(@"-------\n\n\n");
        
        
        memcpy(writePointer, [((PacketAudioBuffer *)packet).audioBufferData bytes], length);
        
        [ringBuffer didWriteLength:length];    
   // }

    if (!hasStartedReading) {
        [streamer start];
        hasStartedReading = true;
    }
}    


-(AVAssetTrack *)extractTrackFromMediaItemCollection:(MPMediaItemCollection*)userMediaItemCollection
{
    NSArray *items = [userMediaItemCollection items];    

    MPMediaItem *song = [items objectAtIndex:0];
    NSURL *assetURL = [song valueForProperty:MPMediaItemPropertyAssetURL];       

    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];        
    AVAssetTrack* track = [songAsset.tracks objectAtIndex:0];    

    return track;
}


-(AudioStreamBasicDescription)getTrackNativeSettings:(AVAssetTrack *) track
{
    
    CMFormatDescriptionRef formDesc = (__bridge CMFormatDescriptionRef)[[track formatDescriptions] objectAtIndex:0];
    const AudioStreamBasicDescription* asbdPointer = CMAudioFormatDescriptionGetStreamBasicDescription(formDesc);
    //because this is a pointer and not a struct we need to move the data into a struct so we can use it
    AudioStreamBasicDescription asbd = {0};
    memcpy(&asbd, asbdPointer, sizeof(asbd));
    //asbd now contains a basic description for the track
    return asbd;    
}



- (void)serverReceivedPacket:(Packet *)packet fromPlayer:(Player *)player
{
    [Logger Log:@"we are inside serverReceivedPacket"];
	switch (packet.packetType)
	{       
        case PacketTypeJoinResponse:
            NSLog(@"SERVER: server received PacketTypeJoinResponse");
            if (_state == GameStateWaitingForJoinResponse)
            {
                NSLog(@"about to highlight row");
                [hostViewController.cell highlightRow];
                player.hasJoinedForBroadcast = YES;
                _state = GameStateWaitingForSignIn;
            }
            break;
            
            
		case PacketTypeSignInResponse:
            NSLog(@"SERVER: server received PacketTypeSignInResponse");
			if (_state == GameStateWaitingForSignIn)
			{

				player.name = ((PacketSignInResponse *)packet).playerName;
                                
                NSLog(@"SERVER:.. in a state GameStateWaitingForSignIn with player name ..");
                
                if ([self receivedResponsesFromAllPlayers])
				{
                    
                    NSLog(@"SERVER:. sending PacketServerReady to all clients");
					_state = GameStateWaitingForReady;
                    
					 //NSLog(@"all clients have signed in");
                    
                    _format = [self getTrackNativeSettings:
                               [self extractTrackFromMediaItemCollection:
                                hostViewController.simplePlayerVC.collection]];
                    
                    CalculateBytesForTime(_format, 0.5, &_bufferByteSize, &_numPacketsToRead); 
                    
                    Packet *packet = [PacketServerReady packetWithPlayers:_players
                                                              audioFormat:_format                                      
                                      ];
					[self sendPacketToAllClients:packet];
				}
                
			}
			break;
            
        case PacketTypeClientReady:
        {   NSLog(@"SERVER: just received PacketTypeClientReady");
			if (_state == GameStateWaitingForReady && [self receivedResponsesFromAllPlayers])
			{
                [Logger Log:@"SERVER: the clients are all ready!"];
                NSThread *broadcastingThread = [[NSThread alloc]
                 initWithTarget:self
                 selector:@selector(beginServerBroadcast)
                 object:nil];
                [broadcastingThread start];

                _state = GameStateWaitingForPrimed;
	
			}
        }
        break;            
            
        case PacketTypeClientPrimed:
        {
            [Logger Log:@"SERVER: JUST RECEIVED A PRIMED PACKET!"];
            player.isPrimed = true;  
            if (_state == GameStateWaitingForPrimed && [self allPlayersArePrimed])
            {
                [broadcastLock lock];
                
                _broadCastState = BroadCastStatePaused;
                [hostViewController.musicPlayer skipToBeginning];
                
                Packet *packet = [Packet packetWithType:PacketTypePlayMusicNow];

                NSError *error;
                NSLog(@"all players are primed now!.. pausing broadcast ");
                [hostViewController.musicPlayer play];
                [_session sendDataToAllPeers:[packet data] withDataMode:GKSendDataUnreliable error:&error];
                NSLog(@"will fire music player");
                
                
                [broadcastLock unlock];
                _broadCastState = BroadCastStateInProgress;
                _state =  GameStatePlayBackCommenced;


            }
        }
        break;            
            
		default:
			break;
	}
}


- (Player *)playerWithPeerID:(NSString *)peerID
{
	return [_players objectForKey:peerID];
}

#pragma mark - GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
#ifdef DEBUG
	 //NSLog(@"Game: peer %@ changed state %d", peerID, state);
#endif
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
#ifdef DEBUG
	 //NSLog(@"Game: connection request from peer %@", peerID);
#endif
    
	[session denyConnectionFromPeer:peerID];
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
#ifdef DEBUG
	 //NSLog(@"Game: connection with peer %@ failed %@", peerID, error);
#endif
    
	// Not used.
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
#ifdef DEBUG
	 //NSLog(@"Game: session failed %@", error);
#endif
}

#pragma mark - GKSession Data Receive Handler

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peerID inSession:(GKSession *)session context:(void *)context
{

#ifdef DEBUG
  /*
    totalBytesReceived += [data length];
	 NSLog(@"Game: receive data from peer: %@ length: %d with total %lu", data,  [data length],totalBytesReceived);
     NSLog(@"\n\n\n");            
     NSLog(@":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::");*/

#endif
    
	Packet *packet = [Packet packetWithData:data];
	if (packet == nil)
	{
		 NSLog(@"Invalid packet: %@", data);
		return;
	}
    
	Player *player = [self playerWithPeerID:peerID];
    
    if (player != nil)
	{
		player.receivedResponse = YES;  // this is the new bit
	} else {
        Player *player = [[Player alloc] init];
		player.peerID = peerID;
		[_players setObject:player forKey:player.peerID];
    }
    
	if (self.isServer)
    {
        [Logger Log:@"SERVER: we just received packet"];   
		[self serverReceivedPacket:packet fromPlayer:player];
        
    }
	else
		[self clientReceivedPacket:packet];
}

#pragma mark - Networking

- (void)sendPacketToAllClients:(Packet *)packet
{
    [_players enumerateKeysAndObjectsUsingBlock:^(id key, Player *obj, BOOL *stop)
     {
         obj.receivedResponse = [_session.peerID isEqualToString:obj.peerID];
     }];
    
	GKSendDataMode dataMode = packet.sendReliably ? GKSendDataReliable : GKSendDataUnreliable;
    
	NSData *data = [packet data];
	NSError *error;
    
    NSLog(@"sendPacketToAllClients: about to send packet to all peers with data %@",data);
	if (![_session sendDataToAllPeers:data withDataMode:dataMode error:&error])
	{
		 NSLog(@"Error sending data to clients: %@", error);
	}

    
}

- (void)sendPacketToServer:(Packet *)packet
{
	GKSendDataMode dataMode = packet.sendReliably ? GKSendDataReliable : GKSendDataUnreliable;
	NSData *data = [packet data];
	NSError *error;
    NSLog(@"sending packet to server with data %@ ", data);
    
	if (![_session sendData:data toPeers:[NSArray arrayWithObject:_serverPeerID] withDataMode:dataMode error:&error])
	{
		 NSLog(@"Error sending data to server: %@", error);
	}
}


-(void)sendPacketToClient:(Packet *)packet
                   peerID:(NSString*)peerID
{
	GKSendDataMode dataMode = GKSendDataReliable;
	NSData *data = [packet data];
	NSError *error;
    NSLog(@"sending packet to %@ with data %@ ", peerID, data);
    
	if (![_session sendData:data toPeers:[NSArray arrayWithObject:peerID] withDataMode:dataMode error:&error])
	{
        NSLog(@"Error sending data to server: %@", error);
	}    
    
}


- (BOOL)receivedResponsesFromAllPlayers
{
	for (NSString *peerID in _players)
	{
		Player *player = [self playerWithPeerID:peerID];
		if (!player.receivedResponse)
			return NO;
	}
	return YES;
}

- (BOOL)allPlayersArePrimed
{
    NSLog(@"we are inside allPlayersArePrimed and we got %d players", [_players count]);
    for (NSString *peerID in _players)
    {
        Player *player = [self playerWithPeerID:peerID];
        // we only want the non server guys to be primed
        if (!player.isPrimed && !player.isServer) {
            NSLog(@"CLIENT: allPlayersArePrimed: players are not primed!");
            return NO;
        }
    }
    NSLog(@"CLIENT: players are primed!");
    return YES;
}

- (void)beginGame
{
	_state = GameStateDealing;
	[self.delegate gameDidBegin:self];
}

#pragma mark user data struct


static void CheckError (OSStatus error, const char *operation)
{
    if (error == noErr) return;
    
    char errorString [20];
    // see if it asppears to be a 4-char code
    *(UInt32 *) (errorString + 1) = CFSwapInt32HostToBig(error);
    if (isprint(errorString[1]) && isprint (errorString[2]) && 
        isprint(errorString[3]) && isprint (errorString[4])) {
        errorString[0] = errorString[5] = '\'';
        errorString[6] = '\0';
    } else 
        // no format ist as an integer
        sprintf(errorString, "%d", (int)error);
    fprintf(stderr, "error: %s (%s)\n", operation, errorString);
    
    exit(1);
}

    

-(AudioStreamBasicDescription)extractTrackFormat:(AVAssetTrack *)track
{    
    CMFormatDescriptionRef formDesc = (__bridge CMFormatDescriptionRef)[[track formatDescriptions] objectAtIndex:0];
    const AudioStreamBasicDescription* asbdPointer = CMAudioFormatDescriptionGetStreamBasicDescription(formDesc);
    //because this is a pointer and not a struct we need to move the data into a struct so we can use it
    AudioStreamBasicDescription asbd = {0};
    memcpy(&asbd, asbdPointer, sizeof(asbd));
    //asbd now contains a basic description for the track
    return asbd;
}

-(UInt32)getBroadCastInterval
{
    UInt32 playersCount = [_players count] -1;
    if (playersCount == 1)
        return 2.15;
    else if (playersCount > 1)
        return 0;
    else
        return 0;
}


- (void)beginServerBroadcast
{            
    [Logger Log:@"SERVER: we are in begin server broadcast"];
    
    @autoreleasepool {
        
        _broadCastState = BroadCastStateInProgress;
        streamer.state = AS_WAITING_FOR_QUEUE_TO_START;
        
        [self setUpReader];
        
        
        
        
        NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        sampleBroadcastTimer = [[NSTimer alloc] initWithFireDate:fireDate
                                                  interval:[self getBroadCastInterval]
                                                    target:self
                                                  selector:@selector(broadcastSample)
                                                  userInfo:NULL
                                                   repeats:YES];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:sampleBroadcastTimer forMode:NSDefaultRunLoopMode];
        
        
        BOOL isRunning = YES;
        do
        {
            NSLog(@"SERVER: before broadcast run loop");
            isRunning = [[NSRunLoop currentRunLoop]
                         runMode:NSDefaultRunLoopMode
                         beforeDate:[NSDate distantFuture]];
            
            NSLog(@"SERVER: after broadcast run loop");            
        } while (isRunning);
    }   
    
    
    NSLog(@"about to exit server broad cast loop");
}

-(BOOL)shouldContinueBroadcasting
{
    if (_broadCastState == BroadCastStateInProgress) {
//        NSLog(@"shouldContinueBroadcasting? YES");
        return YES;
    }
    
  //          NSLog(@"shouldContinueBroadcasting? NO");
    return NO;
}

-(void)setUpReader
{

    MPMediaItemCollection	*userMediaItemCollection = hostViewController.simplePlayerVC.collection;
    NSArray *items = [userMediaItemCollection items];
    
    
    MPMediaItem *song = [items objectAtIndex:0];
    NSURL *assetURL = [song valueForProperty:MPMediaItemPropertyAssetURL];       
    assetOnAirID = [self generateID:song];
    
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    
    NSError * error = nil;
    AVAssetReader* reader = [[AVAssetReader alloc] initWithAsset:songAsset error:&error];
    
    AVAssetTrack* track = [songAsset.tracks objectAtIndex:0];    
    
    readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:track
                                                              outputSettings:nil];
    
    
    [reader addOutput:readerOutput];
    [reader startReading];
        
    
    packetNumber = 0;
        
    _localPlayerObj = [self playerWithPeerID:_session.peerID];
    
    // allocate memory to move around audio data
    packet = (char*)malloc(MAX_PACKET_SIZE);
    packetDescriptions = (char*)malloc(MAX_PACKET_DESCRIPTIONS_SIZE);
    
    broadcastLock = [[NSLock alloc] init];
}


-(void)broadcastSample
{
    [broadcastLock lock];
    
        CMSampleBufferRef sample;
        sample = [readerOutput copyNextSampleBuffer];
        
        CMItemCount numSamples = CMSampleBufferGetNumSamples(sample);
        
        if (!sample || (numSamples == 0)) {
            Packet *packet = [Packet packetWithType:PacketTypeEndOfSong];
            packet.sendReliably = NO;
            [self sendPacketToAllClients:packet];
            [sampleBroadcastTimer invalidate];
            return;
        }
        
                                          
        NSLog(@"SERVER: going through sample loop");
        Boolean isBufferDataReady = CMSampleBufferDataIsReady(sample);
        

        
        CMBlockBufferRef CMBuffer = CMSampleBufferGetDataBuffer( sample );                                                         
        AudioBufferList audioBufferList;  
        
        CheckError(CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
                                                                           sample,
                                                                           NULL,
                                                                           &audioBufferList,
                                                                           sizeof(audioBufferList),
                                                                           NULL,
                                                                           NULL,
                                                                           kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment,
                                                                           &CMBuffer
                                                                           ),
                   "could not read sample data");
        
        const AudioStreamPacketDescription   * inPacketDescriptions;
        
        size_t								 packetDescriptionsSizeOut;
        size_t inNumberPackets;
        
        CheckError(CMSampleBufferGetAudioStreamPacketDescriptionsPtr(sample, 
                                                                     &inPacketDescriptions,
                                                                     &packetDescriptionsSizeOut),
                   "could not read sample packet descriptions");
        
        inNumberPackets = packetDescriptionsSizeOut/sizeof(AudioStreamPacketDescription);
        
        AudioBuffer audioBuffer = audioBufferList.mBuffers[0];
        
        
        
        for (int i = 0; i < inNumberPackets; ++i)
        {

            NSLog(@"going through packets loop");
            SInt64 dataOffset = inPacketDescriptions[i].mStartOffset;
            UInt32 dataSize   = inPacketDescriptions[i].mDataByteSize;            
            
            size_t packetSpaceRemaining = MAX_PACKET_SIZE - packetBytesFilled - packetDescriptionsBytesFilled;
            size_t packetDescrSpaceRemaining = MAX_PACKET_DESCRIPTIONS_SIZE - packetDescriptionsBytesFilled;        

            if ((packetSpaceRemaining < (dataSize + AUDIO_STREAM_PACK_DESC_SIZE)) || 
                (packetDescrSpaceRemaining < AUDIO_STREAM_PACK_DESC_SIZE))
            {
                if (![self encapsulateAndShipPacket:packet packetDescriptions:packetDescriptions packetID:assetOnAirID])
                    break;
            }
            
            memcpy((char*)packet + packetBytesFilled, 
                   (const char*)(audioBuffer.mData + dataOffset), dataSize); 
            
            memcpy((char*)packetDescriptions + packetDescriptionsBytesFilled, 
                   [self encapsulatePacketDescription:inPacketDescriptions[i]
                                         mStartOffset:packetBytesFilled
                    ],
                   AUDIO_STREAM_PACK_DESC_SIZE);  
            
            
            packetBytesFilled += dataSize;
            packetDescriptionsBytesFilled += AUDIO_STREAM_PACK_DESC_SIZE; 
            
            // if this is the last packet, then ship it
            if (i == (inNumberPackets - 1)) {          
                NSLog(@"woooah! this is the last packet (%d).. so we will ship it!", i);
                if (![self encapsulateAndShipPacket:packet packetDescriptions:packetDescriptions packetID:assetOnAirID])
                    break;
                
            }

        }
    
    [broadcastLock unlock];
}


-(NSString *)generateID:(MPMediaItem *)song
{
    NSLog(@"inside generate ID");
    NSString *itemID = [song valueForProperty:MPMediaItemPropertyArtist];
    return itemID;
}


- (char *)encapsulatePacketDescription:(AudioStreamPacketDescription)inPacketDescription
                          mStartOffset:(SInt64)mStartOffset
{
    // take out 32bytes b/c for mStartOffset we are using a 32 bit integer, not 64
    char * packetDescription = (char *)malloc(AUDIO_STREAM_PACK_DESC_SIZE);
    
    appendInt32(packetDescription, (UInt32)mStartOffset, 0);
    appendInt32(packetDescription, inPacketDescription.mVariableFramesInPacket, 4);
    appendInt32(packetDescription, inPacketDescription.mDataByteSize,8);    
    
    return packetDescription;
}

- (BOOL)encapsulateAndShipPacket:(void *)source
              packetDescriptions:(void *)packetDescriptions
                        packetID:(NSString *)packetID
{
  /*  if (![self shouldContinueBroadcasting])
    {
        [sampleBroadcastTimer invalidate];
        return NO;
    }*/
    // package Packet
    char * headerPacket = (char *)malloc(MAX_PACKET_SIZE + AUDIO_BUFFER_PACKET_HEADER_SIZE + packetDescriptionsBytesFilled);
    
    appendInt32(headerPacket, 'SNAP', 0);    
    appendInt32(headerPacket,packetNumber, 4);    
    appendInt16(headerPacket,PacketTypeAudioBuffer, 8);   
    // we use this so that we can add int32s later
    UInt16 filler = 0x00;
    appendInt16(headerPacket,filler, 10);    
    appendInt32(headerPacket, packetBytesFilled, 12);
    appendInt32(headerPacket, packetDescriptionsBytesFilled, 16);    
    appendUTF8String(headerPacket, [packetID UTF8String], 20);
    
    
    int offset = AUDIO_BUFFER_PACKET_HEADER_SIZE;        
    memcpy((char *)(headerPacket + offset), (char *)source, packetBytesFilled);
    
    offset += packetBytesFilled;
    
    memcpy((char *)(headerPacket + offset), (char *)packetDescriptions, packetDescriptionsBytesFilled);
    
    NSData *completePacket = [NSData dataWithBytes:headerPacket length: AUDIO_BUFFER_PACKET_HEADER_SIZE + packetBytesFilled + packetDescriptionsBytesFilled];
    
    
       //ship packet
 /*   NSLog(@"HOST: this is the packet content after encapsulation of packet (abs number: %lu) %@",packetNumber, completePacket);
     NSLog(@"\n\n\n");            
     NSLog(@":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::");*/
    
    if (numProfilePackets < kNumAQBufs) {   
        double curTime = [Timer getCurTime];
     //   NSLog(@"SERVER: sending encapsulated packet for packet number %d with timeStamp %f",numProfilePackets,curTime);
        [_localPlayerObj.packetProfiler.packetSentSchedule insertObject:[NSNumber numberWithDouble:curTime]
                                                                atIndex:packetNumber];
        numProfilePackets++;        
    }
    

    
    
    NSLog(@"sending packet number %lu to all peers", packetNumber);
    NSError *error;    
    if (![_session sendDataToAllPeers:completePacket withDataMode:GKSendDataReliable error:&error]) {
        NSLog(@"Error sending data to clients: %@", error);
    }   
    
    Packet *packet = [Packet packetWithData:completePacket];
    
    // reset packet 
    packetBytesFilled = 0;
    packetDescriptionsBytesFilled = 0;
    
    packetNumber++;
    free(headerPacket);    
    //  free(packet); free(packetDescriptions);
    return YES;
    
}




- (void)changeRelativePositionsOfPlayers
{
	NSAssert(!self.isServer, @"Must be client");
    
	Player *myPlayer = [self playerWithPeerID:_session.peerID];
	int diff = myPlayer.position;
	myPlayer.position = PlayerPositionBottom;
    
	[_players enumerateKeysAndObjectsUsingBlock:^(id key, Player *obj, BOOL *stop)
     {
         if (obj != myPlayer)
         {
             obj.position = (obj.position - diff) % 4;
         }
     }];
}

-(void)setUpStreamer:(Player *)player
{
    if (!audioPool) {
        audioPool = [[AudioPool alloc] initPool];
    }    
        
    ringBufferCapacity = _bufferByteSize * kNumAQBufs;
    ringBuffer = [(VirtualRingBuffer *)[VirtualRingBuffer alloc] initWithLength:(ringBufferCapacity)];

    
    streamer = [[AudioStreamer alloc] initWithRingBuffer:ringBuffer
                                          bufferByteSize:_bufferByteSize
                                        numPacketsToRead:_numPacketsToRead
                                                 gameObj:self
                ];  
    
    
    // create the audio queue
    if (player.isServer)
        NSLog(@"we are creating audio queue on server with the absd of the original song");
    else 
        NSLog(@"we are creating audio queue on client with the absd of the original song");
    
	OSStatus err = AudioQueueNewOutput(&_format, MyAudioQueueOutputCallback, (__bridge void*)streamer, NULL, NULL, 0, &streamer->audioQueue);
	if (err)
	{
		[streamer failWithErrorCode:AS_AUDIO_QUEUE_CREATION_FAILED];
		return;
	}
    
    // allocate the buffers and prime the queue with some data before starting        
    int i;
    for (i = 0; i < kNumAQBufs; ++i)
    {
        CheckError(AudioQueueAllocateBuffer(streamer->audioQueue, _bufferByteSize, &streamer->audioQueueBuffer[i]), "AudioQueueAllocateBuffer failed");    
    }	
    
    // initlize player obj
    streamer->_localPlayerObj = player;
}




//
// destroyStreamer
//
// Removes the streamer, the UI update timer and the change notification
//
- (void)destroyStreamer
{
	if (streamer)
	{
		[[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:ASStatusChangedNotification
         object:streamer];
	//	[progressUpdateTimer invalidate];
//		progressUpdateTimer = nil;
		
		[streamer stop];
//		[streamer release];
		streamer = nil;
	}
}


void appendInt32(void * source, int value, int offset )
{
    // ensure that data is transmitted in network byte order
    // which is big endian on 32 byte elements (ie long/int)

    
    value = htonl(value);
    memcpy((void *)(source + offset), &value, 4);            
}


void appendInt16(void * source, short value, int offset)
{
    // ensure that data is transmitted in network byte order
    // which is big endian on 16 byte elements (ie short)
    value = htons(value);
    memcpy((void *)(source + offset), &value, 2);            
}

void appendUTF8String(void * source, const char *cString, int offset)
{
    memcpy((void *)(source + offset), cString, strlen(cString)+1);        
}

unsigned numDigits(const unsigned n) {
    if (n < 10) return 1;
    return 1 + numDigits(n / 10);
}



@end
