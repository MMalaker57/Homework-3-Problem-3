//
//  Bounding Box.swift
//  Homework 1
//
//  Created by Matthew Malaker on 1/26/22.
//

import Foundation


//It is important to note that bounding boxes are used in two and three dimensions, so we should impliment both cases in the same piece of code in order to maximize its usefullness. There are two ways to do this.
//One way is to have an integer argument that contains the desired dimension and is used in "if" statements to control the code. The other would be to have the function change its behavior depending on if two or three arguments were passed to it. The former requires extra effort each time the function is implimented but is significantly more explicit in how it behaves.
//Another option is simply to pass zeroes for third dimension if a 2D box is desired.
//Another option is to make the function take an arbitrary number of "Double" parameters and output the surface area and volume of said N-dimensional object. This is the most general way to make a function like this. I've written code for such functions, but said work is not complete for the perimeter and is commented out as a result.

class Bounding_Box: NSObject, ObservableObject{
    /// - Parameters:
    ///   - numberOfSides: Number of sides of bounding box
    ///   - sideOneDimension: Length of side one
    ///   - sideTwoDimension: Length of side two
    ///   - SideThreeDimension: Length of side three
    /// - Returns: Volume of the Cuboid

    func cuboidVolume(numberOfSides: Int, sideOneDimension: Double, sideTwoDimension: Double, sideThreeDimension: Double) -> Double {
        if numberOfSides == 2{
            return(abs(sideOneDimension*sideTwoDimension))
        }
        else{
            return (abs(sideOneDimension*sideTwoDimension*sideThreeDimension))
        }
    }

    /// - Parameters:
    ///   - numberOfSides: Number of sides of bounding box
    ///   - sideOneDimension: Length of side one
    ///   - sideTwoDimension: Length of side two
    ///   - sideThreeDimension: Length of side three
    /// - Returns: Surface Area of the Cuboid
    /// - Note:
    ///  - The three sides of the cuboid need not be identical, but for implimentaions needing a cube, a single value should be passed
    ///     two or three times

    func cuboidSurfaceArea(numberOfSides: Int, sideOneDimension: Double, sideTwoDimension: Double, sideThreeDimension: Double) -> Double {
        var perimeter = 0.0
        var sideOneDimensionAbs = 0.0
        var sideTwoDimensionAbs = 0.0
        var sideThreeDimensionAbs = 0.0
        sideOneDimensionAbs = abs(sideOneDimension)
        sideTwoDimensionAbs = abs(sideTwoDimension)
        sideThreeDimensionAbs = abs(sideThreeDimension)
        
        //We must take twice the value of each side, but it is better to factor out the two. This requires only one multiply operation rather than three
        if numberOfSides==2{
            perimeter = 2*sideOneDimensionAbs*sideTwoDimensionAbs
        }
        else{
            perimeter=(2*((sideOneDimensionAbs*sideTwoDimensionAbs)+(sideTwoDimensionAbs*sideThreeDimensionAbs)+(sideOneDimensionAbs*sideThreeDimensionAbs)))
        }
        return(perimeter)
    }
    
//
//
//
//  Below are the functions I mentioned previously that attempt to calculate the volume and surface area of
//  an N-Dimensional rectangular prism. The volume function is complete, but the perimeter function is not. I
//  am not exactly sure how to impliment the perimeter as of currently, so I left it for another day in case
//  it will be beneficial to have such a function. The idea is to have a function that is easy to impliment
//  because it can be passed an arbitrary number of double values, one for each dimension of the n-sided
//  orthorhomboid.
//
//  Each function is commented out and is NOT used in homework one. There is no reason to look at either other
//  than curiosity. I left them in because I might work on them later.
//
//    func NCuboidVolume(_ dimensions: Double...) -> Double {
//        //We cannot rely on the programmer to impliment the function properly, so we must sanitize the inputs.
//        //We cannot have negative side lengths, so we will take the magnitude of each given dimension and use
//        //the result
//
//        var volume = 1.0
//
//        for side in stride(from: 0, to: dimensions.count, by:1){
//
//            volume *= abs(dimensions[side])
//        }
//
//        return(volume)
//    }
//    func NCuboidSurfaceArea(_ dimensions: Double...) -> Double {
//        //We cannot rely on the programmer to impliment the function properly, so we must sanitize the inputs.
//        //We cannot have negative side lengths, so we will take the magnitude of each given dimension and use
//        //the result
//
//        var perimeter = 0.0
//        var sanitizedDimensions = Array(repeating: 0.0, count: dimensions.count)
//        for i in stride(from: 0, to: dimensions.count, by: 1){
//            sanitizedDimensions[i] = abs(dimensions[i])
//        }
//
//
//        //THE FOLLOWING IS WRONG
//        //We need to iterate over each permutation of sides to get the surface ara
//        for i in stride(from: 0, to: sanitizedDimensions.count, by: 1){
//            for j in stride(from: i, through: sanitizedDimensions.count-1, by: 1){
//                perimeter += sanitizedDimensions[i]*sanitizedDimensions[j]
//            }
//        }
//        perimeter*=2.0
//        return(perimeter)
//
//
//}

}








