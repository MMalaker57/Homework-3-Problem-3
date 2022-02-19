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
    typealias integrationFunctionHandler = (_ inputs: (r: Double, phi: Double, theta: Double))-> Double
    
    //THIS NEEDS TO TAKE TWO ARBITRARY FUNCTIONS
    func calculate1sOverlap(lowerXBound: Double, upperXBound: Double,lowerYBound: Double, upperYBound: Double,lowerZBound: Double, upperZBound: Double, R: Double, maximumGuesses: UInt64, psi1: integrationFunctionHandler, psi2: integrationFunctionHandler) -> (integral: Double, belowPoints: [(Double, Double, Double)], abovePoints: [(Double, Double, Double)]){
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
            
        
        var data: [(probability: Double, x: Double, y: Double, z: Double)] = []
            for i in stride(from: 1, through: maximumGuesses, by: 1){
                
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
                    
                    let probabilityAtPoint = psi1(self.convertToSpherical(x: xtemp1, y: point.yCoord, z: point.zCoord)) * psi2(self.convertToSpherical(x: xtemp2, y: point.yCoord, z: point.zCoord))
                    
                data.append((probability: probabilityAtPoint, x: point.xCoord, y: point.yCoord, z: point.zCoord))
                
            }
            
        
        var sumOfP: Double = 0.0
        for i in data{
            sumOfP += i.probability
            
        }
        sumOfP *= (1/(Double.pi*pow(aNaught,3)))

        integral = Double(sumOfP)/Double(maximumGuesses)*box.cuboidVolume(numberOfSides: 3, sideOneDimension: upperXBound - lowerXBound, sideTwoDimension: upperYBound - lowerYBound, sideThreeDimension: upperZBound - lowerZBound)
        
        
        return((integral: integral, belowPoints: newPointsBelow, abovePoints: newPointsAbove))
        

        
        
    }
    
    
    
    
    func calculateOverlapPoints(lowerXBound: Double, upperXBound: Double,lowerYBound: Double, upperYBound: Double,lowerZBound: Double, upperZBound: Double, R: Double, maximumGuesses: UInt64, psi1: integrationFunctionHandler, psi2: integrationFunctionHandler) -> (probabilityBelow: [Double], probabilityAbove: [Double], pointsBelow: [(xPoint: Double, yPoint: Double)], pointsAbove: [(xPoint: Double, yPoint: Double)]){
        
        //This is the same as the integral, just without the integratiom. We are trying to get the data in a nice 2d form for plotting
        //Doing this each time is a waste of time
        var pointsBelow: [(xPoint: Double, yPoint: Double)] = []
        var pointsAbove: [(xPoint: Double, yPoint: Double)] = []
        var probabilityBelow: [Double] = []
        var probabilityAbove: [Double] = []
        
        var data: (probabilityBelow: [Double], probabilityAbove: [Double], pointsBelow: [(xPoint: Double, yPoint: Double)], pointsAbove: [(xPoint: Double, yPoint: Double)])
            for i in stride(from: 1, through: 2000, by: 1){
                
                    var point = (xCoord: 0.0, yCoord: 0.0, zCoord: 0.0)
                    
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
                    
                    let probabilityAtPoint = psi1(self.convertToSpherical(x: xtemp1, y: point.yCoord, z: point.zCoord)) * psi2(self.convertToSpherical(x: xtemp2, y: point.yCoord, z: point.zCoord))
                
                var vertical = 0.0
                if point.yCoord < 0.0{
                    vertical = -1.0*sqrt(pow(point.yCoord, 2)+pow(point.zCoord, 2))
                    
                }
                else{
                    vertical = sqrt(pow(point.yCoord, 2)+pow(point.zCoord, 2))
                }
                if probabilityAtPoint < 0{
                    pointsBelow.append((xPoint: point.xCoord, yPoint: vertical))
                    probabilityBelow.append(probabilityAtPoint)
                }
                else{
                    pointsAbove.append((xPoint: point.xCoord, yPoint: vertical))
                    probabilityAbove.append(probabilityAtPoint)
                }
                    
                
            }
            
        data = (probabilityBelow, probabilityAbove, pointsBelow, pointsAbove)
        
        return data
        

        
        
    }
    
    
    
    
    
    
    func calculateReal(R: Double)->Double{
        let aNaught = 0.529
        return exp(-1.0*Double(R)/aNaught)*(1+(R/aNaught)+(pow(R/aNaught,2)/3))
        
    }
    
    func convertToSpherical(x: Double, y: Double, z: Double) -> (r: Double, phi: Double, theta: Double){
        let r = sqrt(pow(x,2)+pow(y,2)+pow(z,2))
        let phi = atan2(y, x)
        
        let theta = acos(z/r)
        return((r: r, phi: phi, theta: theta))
        
    }
    func psi1s(r: Double, phi: Double, theta: Double)->Double{
        let aNaught = 0.529
        return exp(-1.0*r/aNaught)
    }
    
    func psi2px(r: Double, phi: Double, theta: Double)->Double{
        let aNaught = 0.529
        //we have a constant multiple of 1/4sqrt(2), but calculating that each time is dumb. Double precision is just shy of 16 decimal places, so I've pre-calculated the value of 1/4sqrt(2) to that places.
        //Ideally, it'd be best to apply this factor at the END of the integral ( it factors out ), but when the function is selectable, that is not really an option.
        //There is ALWAYS a factor of 1/sqrt(pi*a^3), though
        //The trig functions make this REALLY slow
        return (r/aNaught)*exp(-1.0*r/(2*aNaught))*(0.1767766952966368)*sin(theta)*cos(phi)
    }
}
