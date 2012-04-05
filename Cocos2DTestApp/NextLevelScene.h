//
//  GameOverScene.h
//  Cocos2DTestApp
//
//  Created by Dmitriy Starodubtsev on 03.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "HelloWorldLayer.h"

@interface NextLevelLayer : CCLayerColor {
    CCLabelTTF *_label;
    HelloWorldLayer *controller;
}
@property (nonatomic, retain) CCLabelTTF *label;
@property (nonatomic, retain) HelloWorldLayer *controller;
@end

@interface NextLevelScene : CCScene {
    NextLevelLayer *_layer;

}
@property (nonatomic, retain) NextLevelLayer *layer;
@end