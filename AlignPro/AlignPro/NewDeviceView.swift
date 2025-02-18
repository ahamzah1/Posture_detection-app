////
////  NewDeviceView.swift
////  AlignPro
////
////  Created by Jim Greenwood on 2024-12-30.
////
//
//import SwiftUI
//
//struct NewDeviceView: View {
//    @EnvironmentObject var bleViewModel: BLEViewModel
//
//    var body: some View {
//        ZStack {
//            Color("Background Colour")
//                .ignoresSafeArea()
//
//            VStack {
//                Text("Connect New Device")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .foregroundColor(Color("Text Colour"))
//                    .frame(maxWidth: .infinity, alignment: .topLeading)
//                    .padding()
//
//                ScrollView {
//                    ForEach(bleViewModel.discoveredDevices, id: \.self) { device in
//                        HStack {
//                            Text(device)
//                                .fontWeight(.semibold)
//                                .foregroundStyle(Color("Text Colour"))
//                                .padding()
//
//                            Spacer()
//
//                            Button(action: {
//                                bleViewModel.connectToDevice(named: device)
//                            }) {
//                                Text("Connect")
//                                    .fontWeight(.semibold)
//                                    .foregroundColor(.white)
//                                    .padding()
//                                    .background(Color.blue)
//                                    .cornerRadius(8)
//                            }
//                        }
//                        .frame(maxWidth: .infinity)
//                        .padding(.horizontal)
//                        .background(Color("Submenu Colour"))
//                        .cornerRadius(10)
//                        .padding(.vertical, 5)
//                    }
//                }
//                .padding()
//                .frame(maxHeight: 300)
//                .background(Color("Submenu Colour"))
//                .cornerRadius(10)
//                .padding()
//
//                Text("Make sure your device is turned on, in pairing mode, and in range.")
//                    .fontWeight(.semibold)
//                    .foregroundColor(Color("Text Colour"))
//                    .multilineTextAlignment(.center)
//                    .padding()
//
//                Spacer()
//
//                Button(action: {
//                    bleViewModel.toggleScan()
//                }) {
//                    Text(bleViewModel.isScanning ? "Stop Scanning" : "Start Scanning")
//                        .fontWeight(.semibold)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(bleViewModel.isScanning ? Color.red : Color.green)
//                        .foregroundColor(.white)
//                        .clipShape(Capsule())
//                }
//                .padding(.horizontal)
//            }
//        }
//    }
//}
//
//#Preview {
//    NewDeviceView()
//}
