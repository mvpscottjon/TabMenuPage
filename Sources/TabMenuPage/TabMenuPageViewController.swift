//
//  TopTabMenuViewController.swift
//  TabMenu
//
//  Created by Seven Tsai on 2023/11/22.
//

import UIKit
import SnapKit

protocol TabMenuPageViewControllerDataSource: AnyObject {
    func viewControllers() -> [UIViewController]
    func titles() -> [String]
}

final class TabMenuPageViewController: UIViewController {
    
    private enum Constants {
        static let cellIdentifier = "tabMenu"
    }
    
    // MARK: - Property
    
    weak var dataSource: TabMenuPageViewControllerDataSource? {
        didSet {
            tabMenuCollectionView.reloadData()
        }
    }
    
    private var contentViewControllers: [UIViewController] {
        dataSource?.viewControllers() ?? []
    }
    
    private(set) var currentPage: Int = 0 {
        didSet {
            handlePageSelected(at: currentPage)
        }
    }
    
    private let menuSize = CGSize(width: UIScreen.main.bounds.width / 3, height: 50.0)
    
    // MARK: - View
    
    private lazy var tabMenuCollectionView = makeCollectionView()
    private lazy var pageViewController = makePageViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        tabMenuCollectionView.backgroundColor = .orange
    }
}

// MARK: - UICollectionViewDataSource

extension TabMenuPageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        contentViewControllers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath)
        
        if let cell = cell as? TabMenuCell, let titles = dataSource?.titles() {
            cell.update(withTitle: titles[indexPath.item])
        }
        
        return cell
    }
}

// MARK: - Expose

extension TabMenuPageViewController {
    func selectPage(at page: Int) {
        currentPage = page
    }
}

// MARK: - UICollectionViewDelegate

extension TabMenuPageViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentPage = indexPath.item
    }
}

// MARK: - UIScrollViewDelegate

extension TabMenuPageViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    }
}

// MARK: - UIPageViewControllerDataSource

extension TabMenuPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = contentViewControllers.firstIndex(of: viewController) ?? 0

          if currentIndex == 0 {
              // 如果當前是第一頁，則切換到最後一頁
              return contentViewControllers.last
          } else {
              // 否則切換到前一頁
              return contentViewControllers[currentIndex - 1]
          }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex = contentViewControllers.firstIndex(of: viewController) ?? 0

        if currentIndex == contentViewControllers.count - 1 {
            // 如果當前是最後一頁，則切換到第一頁
            return contentViewControllers.first
        } else {
            // 否則切換到下一頁
            return contentViewControllers[currentIndex + 1]
        }
    }
    
    
}

// MARK: - UIPageViewControllerDelegate

extension TabMenuPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        // current page
        guard let currentPageViewController = pageViewController.viewControllers?.first, let currentPageIndex = contentViewControllers.firstIndex(of: currentPageViewController) else { return }
        currentPage = currentPageIndex
        selectPage(at: currentPageIndex)
    }
}

private extension TabMenuPageViewController {
    func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [tabMenuCollectionView, pageViewController.view])
        stackView.axis = .vertical
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        tabMenuCollectionView.snp.makeConstraints{
            $0.height.equalTo(menuSize.height)
        }
        
        setupPageViewController()
        
    }
    
    func setupPageViewController() {
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
        // Must only give one vc which you want to selected. If more than one, will crash.
        pageViewController.setViewControllers([contentViewControllers[0]], direction: .forward, animated: true)
    }
}

private extension TabMenuPageViewController {
    func makeCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = menuSize
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(TabMenuCell.self, forCellWithReuseIdentifier: Constants.cellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }
    
    func makePageViewController() -> UIPageViewController {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        return vc
    }
}

// MARK: - Helper

private extension TabMenuPageViewController {
    func getViewController(atPage page: Int) -> UIViewController? {
        return contentViewControllers[page]
    }
    
    func handleEndPage() -> UIViewController? {
        return nil
    }
    
    func handlePageSelected(at page: Int) {
        menuSelected(at: page)
        pageViewSelected(at: page)
    }
    
    func menuSelected(at page: Int) {
        let index = IndexPath(item: page, section: 0)
        tabMenuCollectionView.selectItem(at: index, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    func pageViewSelected(at page: Int) {
        pageViewController.setViewControllers([contentViewControllers[page]], direction: .forward, animated: true)
    }
}
