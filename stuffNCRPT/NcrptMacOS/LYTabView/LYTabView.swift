//
//  LYTabView.swift
//  LYTabView
//
//  Created by Lu Yibin on 16/4/13.
//  Copyright © 2016年 Lu Yibin. All rights reserved.
//

import Foundation
import Cocoa

/// Description
public class LYTabView: NSView {

    /// Tab bar view of the LYTabView
    public let tabBarView: LYTabBarView = LYTabBarView(frame: .zero)

    /// Native NSTabView of the LYTabView
    public let tabView: NSTabView = NSTabView(frame: .zero)

    //
    private let stackView: NSStackView = NSStackView(frame: .zero)

    /// delegate of LYTabView
    public var delegate: NSTabViewDelegate? {
        get {
            return tabBarView.delegate
        }
        set(newDelegate) {
            tabBarView.delegate = newDelegate
        }
    }

    public var numberOfTabViewItems: Int { return self.tabView.numberOfTabViewItems }
    public var tabViewItems: [NSTabViewItem] { return self.tabView.tabViewItems }
    public var selectedTabViewItem: NSTabViewItem? { return self.tabView.selectedTabViewItem }

    final private func setupViews() {
        tabView.delegate = tabBarView
        tabView.tabViewType = .noTabsNoBorder
        tabBarView.tabView = tabView

        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true

        tabView.translatesAutoresizingMaskIntoConstraints = false
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addView(tabBarView, in: .center)
        stackView.addView(tabView, in: .center)
        stackView.orientation = .vertical
        stackView.distribution = .fill
        stackView.alignment = .centerX
        stackView.spacing = 0
        stackView.leadingAnchor.constraint(equalTo: tabBarView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: tabBarView.trailingAnchor).isActive = true

        stackView.leadingAnchor.constraint(equalTo: tabView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: tabView.trailingAnchor).isActive = true

        let lowerPriority = NSLayoutConstraint.Priority(rawValue: NSLayoutConstraint.Priority.defaultLow.rawValue-10)
        tabView.setContentHuggingPriority(lowerPriority, for: .vertical)
        tabBarView.setContentCompressionResistancePriority(NSLayoutConstraint.Priority.defaultHigh, for: .vertical)
        tabBarView.setContentHuggingPriority(NSLayoutConstraint.Priority.defaultHigh, for: .vertical)
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    required public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupViews()
    }
}

public extension LYTabView {
    func addTabViewItem(_ tabViewItem: NSTabViewItem) {
        self.tabBarView.addTabViewItem(tabViewItem)
    }

    func insertTabViewItem(_ tabViewItem: NSTabViewItem, atIndex index: Int) {
        self.tabView.insertTabViewItem(tabViewItem, at: index)
    }

    func removeTabViewItem(_ tabViewItem: NSTabViewItem) {
        self.tabBarView.removeTabViewItem(tabViewItem)
    }

    func indexOfTabViewItem(_ tabViewItem: NSTabViewItem) -> Int {
        return self.tabView.indexOfTabViewItem(tabViewItem)
    }

    func indexOfTabViewItemWithIdentifier(_ identifier: AnyObject) -> Int {
        return self.tabView.indexOfTabViewItem(withIdentifier: identifier)
    }

    func tabViewItem(at index: Int) -> NSTabViewItem {
        return self.tabView.tabViewItem(at: index)
    }

    func selectFirstTabViewItem(_ sender: AnyObject?) {
        self.tabView.selectFirstTabViewItem(sender)
    }

    func selectLastTabViewItem(_ sender: AnyObject?) {
        self.tabView.selectLastTabViewItem(sender)
    }

    func selectNextTabViewItem(_ sender: AnyObject?) {
        self.tabView.selectNextTabViewItem(sender)
    }

    func selectPreviousTabViewItem(_ sender: AnyObject?) {
        self.tabView.selectPreviousTabViewItem(sender)
    }

    func selectTabViewItem(_ tabViewItem: NSTabViewItem?) {
        self.tabView.selectTabViewItem(tabViewItem)
    }

    func selectTabViewItem(at index: Int) {
        self.tabView.selectTabViewItem(at: index)
    }

    func selectTabViewItem(withIdentifier identifier: AnyObject) {
        self.tabView.selectTabViewItem(withIdentifier: identifier)
    }

    func takeSelectedTabViewItemFromSender(_ sender: AnyObject?) {
        self.tabView.takeSelectedTabViewItemFromSender(sender)
    }
}
