//
//  ButtonView.swift
//  SwiftUICalculator
//
//  Created by Junjie Li on 10/22/21.
//

import SwiftUI

struct ButtonView: View {
    var width: CGFloat
    var height: CGFloat
    
    var action: () -> Void = {}
    var buttonConfig: ButtonConfig;
    
    var body: some View {
        Button(action: action) {
            Text(buttonConfig.content)
        }
        .frame(width: width, height: height)
        .foregroundColor(Color(red: buttonConfig.fred/255, green:buttonConfig.fgreen/255 , blue: buttonConfig.fblue/255))
        .background(Color(red: buttonConfig.bred/255, green:buttonConfig.bgreen/255 , blue: buttonConfig.bblue/255))
        .font(Font.title)
        .cornerRadius(5)
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView(width: 45, height: 25, action: {}, buttonConfig: ButtonConfig(fred: 1, fgreen: 0, fblue: 0, bred: 166, bgreen: 165, bblue: 165,content: "÷"))
    }
}
