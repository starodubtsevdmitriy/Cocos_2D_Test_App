//
//  HelloWorldLayer.h
//  Cocos2DTestApp
//
//  Created by Dmitriy Starodubtsev on 03.04.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayerColor {
    NSMutableArray *_projectiles;
    NSMutableArray *_targets;
    int _projectilesDestroyed;
    int lifes;
    int levelNumber;
    CCLabelAtlas *scoreLabel;
    CCSprite *lifeico;
}

@property (nonatomic, assign) CCLabelTTF *scoreLabel;
// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
