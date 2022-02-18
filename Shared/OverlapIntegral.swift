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
    
    var plotDataModel: PlotDataClass? = nil
    func calculate1sOverlap(lowerXBound: Double, upperXBound: Double,lowerYBound: Double, upperYBound: Double,lowerZBound: Double, upperZBound: Double, R: Double, maximumGuesses: UInt64) async->(integral: Double, belowPoints: [(Double, Double, Double)], abovePoints: [(Double, Double, Double)]){
        let box = Bounding_Box()
//        var numberOfGuesses = UInt64(0)
        let aNaught = 0.529
        var integral = 0.0
        var pointsBelow: Int = 0
        var newPointsBelow: [(r1Coord: Double, r2Coord: Double, Probability: Double)] = []
        var newPointsAbove: [(r1Coord: Double, r2Coord: Double, Probability: Double)] = []
        var r1List: [Double] = []
        var r2List: [Double] = []
        
       
        
        //In order to do this integral, we need to generate a random point within the set bounds passed as arguments. We do not need to check the horizontal coordinates because the random generation is defined to be within the bounds, but the vertical coordinate does need to be checked. The horizontal is generated because the vertical depends on the horizontal
        
        
        //This will be really slow, so we will thread it
        
        let data = await withTaskGroup(of: (r1: Double, r2: Double, probability: Double, status: Bool).self, returning: [(r1: Double, r2: Double, probability: Double, status: Bool)].self, body: {taskGroup in
            
            for i in stride(from: 1, through: maximumGuesses, by: 1){
                
                taskGroup.addTask{ [self] in
                    var point = (xCoord: 0.0, yCoord: 0.0, zCoord: 0.0)
                    var secondPoint = 0.0
                    var isUnderCurve = false
                    point.xCoord = Double.random(in: lowerXBound...upperXBound)
                    point.yCoord = Double.random(in: lowerYBound...upperYBound)
                    point.zCoord = Double.random(in: lowerZBound...upperZBound)
//                    print(point)
                    var xtemp1 = 0.0
                    var xtemp2 = 0.0
                    if(point.xCoord > 0){
                        xtemp1 = (R/2) + point.xCoord
                        xtemp2 = (R/2) - point.xCoord
                    }
                    else{
                        if(point.xCoord < 0){
                            xtemp1 = (R/2) - point.xCoord
                            xtemp2 = (R/2) + point.xCoord
                            
                        }
                    }
                    let r1 = self.convertToSpherical(x: xtemp1, y: point.yCoord, z: point.zCoord).r
                    let r2 = self.convertToSpherical(x: xtemp2, y: point.yCoord, z: point.zCoord).r
//                    print(-1.0*r1/aNaught)
//                    print(exp(-1.0*r1/aNaught))
                    let probabilityAtPoint = (exp((-1.0*r1)/aNaught))*(exp((-1.0*r2/aNaught)))
//                    print(probabilityAtPoint)
                    secondPoint = Double.random(in: 0...(1/(Double.pi*pow(aNaught,3)))*(exp((-1.0*R/aNaught))))
//                    print((1/(Double.pi*pow(aNaught,3)))*(exp((-1.0*R/aNaught))))
                    if(secondPoint < probabilityAtPoint){
                        isUnderCurve = true
                        
                    }

                    return((r1: r1, r2: r2, probability: probabilityAtPoint, status: isUnderCurve))
                    
                }
                
                }
            var interimResults: [(r1: Double, r2: Double, probability: Double, status: Bool)] = []
            for await result in taskGroup{
                interimResults.append(result)
            }
            return interimResults
            
        })
        
        var sumOfP: Double = 0.0
        for i in data{
            r1List.append(i.r1)
            r2List.append(i.r2)
//            print(i.status)
            if(i.status){
                pointsBelow += 1
                newPointsBelow.append((r1Coord: i.r1, r2Coord: i.r2, Probability: i.probability))
            }
            else{
                newPointsAbove.append((r1Coord: i.r1, r2Coord: i.r2, Probability: i.probability))
            }
            sumOfP += i.probability
        }
        sumOfP *= (1/(Double.pi*pow(aNaught,3)))

        integral = Double(sumOfP)/Double(maximumGuesses)*box.cuboidVolume(numberOfSides: 3, sideOneDimension: upperXBound - lowerXBound, sideTwoDimension: upperYBound - lowerYBound, sideThreeDimension: upperZBound - lowerZBound)
        
        
        return((integral: integral, belowPoints: newPointsBelow, abovePoints: newPointsAbove))
        
//        while numberOfGuesses < maximumGuesses{
//
//            point.xCoord = Double.random(in: lowerXBound...upperXBound)
//            point.yCoord = Double.random(in: lowerYBound...upperYBound)
//            point.zCoord = Double.random(in: lowerZBound...upperZBound)
//
//
//            //The integral is the area under the curve, so if under the curve, we need to add it to a counter specifically for that case.
//
//            //The curve is our probability distribution, which is psi1*psi2
//
//            let r1 = sqrt(pow(point.xCoord,2)+pow(point.yCoord,2)+pow(point.zCoord,2))
//            let r2 = sqrt(pow(R-point.xCoord,2)+pow(point.yCoord,2)+pow(point.zCoord,2))
//            let probabilityAtPoint = (1/(Double.pi*pow(aNaught,3)))*(exp((-1.0*r1)/aNaught))*(exp((-1.0*r2/aNaught)))
//            secondPoint = Double.random(in: 0...1)
//            if(secondPoint < probabilityAtPoint){
//                pointsUnderCurve += 1
//                newPointsBelow.append((r1,r2,secondPoint))
//            }
//
//            //If above the curve, do not add to below curve counter
//            else{
//                newPointsAbove.append((r1,r2,secondPoint))
//            }
//            r1List.append(r1)
//            r2List.append(r2)
//
//
//            numberOfGuesses += 1
//        }
    //        print(pointsUnderCurve)
        
        //After all points are done
//        let r1Min = Double(r1List.min() ?? -1.0)
//        let r1Max = Double(r1List.max() ?? 1.0)
//        let r2Min = Double(r2List.min() ?? -1.0)
//        let r2Max = Double(r2List.max() ?? 1.0)
//
//
//        integral = Double(pointsUnderCurve/numberOfGuesses)*box.cuboidVolume(numberOfSides: 3, sideOneDimension: r1Max-r1Min, sideTwoDimension: r2Max-r2Min, sideThreeDimension: 1.0)
//
//        return (integral,newPointsBelow, newPointsAbove)
        
        
    }
    
    func calculateReal(R: Double)->Double{
        let aNaught = 0.529
        return exp(-1.0*Double(R)/aNaught)*(1+(R/aNaught)+(pow(R/aNaught,2)/3))
        
    }
    
    func convertToSpherical(x: Double, y: Double, z: Double) -> (r: Double, phi: Double, theta: Double){
        let r = sqrt(pow(x,2)+pow(y,2)+pow(z,2))
        var phi = 0.0
        if(x == 0.0 && y == 0.0){
            phi = 0.0
        }
        else{
            if(x == 0.0 && y < 0.0){
                phi = -1.0*Double.pi/2.0
            }
            else{
                if(x == 0.0 && y > 0.0){
                    phi = Double.pi/2.0
                }
                else{
                    if(x < 0.0 && y < 0.0){
                        phi = atan(y/x) - Double.pi
                    }
                    else{
                        if(x < 0.0 && y >= 0.0){
                            phi = atan(y/x) - Double.pi
                        }
                        else{
                            if(x > 0){
                                phi = atan(y/x)
                            }
                        }
                    }
                }
            }
        }
        
        let theta = acos(z/r)
        return((r: r, phi: phi, theta: theta))
        
    }
    
    
}
