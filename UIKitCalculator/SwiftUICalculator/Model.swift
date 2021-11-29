//
//  Model.swift
//  SwiftUICalculator
//
//  Created by Junjie Li on 10/22/21.
//

import Foundation

struct ButtonConfig{
    var fred: Double
    var fgreen: Double
    var fblue: Double
    
    var bred: Double
    var bgreen: Double
    var bblue: Double
    
    var content: String
}

class Model: ObservableObject{
    var buttonConfigs: [ButtonConfig] = [
        ButtonConfig(fred: 1, fgreen: 0, fblue: 0, bred: 166, bgreen: 165, bblue: 165,content: "AC"),
        ButtonConfig(fred: 1, fgreen: 0, fblue: 0, bred: 166, bgreen: 165, bblue: 165,content: "+/-"),
        ButtonConfig(fred: 1, fgreen: 0, fblue: 0, bred: 166, bgreen: 165, bblue: 165,content: "%"),
        ButtonConfig(fred: 254, fgreen: 254, fblue: 254, bred: 245, bgreen: 160, bblue: 37,content: "÷"),
        
        ButtonConfig(fred: 254, fgreen: 254, fblue: 254, bred: 51, bgreen: 51, bblue: 51,content: "7"),
        ButtonConfig(fred: 254, fgreen: 254, fblue: 254, bred: 51, bgreen: 51, bblue: 51,content: "8"),
        ButtonConfig(fred: 254, fgreen: 254, fblue: 254, bred: 51, bgreen: 51, bblue: 51,content: "9"),
        ButtonConfig(fred: 254, fgreen: 254, fblue: 254, bred: 245, bgreen: 160, bblue: 37,content: "×"),
        
        ButtonConfig(fred: 254, fgreen: 254, fblue: 254, bred: 51, bgreen: 51, bblue: 51,content: "4"),
        ButtonConfig(fred: 254, fgreen: 254, fblue: 254, bred: 51, bgreen: 51, bblue: 51,content: "5"),
        ButtonConfig(fred: 254, fgreen: 254, fblue: 254, bred: 51, bgreen: 51, bblue: 51,content: "6"),
        ButtonConfig(fred: 254, fgreen: 254, fblue: 254, bred: 245, bgreen: 160, bblue: 37,content: "-"),
        
        ButtonConfig(fred: 254, fgreen: 254, fblue: 254, bred: 51, bgreen: 51, bblue: 51,content: "1"),
        ButtonConfig(fred: 254, fgreen: 254, fblue: 254, bred: 51, bgreen: 51, bblue: 51,content: "2"),
        ButtonConfig(fred: 254, fgreen: 254, fblue: 254, bred: 51, bgreen: 51, bblue: 51,content: "3"),
        ButtonConfig(fred: 254, fgreen: 254, fblue: 254, bred: 245, bgreen: 160, bblue: 37,content: "+"),
        
        ButtonConfig(fred: 254, fgreen: 254, fblue: 254, bred: 51, bgreen: 51, bblue: 51,content: "0"),
        //ButtonConfig(fred: 254, fgreen: 254, fblue: 254, bred: 51, bgreen: 51, bblue: 51,content: "0"),
        ButtonConfig(fred: 254, fgreen: 254, fblue: 254, bred: 51, bgreen: 51, bblue: 51,content: "."),
        ButtonConfig(fred: 254, fgreen: 254, fblue: 254, bred: 245, bgreen: 160, bblue: 37,content: "="),
    ]
    
    @Published
    var result: String = "0"
    
    func processInput(button: String){
        //上次计算的结果清零
        if result.firstIndex(of: "=") != nil || result.firstIndex(of: "!") !=  nil{
            result = "0"
        }
        //print(button+"is touch")
        //去重
        if (result.last == "+" || result.last == "-" || result.last == "×" || result.last == "÷" || result.last == ".") &&
            (button == "+" || button == "-" || button == "×" || button == "÷" || button == "." || button == "%"){
            result.removeLast()
            result.append(button)
            return
        }
        
        if button == "+" || button == "-" || button == "×" || button == "÷"{
            //if result != "0"{
            result += button
            // }
            return
        }
        
        if button == "%"{
            result = result + "÷100"
            return
        }
        
        if button == "+/-"{
            if result != "0"{
                if result.first != "-"{
                    result = "-" + result
                }
                else if result.first == "-"{
                    result.removeFirst()
                }
            }
            return
        }
        
        if button == "AC"{
            result = "0"
            return
        }
        
        if button == "="{
            result = calculate()
            return
        }
        
        if result ==  "0"{
            result = button
            if button == "."{
                result = "0" + result
            }
        }
        else{
            result += button
        }
        
    }
    
    func calculate()->String{
        if result == "0"{
            return "0"
        }
        if result.last == "+" || result.last == "-" || result.last == "×" || result.last == "÷" || result.last == "."{
            return "表达式有误!"
        }
        
        var s: String = ""
        for c in result{
            if c == "×"{
                s.append("*")
            }
            else  if c == "÷"{
                s.append("/")
            }
            else{
                s.append(c)
            }
        }
        
        let ns = NSExpression(format: s)
        if let value = ns.expressionValue(with: nil, context: nil) //as? Double{
        { print(value)
            return result + " = " + "\(value)"
        }
        
        return "表达式有误!"
    }
    
}
