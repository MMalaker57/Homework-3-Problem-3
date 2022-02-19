//
//  DrawingView.swift
//  Monte Carlo Integration
//
//  Created by Jeff Terry on 12/31/20.
//

import SwiftUI

struct drawingView: View {
    
    @Binding var redLayer : [(xPoint: Double, yPoint: Double)]
    @Binding var blueLayer : [(xPoint: Double, yPoint: Double)]
    @Binding var upperX: Double
    @Binding var upperY: Double

    
    var body: some View {
    
        
        ZStack{
        
            drawIntegral(upperXBound: upperX, upperYBound: upperY, drawingPoints: redLayer)
                .stroke(Color.red)
            
            drawIntegral(upperXBound: upperX, upperYBound: upperY, drawingPoints: blueLayer)
                .stroke(Color.blue)
        }
        .background(Color.white)
        .aspectRatio(1, contentMode: .fill)
        
    }
}

struct DrawingView_Previews: PreviewProvider {
    
    @State static var redLayer : [(xPoint: Double, yPoint: Double)] = [(-5.0, 5.0), (5.0, 5.0), (0.0, 0.0), (0.0, 5.0)]
    @State static var upperX: Double = 10.0
    @State static var upperY: Double = 10.0
    @State static var blueLayer : [(xPoint: Double, yPoint: Double)] = [(-5.0, -5.0), (5.0, -5.0), (4.5, 0.0)]
    
    static var previews: some View {
       
        
        drawingView(redLayer: $redLayer, blueLayer: $blueLayer, upperX: $upperX, upperY: $upperY)
            .aspectRatio(1, contentMode: .fill)
            //.drawingGroup()
           
    }
}



struct drawIntegral: Shape {
    
    var upperXBound: Double
    var upperYBound: Double
    let smoothness : CGFloat = 1.0
    var drawingPoints: [(xPoint: Double, yPoint: Double)]  ///Array of tuples
    
    func path(in rect: CGRect) -> Path {
        
               
        // draw from the center of our rectangle
        
        
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let hScale = rect.width/(2.5*upperXBound)
        let vScale = rect.height/(2.5*upperYBound)
        

        // Create the Path for the display
        
        var path = Path()
        
        for item in drawingPoints {

            path.addRect(CGRect(x: item.xPoint*Double(hScale)+center.x, y: item.yPoint*Double(vScale)+center.y, width: 2.0, height: 2.0 ))
//            path.addLine(to: CGPoint(x: item.xPoint*Double(hScale), y: item.yPoint*Double(vScale)))

        }
        
        

        
        return (path)
    }
}

