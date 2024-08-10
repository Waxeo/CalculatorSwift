//
//  ContentView.swift
//  calculatorProject
//
//  Created by Matteo Gauvrit on 29/07/2024.
//

import SwiftUI

struct HomeView: View {
    // Button grid for portrait
    let buttonsP = [
        ["7", "8", "9", "C", "AC"],
        ["4", "5", "6", "+", "-"],
        ["1", "2", "3", "*", "/"],
        ["0", ".", "00", "=", "(-x)"]
    ]
    
    // Button grid for landscape
    let buttonsL = [
        ["9", "8", "7", "6", "5"],
        [".", "00", "C", "AC", "(-x)"],
        ["4", "3", "2", "1", "0"],
        ["+", "-", "*", "/", "="]
    ]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                TopBar()
                    
                if geometry.size.width > geometry.size.height {
                    // Landscape
                    ButtonGrid(buttons: buttonsL, columns: 10, minButtonHeight: 60)
                        .padding(1)
                } else {
                    // Portrait
                    ButtonGrid(buttons: buttonsP, columns: 5, minButtonHeight: 80)
                }
                
            }
            .edgesIgnoringSafeArea(.top)
            .background(Color.black)
        }
    }
}

struct ButtonGrid: View {
    let buttons: [[String]]
    let columns: Int
    let minButtonHeight: CGFloat
    @State var res: String = "0"
    @State var expression: [String] = []
    @State var index: Int = 0
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    // Expression zone
                    Text(expression.isEmpty || expression[index].isEmpty ? "0" : expression[index])
                        .font(.system(size: fontSize(for: geometry.size)))
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(nil)
                        .frame(width: geometry.size.width, height: geometry.size.height / 3.7, alignment: .trailing)
                        .background(Color.black)
                }
                
                HStack {
                    // Results zone
                    Text(res)
                        .font(.system(size: fontSize(for: geometry.size)))
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.trailing)
                        .frame(width: geometry.size.width, height: geometry.size.height / 3.7, alignment: .trailing)
                        .background(Color(hue: 1.0, saturation: 0.09, brightness: 0.35))
                }
                
                let gridItems = Array(repeating: GridItem(.flexible(), spacing: 0), count: columns)
                
                LazyVGrid(columns: gridItems, spacing: 0) {
                    ForEach(buttons.flatMap { $0 }, id: \.self) { buttonTitle in
                        Button(action: {
                            print("\(buttonTitle) pressed")
                            // Buttons reaction
                            switch buttonTitle {
                                case "AC":
                                    index = 0
                                    res = "0"
                                    expression.removeAll()
                                case "C":
                                    if !expression.isEmpty && !expression[index].isEmpty {
                                        expression[index].removeLast()
                                        
                                        // Remove the empty string if it is the last element in the array
                                        if expression[index].isEmpty {
                                            expression.remove(at: index)
                                            // Adjust index if needed
                                            index = max(expression.count - 1, 0)
                                        }
                                    }
                                case "=":
                                    index = 0
                                    res = calculExpression(&expression, &index)
                                    index = 0
                                    expression.removeAll()
                                default:
                                    completeExpression(buttonTitle, &expression, &index)
                            }
                        }) {
                            Text(buttonTitle)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(hue: 0.073, saturation: 0.91, brightness: 0.941))
                                .foregroundColor(.white)
                                .font(.title)
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.white, lineWidth: 1)
                                )
                        }
                        .frame(minHeight: minButtonHeight)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color.black)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }

    private func fontSize(for size: CGSize) -> CGFloat {
        // Calcul font size
        let minFontSize: CGFloat = 10
        let maxFontSize: CGFloat = 75
        let availableSpace = min(size.width / 2, size.height / 2)
        let newSize = max(minFontSize, min(maxFontSize, availableSpace / 5))
        return newSize
    }
    
    
    // Check if the sign to add will not cause a syntax problem
    func checkSign(_ toCheck: String) -> Bool {
        
        let dic: [String] = ["-", "+", "/", "*"]
        
        for i in 0...3 {
            if dic[i] == toCheck {
                return true
            }
        }
        
        return false
    }
    
    // Add the entry to the expression
    func completeExpression(_ buttonTitle: String, _ expression: inout [String], _ index: inout Int) {
        
        // To check if the button pressed is a number
        func isNumber(_ string: String) -> Bool {
            return Double(string) != nil
        }

        // Check if the button pressed is a number
        if isNumber(buttonTitle) {
            
            // If the last element is a number or a ".", append the digit to the last number
            if !expression.isEmpty && (isNumber(expression.last!) || expression.last! == ".") {
                expression[expression.count - 1] += buttonTitle
            } else {
                // Otherwise, start a new number
                expression.append(buttonTitle)
            }
            
        } else if checkSign(buttonTitle) {
            
            if !expression.isEmpty && checkSign(expression.last!) {
                // Replacing the last operator if another operator is pressed
                expression[expression.count - 1] = buttonTitle
            } else if !expression.isEmpty {
                // Add operator to the end of the expression only if the last element is not an operator
                expression.append(buttonTitle)
            }
            
        } else if buttonTitle == "." {
            
            if expression.isEmpty || expression.last!.contains(".") || !isNumber(expression.last!) {
                print("Cannot add '.' here")
            } else {
                expression[expression.count - 1] += buttonTitle
            }
            
        } else if buttonTitle == "(-x)" {
            
            // If this index is not empty, don't add the negative "-" as an operator
            if !expression.isEmpty && checkSign(expression.last!) {
                return
            } else if !expression.isEmpty && isNumber(expression.last!) {
                // If the last element is a number, prefix it with a minus
                expression[expression.count - 1] = "-" + expression[expression.count - 1]
            }
        }

        // Update the index to the end of the expression
        index = expression.count - 1
    }

    
    // Calcul
    func calculExpression(_ expression : inout [String], _ index: inout Int) -> String {
        let dic1: [String] = ["/", "*"]
        let dic2: [String] = ["+", "-"]
        var left: Double = 0
        var right: Double = 0
        var tmp: Double = 0
        var i: Int = 0

        // Verify if the expression is valid
        guard expression.count >= 3 else {
            print("Expression is incomplete.")
            index = 0
            expression.removeAll()
            return "0"
        }
        
        // Priority calculs (* & /)
        while i < expression.count {
            for n in 0...1 {
                if dic1[n] == expression[i] {
                    left = (expression[i - 1] as NSString).doubleValue
                    right = (expression[i + 1] as NSString).doubleValue

                    if expression[i] == "*" {
                        tmp = left * right
                        // Overflow check
                        if tmp.isInfinite || tmp.isNaN {
                            print("Overflow or NaN detected")
                            return "Error"
                        }
                    }
                    else if expression[i] == "/" {
                        if right == 0 {
                            print("Error: Division by 0")
                            return "Error"
                        }
                        tmp = left / right
                        if tmp.isInfinite || tmp.isNaN {
                            print("Overflow or NaN detected")
                            return "Error"
                        }
                    }
                    expression[i - 1] = String(tmp)
                    expression.remove(at: i + 1)
                    expression.remove(at: i)
                    i = 0
                }
            }
            i += 1
        }
        
        i = 0
        
        // Remaining calculs (+ et -)
        while i < expression.count {
            for n in 0...1 {
                if dic2[n] == expression[i] {
                    left = (expression[i - 1] as NSString).doubleValue
                    right = (expression[i + 1] as NSString).doubleValue

                    if expression[i] == "+" {
                        tmp = left + right
                        if tmp.isInfinite || tmp.isNaN {
                            print("Overflow or NaN detected")
                            return "Error"
                        }
                    }
                    else if expression[i] == "-" {
                        tmp = left - right
                        if tmp.isInfinite || tmp.isNaN {
                            print("Overflow or NaN detected")
                            return "Error"
                        }
                    }
                    expression[i - 1] = String(tmp)
                    expression.remove(at: i + 1)
                    expression.remove(at: i)
                    i = 0
                }
            }
            i += 1
        }
        
        return expression.isEmpty ? "0" : expression[0]
    }}

struct TopBar: View {
    var body: some View {
        VStack {
            Text("Calculator")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(Color.white)
        }
        .padding(.top, 50)
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(Color(hue: 1.0, saturation: 0.09, brightness: 0.35))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
