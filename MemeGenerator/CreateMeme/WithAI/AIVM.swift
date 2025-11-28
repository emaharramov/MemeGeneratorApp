//
//  AIVM.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 24.11.25.
//

import UIKit

final class AIVM: BaseViewModel {
    private let manager = HomeManager.shared
    
    var onTemplatesLoaded: (([TemplateDTO]) -> Void)?
    var onMemeGenerated: ((UIImage?) -> Void)?
    var onLoadingStateChange: ((Bool) -> Void)?
    var onError: ((String) -> Void)?

    enum ViewState {
        case loading
        case loaded
        case success
        case error(String)
        case idle
    }

    var stateUpdated: ((ViewState) -> Void)?

    private(set) var state: ViewState = .idle {
        didSet { stateUpdated?(state) }
    }

    func getAllTemplates() {
        state = .loading

    }
}
