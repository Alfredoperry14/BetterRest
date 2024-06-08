//
//  ContentView.swift
//  BetterRest
//
//  Created by Alfredo Perry on 6/6/24.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 0
    @State private var bedTime = ""
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    
    static var defaultWakeTime: Date{
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack{
            Form{
                Section{
                    
                    Text("When do you want to wake up")
                        .font(.headline)
                    
                    
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                Section{
                    Text("Desired amount of sleep")
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section{
                    Text("Daily coffee intake")
                        .font(.headline)
                        
                    Picker("^[\(coffeeAmount + 1) cup](inflect:true)", selection: $coffeeAmount) {
                        ForEach(1..<21){
                            Text("^[\($0) cup](inflect:true)")
                        }
                    }

                }
                
                Section{
                    Text("You should go to bed at \(formattedBedtime)")
                }
                
            }
            .navigationTitle("BetterRest")
            .alert(alertTitle, isPresented: $showingAlert){
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func calculateBedtime() -> Date{
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour+minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            return sleepTime

        } catch{
            return Date.now
        }
    }
    
    var formattedBedtime: String{
        var bedTimeDate = calculateBedtime()
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: bedTimeDate)
    }
}
#Preview {
    ContentView()
}
