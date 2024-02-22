//
//  RowView.swift
//  WordScramble
//
//  Created by Job Lipat on 2/22/24.
//

import SwiftUI

struct RowView: View {
    let word: String
    
    var body: some View {
        HStack{
            Image(systemName: "\(word.count).circle")
            Text(word)
        }
    }
}

#Preview {
    RowView(word: "Hello")
}
