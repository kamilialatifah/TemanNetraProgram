//
//  OnBoardingViewController.swift
//  TemanNetraProgram
//
//  Created by Georgius Yoga Dewantama on 20/08/19.
//  Copyright © 2019 Georgius Yoga Dewantama. All rights reserved.
//

import UIKit

class OnBoardingViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    // membuat variable untuk menyimpan 3 Welcome Page
    lazy var viewControllerList : [UIViewController] = {
        
        // membuat variable story board
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        // membuat variable setiap welcome page dengan identifier
        let welcomePage1 = storyBoard.instantiateViewController(withIdentifier: "OnBoardOne")
        let welcomePage2 = storyBoard.instantiateViewController(withIdentifier: "OnBoardTwo")
        let welcomePage3 = storyBoard.instantiateViewController(withIdentifier: "OnBoardThree")
        let welcomePage4 = storyBoard.instantiateViewController(withIdentifier: "OnBoardFour")
        
        return[welcomePage1, welcomePage2, welcomePage3, welcomePage4]
    }()
    
    // membuat variable untuk class PageControl
    var pageControl = UIPageControl()
    
    // melakukan konfigurasi untuk page control
    func configurePageControl(){
        pageControl = UIPageControl(frame: CGRect(x: 0, y: UIScreen.main.bounds.maxY - 75, width: UIScreen.main.bounds.width, height: 50))
        pageControl.numberOfPages = viewControllerList.count
        pageControl.currentPage = 0
        pageControl.tintColor = UIColor.white
        pageControl.pageIndicatorTintColor = UIColor.gray
        pageControl.isUserInteractionEnabled = true
        pageControl.currentPageIndicatorTintColor = UIColor.blue
        self.view.addSubview(pageControl)
    }
    
   
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        
        // membuat index view controller saat ini
        guard let vcIndex = viewControllerList.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = vcIndex - 1
        
        // mengeksekusi ketika kondisi previousIndex tidak sama dengan nol
        guard previousIndex >= 0 else {
            
            // kalo mau infinity Loop
            // return viewControllerList.last
            
            // kalo mau Looping terbatas
            return nil
        }
        
        // mengantisipasi ketika previous index lebih besar dari list array
        guard viewControllerList.count > previousIndex else {
            return nil
        }
        
        // menampilkan view controller sebelumnya
        return viewControllerList[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        // membuat variable index untuk menyimpan view controller
        guard let vcIndex = viewControllerList.firstIndex(of: viewController) else { return nil }
        
        let afterIndex = vcIndex + 1
        
        // untuk membatasi gerakan dari view controller
        guard viewControllerList.count != afterIndex else {
            
            // kalo mau infinity Loop
            // return viewControllerList.first
            
            // kalo mau looping terbatas
            return nil
        }
        
        guard viewControllerList.count > afterIndex else {
            return nil
        }
        
        return viewControllerList[afterIndex]
    }
    
    // fungsi untuk transisi page control diambil dari delegate pageView Controller
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        // ambil index dari viewControllers
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = viewControllerList.firstIndex(of: pageContentViewController)!
        
//        // ketika index bernilai terakhir, maka transisi opacity terjadi
//        if pageContentViewController == viewControllerList.last {
//
//            //pageControl.alpha = 0
//            UIView.animate(withDuration: 0.2, delay: 0.3, options: UIView.AnimationOptions.curveEaseOut, animations: {
//                self.pageControl.alpha = 0
//            }, completion: nil)
//
//            // ketika index pertama langsung tertampil
//        }else if pageContentViewController == viewControllerList.first {
//            pageControl.alpha = 1
//        }
//
//            // ketika index kedua, maka page control tertampil lagi
//        else {
//            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
//                self.pageControl.alpha = 1
//            }, completion: nil)
//        }
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        // Do any additional setup after loading the view.
        
        // membuat variabel untuk menampung ketika list VC di panggil
        if let firstViewController = viewControllerList.first {
            self.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        
        self.delegate = self
        configurePageControl()
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
