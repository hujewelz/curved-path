//
//  CurvedPath.swift
//  pathSample
//
//  Created by huluobo on 2019/6/21.
//  Copyright © 2019 jewelz. All rights reserved.
//

import UIKit

extension CGPoint {
    func distanceToLine(_ line: Line) -> CGFloat {
        let a = line.p2.y - line.p1.y
        let b = line.p1.x - line.p2.x
        let c = line.p1.y * line.p2.x - line.p2.y * line.p1.x
        
        return abs(a * x + b * y + c) / sqrt(a * a + b * b)
    }
}

struct Corner {
    let point: CGPoint
    let radius: CGFloat
}

extension Corner {
    init(x: CGFloat, y: CGFloat, radius: CGFloat) {
        point = CGPoint(x: x, y: y)
        self.radius = radius
    }
}

struct CurvedPoint {
    var p1: CGPoint = .zero
    var p2: CGPoint = .zero
    var controlPoint: CGPoint = .zero
    var center: CGPoint = .zero
    var radius: CGFloat = 0
    
    init(p1: CGPoint, p2: CGPoint, controlPoint: CGPoint, center: CGPoint, radius: CGFloat) {
        self.p1 = p1
        self.p2 = p2
        self.controlPoint = controlPoint
        self.center = center
        self.radius = radius
    }
}

struct Line {
    let p1: CGPoint
    var p2: CGPoint
}

protocol Shape {
    func path() -> CGPath
}

struct CurvedPath: Shape {
    let points: [Corner]
    
    var curvedPoints: [CurvedPoint] {
        var result: [CurvedPoint] = []
        for i in points.startIndex+1..<points.endIndex-1 {
            let previous = points[i-1]
            let current = points[i]
            let next = points[i+1]
            let curvedPoint = self.curvedPoint(previous.point, p2: current.point, p3: next.point, radius: current.radius)
            result.append(curvedPoint)
        }
        return result
    }
    
    init(points: [Corner]) {
        self.points = points
    }
    
    func centerOfTwoLine(_ l1: Line, l2: Line, radius: CGFloat) -> CGPoint {
        
        let a1 = l1.p2.y - l1.p1.y
        let b1 = l1.p1.x - l1.p2.x
        let c1 = l1.p1.y * l1.p2.x - l1.p2.y * l1.p1.x
        
        let a2 = l2.p2.y - l2.p1.y
        let b2 = l2.p1.x - l2.p2.x
        let c2 = l2.p1.y * l2.p2.x - l2.p2.y * l2.p1.x
        
        let d1 = sqrt(a1 * a1 + b1 * b1)
        let d2 = sqrt(a2 * a2 + b2 * b2)
        
        let some = [
            (radius * d1, radius * d2),
            (-radius * d1, radius * d2),
            (radius * d1, -radius * d2),
            (-radius * d1, -radius * d2)
        ]
        
        var center = CGPoint.zero
        var mimDistance: CGFloat = CGFloat.infinity
        var resultCenter: CGPoint = .zero
        for s in some {
            let r1 = s.0
            let r2 = s.1
            if a1 == 0 {
                center.y = (r1 - c1) / b1
                center.x = (r2 - c2 - b2 * center.y) / a2
            } else {
                let result = r2 - c2 - a2 * (r1 - c1) / a1
                let o = b2 - b1 * a2 / a1
                center.y = result / o
                center.x = (r1 - c1 - b1 * center.y) / a1
            }
            let dd = center.distanceToLine(Line(p1: l1.p1, p2: l2.p2))
            if dd < mimDistance {
                mimDistance = dd
                resultCenter = center
            }
        }
        return resultCenter
    }
    
    /// 求两条互相垂直直线的交点
    /// - parameter line: 已知直线
    /// - parameter p: 与已知直线的垂直线上的点
    /// - returns 两条互相垂直直线的交点
    func intersectionPointOfPerpendicularLine(_ line: Line, pointAtOtherLine p: CGPoint) -> CGPoint {
        let a = line.p2.y - line.p1.y
        let b = line.p1.x - line.p2.x
        let c = line.p1.y * line.p2.x - line.p2.y * line.p1.x
        
        let bb = p.y - b / a * p.x
        var intersectionPoint = CGPoint.zero
        if a == 0 {
            intersectionPoint.x = p.x
            intersectionPoint.y = (-c - a * intersectionPoint.x) / b
            
        } else {
            intersectionPoint.x = (-c - b * bb) * a / (a * a + b * b)
            intersectionPoint.y = b / a * intersectionPoint.x + bb
        }
        return intersectionPoint
    }
    
    func curvedPoint(_ p1: CGPoint, p2: CGPoint, p3: CGPoint, radius: CGFloat) -> CurvedPoint {
        if radius == 0 {
            return CurvedPoint(p1: p2, p2: p2, controlPoint: p2, center: .zero, radius: 0)
        }
        if p1 == p2 {
            
        }
        
        let center = centerOfTwoLine(Line(p1: p1, p2: p2), l2: Line(p1: p2, p2: p3), radius: radius)
        let controlP1 = intersectionPointOfPerpendicularLine(Line(p1: p1, p2: p2), pointAtOtherLine: center)
        let controlP2 = intersectionPointOfPerpendicularLine(Line(p1: p2, p2: p3), pointAtOtherLine: center)
        
        return CurvedPoint(p1: controlP1, p2: controlP2, controlPoint: p2, center: center, radius: radius)
    }
    
    func path() -> CGPath {
        let beizerPath = UIBezierPath()
        guard !points.isEmpty else { return beizerPath.cgPath }
        
        beizerPath.move(to: points[0].point)
        
        let curvedPoints = self.curvedPoints
        for i in curvedPoints.startIndex..<curvedPoints.endIndex {
            let current = curvedPoints[i]
            beizerPath.addLine(to: current.p1)
            if current.p2 != current.controlPoint { // 半径不为0
                beizerPath.addQuadCurve(to: current.p2, controlPoint: current.controlPoint)
                let circle = UIBezierPath(arcCenter: current.center, radius: current.radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: false)
                beizerPath.append(circle)
                //                beizerPath.addArc(withCenter: current.center, radius: current.radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: false)
            }
            beizerPath.move(to: current.p2)
        }
        beizerPath.addLine(to: points.last!.point)
        return beizerPath.cgPath
    }
}

struct Polyline: Shape {
    var points: [CGPoint]
    
    func path() -> CGPath {
        let beizerPath = UIBezierPath()
        guard !points.isEmpty else { return beizerPath.cgPath }
        
        beizerPath.move(to: points[0])
        for i in 1..<points.count {
            beizerPath.addLine(to: points[i])
        }
        return beizerPath.cgPath
    }
}
