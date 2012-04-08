//
//  HelloWorldLayer.m
//  Cocos2DTestApp
//
//  Created by Dmitriy Starodubtsev on 03.04.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
// Import the interfaces
#import "HelloWorldLayer.h"
#import "SimpleAudioEngine.h"
#import "GameOverScene.h"
#import "NextLevelScene.h"
#import "CCLabelAtlas.h"
#import "AppDelegate.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

@synthesize scoreLabel = _scoreLabel;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
    
	CCScene *scene = [CCScene node];
    // 'layer' is an autorelease object.
    
	HelloWorldLayer *layer = [HelloWorldLayer node];
    // add layer as a child to scene
    
	[scene addChild: layer];
    
	return scene;
}

-(id) init
{    
    if( (self=[super initWithColor:ccc4(255,255,255,255)] )) {
        // Enable touch events
        
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        int currentLevel = [delegate currentLevel];
        if (currentLevel == 2) {
            [self schedule: @selector(tickCountdown:) interval:90];
        }
        else if (currentLevel == 1) {
            [self schedule: @selector(tickCountdown:) interval:60];
        }
        else {
            [self schedule: @selector(tickCountdown:) interval:30];
        }
        self.isTouchEnabled = YES;
		lives = 3;
		// Initialize arrays
        
		_targets = [[NSMutableArray alloc] init];
		_projectiles = [[NSMutableArray alloc] init];
		// Get the dimensions of the window for calculation purposes
        
		CGSize winSize = [[CCDirector sharedDirector] winSize];
        CCSprite *player = [CCSprite spriteWithFile:@"Player.png" rect:CGRectMake(0, 0, 27, 40)];
		player.position = ccp(player.contentSize.width/2, winSize.height/2);
		[self addChild:player];
		// Call game logic about every second
        
		[self schedule:@selector(gameLogic:) interval:1.0];
		[self schedule:@selector(update:)];
		// Start up the background music
        
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
		for (int i = 0; i < lives; i++) {
            lifeico.tag = 3;
            lifeico = [CCSprite spriteWithFile:@"life.png"rect:CGRectMake(0, 0, 24, 24)];
            lifeico.position = ccp(75 - 25 * i,300);
            [self addChild:lifeico];
        }
        self.scoreLabel = [CCLabelTTF labelWithString:@"0" dimensions:CGSizeMake(100, 50) alignment:UITextAlignmentRight fontName:@"Marker Felt" fontSize:32];
        _scoreLabel.position = ccp(420, 290);
        _scoreLabel.color = ccc3(0,0,0);
        [self addChild:_scoreLabel z:1];
	}
        return self;
}

-(void) tickCountdown: (ccTime) dt {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    int currentLevel = [delegate currentLevel];
    if ( lives > 0 && currentLevel != 2) {
        NextLevelScene *nextLevelScenee = [NextLevelScene node];
        _projectilesDestroyed = 0;
        delegate.currentLevel++;
        [[CCDirector sharedDirector] replaceScene:nextLevelScenee];
    }
    else if (lives > 0 && currentLevel == 2) {
        GameOverScene *gameOverScene = [GameOverScene node];
        _projectilesDestroyed = 0;
        [gameOverScene.layer.label setString:@"You Win!"];
        [[CCDirector sharedDirector] replaceScene:gameOverScene];
        delegate.currentLevel = 0;
    }
}

-(void)addTarget {
    CCSprite *target = [CCSprite spriteWithFile:@"Target.png" 
                                           rect:CGRectMake(0, 0, 27, 40)]; 
    target.tag = 1;
    [_targets addObject:target];
    // Determine where to spawn the target along the Y axis
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    int minY = target.contentSize.height/2;
    int maxY = winSize.height - target.contentSize.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    // Create the target slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    
    target.position = ccp(winSize.width + (target.contentSize.width/2), actualY);
    [self addChild:target];
    // Determine speed of the target
    
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    // Create the actions
    
    id actionMove = [CCMoveTo actionWithDuration:actualDuration 
                                        position:ccp(-target.contentSize.width/2, actualY)];
    id actionMoveDone = [CCCallFuncN actionWithTarget:self 
                                             selector:@selector(spriteMoveFinished:)];
    [target runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
 }

-(void)spriteMoveFinished:(id)sender {
    CCSprite *sprite = (CCSprite *)sender;
    [self removeChild:sprite cleanup:YES];
    lifeico.tag = 3;
    if (sprite.tag == 1) {// target
        if (lives > 1) {
            lives --;
            [self removeChildByTag: 3 cleanup:YES];
        }
        else {  
            [self removeChild:lifeico cleanup:YES];
            [_targets removeObject:sprite];
            GameOverScene *gameOverScene = [GameOverScene node];
            [gameOverScene.layer.label setString:@"You Lose :["];
            [[CCDirector sharedDirector] replaceScene:gameOverScene];
        }
    } else if (sprite.tag == 2) { // projectile
        [_projectiles removeObject:sprite];
    }
}

-(void)gameLogic:(ccTime)dt {
    [self addTarget];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Choose one of the touches to work with
	
    UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	// Set up initial location of projectile
	
    CGSize winSize = [[CCDirector sharedDirector] winSize];
	CCSprite *projectile = [CCSprite spriteWithFile:@"Projectile.png" rect:CGRectMake(0, 0, 20, 20)];
	projectile.position = ccp(20, winSize.height/2);
    // Determine offset of location to projectile
	
    int offX = location.x - projectile.position.x;
	int offY = location.y - projectile.position.y;
	// Bail out if we are shooting down or backwards
	
    if (offX <= 0) return;
    // Ok to add now - we've double checked position
    
    [self addChild:projectile];
    // Play a sound!
	
    [[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew-lei.caf"];
	// Determine where we wish to shoot the projectile to
	
    int realX = winSize.width + (projectile.contentSize.width/2);
	float ratio = (float) offY / (float) offX;
	int realY = (realX * ratio) + projectile.position.y;
	CGPoint realDest = ccp(realX, realY);
	// Determine the length of how far we're shooting
	
    int offRealX = realX - projectile.position.x;
	int offRealY = realY - projectile.position.y;
	float length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));
	float velocity = 480/1; // 480pixels/1sec
	float realMoveDuration = length/velocity;
	// Move projectile to actual endpoint
	
    [projectile runAction:[CCSequence actions:
						   [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
						   [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
						   nil]];
	// Add to projectiles array
	
    projectile.tag = 2;
	[_projectiles addObject:projectile];
}

- (void)update:(ccTime)dt {
    NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
    for (CCSprite *projectile in _projectiles) {
        CGRect projectileRect = CGRectMake(
                                           projectile.position.x - (projectile.contentSize.width/2), 
                                           projectile.position.y - (projectile.contentSize.height/2), 
                                           projectile.contentSize.width, 
                                           projectile.contentSize.height);
        
        NSMutableArray *targetsToDelete = [[NSMutableArray alloc] init];
        for (CCSprite *target in _targets) {
            CGRect targetRect = CGRectMake(
                                           target.position.x - (target.contentSize.width/2), 
                                           target.position.y - (target.contentSize.height/2), 
                                           target.contentSize.width, 
                                           target.contentSize.height);
            if (CGRectIntersectsRect(projectileRect, targetRect)) {
                [targetsToDelete addObject:target];				
            }						
        }
        for (CCSprite *target in targetsToDelete) {
            [_targets removeObject:target];
            [self removeChild:target cleanup:YES];									
        }
        if (targetsToDelete.count > 0) {
            [projectilesToDelete addObject:projectile];
        }
        [targetsToDelete release];
    }
    for (CCSprite *projectile in projectilesToDelete) {
        [_projectiles removeObject:projectile];
        [self removeChild:projectile cleanup:YES];
        _projectilesDestroyed++;
    }
     [_scoreLabel setString:[NSString stringWithFormat:@"%d", _projectilesDestroyed * 25]];
     [projectilesToDelete release];
}
// on "dealloc" you need to release all your retained objects

- (void) dealloc
{
    [_targets release];
    _targets = nil;
    [_projectiles release];
    _projectiles = nil;
	[super dealloc];
}

@end
