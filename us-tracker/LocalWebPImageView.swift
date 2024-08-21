//
//  LocalWebPImageView.swift
//  us-tracker
//
//  Created by Jason Morales on 8/20/24.
//

import SwiftUI
import SDWebImageSwiftUI
import SDWebImage


struct LocalWebPImageView: View {
    let imageName: String
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        if let imagePath = Bundle.main.path(forResource: imageName, ofType: "webp"),
           let imageURL = URL(string: "file://\(imagePath)") {
            WebImage(url: imageURL) {
                image in
                image
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: width, height: height)
            } placeholder: {
                    Image(systemName: "photo")
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: width, height: height)
                }
        } else {
            Image(systemName: "photo")
                .resizable()
                .clipShape(Circle())
                .frame(width: width, height: height)
        }
    }
}

#Preview {
    LocalWebPImageView(imageName: "pulisic", width: 70, height: 70)
}
