//
//  CalculatorView.swift
//  SwiftUICalculator
//
//  Created by Junjie Li on 10/20/21.
//

import SwiftUI

struct CalculatorView: View {
    @ObservedObject
    var model: Model = Model()
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 4)
    
    var body: some View {
        ZStack{
            Color.black.edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                VStack{
                    VStack{
                        Spacer()
                        HStack{
                            Spacer()
                            Text(model.result)
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height*2/5)
                    
                    
                    //                LazyVGrid(columns: columns, alignment: .center, spacing: geometry.size.height*3/5/6/5 ) {
                    //                    ForEach((0..<20), id: \.self) {index in
                    //                        ButtonView(width: geometry.size.width/5, height: geometry.size.height*3/5/6, action: {}, buttonConfig: model.buttonConfigs[index])
                    //                    }
                    //                }
                    
                    GeometryReader{geometry1 in
                        VStack(alignment: .center, spacing: getSpacing(width: geometry1.size.width, height: geometry1.size.height)){
                            ForEach((0..<4), id: \.self){id1 in
                                HStack(alignment: .center, spacing: getSpacing(width: geometry1.size.width, height: geometry1.size.height)){
                                    ForEach((0..<4), id: \.self) {id2 in
                                        ButtonView(
                                            width: buttonWidth(width: geometry1.size.width,height: geometry1.size.height, index: id1*4+id2),
                                            height:  buttonHeight(width: geometry1.size.width, height: geometry1.size.height,
                                                                  index: id1*4+id2),
                                            action: {
                                                model.processInput(button: model.buttonConfigs[id1*4+id2].content)
                                            },
                                            buttonConfig: model.buttonConfigs[id1*4+id2])
                                    }
                                }
                            }
                            
                            HStack(spacing: getSpacing(width: geometry1.size.width, height: geometry1.size.height)){
                                ForEach(16..<19, id: \.self){id3 in
                                    ButtonView(width: buttonWidth(width: geometry1.size.width,  height: geometry1.size.height, index: id3),
                                               height:  buttonHeight(width: geometry1.size.width, height: geometry1.size.height,
                                                                     index: id3),
                                               action: {
                                        model.processInput(button: model.buttonConfigs[id3].content)
                                    },
                                               buttonConfig: model.buttonConfigs[id3])
                                }
                            }
                        }
                    }
                }
            }
            .padding(.all)
        }
    }
    
    func buttonWidth(width: CGFloat, height: CGFloat, index: Int) -> CGFloat{
        let space = getSpacing(width: width, height: height)
        if index == 16{
            return (width - 3*space)/4*2 + space
        }
        return (width - 3*space)/4
    }
    
    func buttonHeight(width: CGFloat, height: CGFloat, index: Int) -> CGFloat{
        let  space = getSpacing(width: width, height: height)
        return (height - 4*space)/5
    }
    
    func getSpacing(width: CGFloat, height: CGFloat) -> CGFloat {
        return min(width,height)/30;
    }
}


struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorView()
    }
}
