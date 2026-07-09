// from https://zenn.dev/kyome/articles/a8ac1eb11b3c1d
import SwiftUI

struct PreActionButtonStyle: PrimitiveButtonStyle {
    let preAction: () -> Void

    func makeBody(configuration: Configuration) -> some View {
        Button(role: configuration.role) {
            preAction()
            configuration.trigger()
        } label: {
            configuration.label
        }
    }
}

struct PreActionButtonStyleModifier: ViewModifier {
    let preAction: () -> Void

    func body(content: Content) -> some View {
        content.buttonStyle(PreActionButtonStyle(preAction: preAction))
    }
}

extension View {
    func preActionButtonStyle(preAction: @escaping () -> Void) -> some View {
        modifier(PreActionButtonStyleModifier(preAction: preAction))
    }
}
