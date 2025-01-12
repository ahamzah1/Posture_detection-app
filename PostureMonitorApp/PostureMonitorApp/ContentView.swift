//////
//////  ContentView.swift
//////  PostureMonitorApp
//////
//////  Created by Ahmad Capstone on 2025-01-07.
//////
////
//struct ContentView: View {
//    @Environment(\.managedObjectContext) private var viewContext
//    @EnvironmentObject var bleViewModel: BLEViewModel
//
//    var body: some View {
//        VStack {
//            Text("BLE Status: (bleViewModel.statusText)")
//            Button("Toggle Scan") {
//                bleViewModel.toggleScan()
//            }
//        }
//        .padding()
//        .onAppear {
//            print("Core Data Context: (viewContext)")
//        }
//    }
//}
