//
//  Finder.swift
//  NcrptMacOS
//
//  Created by Michael Safir on 16.01.2023.
//

import Foundation
import AppKit

func showInFinder(url: URL?) {
    guard let url = url else { return }
    
    if url.hasDirectoryPath {
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
    }
    else {
        showInFinderAndSelectLastComponent(of: url)
    }
}

// Select file function
public func showInFinderAndSelectLastComponent(of url: URL) {
    NSWorkspace.shared.activateFileViewerSelecting([url])
}


