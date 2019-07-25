//
//  TokenPageController.swift
//  PlanetWallet
//
//  Created by grabity on 16/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

protocol TokenPageDelegate {
    func didMoveToPage(index: Int)
    func didScroll(offset: CGFloat)
}

class TokenPageController: UIPageViewController {

    var userInfo: Dictionary<String,Any>?
    var pageDelegate: TokenPageDelegate?
    
    lazy var orderedViewControllers: [UIViewController] = {
        
        let page1: PlanetWalletViewController = UIStoryboard(name: "5_Token", bundle: nil).instantiateViewController(withIdentifier: "TokenListController") as! PlanetWalletViewController
        let page2: PlanetWalletViewController = UIStoryboard(name: "5_Token", bundle: nil).instantiateViewController(withIdentifier: "CustomTokenController") as! PlanetWalletViewController
        
        page1.userInfo = self.userInfo
        page2.userInfo = self.userInfo
        
        return [page1,page2]
    }()
    
    lazy var scrollView: UIScrollView? = {
        for subview in self.view?.subviews ?? [] {
            if let scrollView = subview as? UIScrollView {
                return scrollView
            }
        }
        return nil
    }()
    
    var currentPageIdx = 0 {
        didSet {
            pageDelegate?.didMoveToPage(index: currentPageIdx)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        dataSource = self
        scrollView?.delegate = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }
}

extension TokenPageController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if (!completed) {
            return
        }
        
        currentPageIdx = pageViewController.viewControllers!.first!.view.tag
    }
}

extension TokenPageController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
}

extension TokenPageController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let point = scrollView.contentOffset.x
        let width = scrollView.bounds.width
        let page = CGFloat(self.currentPageIdx)
        let count = CGFloat(orderedViewControllers.count)
        let percentage = (point - width + page * width) / (count * width)
        
        pageDelegate?.didScroll(offset: width * percentage)
    }
}
