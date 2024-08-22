//
//  Toast.swift
//  us-tracker
//
//  Created by Jason Morales on 8/22/24.
//

import SwiftUI

struct ToastModel {
    var title: String
    var image: String
}

struct Toast: View {
    let toast: ToastModel
    @Binding var show: Bool
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text(toast.title)
                Image(systemName: toast.image)
            }
            .font(.headline)
            .foregroundStyle(.primary)
            .padding(.vertical, 20)
            .padding(.horizontal, 40)
            .background(.green.opacity(0.4), in: Capsule())
            .transition(AnyTransition.move(edge: .bottom).combined(with: .opacity))
            .onTapGesture {
                withAnimation {
                    self.show = false
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                    withAnimation {
                        self.show = false
                    }
                }
            }
        }
    }
}

struct ToastTestView: View {
    @State var show = false
    var toast = ToastModel(title: "Notification Added", image: "checkmark.circle.fill")
    var body: some View {
        ZStack {
            Button {
                show.toggle()
            } label: {
                Text("Notification Added")
                    .padding(.vertical, 50)
            }
            
            if show {
                VStack {
                    Spacer()
                    Toast(toast: toast, show: $show)
                }
            }
        }
    }
}

#Preview {
    ToastTestView()
}
