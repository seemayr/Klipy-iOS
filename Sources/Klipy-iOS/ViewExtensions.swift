import SwiftUI

public extension View {
    func klipyBorder(color: Color = .blue, width: CGFloat = 2) -> some View {
        self
            .border(color, width: width)
            .padding(4)
    }
    
    func klipyCard(backgroundColor: Color = .gray.opacity(0.1)) -> some View {
        self
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
            .shadow(radius: 4)
    }
}