//
//  RootViewController.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/22/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import UIKit

class RootViewController: UIViewController, UIPageViewControllerDataSource {

    var pageViewController: UIPageViewController = UIPageViewController()
    var pageImages: NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageImages = ["TestTest", "TestTest"]
        
        // Create page view controller
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        var startingViewController: PageContentViewController = self.viewControllerAtIndex(0)
        var viewControllers: NSArray = [startingViewController]
        self.pageViewController.setViewControllers(viewControllers as [AnyObject], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)

        
        // Change the size of page view controller
        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
        
        self.addChildViewController(pageViewController)
        self.view.addSubview(pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)


    }
        // Do any additional setup after loading the view.

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func viewControllerAtIndex(index: NSInteger) -> PageContentViewController {
        if ((self.pageImages.count == 0) || (index >= self.pageImages.count)) {
            return PageContentViewController()
        }
        // Create a new view controller and pass suitable data.
        var pageContentViewController: PageContentViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PageContentViewController") as! PageContentViewController
        pageContentViewController.imageFile = self.pageImages[index] as! String
        pageContentViewController.pageIndex = index
        
        return pageContentViewController;

    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> NSInteger {
        return self.pageImages.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> NSInteger {
        return 0
    }
    
    
    
        /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RootViewController: UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index: NSInteger = (viewController as! PageContentViewController).pageIndex
        
        if ((index == 0) || (index == NSNotFound)) {
            return nil;
        }
        
        index--;
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
         var index: NSInteger = (viewController as! PageContentViewController).pageIndex
        
        if (index == NSNotFound) {
            return nil;
        }
        
        index++;
        if index == self.pageImages.count {
            return nil;
        }
        return viewControllerAtIndex(index);
    }
    
}