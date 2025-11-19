//
//  AIMemeViewModel.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit

final class AIMemeViewModel {

    // MARK: - Inputs / Outputs
    var onTemplatesLoaded: (([TemplateDTO]) -> Void)?
    var onMemeGenerated: ((UIImage?) -> Void)?
    var onLoadingStateChange: ((Bool) -> Void)?
    var onError: ((String) -> Void)?

    private(set) var selectedTemplateId: String?
    private let userId: String

    init(userId: String) {
        self.userId = userId
    }

    // MARK: - Fetch Templates
    func loadTemplates() {
        // Burda loading toast lazım deyil deyə state göndərmirik
        MemeService.shared.fetchTemplates { [weak self] list, error in
            guard let self else { return }

            if let error {
                self.onError?(error)
                return
            }
            guard let list else { return }

            self.onTemplatesLoaded?(list)
        }
    }

    func selectTemplate(id: String) {
        selectedTemplateId = id
    }

    // MARK: - Generate Meme
    func generateMeme(prompt: String) {
        guard !prompt.isEmpty else {
            onError?("Please enter a prompt")
            return
        }

        guard let templateId = selectedTemplateId else {
            onError?("Please select a template")
            return
        }

        onLoadingStateChange?(true)

        MemeService.shared.generateMeme(
            userId: userId,
            prompt: prompt,
            templateId: templateId
        ) { [weak self] dto, error in

            guard let self = self else { return }
            self.onLoadingStateChange?(false)

            if let error {
                self.onError?(error)
                return
            }
            guard let dto else {
                self.onError?("No meme received")
                return
            }

            MemeService.shared.loadImage(url: dto.imageUrl) { img in
                DispatchQueue.main.async {
                    self.onMemeGenerated?(img)
                }
            }
        }
    }
}
