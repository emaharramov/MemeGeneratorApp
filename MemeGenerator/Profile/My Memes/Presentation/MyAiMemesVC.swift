//
//  MyAiMemesVC.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 06.12.25.
//

import UIKit

final class MyAiMemesVC: BaseController<MyMemesVM> {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "MyAiMemesVC"
        viewModel.getAiMemes()
    }

}
