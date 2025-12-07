//
//  HelpFeedbackVM.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 05.12.25.
//

final class HelpFeedbackVM: BaseViewModel {

    private let items = HelpFAQItem.all

    private(set) var expandedIndex: Int? = 0

    var numberOfItems: Int { items.count }

    func item(at index: Int) -> HelpFAQItem {
        items[index]
    }

    func isItemExpanded(_ index: Int) -> Bool {
        expandedIndex == index
    }

    func handleTap(at index: Int) {
        if expandedIndex == index {
            expandedIndex = nil
        } else {
            expandedIndex = index
        }
    }
}
