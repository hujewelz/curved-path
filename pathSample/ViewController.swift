//
//  ViewController.swift
//  pathSample
//
//  Created by huluobo on 2019/5/30.
//  Copyright © 2019 jewelz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let points = [
            MyPoint(x: 10, y: 10, radius: 0),
            MyPoint(x: 200, y: 10, radius: 10),
            MyPoint(x: 180, y: 190, radius: 10),
            MyPoint(x: 20, y: 200, radius: 0),
        ]
        let pathView = PathView(points: points, frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 400))
        pathView.backgroundColor = UIColor.purple
        view.addSubview(pathView)
    }
}


class PathView: UIView {
    var points: [MyPoint] = []
    
    init(points: [MyPoint], frame: CGRect) {
        self.points = points
        super.init(frame: frame)
        setupPath()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    private func setupPath() {
        let shapeLayer = layer as! CAShapeLayer
        shapeLayer.lineWidth = 2
        shapeLayer.lineCap = .round
        shapeLayer.fillColor = UIColor.red.withAlphaComponent(0.2).cgColor
        shapeLayer.strokeColor = UIColor.red.cgColor
        
        
        let bezierPath = UIBezierPath()
        let startPoint = points[0]
        bezierPath.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
        for point in points.dropFirst() {
            bezierPath.addLine(to: CGPoint(x: point.x, y: point.y))
            let p = UIBezierPath(arcCenter: CGPoint(x: point.x-5, y: point.y+5),
                                 radius: point.radius,
                                 startAngle: 0,
                                 endAngle: CGFloat.pi * 2,
                                 clockwise: false)
            bezierPath.append(p)
        }
        bezierPath.addLine(to: CGPoint(x: startPoint.x, y: startPoint.y))
        shapeLayer.path = bezierPath.cgPath
    }
}

struct MyPoint {
    var x: CGFloat
    var y: CGFloat
    var radius: CGFloat
}


