//
//  Copyable.swift
//  JournalEntry
//
//  Created by Cagri Sahan on 4/30/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//

// Attribution: https://stackoverflow.com/a/35915186
public protocol Copyable {
    init(fromObject: Self)
}

public extension Copyable {
    public func copy() -> Self {
        return Self.init(fromObject: self)
    }
}
