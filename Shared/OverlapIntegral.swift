//
//  OverlapIntegral.swift
//  Homework 3 Problem 3 Attempt One
//
//  Created by Matthew Malaker on 2/17/22.
//

import SwiftUI
import CorePlot
import Foundation
import simd

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

class overlapIntegral: NSObject, ObservableObject {
    
    var plotDataModel: PlotDataClass? = nil
    typealias integrationFunctionHandler = (_ r: Double, _ phi: Double, _ theta: Double) -> Double
    
    func createCG() -> (CGImage, NSImage){
        var imageData: [Double] = []
        for i in stride(from: 1, through: 600, by: 1){
            for j in stride(from: 1, through: 600, by: 1){
                imageData.append(1)
                imageData.append(1)
                imageData.append(30)

            }
        }
        let pixelData = Data(fromArray: imageData)
        let cfData = NSData(data: pixelData) as CFData
        let provider = CGDataProvider(data: cfData)!
        let info: CGBitmapInfo = [.byteOrder32Little, .floatComponents]
        let cg = CGImage(width: 600, height: 600, bitsPerComponent: 32, bitsPerPixel: 96, bytesPerRow: 7200, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: info, provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)!
        var ns = NSImage(cgImage: cg, size: .zero)
        return (cg,ns)
        
    }
    
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
                

                    var xtemp1 = point.xCoord + (R/2)
                    var xtemp2 = point.xCoord - (R/2)
                    
                let psi1Coords =  convertToSpherical(x: xtemp1, y: point.yCoord, z: point.zCoord)
                let psi2Coords =  convertToSpherical(x: xtemp2, y: point.yCoord, z: point.zCoord)
                
                let probabilityAtPoint = psi1(psi1Coords.r, psi1Coords.phi, psi1Coords.theta) * psi2(psi2Coords.r, psi2Coords.phi, psi2Coords.theta)
                

                    
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
            for i in stride(from: 1, through: 10000000, by: 1){
                
                    var point = (xCoord: 0.0, yCoord: 0.0, zCoord: 0.0)
                    
                    point.xCoord = Double.random(in: lowerXBound...upperXBound)
                    point.yCoord = Double.random(in: lowerYBound...upperYBound)
                    point.zCoord = 0.0
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
                let psi1Coords =  convertToSpherical(x: xtemp1, y: point.yCoord, z: point.zCoord)
                let psi2Coords =  convertToSpherical(x: xtemp2, y: point.yCoord, z: point.zCoord)
                
                let probabilityAtPoint = psi1(psi1Coords.r, psi1Coords.phi, psi1Coords.theta) * psi2(psi2Coords.r, psi2Coords.phi, psi2Coords.theta)
                
                var vertical = point.yCoord
//                if point.yCoord < 0.0{
//                    vertical = -1.0*sqrt(pow(point.yCoord, 2)+pow(point.zCoord, 2))
//
//                }
//                else{
//                    vertical = sqrt(pow(point.yCoord, 2)+pow(point.zCoord, 2))
//                }
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
    
    
    
    func calculateOverlapPointsOutputData(lowerXBound: Double, upperXBound: Double,lowerYBound: Double, upperYBound: Double,lowerZBound: Double, upperZBound: Double, R: Double, maximumGuesses: UInt64, psi1: integrationFunctionHandler, psi2: integrationFunctionHandler) -> [(x: Double, y: Double, probability: Double)]{
        
        //This is the same as the integral, just without the integratiom. We are trying to get the data in a nice 2d form for plotting
        //Doing this each time is a waste of time
        var pointsBelow: [(xPoint: Double, yPoint: Double)] = []
        var pointsAbove: [(xPoint: Double, yPoint: Double)] = []
        var probabilityBelow: [Double] = []
        var probabilityAbove: [Double] = []
        
        var data: [(x: Double, y: Double, probability: Double)] = []
            for i in stride(from: 1, through: 10000000, by: 1){
                
                    var point = (xCoord: 0.0, yCoord: 0.0, zCoord: 0.0)
                    
                    point.xCoord = Double.random(in: lowerXBound...upperXBound)
                    point.yCoord = Double.random(in: lowerYBound...upperYBound)
                    point.zCoord = 0.0
//                    print(point)
                
                    var xtemp1 = point.xCoord + (R/2)
                    var xtemp2 = point.xCoord - (R/2)
                    
            
                let psi1Coords =  convertToSpherical(x: xtemp1, y: point.yCoord, z: point.zCoord)
                let psi2Coords =  convertToSpherical(x: xtemp2, y: point.yCoord, z: point.zCoord)
                
                let probabilityAtPoint = psi1(psi1Coords.r, psi1Coords.phi, psi1Coords.theta) * psi2(psi2Coords.r, psi2Coords.phi, psi2Coords.theta)
                
                var vertical = point.yCoord

                data.append((x: point.xCoord, y: point.yCoord, probability: probabilityAtPoint))
                
            }
        
        return data
    }
    
    
    
    
    func calculateReal(R: Double)->Double{
        let aNaught = 0.529
        return exp(-1.0*Double(R)/aNaught)*(1+(R/aNaught)+(pow(R/aNaught,2)/3))
        
    }
    
    func convertToSpherical(x: Double, y: Double, z: Double) -> (r: Double, phi: Double, theta: Double){
        let r = sqrt(pow(x,2)+pow(y,2)+pow(z,2))
        let phi = atan2(y, x)
        let theta = atan2(sqrt(pow(x,2.0)+pow(y,2.0)),z)
        return((r: r, phi: phi, theta: theta))
        
    }
    func psi1s(r: Double, phi: Double, theta: Double)->Double{
//        print("Psi1s Called")
        let aNaught = 0.529177210903
        return exp(-1.0*r/aNaught)
    }
    
    func psi2px(r: Double, phi: Double, theta: Double)->Double{
//        print("Psi2px Called")
        let aNaught = 0.529177210903
        //we have a constant multiple of 1/4sqrt(2), but calculating that each time is dumb. Double precision is just shy of 16 decimal places, so I've pre-calculated the value of 1/4sqrt(2) to that places.
        //Ideally, it'd be best to apply this factor at the END of the integral ( it factors out ), but when the function is selectable, that is not really an option.
        //There is ALWAYS a factor of 1/sqrt(pi*a^3), though
        //The trig functions make this REALLY slow
        return (r/aNaught)*exp(-1.0*r/(2*aNaught))*(0.1767766952966368)*sin(theta)*cos(phi)
    }
    
    func formatData(data: [(x: Double, y: Double, probability: Double)])->[Float]{
        var rgbaData: [Float] = [] //R[(x,y)], G[(x,y)], B[(x,y)], A[(x,y)], REPEAT
        //We need to go across each point and assign it's place in the array based on its coordinates and its color based on the probability at that point
        var xs: [Double] = []
        var ys: [Double] = []
        var ps: [Double] = []
        for i in data{
            xs.append(i.x)
            ys.append(i.y)
            ps.append(i.probability)
        }
        let maxX = xs.max() ?? 1.0
        
        let maxY = ys.max() ?? 1.0
        let minX = xs.min() ?? 1.0
        let minY = ys.min() ?? 1.0
        let maxP = ps.max() ?? 1.0
        print("maxX = \(maxX), minX = \(minX), maxY = \(maxY), minY = \(minY)")
        
        
        var pixelData: [(xPixel: Int, yPixel: Int, probability: Double)] = []
        var pixelData2: [(xPixel: Int, yPixel: Int, probability: Double)] = []
        var samePixels: [(xPixel: Int, yPixel: Int, probability: Double)] = []
    
        //First we need to convert each X and Y coordinate to pixels
        let width = 601.0
        let height = 601.0
        let pscale = 1/abs(log2(maxP))
        print("pscale = \(pscale)")
        let hscale = Double(width/(maxX-minX))
        print(hscale)
        let vscale = Double(height/(maxY-minY))
        print(vscale)
        
        //assign to pixel. We can only have one pixel at each dimension, which will end up being the sum of P at that pixel
        
        for i in data{
            pixelData2.append((xPixel: Int((hscale*i.x+(width/2.0))), yPixel: Int((vscale*i.y+(height/2.0))), probability:(i.probability)))
        }
        
        var nextIsNew = false
        var pSum = 0.0
        //sum p for all identical x and y
        //We will append the current point to samePixels. If the next point is new, we will sum all p in samepixels and append the sum to pixelData. Else, we just continue. We clear samePixels and pSum on add
        
        //We need to make sure we have data at each pixel, otherwise our formatted data will not have enough pixels
        
        
        for i in stride(from: 0, through: 600, by: 1){
            for j in stride(from: 0, through: 600, by: 1){
                pixelData2.append((xPixel: i, yPixel: j, probability: 0.0))
            }

        }
        
        pixelData2.sort{
            ($0.xPixel, $0.yPixel, $0.probability) <
            (($1.xPixel, $1.yPixel, $1.probability))
        }
        print("pixelData2 is \(pixelData2.count) long")
        

        
        for i in stride(from: 0, to: pixelData2.count-1, by: 1){
            samePixels.append(pixelData2[i])
//            print("current x is: \(pixelData2[i].xPixel), next x is: \(pixelData2[i+1].xPixel), current y is: \(pixelData2[i].yPixel), next y is: \(pixelData2[i+1].yPixel)")
            
            //check if point in front is new
            //We do this because we need to sum the probabilities if and only if the next point is new. If not, then we continue and add it's probability to the pixel on the next pass
            //The time we need to do all of the summing of P. Converting to RGB will be based on the sign of P
            if (pixelData2[i+1].xPixel != pixelData2[i].xPixel || pixelData2[i+1].yPixel != pixelData2[i].yPixel){
                for j in samePixels{
                    pSum += j.probability
                }
                pixelData.append((pixelData2[i].xPixel,pixelData2[i].yPixel, pSum))
                pSum = 0.0
                samePixels.removeAll()
//                print("appended and pixelData is \(pixelData.count) long")
            }
        }
        
        //sort pixelData
        //PixelData does not have data for each pixel, so we need to add dummy data at x,y without data
        
//        var hasBoth = false
        
        
//        for i in stride(from: 1, through: 600, by: 1){
//            for j in stride(from: 1, through: 600, by: 1){
//                for k in pixelData{
//                    if (k.xPixel == i && k.yPixel == j){
//                        hasBoth = true
//                    }
//
//                }
//
//                if hasBoth == false{
//                    pixelData.append((xPixel: i, yPixel: j, probability: 0.0))
//                }
//                hasBoth = false
//            }
//
//        }
        if pixelData.count == 361200{
            
            pixelData.append((xPixel: 601, yPixel: 601, probability: 0.0))
        }
        
        pixelData.sort{
            ($0.xPixel, $0.yPixel, $0.probability) <
            (($1.xPixel, $1.yPixel, $1.probability))
        }
        
        print("pixelData is \(pixelData.count) long")
        
        
        
        for i in stride(from: 0, to: pixelData.count-2, by: 1){

                    if pixelData[i].xPixel == pixelData[i+1].xPixel && pixelData[i].yPixel == pixelData[i+1].yPixel{
//                        print("Duplicate point at x= \(pixelData[i].xPixel), y=\(pixelData[i].yPixel)")
                    }
//            print("x: \(pixelData[i].xPixel), y: \(pixelData[i].yPixel)")
        }
        
        
        print("pixelData is \(pixelData.count) long")
        //Here, we have an array of UNIQUE points about to be assigned a. RGBA value. A=255, but color depends on sign.
        //Negative p are red. Positive are blue
        for i in pixelData{
            
//            print("color=\((abs((i.probability * pscale))))")
            if i.probability == 0{
                rgbaData.append(1)
                rgbaData.append(1)
                rgbaData.append(1)
            }
            if i.probability < 0{
                
                rgbaData.append(0)
                rgbaData.append(0)
                var color: Float = Float((log2(abs((i.probability))) + 20.0)*pscale/2)
                if color < 0.0{
                    color = Float(0.0)
                }
//                if(color > 0.0){
//                    print("probability: \(i.probability) = \(color)")
//                }
                
                rgbaData.append(color)
                                
            }
            if i.probability > 0{
                var color: Float = Float((log2(abs((i.probability))) + 20.0)*pscale/2)
                if color < 0.0{
                    color = Float(0.0)
                }
//                if color > 0.0{
//                print("probability: \(i.probability) = \(color)")
//                }
                rgbaData.append(color)
                rgbaData.append(0)
                rgbaData.append(0)
                
            }
        }
        
//        for i in stride(from: 1, through: 360000, by: 1){
//            rgbaData.append(50)
//            rgbaData.append(50)
//            rgbaData.append(0.8)
////            rgbaData.append(0.5)
////            rgbaData.append(0)
////            rgbaData.append(0.5)
//        }
        return rgbaData
    }
    
}

