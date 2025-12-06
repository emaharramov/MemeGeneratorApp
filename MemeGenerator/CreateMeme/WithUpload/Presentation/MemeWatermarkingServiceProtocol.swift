//
//  MemeWatermarkingServiceProtocol.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 07.12.25.
//

import Foundation

protocol MemeWatermarkingServiceProtocol {
    func addWatermark(to imageData: Data, text: String) -> Data
}
