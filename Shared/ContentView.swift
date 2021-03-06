//
//  ContentView.swift
//  Shared
//
//  Created by Jeff Terry on 1/25/21.
//

import SwiftUI
import CorePlot
import Foundation
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
    typealias plotDataType = [CPTScatterPlotField : Double]
    @ObservedObject private var calculator = CalculatePlotData()
    
    @ObservedObject var plotDataModel = PlotDataClass(fromLine: true)
    @ObservedObject var overlap = overlapIntegral()
    @State var isChecked:Bool = false
    @State var tempInput = ""
    
    @State var selector = 0

    //BEGIN VARAIBLE BLOCK
    @State var lowerXBoundDouble = -10.0
    @State var lowerXBoundString = ""
    @State var upperXBoundDouble = 10.0
    @State var upperXBoundString = ""
    @State var lowerYBoundDouble = -10.0
    @State var lowerYBoundString = ""
    @State var upperYBoundDouble = 10.0
    @State var upperYBoundString = ""
    @State var lowerZBoundDouble = -10.0
    @State var lowerZBoundString = ""
    @State var upperZBoundDouble = 10.0
    @State var upperZBoundString = ""
    @State var stepSizeDouble = 0.2
    @State var stepSizeString = ""
    
    @State var rDouble = 2.0
    @State var rString = ""
    @State var maximumGuesses: UInt64 = 50000
    @State var maximumGuessesString = ""
    
    @State var plotDataList: [(Double, Double)] = []
    @State var realDataList: [(Double, Double)] = []
    @State var func1String = "1s"
    @State var func2String = "1s"
        
    @State var function1: overlapIntegral.integrationFunctionHandler
    @State var function2: overlapIntegral.integrationFunctionHandler
    @State var belowPointsToDraw: [(xPoint: Double, yPoint: Double)] = []
    @State var abovePointsToDraw: [(xPoint: Double, yPoint: Double)] = []
    @State var probabilitiesBelow: [Double] = []
    @State var probabilitiesAbove: [Double] = []
    @State var image: CGImage
    @State var imageNS: NSImage
    @State var integralOutputString = ""
    
    
    var body: some View {
        

        VStack{
        HStack{	
            // Stop the window shrinking to zero.
                
            CorePlot(dataForPlot: $plotData.plotArray[selector].plotData, changingPlotParameters: $plotData.plotArray[selector].changingPlotParameters)
                .setPlotPadding(left: 10)
                .setPlotPadding(right: 10)
                .setPlotPadding(top: 10)
                .setPlotPadding(bottom: 10)
                .padding()

            Divider()
            
//            drawingView(redLayer:$belowPointsToDraw, blueLayer: $abovePointsToDraw, upperX: $upperXBoundDouble, upperY: $upperYBoundDouble)
//                .padding()
//                .aspectRatio(1, contentMode: .fit)
//                .drawingGroup()
            Image(nsImage: imageNS)
           
            Divider()
            
            VStack{
            VStack{
               
                HStack{
                    Text("Input x Upper Bound")
                        .font(.callout)
                        .bold()
                    TextField("", text: $upperXBoundString, onCommit: {upperXBoundDouble = Double(upperXBoundString) ?? 1.0;  lowerXBoundDouble = -1.0*upperXBoundDouble})
                        .padding()
                }
                
                
                HStack{
                    Text("Input y Upper Bound")
                        .font(.callout)
                        .bold()
                        TextField("", text: $upperYBoundString, onCommit: {upperYBoundDouble = Double(upperYBoundString) ?? 1.0; lowerYBoundDouble = -1.0*upperYBoundDouble})
                        .padding()
                }
                
                HStack{
                    Text("Input z Upper Bound")
                        .font(.callout)
                        .bold()
                    TextField("", text: $upperZBoundString, onCommit: {upperZBoundDouble = Double(upperZBoundString) ?? 1.0; lowerZBoundDouble = -1.0*upperZBoundDouble})
                        .padding()
                }
            }
            
            VStack{
                HStack{
                    Text("Input Distance Between Sources")
                        .font(.callout)
                        .bold()
                    TextField("", text: $rString, onCommit: {rDouble = Double(rString) ?? 0.0})
                        .padding()
                }
                
                HStack{
                    Text("Input Guesses Per Point")
                        .font(.callout)
                        .bold()
                    TextField("", text: $maximumGuessesString, onCommit: {maximumGuesses = UInt64(maximumGuessesString) ?? 1})
                        .padding()
                }
                
                HStack{
                    Text("Input Step Size")
                        .font(.callout)
                        .bold()
                    TextField("", text: $stepSizeString, onCommit: {stepSizeDouble = Double(stepSizeString) ?? 0.1})
                        .padding()
                }
                Picker("Psi1", selection: $func1String){
                    Text("1s").tag("1s")
                    Text("2px").tag("2px")
                    
                }
                
                Picker("Psi2", selection: $func2String){
                    Text("1s").tag("1s")
                    Text("2px").tag("2px")
                    
                }
            }
            
            HStack{
                Button("Calculate Overlap", action: {
                    
                    Task.init{
                    self.selector = 0
                        self.selectorFunc(function1Str: func1String, function2Str: func2String);plotDataList = await self.calculateOverlap(lowerXBound: lowerXBoundDouble, upperXBound: upperXBoundDouble, lowerYBound: lowerYBoundDouble, upperYBound: upperYBoundDouble, lowerZBound: lowerZBoundDouble, upperZBound: upperZBoundDouble, R: rDouble, maximumGuesses: maximumGuesses, stepSize: stepSizeDouble); realDataList = self.calculateRealValue(R: rDouble, stepSize: stepSizeDouble);self.drawOverlap(lowerXBound: lowerXBoundDouble, upperXBound: upperXBoundDouble, lowerYBound: lowerYBoundDouble, upperYBound: upperYBoundDouble, lowerZBound: lowerZBoundDouble, upperZBound: upperZBoundDouble, R: rDouble, maximumGuesses: maximumGuesses, stepSize: stepSizeDouble)
                    }
                })
                .padding()
                Button("Draw", action: {
                    
                    Task.init{
                    self.selector = 0
                        await self.calculate();
                        self.plotData.objectWillChange.send()
                    }
                })
//                Button("Apply", action: {
//                        self.selector(function1Str: func1String, function2Str: func2String)
//
//                })
                Button("Draw Real", action: {
                    
                    Task.init{
                    self.selector = 1
                        await self.calculate2();
                        self.plotData.objectWillChange.send()
                    }
                })
                
            }
            }
        }
            TextEditor(text: $integralOutputString)
            
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
        overlap.plotDataModel = self.plotDataModel
        
     //   Task{
            
            
            let _ = await withTaskGroup(of:  Void.self) { taskGroup in



                taskGroup.addTask {

        
        var temp = 0.0
        
        
        
        //Calculate the new plotting data and place in the plotDataModel
        
        await calculator.plotFunction(dataToPlot: plotDataList)
        
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
        await calculator.plotFunction(dataToPlot: realDataList)
                  
                    // This forces a SwiftUI update. Force a SwiftUI update.
        await self.plotData.objectWillChange.send()
                    
                }
                
            }
            
    //    }
        
        

    }
    
//BEGIN FUNCTION BLOCK
    func calculateOverlap(lowerXBound: Double, upperXBound: Double,lowerYBound: Double, upperYBound: Double,lowerZBound: Double, upperZBound: Double, R: Double, maximumGuesses: UInt64, stepSize: Double) async -> [(R: Double, integral: Double)]{
        plotDataList.removeAll()
        integralOutputString = ""
        var dataToPlot: [plotDataType] = []
        var plotData: [(Double, Double)] = []
        let NumberofThreads: UInt64 = 4
        var plotDataLarge: [(r: Double, calculatedData: (integral: Double, belowPoints: [(Double, Double, Double)], abovePoints: [(Double, Double, Double)]))] = []
        
        setupPlotDataModel(selector: 0)
        
        //Iterate over spots
        for r in stride(from: 0, through: R, by: stepSize){
            print(r)
            let guessesPerThread = maximumGuesses/NumberofThreads
            
            //calculate integral of separation r with number of threads of tasks
            let plotDataR = await withTaskGroup(of: (r: Double, calculatedData: (integral: Double, belowPoints: [(Double, Double, Double)], abovePoints: [(Double, Double, Double)])).self, returning: (r: Double, calculatedData: (integral: Double, belowPoints: [(Double, Double, Double)], abovePoints: [(Double, Double, Double)])).self, body: {taskGroup in
                
                var dataStruct: (r: Double, calculatedData: (integral: Double, belowPoints: [(Double, Double, Double)], abovePoints: [(Double, Double, Double)]))
                for i in stride(from: 1, through: NumberofThreads, by: 1){
                    taskGroup.addTask{
                        let dataSlice = await overlap.calculate1sOverlap(lowerXBound: lowerXBound, upperXBound: upperXBound, lowerYBound: lowerYBound, upperYBound: upperYBound, lowerZBound: lowerZBound, upperZBound: upperZBound, R: r, maximumGuesses: guessesPerThread, psi1: function1, psi2: function2)
                        return((r: r, calculatedData: dataSlice))
                    }
                }
                
//                Interim
                var interimResults:[(r: Double, calculatedData: (integral: Double, belowPoints: [(Double, Double, Double)], abovePoints: [(Double, Double, Double)]))] = []
                for await result in taskGroup{
                    interimResults.append(result)
                }
                dataStruct.r = interimResults[0].r
                var tempIntegral = 0.0
                var pointsBelowList: [(Double, Double, Double)] = []
                var pointsAboveList: [(Double, Double, Double)] = []
                for i in interimResults{
                    tempIntegral += i.calculatedData.integral
                    for j in i.calculatedData.belowPoints{
                        pointsBelowList.append(j)
                    }
                    for j in i.calculatedData.abovePoints{
                        pointsAboveList.append(j)
                    }
                }
                dataStruct.calculatedData.belowPoints = pointsBelowList
                dataStruct.calculatedData.abovePoints = pointsAboveList
                dataStruct.calculatedData.integral = tempIntegral/Double(NumberofThreads)
                return dataStruct
                
            })
            
            plotDataLarge.append(plotDataR)
            
        }
        
        for i in plotDataLarge{
            plotData.append((i.r, i.calculatedData.integral))
            integralOutputString.append("Integral value at R= \(i.r) = \(i.calculatedData.integral) \n")
            print(i.calculatedData.integral)
        }
        plotDataModel.appendData(dataPoint: dataToPlot)
        return plotData
        

    }
    
    func drawOverlap(lowerXBound: Double, upperXBound: Double,lowerYBound: Double, upperYBound: Double,lowerZBound: Double, upperZBound: Double, R: Double, maximumGuesses: UInt64, stepSize: Double){
        belowPointsToDraw.removeAll()
        abovePointsToDraw.removeAll()
        
        let drawMass = overlap.calculateOverlapPointsOutputData(lowerXBound: lowerXBound, upperXBound: upperXBound, lowerYBound: lowerYBound, upperYBound: upperYBound, lowerZBound: lowerZBound, upperZBound: upperZBound, R: R, maximumGuesses: 10000, psi1: function1, psi2: function2)
        print("drawmass")
        print(drawMass.count)
        let dataFormatted = overlap.formatData(data: drawMass)
        print("data")
        print(dataFormatted.count)
        let pixelData = Data(fromArray: dataFormatted)
        let cfData = NSData(data: pixelData) as CFData
        let provider = CGDataProvider(data: cfData)!
        let info: CGBitmapInfo = [.byteOrder32Little, .floatComponents]
        let cg = CGImage(width: 601, height: 601, bitsPerComponent: 32, bitsPerPixel: 96, bytesPerRow: (96/8)*601, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: info, provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)!
        image = cg
        
        imageNS = NSImage(cgImage: image, size: .zero)
    }
   
    func calculateRealValue(R: Double, stepSize: Double) -> [(Double, Double)]{
//        setupPlotDataModel(selector: 1)
        var tempData: [(Double, Double)] = []
        var dataToPlot: [plotDataType] = []
        for r in stride(from: 0, through: R, by: stepSize){
            let calculatedIntegral = overlap.calculateReal(R: r)
            let dataPoint: plotDataType = [.X: Double(r), .Y: (calculatedIntegral)]
            dataToPlot.append(contentsOf: [dataPoint])
            tempData.append((r, calculatedIntegral))
        }
        return tempData
    }
    
    func selectorFunc(function1Str: String, function2Str: String){
        switch function1Str{
            case "1s" :
            function1 = overlap.psi1s
            print("1s")
            case "2px" :
            function1 = overlap.psi2px
            print("2px")
        default:
            function1 = overlap.psi1s
        print("default")
        }

        switch function2Str{
            case "1s" :
            function2 = overlap.psi1s
            print("1s")
            case "2px" :
            function2 = overlap.psi2px
            print("2px")
        default:
            function2 = overlap.psi1s
            print("default")
        }

    }
    
    

    
    func returningColorCGImage(data: [Float], width: Int, height: Int, rowBytes: Int) -> CGImage{
        let pixelDataAsData = Data(fromArray: data)
        let cfdata = NSData(data: pixelDataAsData) as CFData
        
        let provider = CGDataProvider(data: cfdata)!
        
        let bitmapInfo: CGBitmapInfo = [
            .byteOrder32Little,
            .floatComponents]
              
        let pixelCGImage = CGImage(width:  width, height: height, bitsPerComponent: 32, bitsPerPixel: 96, bytesPerRow: rowBytes, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo, provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)!
        return pixelCGImage
    }
    
    
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
extension Data {

    init<T>(fromArray values: [T]) {
        self = values.withUnsafeBytes { Data($0) }
    }

    func toArray<T>(type: T.Type) -> [T] where T: ExpressibleByIntegerLiteral {
        var array = Array<T>(repeating: 0, count: self.count/MemoryLayout<T>.stride)
        _ = array.withUnsafeMutableBytes { copyBytes(to: $0) }
        return array
    }
}

