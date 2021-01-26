//
//  ContentView.swift
//  BetterRest
//
//  Created by Zaid Raza on 07/09/2020.
//  Copyright © 2020 Zaid Raza. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    @State private var showingAlert = false
    
    @State private var wakeUp = defaultWakeTime
    
    @State private var sleepAmount = 8.0
    
    @State private var coffeeAmount = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
    
    @State private var coffeeCups = 0
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    
    var body: some View {
        
        return NavigationView{
            Form{
                Section(header: Text("When do you want to wake up?").font(.headline)){
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute).labelsHidden().datePickerStyle(WheelDatePickerStyle()).onTapGesture {
                        self.calculateBedtime()
                    }
                }
                
                Section(header: Text("Desired amount of sleep").font(.headline)){
                    Stepper(value: $sleepAmount, in: 4...12, step: 0.25){
                        Text("\(sleepAmount, specifier: "%g") hours")
                    }
                }
                
                Section(header: Text("Daily coffe intake?").font(.headline)){
                    Picker("Daily coffee intake?", selection: $coffeeCups){
                        ForEach(0..<coffeeAmount.count){
                            if self.coffeeAmount[$0] == 1{
                                Text("1 cup").tag($0)
                            }
                            else{
                                Text("\(self.coffeeAmount[$0]) cups").tag($0)
                            }
                        }
                    }
                }
                
                Section{
                    if alertTitle == ""{
                        Text("----------").font(.headline)
                    }
                    else{
                        Text("\(alertTitle) \(alertMessage)").font(.headline)
                    }
                }
            }
            .navigationBarTitle("Better Rest")
        }
    }
    
    func calculateBedtime(){
        
        let model = SleepCalculator()
        let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        
        do{
            let prediction = try model.prediction(wake: Double(hour+minute), estimatedSleep: sleepAmount, coffee: Double(coffeeCups))
            let sleepTime = wakeUp - prediction.actualSleep
            let formatter =  DateFormatter()
            formatter.timeStyle = .short
            alertMessage = formatter.string(from: sleepTime)
            alertTitle = "Your ideal bedtime is…"
        }
        catch{
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        showingAlert = true
    }
}

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { selection in
                self.wrappedValue = selection
                handler(selection)
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
