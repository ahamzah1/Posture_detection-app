//
//  HistoryView.swift
//  AlignPro
//
//  Created by Ty Greenwood on 2024-12-30.
//

import SwiftUI

struct HistoryView: View {
    var PlotType = ["Day", "Week"]
    @State private var selectedPlotType = "Day"
    
    var body: some View {
        ZStack{
            Color("Background Colour")
                .ignoresSafeArea()
            
            VStack{
                Text("Posture History")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("Text Colour"))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.all)
                    
                //Spacer()
                
                Picker("Plot Type", selection: $selectedPlotType){
                    ForEach(PlotType, id: \.self){
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)
                .padding([.top, .leading, .trailing])
                
                if selectedPlotType == "Day"{
                    ZStack{
                        RoundedRectangle(cornerRadius: 20)
                            .padding(.all)
                            .frame(height: 400)
                            .foregroundStyle(Color("Text Colour"))
                        
                        Text("Day Plot")
                            .fontWeight(.bold)
                            .foregroundStyle(Color("Background Colour"))
                    }
                }
                else if selectedPlotType == "Week"{
                    ZStack{
                        RoundedRectangle(cornerRadius: 20)
                            .padding(.all)
                            .frame(height: 400)
                            .foregroundStyle(Color("Text Colour"))
                        
                        Text("Week Plot")
                            .fontWeight(.bold)
                            .foregroundStyle(Color("Background Colour"))
                    }
                }
                else{
                    ZStack{
                        RoundedRectangle(cornerRadius: 20)
                            .padding(.all)
                            .frame(height: 400)
                            .foregroundStyle(Color("Text Colour"))
                        
                        Text("Something went wrong")
                            .fontWeight(.bold)
                            .foregroundStyle(Color("Background Colour"))
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    HistoryView()
}
