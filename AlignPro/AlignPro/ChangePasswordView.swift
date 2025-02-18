//
//  ChangePasswordView.swift
//  AlignPro
//
//  Created by Jim Greenwood on 2025-01-02.
//

import SwiftUI

struct ChangePasswordView: View {
    @Binding var correctPassword: String
    
    @State var enteredOldPW: String = ""
    @State var enteredNewPW: String = ""
    @State var enteredConfirm: String = ""
    
    @State var oldMatch: Bool = true
    @State var newMatch: Bool = true
    var body: some View {
        ZStack{
            Color("Background Colour")
                .ignoresSafeArea()
            
            VStack{
                Text("Set New Password")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("Text Colour"))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.all)
                
                Text("Enter Old Password")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color("Text Colour"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.top, .leading, .trailing])
                
                SecureField("Old Password", text: $enteredOldPW)
                    .autocorrectionDisabled()
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    .textContentType(.emailAddress)
                    .textFieldStyle(.roundedBorder)
                    .foregroundStyle(Color("Text Colour"))
                    .padding([.leading, .bottom, .trailing])
                
                Text("Enter New Password")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color("Text Colour"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.top, .leading, .trailing])
                
                SecureField("New Password", text: $enteredNewPW)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
                    .textFieldStyle(.roundedBorder)
                    .foregroundStyle(Color("Text Colour"))
                    .padding([.leading, .bottom, .trailing])
                
                Text("Confirm New Password")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color("Text Colour"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.top, .leading, .trailing])
                
                SecureField("Old Password", text: $enteredConfirm)
                    .autocorrectionDisabled()
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    .textContentType(.emailAddress)
                    .textFieldStyle(.roundedBorder)
                    .foregroundStyle(Color("Text Colour"))
                    .padding([.leading, .bottom, .trailing])
                
                if(!oldMatch){
                    Text("Old password is incorrect!")
                        .foregroundStyle(Color.red)
                        .padding([.leading, .bottom, .trailing])
                }
                if(!newMatch){
                    Text("New password and confirmation don't match!")
                        .foregroundStyle(Color.red)
                        .padding([.leading, .bottom, .trailing])
                }
                if(oldMatch && newMatch){
                    Text("Password is up to date!")
                        .foregroundStyle(Color("AccentColor"))
                        .padding([.leading, .bottom, .trailing])
                }
                
                Button("Set New Password"){
                    if(enteredOldPW != correctPassword){
                        oldMatch = false
                    }
                    else{
                        oldMatch = true
                    }
                    
                    if(enteredNewPW != enteredConfirm){
                        newMatch = false
                    }
                    else{
                        newMatch = true
                    }
                    
                    if(oldMatch && newMatch){
                        correctPassword = enteredNewPW
                        enteredConfirm = ""
                        enteredNewPW = ""
                        enteredOldPW = ""
                    }
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
    ContentView()
}
