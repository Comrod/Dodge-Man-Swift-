//
//  MenuScene.swift
//  Dodge Man (Swift)
//
//  Created by Cormac Chester on 12/30/14.
//  Copyright (c) 2014 Extreme Images. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        //Start Label
        let startLabel = SKLabelNode(fontNamed:"Arial-BoldMT")
        startLabel.text = "Start";
        startLabel.fontSize = 40;
        startLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
        self.addChild(startLabel)
        
        NSLog("Stuff")
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)

            //Add node thing where you touch the label later
            
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}