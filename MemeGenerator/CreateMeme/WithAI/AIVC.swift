//
//  AIVC.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 24.11.25.
//

import UIKit

final class AIVC: BaseController<AIVM> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override init(viewModel: AIVM) {
           super.init(viewModel: viewModel)
    }

   required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
   }
}
