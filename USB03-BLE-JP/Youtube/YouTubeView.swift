//
//  YouTubeView.swift
//  USB03-BLE-JP
//
//  Created by 이요섭 on 6/3/24.
//

import SwiftUI
import WebKit

struct YouTubeView: UIViewRepresentable {
    let videoID: String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let htmlString = """
                <!DOCTYPE html>
                <html>
                <head>
                <style>
                body, html {
                    margin: 0;
                    padding: 0;
                    overflow: hidden;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    height: 100%;
                    background-color: transparent;
                }
                </style>
                </head>
                <body>
                <iframe width="1920" height="934" src="https://www.youtube.com/embed/gWstaniV0Jw" title="우리엘전자 리브랜딩(URIEL BRAND RENEWAL)" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
                </body>
                </html>
                """
                uiView.loadHTMLString(htmlString, baseURL: nil)
    }
}

