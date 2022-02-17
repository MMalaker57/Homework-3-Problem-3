//
//  OverlapIntegral.swift
//  Homework 3 Problem 3 Attempt One
//
//  Created by Matthew Malaker on 2/17/22.
//

import Foundation

//                       - r
//                       ----
//                1       a0
// Psi   =   ---------  e
//   1s
//            __    3/2
//          |/pi * a
//          0
//
//

class overlapIntegral: NSObject, ObservableObject  {
    func calculate1sOverlap(lowerXBound: Double, upperXBound: Double,lowerYBound: Double, upperYBound: Double,lowerZBound: Double, upperZBound: Double, deltaX: Double, deltaY: Double, deltaZ: Double, maximumGuesses: UInt64)->(integral: Double, belowPoints: [(Double, Double, Double)], abovePoints: [(Double, Double, Double)]){
        let box = Bounding_Box()
        var numberOfGuesses = UInt64(0)
        var pointsUnderCurve = UInt64(0)
        let aNaught = 0.529
        var integral = 0.0
        var point = (xCoord: 0.0, yCoord: 0.0, zCoord: 0.0)
        var newPointsBelow: [(xCoord: Double, yCoord: Double, zCoord: Double)] = []
        var newPointsAbove: [(xCoord: Double, yCoord: Double, zCoord: Double)] = []
        
        //In order to do this integral, we need to generate a random point within the set bounds passed as arguments. We do not need to check the horizontal coordinates because the random generation is defined to be within the bounds, but the vertical coordinate does need to be checked. The horizontal is generated because the vertical depends on the horizontal
        while numberOfGuesses < maximumGuesses{
        
            point.xCoord = Double.random(in: lowerXBound...upperXBound)
            point.yCoord = Double.random(in: lowerYBound...upperYBound)
            point.zCoord = Double.random(in: lowerZBound...upperZBound)
            
            
            //The integral is the area under the curve, so if under the curve, we need to add it to a counter specifically for that case.
            
            //The curve is our probability distribution, which is psi1*psi2
            if(sqrt(pow(point.xCoord,2)+pow(point.yCoord,2)+pow(point.zCoord,2)) < ((1/(Double.pi*pow(aNaught,3))*(exp(-1.0*sqrt(pow(point.xCoord,2)+pow(point.yCoord,2)+pow(point.zCoord,2))))*(exp(-sqrt(pow(point.xCoord+deltaX,2)+pow(point.yCoord+deltaY,2)+pow(point.zCoord+deltaZ,2))))))){
                pointsUnderCurve += 1
                newPointsBelow.append(point)
            }
            
            //If above the curve, do not add to below curve counter
            else{
                newPointsAbove.append(point)
            }
            numberOfGuesses += 1
        }
    //        print(pointsUnderCurve)
        
            integral = Double(pointsUnderCurve/numberOfGuesses)*box.cuboidVolume(numberOfSides: 3, sideOneDimension: upperXBound-lowerXBound, sideTwoDimension: upperYBound-lowerYBound, sideThreeDimension: upperZBound-lowerZBound)
        
        return (integral,newPointsBelow, newPointsAbove)
        
        
    }
}
