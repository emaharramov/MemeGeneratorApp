//
//  MyAiTempVC.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 06.12.25.
//

import UIKit

final class MyAiTempVC: BaseController<MyMemesVM> {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        navigationItem.title = "MyAiTempVC"
        viewModel.getAiTemplateMemes()
    }

}
