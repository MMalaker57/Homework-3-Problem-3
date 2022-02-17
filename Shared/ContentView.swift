//
//  ContentView.swift
//  Shared
//
//  Created by Jeff Terry on 1/25/21.
//

import SwiftUI
import CorePlot
import simd

typealias plotDataType = [CPTScatterPlotField : Double]

//IMPORTANT INFORMATION
//
//THE MAIN FUNCTION USED TO CALCULATE THE INTEGRAL HAS THE ARGUMENTS: (lowerXBound: Double, upperXBound: Double,lowerYBound: Double, upperYBound: Double,lowerZBound: Double, upperZBound: Double, deltaX: Double, deltaY: Double, deltaZ: Double, maximumGuesses: UInt64)->(integral: Double, belowPoints: [(Double, Double, Double)], abovePoints: [(Double, Double, Double)])
//
//REFORMATTED, THAT IS:
///Parameters
/// - lowerXBound: Double - Lower bound of bounding box in x
/// - upperXBound: Double - Upper bound of bounding box in x
/// - lowerYBound: Double - Lower bound of bounding box in y
/// - upperYBound: Double - Upper bound of bounding box in y
/// - lowerZBound: Double - Lower bound of bounding box in z
/// - upperZBound: Double - Upper bound of bounding box in z
/// - deltaX: Double - Distance between atoms x coordinate
/// - deltaY: Double - Distance between atoms y coordinate
/// - deltaZ: Double - Distance between atoms z coordinate
/// - maximumGuesses: UInt64 - number of guesses for monte carlo
//
//THIS MEANS WE NEED A STRING VARIABLE, NUMERICAL VARIABLE, AND TEXT FIELD FOR ALL OF THESE
//USER INPUT MUST BE SANITIZED


struct ContentView: View {
    @EnvironmentObject var plotData :PlotClass
    
    @ObservedObject private var calculator = CalculatePlotData()
    @ObservedObject var integral = overlapIntegral()
    @State var isChecked:Bool = false
    @State var tempInput = ""
    
    @State var selector = 0

    //BEGIN VARAIBLE BLOCK
    @State var lowerXBoundDouble = 0.0
    @State var lowerXBoundString = ""
    @State var upperXBoundDouble = 0.0
    @State var upperXBoundString = ""
    @State var lowerYBoundDouble = 0.0
    @State var lowerYBoundString = ""
    @State var upperYBoundDouble = 0.0
    @State var upperYBoundString = ""
    @State var lowerZBoundDouble = 0.0
    @State var lowerZBoundString = ""
    @State var upperZBoundDouble = 0.0
    @State var upperZBoundString = ""
    @State var stepSizeDouble = 0.0
    @State var stepSizeString = ""
    
    @State var deltaXDouble = 0.0
    @State var deltaXString = ""
    @State var deltaYDouble = 0.0
    @State var deltaYString = ""
    @State var deltaZDouble = 0.0
    @State var deltaZString = ""
    @State var maximumGuesses: UInt64 = 1
    @State var maximumGuessesString = ""
    
    
    
    
    var body: some View {
        
        VStack{
      
            CorePlot(dataForPlot: $plotData.plotArray[selector].plotData, changingPlotParameters: $plotData.plotArray[selector].changingPlotParameters)
                .setPlotPadding(left: 10)
                .setPlotPadding(right: 10)
                .setPlotPadding(top: 10)
                .setPlotPadding(bottom: 10)
                .padding()
            
            Divider()
            VStack{
                HStack{
                    Text("Input x Lower Bound")
                        .font(.callout)
                        .bold()
                    TextField("", text: $lowerXBoundString, onCommit: {lowerXBoundDouble = Double(lowerXBoundString) ?? -1.0})
                        .padding()
                }
                
                HStack{
                    Text("Input x Upper Bound")
                        .font(.callout)
                        .bold()
                    TextField("", text: $upperXBoundString, onCommit: {upperXBoundDouble = Double(upperXBoundString) ?? 1.0})
                        .padding()
                }
                
                HStack{
                    Text("Input y Lower Bound")
                        .font(.callout)
                        .bold()
                    TextField("", text: $lowerYBoundString, onCommit: {lowerYBoundDouble = Double(lowerYBoundString) ?? -1.0})
                        .padding()
                }
                
                HStack{
                    Text("Input y Upper Bound")
                        .font(.callout)
                        .bold()
                    TextField("", text: $upperYBoundString, onCommit: {upperYBoundDouble = Double(upperYBoundString) ?? 1.0})
                        .padding()
                }
                
                HStack{
                    Text("Input z Lower Bound")
                        .font(.callout)
                        .bold()
                    TextField("", text: $lowerZBoundString, onCommit: {lowerZBoundDouble = Double(lowerZBoundString) ?? -1.0})
                        .padding()
                }
                
                HStack{
                    Text("Input z Upper Bound")
                        .font(.callout)
                        .bold()
                    TextField("", text: $upperZBoundString, onCommit: {upperZBoundDouble = Double(upperZBoundString) ?? 1.0})
                        .padding()
                }
            }
            
            VStack{
                HStack{
                    Text("Input x Displacement")
                        .font(.callout)
                        .bold()
                    TextField("", text: $deltaXString, onCommit: {deltaXDouble = Double(deltaXString) ?? 0.0})
                        .padding()
                }
            }
            HStack{
                Text("Input y Displacement")
                    .font(.callout)
                    .bold()
                TextField("", text: $deltaYString, onCommit: {deltaXDouble = Double(deltaXString) ?? 0.0})
                    .padding()
            }
        
            
            HStack{
                Button("Calculate Overlap", action: {
                    
                    Task.init{
                    self.selector = 0
                    await self.calculate()
                    }
                }
                
                
                )
                .padding()
                
            }
        }
            

            
        }
        
    
    
    @MainActor func setupPlotDataModel(selector: Int){
        
        calculator.plotDataModel = self.plotData.plotArray[selector]
    }
    
    
    /// calculate
    /// Function accepts the command to start the calculation from the GUI
    func calculate() async {
        
        //pass the plotDataModel to the Calculator
       // calculator.plotDataModel = self.plotData.plotArray[0]
        
        setupPlotDataModel(selector: 0)
        
     //   Task{
            
            
            let _ = await withTaskGroup(of:  Void.self) { taskGroup in



                taskGroup.addTask {

        
        var temp = 0.0
        
        
        
        //Calculate the new plotting data and place in the plotDataModel
        await calculator.ploteToTheMinusX()
        
                    // This forces a SwiftUI update. Force a SwiftUI update.
        await self.plotData.objectWillChange.send()
                    
                }

                
            }
            
  //      }
        
        
    }
    
    /// calculate
    /// Function accepts the command to start the calculation from the GUI
    func calculate2() async {
        
        
        //pass the plotDataModel to the Calculator
       // calculator.plotDataModel = self.plotData.plotArray[0]
        
        setupPlotDataModel(selector: 1)
        
     //   Task{
            
            
            let _ = await withTaskGroup(of:  Void.self) { taskGroup in



                taskGroup.addTask {

        
        var temp = 0.0
        
        
        
        //Calculate the new plotting data and place in the plotDataModel
        await calculator.plotYEqualsX()
                  
                    // This forces a SwiftUI update. Force a SwiftUI update.
        await self.plotData.objectWillChange.send()
                    
                }
                
            }
            
    //    }
        
        

    }
    
//BEGIN FUNCTION BLOCK
    func calculateOverlap(lowerXBound: Double, upperXBound: Double,lowerYBound: Double, upperYBound: Double,lowerZBound: Double, upperZBound: Double, deltaX: Double, deltaY: Double, deltaZ: Double, maximumGuesses: UInt64, stepSize: Double) async -> (integrals: [Double], belowPoints: [(Double, Double, Double)], abovePoints: [(Double, Double, Double)]){
        
        let R = sqrt(pow(deltaX,2) + pow(deltaY,2) + pow(deltaZ,2))
        let xStep = stepSize*(deltaX/sqrt(pow(deltaX,2)+pow(deltaY,2)+pow(deltaZ,2)))
        let yStep = stepSize*(deltaY/sqrt(pow(deltaX,2)+pow(deltaY,2)+pow(deltaZ,2)))
        let zStep = stepSize*(deltaZ/sqrt(pow(deltaX,2)+pow(deltaY,2)+pow(deltaZ,2)))
        let integralList = await withTaskGroup(of: Double, returning: [Double].self, body: {taskGroup in
        let numberOfSteps = Int(R/stepSize)
            
            for i in 0...numberOfSteps{
                traskGroup.addTask{
                    let integralValue = integral.calculate1sOverlap(lowerXBound: lowerXBound, upperXBound: upperXBound, lowerYBound: lowerYBound, upperYBound: upperYBound, lowerZBound: lowerZBound, upperZBound: upperZBound, deltaX: deltaX, deltaY: deltaY, deltaZ: deltaZ, maximumGuesses: maximumGuesses)
                    
                    
                }
            }
            
            
            
            
        })
        
        
        
        
    }
   
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
