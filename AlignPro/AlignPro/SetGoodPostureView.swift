//
//  SetGoodPostureView.swift
//  AlignPro
//
//  Created by Jim Greenwood on 2024-12-30.
//

import SwiftUI

struct SetGoodPostureView: View {
    var body: some View {
        ZStack{
            Color("Background Colour")
                .ignoresSafeArea()
            
            VStack{
                Text("Set Good Posture")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("Text Colour"))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.all)
                
                Text("Assume a postion with good posture, then press the below button. Stay still until you are brought back to the settings page.")
                    .fontWeight(.semibold)
                    .foregroundStyle(Color("Text Colour"))
                    .multilineTextAlignment(.leading)
                    .padding([.leading, .bottom, .trailing])
                
                Button("Set Posture"){
                    // Redirect
                }
                .padding(.all)
                .foregroundStyle(Color("Button Text Colour"))
                .fontWeight(.semibold)
                .background(Color("AccentColor"))
                .clipShape(Capsule())
                
                Spacer()
            }
        }
    }
}

#Preview {
    SetGoodPostureView()
}
