//
//  ViewController.swift
//  PDFReader
//
//  Created by xhgc01 on 2018/12/10.
//  Copyright © 2018 baleen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UXReaderViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let fileStr = Bundle.main.path(forResource: "foxitpdf", ofType: "pdf")!
        guard let document = UXReaderDocument.init(url: URL.init(fileURLWithPath: fileStr)) else { return }
        document.setUseNativeRendering()
        document.setHighlightLinks(true)
        document.setShowRTL(true)

        let readerViewController = UXReaderViewController.init()
        readerViewController.setDocument(document)
        readerViewController.delegate = self
        self.present(readerViewController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func dismiss(_ viewController: UXReaderViewController) {
        self.presentedViewController?.dismiss(animated: true, completion: nil)
    }
}

