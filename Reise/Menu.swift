//
//  Menu.swift
//  Reise
//
//  Created by Nils Schwenkel on 28.05.18.
//  Copyright © 2018 Nils Schwenkel. All rights reserved.
//

import Foundation
import SpriteKit

class Menu: SKScene {

    var chapterParallax: Chapter?
    var chapterOne: Chapter?
    var chapters: [Chapter] = Array()
    
    init(size: CGSize, chapters: [Chapter]) {
        super.init(size: size)

        self.chapters = chapters
        let xPosition: CGFloat = self.frame.size.width/2
        var yPosition: CGFloat = self.frame.size.height/5 * 4
        
        for chapter in chapters {
            
            let parallaxLabel = SKLabelNode(text: "Chapter: " + chapter.title)
            parallaxLabel.name = chapter.title
            parallaxLabel.fontSize = 65
            parallaxLabel.position.x = xPosition
            parallaxLabel.position.y = yPosition
            self.addChild(parallaxLabel)
            
            yPosition -= 200
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    override func didMove(to view: SKView) {
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var isRight : Bool = false
        var isLeft : Bool = false
        
        for touch in touches {
            let location = touch.location(in: self)
            
            let nodes = self.nodes(at: location)
            
            for node in nodes {
                for index in 0..<chapters.count {
                    if chapters[index].title == node.name {
                        let scene = GameScene(size:CGSize(width: self.frame.size.width, height: self.frame.size.height), displayChapter: index, fromChapters: self.chapters)
                        self.scene?.view?.presentScene(scene, transition: SKTransition.doorsOpenHorizontal(withDuration: TimeInterval(1)))
                    }
                }
            }
            
            if(location.x < self.frame.size.width/2){
                isLeft = true
            }
            
            if(location.x > self.frame.size.width/2){
                isRight = true
            }
        }
        
        
        if (isRight && isLeft){
            // "Both touched"
            // do something..
        } else if(isRight) {
        } else if(isLeft) {
        }
    
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
