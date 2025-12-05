//
//  StarSelectionView.swift
//  WayCup
//
//  Created by Jazmine Singh on 12/4/25.
//

import SwiftUI

struct StarSelectionView: View {
    @State var rating: Int
    let highestRating = 5
    let unselected = Image(systemName: "star")
    let selected = Image(systemName: "star.fill")
    let font: Font = .largeTitle
    let FillColor: Color = .yellow
    let emptyColor: Color = .gray
    var body: some View {
        HStack{
            ForEach(1...highestRating, id: \.self) { number in
                showStar(for: number)
                    .foregroundStyle(number <= rating ? FillColor : emptyColor)
                    .onTapGesture {
                        rating = number
                    }
            }
            .font(font)
        }
    }
    func showStar(for number: Int) -> Image {
        if number > rating {
            return unselected
        } else {
            return selected
        }
    }
}

#Preview {
    StarSelectionView(rating: 4)
}
