//
//  CalculatePlotData.swift
//  SwiftUICorePlotExample
//
//  Created by Jeff Terry on 12/22/20.
//

import Foundation
import SwiftUI
import CorePlot

class CalculatePlotData: ObservableObject {
    
    var plotDataModel: PlotDataClass? = nil
    var theText = ""
    

    @MainActor func setThePlotParameters(color: String, xLabel: String, yLabel: String, title: String) {
        //set the Plot Parameters
        plotDataModel!.changingPlotParameters.yMax = 2.0
        plotDataModel!.changingPlotParameters.yMin = -1.0
        plotDataModel!.changingPlotParameters.xMax = 10.0
        plotDataModel!.changingPlotParameters.xMin = -1.0
        plotDataModel!.changingPlotParameters.xLabel = xLabel
        plotDataModel!.changingPlotParameters.yLabel = yLabel
        
        if color == "Red"{
            plotDataModel!.changingPlotParameters.lineColor = .red()
        }
        else{
            
            plotDataModel!.changingPlotParameters.lineColor = .blue()
        }
        plotDataModel!.changingPlotParameters.title = title
        
        plotDataModel!.zeroData()
    }
    
    @MainActor func appendDataToPlot(plotData: [plotDataType]) {
        plotDataModel!.appendData(dataPoint: plotData)
    }
    
    func plotYEqualsX() async
    {
        
        theText = "y = x\n"
        
        await setThePlotParameters(color: "Red", xLabel: "R", yLabel: "Integral", title: "Integral Vs R")
        
        await resetCalculatedTextOnMainThread()
        
        
        var plotData :[plotDataType] =  []
        
        
        for i in 0 ..< 120 {
             
            //create x values here

            let x = -2.0 + Double(i) * 0.2

        //create y values here

        let y = x


            let dataPoint: plotDataType = [.X: x, .Y: y]
            plotData.append(contentsOf: [dataPoint])
            theText += "x = \(x), y = \(y)\n"
        
        }
        
        await appendDataToPlot(plotData: plotData)
        await updateCalculatedTextOnMainThread(theText: theText)
        
        
    }
    
    
    func plotFunction(dataToPlot: [(r: Double, integral: Double)]) async
    {
        
//        var rs: [Double] = []
//        var ints: [Double] = []
//        for i in dataToPlot{
//            rs.append(i.r)
//            ints.append(i.integral)
//        }
        //set the Plot Parameters
        await plotDataModel!.changingPlotParameters.yMax = 2.0
        await plotDataModel!.changingPlotParameters.yMin = -1.0
        await plotDataModel!.changingPlotParameters.xMax = 10.0
        await plotDataModel!.changingPlotParameters.xMin = -1.0
        await plotDataModel!.changingPlotParameters.xLabel = "R"
        await plotDataModel!.changingPlotParameters.yLabel = "Integral"
        await plotDataModel!.changingPlotParameters.lineColor = .blue()
        await plotDataModel!.changingPlotParameters.title = "Integral Vs R"

        await plotDataModel!.zeroData()
        var plotData :[plotDataType] =  []
        
        
        
        await setThePlotParameters(color: "Blue", xLabel: "r", yLabel: "Integral", title: "1s Overlap Integral")
        
        await resetCalculatedTextOnMainThread()
        
        theText = "1s Overlap Integral\n"
        
        for i in dataToPlot {

            //create x values here
            let x = i.r

            //create y values here
            let y = i.integral
            
            let dataPoint: plotDataType = [.X: x, .Y: y]
            plotData.append(contentsOf: [dataPoint])
            theText += "x = \(x), y = \(y)\n"
        }
        
        await appendDataToPlot(plotData: plotData)
        await updateCalculatedTextOnMainThread(theText: theText)
        
        return
    }
    
    
        @MainActor func resetCalculatedTextOnMainThread() {
            //Print Header
            plotDataModel!.calculatedText = ""
    
        }
    
    
        @MainActor func updateCalculatedTextOnMainThread(theText: String) {
            //Print Header
            plotDataModel!.calculatedText += theText
        }
    
}



