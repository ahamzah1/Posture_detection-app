//
//  FAQView.swift
//  AlignPro
//
//  Created by Ty Greenwood on 2024-12-30.
//

import SwiftUI

struct FAQView: View {
    var body: some View {
        ZStack{
            Color("Background Colour")
                .ignoresSafeArea()
            
            ScrollView{
                VStack{
                    Text("What is good posture?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("Text Colour"))
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding(.all)
                    
                    Text("     To maintain good posture when standing, aim to stand tall with your shoulders back and your stomach slightly pulled in. Keep most of your weight on the balls of your feet, your head level, and your feet about shoulder-width apart. Let your arms hang naturally at your sides. When sitting, ensure your feet are flat on the floor and your shoulders are relaxed. Keep your elbows close to your body, bent at a comfortable angle between 90 and 120 degrees, and make sure your back is fully supported.")
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(Color("Text Colour"))
                        .padding([.leading, .bottom, .trailing])
                    
                    Image("Posture")
                        .resizable()
                        .cornerRadius(15)
                        .aspectRatio(contentMode: .fit)
                        .padding(.all)
                    
                    Text("     You should be cautious to avoid some common posture mistakes. Slouching in your chair can strain your muscles over time, so make sure to sit upright and engage your core. Leaning on one leg while standing places uneven pressure on your lower back and hips, so be mindful to distribute your weight evenly. Hunching over your screen can lead to neck and upper back pain, so try to sit tall and keep your shoulders relaxed. Avoid poking your chin forward by adjusting your seating position and screen height. Finally, rounded shoulders can result from muscle imbalances, so remember to regularly bring your shoulders back and strengthen your upper back.")
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.all)
                        .foregroundStyle(Color("Text Colour"))
                }
            }
        }
    }
}

#Preview {
    FAQView()
}
