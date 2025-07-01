//
//  CTLinkText.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 26/06/2025.
//

import SwiftUI

struct CTLinkText: View {
    let text: String
    let linkColor: Color
    let shouldOpenLink: Bool
    
    var body: some View {
        Text(makeAttributedString())
            .environment(\.openURL, OpenURLAction { url in
                shouldOpenLink ? .systemAction : .discarded
            })
    }
    
    private func makeAttributedString() -> AttributedString {
        var attributedString = AttributedString(text)
        
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let range = NSRange(location: 0, length: text.utf16.count)
        
        detector?.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
            guard let match,
                  let range = Range(match.range, in: text),
                  let attributedRange = Range(range, in: attributedString),
                  let url = match.url else {
                return
            }
            
            attributedString[attributedRange].foregroundColor = linkColor
            attributedString[attributedRange].underlineStyle = .single
            attributedString[attributedRange].font = .callout.weight(.semibold)
            attributedString[attributedRange].link = url
        }
        
        return attributedString
    }
}
