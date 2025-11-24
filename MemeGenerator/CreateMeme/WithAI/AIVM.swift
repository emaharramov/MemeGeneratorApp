//
//  AIVM.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 24.11.25.
//

final class AIVM: BaseViewModel {
    private let manager = HomeManager.shared

    // yalnız buradan oxunsun
    private(set) var allTemplates: [MemesTemplate] = []

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

        manager.getAllTemplates { [weak self] response, errorMessage in
            guard let self = self else { return }

            if let errorMessage {
                self.state = .error(errorMessage)
                return
            }

            guard let response = response,
                  let templates = response.memes else {
                self.state = .error("No data")
                return
            }

            self.allTemplates = templates
            self.state = .success
        }
    }
}
