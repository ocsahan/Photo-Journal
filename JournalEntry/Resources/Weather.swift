//
//  Weather.swift
//  JournalEntry
//
//  Created by Cagri Sahan on 4/29/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//

struct Report: Codable {
    let currently: Weather
}

struct Weather: Codable {
    let icon: String
}
