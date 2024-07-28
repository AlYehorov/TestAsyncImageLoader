//
//  ContentView.swift
//  TestAsyncImageLoader
//
//  Created by Alex Yehorov on 7/28/24.
//

import SwiftUI
import Foundation
import AsyncImageLoader

struct ImageItem: Identifiable, Codable {
    let id: Int
    let imageUrl: String
}

struct ContentView: View {
    @State var imageList: [ImageItem] = []
    var body: some View {
        Button {
            CacheManager.shared.invalidateCache()
        } label: {
            Text("Invalidate image cache")
        }
        
        List(imageList) { item in
            LazyVStack(alignment: .leading, spacing: 10) {
                if let url = URL(string: "\(item.imageUrl)?size=200") {
                    AsyncImageView(url: url, placeholder: UIImage(systemName: "photo") ?? UIImage())
                        .clipShape(RoundedRectangle(cornerRadius: 16.0, style: .circular))
                } else {
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                        .foregroundColor(.red)
                    Text("Invalid URL")
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .onAppear {
            Task {
                await loadData()
            }
        }
    }
    
    private func loadData() async {
        do {
            imageList = try await fetchImageList()
        } catch {
            debugPrint("something wrong")
        }
    }
    
    func fetchImageList() async throws -> [ImageItem] {
        guard let url = URL(string: "https://zipoapps-storage-test.nyc3.digitaloceanspaces.com/image_list.json") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let imageList = try JSONDecoder().decode([ImageItem].self, from: data)
        return imageList
    }
}

#Preview {
    ContentView()
}
