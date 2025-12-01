//
//  AIVM.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 24.11.25.
//

import Foundation
import Combine

@MainActor
final class AIVM: BaseViewModel {

    enum ViewState {
        case idle
        case memeLoaded(String)
        case error(String)
    }

    @Published private(set) var state: ViewState = .idle
    @Published private(set) var imageUrl: String?

    func generateMeme(prompt: String) {
        let trimmed = prompt.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            let message = "Please enter an idea."
            state = .error(message)
            showError(message)
            return
        }

        performWithLoading(
            resetMessages: true,
            operation: { completion in
                MemeService.shared.generateMemeAI(
                    userId: AppStorage.shared.userId,
                    prompt: trimmed
                ) { response, errorString in

                    if let errorString {
                        completion(.failure(AIMemeError.network(errorString)))
                        return
                    }

                    guard
                        let urlString = response?.meme?.imageURL,
                        !urlString.isEmpty
                    else {
                        completion(.failure(.noMeme))
                        return
                    }
                    completion(.success(urlString))
                }
            },
            errorMapper: { [weak self] (error: AIMemeError) -> String in
                let message = self?.mapError(error)
                    ?? "Something went wrong. Please try again."
                self?.state = .error(message)
                return message
            },
            onSuccess: { [weak self] (urlString: String) in
                guard let self else { return }
                self.imageUrl = urlString
                self.state = .memeLoaded(urlString)
                self.showSuccess("Your meme is ready to serve! 🍽😂")
            }
        )
    }

    private func mapError(_ error: AIMemeError) -> String {
        switch error {
        case .network(let message):
            return message.isEmpty
                ? "Network error. Please try again."
                : message
        case .noMeme:
            return "No meme received. Please try again."
        case .imageDownloadFailed:
            return "Failed to load meme image. Please try again."
        }
    }
}
