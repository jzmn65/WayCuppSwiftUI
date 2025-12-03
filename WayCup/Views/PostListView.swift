//
//  PostListView.swift
//  WayCup
//
//  Created by Jazmine Singh on 12/3/25.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import MapKit

struct PostListView: View {
    let reviews: [Review]
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack{
            ZStack{
            Color.paper
                .ignoresSafeArea()
            
                List(reviews) { review in
                    NavigationLink {
                        PostDisplayView(review: review)
                    } label: {
                        HStack{
                            Image(systemName: review.photoURL ?? "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                            
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: 6) {
                            Text(review.place)
                                .font(.headline)
                            
                            Text(review.order)
                                .foregroundStyle(.secondary)
                            
                            Text(review.review)
                                .font(.body)
                            
        
                        }
                        .padding(.vertical, 4)
                        Spacer()
                        }
                    }
                                }
                                .navigationTitle("Recent Activity")
                                .scrollContentBackground(.hidden)
                                .listRowBackground(Color.paper)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Home", systemImage: "chevron.backward") {
                        dismiss()
                    }
                    
                    
                }
            }
        }
    }
}

#Preview {
    PostListView(reviews: [Review.preview])
}
