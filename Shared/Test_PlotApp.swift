//
//  Test_PlotApp.swift
//  Shared
//
//  Created by Jeff Terry on 1/25/21.
//

import SwiftUI

@main
struct Test_PlotApp: App {

    

    
    
    @StateObject var plotData = PlotClass()
    @ObservedObject var overlap = overlapIntegral()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView(function1: overlap.psi1s, function2: overlap.psi1s, image: overlap.createCG().0, imageNS: overlap.createCG().1)
                    .environmentObject(plotData)
                    .tabItem {
                        Text("Plot")
                    }
                TextView()
                    .environmentObject(plotData)
                    .tabItem {
                        Text("Text")
                    }
                            
                            
            }
            
        }
    }
}

