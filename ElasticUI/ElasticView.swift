//
//  ElasticView.swift
//  ElasticUI
//
//  Created by Mitchell Porter on 1/12/16.
//  Copyright © 2016 Daniel Tavares. All rights reserved.
//

import UIKit

class ElasticView: UIView {
    
    private let topControlPointView = UIView()
    private let leftControlPointView = UIView()
    private let bottomControlPointView = UIView()
    private let rightControlPointView = UIView()
    
    private let elasticShape = CAShapeLayer()
    
    private lazy var displayLink: CADisplayLink = {
       let displayLink = CADisplayLink(target: self, selector: "updateLoop")
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
       return displayLink
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupComponents()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        startUpdateLoop()
        animateControlPoints()
    }
    
    private func setupComponents() {
        // Setup the CAShapeLayer
        elasticShape.fillColor = backgroundColor?.CGColor
        elasticShape.path = UIBezierPath(rect: self.bounds).CGPath
        layer.addSublayer(elasticShape)
        
        // Add control points
        for controlPoint in [topControlPointView, leftControlPointView, bottomControlPointView, rightControlPointView] {
            addSubview(controlPoint)
            controlPoint.frame = CGRectMake(0.0, 0.0, 5.0, 5.0)
            controlPoint.backgroundColor = UIColor.blueColor()
        }
        
        // Position the control points
        positionControlPoints()
    }
    
    private func positionControlPoints() {
        
        // Position the control points
        topControlPointView.center = CGPointMake(bounds.midX, 0.0)
        leftControlPointView.center = CGPointMake(0.0, bounds.midY)
        bottomControlPointView.center = CGPointMake(bounds.midX, bounds.maxY)
        rightControlPointView.center = CGPointMake(bounds.maxX, bounds.midY)
    }
    
    private func bezierPathForControlPoints() -> CGPathRef {
        // 1
        let path = UIBezierPath()
        
        // 2
        let top = topControlPointView.layer.presentationLayer()?.position
        let left = leftControlPointView.layer.presentationLayer()?.position
        let bottom = bottomControlPointView.layer.presentationLayer()?.position
        let right = rightControlPointView.layer.presentationLayer()?.position
        
        let width = frame.size.width
        let height = frame.size.height
        
        // 3
        path.moveToPoint(CGPointMake(0.0, 0.0))
        path.addQuadCurveToPoint(CGPointMake(width, 0), controlPoint: top!)
        path.addQuadCurveToPoint(CGPointMake(width, height), controlPoint:right!)
        path.addQuadCurveToPoint(CGPointMake(0, height), controlPoint:bottom!)
        path.addQuadCurveToPoint(CGPointMake(0, 0), controlPoint: left!)
        
        // 4
        return path.CGPath
    }
    
    private func startUpdateLoop() {
        displayLink.paused = false
    }
    
    private func stopUpdateLoop() {
        displayLink.paused = true
    }
    
    func updateLoop() {
        elasticShape.path = bezierPathForControlPoints()
    }
    
    func animateControlPoints() {
        
        // 1
        let overshootAmount : CGFloat = 10.0
        
        // 2
        UIView.animateWithDuration(0.25, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1.5, options: [], animations: { () -> Void in
            
            // 3 - Animate the control points up, left, down, or right
            self.topControlPointView.center.y -= overshootAmount // Animate up
            self.leftControlPointView.center.x -= overshootAmount // Animate left
            self.bottomControlPointView.center.y += overshootAmount // Animated down
            self.rightControlPointView.center.x += overshootAmount // Animate right
            
            }) { (completed) -> Void in
                // 4
                UIView.animateWithDuration(0.45, delay: 0.0, usingSpringWithDamping: 0.15, initialSpringVelocity: 5.5, options: [], animations: { () -> Void in
                    // 5 - This just resets the control points to their original values
                    // but animates / bounces them back
                    self.positionControlPoints()
                    }, completion: { (completed) -> Void in
                        // 6 -  Stop the display link once things stop moving
                        self.stopUpdateLoop()
                })
        }
    }
}
