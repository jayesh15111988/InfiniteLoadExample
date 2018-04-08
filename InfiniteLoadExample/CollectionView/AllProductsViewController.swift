import UIKit

import UIKit
import RxSwift

private let cellIdentifier = "collectionViewCell"

private let defaultCellHeight: CGFloat = 310.0
private let defaultCellWidth: CGFloat = 305.0
private let defaultContentInsetsTop: CGFloat = 10.0
private let defaultContentInsetsBottom: CGFloat = 10.0
private let defaultContentInsetsLeftRight: CGFloat = 10.0
private let customLayoutCell: String = "customizedCollectionViewCellIdentifier"

class AllProductsViewController: UIViewController {

    var collectionView: UICollectionView!
    var numberOfItems: Int = 20
    var collectionViewModel: AllProductsDataViewModel
    var activityIndicatorView: UIActivityIndicatorView
    let disposeBag: DisposeBag
    let productsCountDisplayLabel: UILabel


    init(collectionViewModel: AllProductsDataViewModel) {
        self.collectionViewModel = collectionViewModel
        self.activityIndicatorView = UIActivityIndicatorView()
        self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicatorView.activityIndicatorViewStyle = .whiteLarge
        self.activityIndicatorView.color = .black
        self.disposeBag = DisposeBag()
        self.productsCountDisplayLabel = UILabel()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.title = "Products Collection"

        let numberOfColumns = 2

        let itemExpectedWidth = (self.view.bounds.width - (defaultContentInsetsLeftRight * (CGFloat(numberOfColumns) + 1.0))) / CGFloat(numberOfColumns)
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: itemExpectedWidth, height: 250)
        flowLayout.minimumLineSpacing = defaultContentInsetsTop
        flowLayout.minimumInteritemSpacing = defaultContentInsetsTop
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets(top: defaultContentInsetsTop, left: defaultContentInsetsLeftRight, bottom: defaultContentInsetsBottom, right: defaultContentInsetsLeftRight)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)

        collectionView.indicatorStyle = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor(red: 0.96, green: 1.0, blue: 0.98, alpha: 1.0)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = true
        self.view.addSubview(collectionView)
        self.view.addSubview(activityIndicatorView)

        self.productsCountDisplayLabel.translatesAutoresizingMaskIntoConstraints = false
        self.productsCountDisplayLabel.numberOfLines = 0
        self.productsCountDisplayLabel.backgroundColor = .blue
        self.view.addSubview(self.productsCountDisplayLabel)

        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)

        let topLayoutGuide = self.topLayoutGuide

        let views: [String: AnyObject] = ["collectionView": collectionView, "topLayoutGuide": topLayoutGuide, "productsCountDisplayLabel": productsCountDisplayLabel]

        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", options: [], metrics: nil, views: views))

        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[topLayoutGuide][collectionView]|", options: [], metrics: nil, views: views))

        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=50)-[productsCountDisplayLabel]-5-|", options: [], metrics: nil, views: views))

        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[topLayoutGuide]-44-[productsCountDisplayLabel]", options: [], metrics: nil, views: views))

        self.view.addConstraint(NSLayoutConstraint(item: activityIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: activityIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0))

        self.collectionView.reloadData()
        self.activityIndicatorView.hidesWhenStopped = true
        self.activityIndicatorView.startAnimating()

        _ = self.collectionViewModel.numberOfItemsLoaded.asObservable().observeOn(MainScheduler.instance).subscribe(onNext: { (numberOfItemsLoaded) in
            self.productsCountDisplayLabel.text = "\n  \(numberOfItemsLoaded)  \n"
        })

        _ = self.collectionViewModel.productsCollection.asObservable().observeOn(MainScheduler.instance).subscribe(onNext: { (products) in
            print("First index \(self.collectionViewModel.currentBeginningIndex) last index \(self.collectionViewModel.currentEndingIndex) products count \(self.collectionViewModel.productsCollection.value.count) page number \(self.collectionViewModel.pageNumber - 1)")
            self.collectionView.performBatchUpdates({
                var indexPathsCollection: [IndexPath] = []
                if self.collectionViewModel.currentBeginningIndex < self.collectionViewModel.currentEndingIndex {
                    for i in self.collectionViewModel.currentBeginningIndex...self.collectionViewModel.currentEndingIndex {
                        indexPathsCollection.append(IndexPath(item: i, section: 0))
                    }
                    self.collectionView.insertItems(at: indexPathsCollection)
                }
            }, completion: nil)
        })

        _ = Observable.combineLatest(self.collectionViewModel.loadingProducts.asObservable(), self.collectionViewModel.markingFavorite.asObservable(), self.collectionViewModel.pageLoadFinished.asObservable()).observeOn(MainScheduler.instance).subscribe(onNext: { (loading, markingFavorite, pageLoadFinished)in
            if (loading == true || markingFavorite == true) && pageLoadFinished == false {
                self.activityIndicatorView.startAnimating()
            } else {
                self.activityIndicatorView.stopAnimating()
            }
        })

        self.collectionViewModel.selectedProduct.asObservable().subscribe(onNext: { [weak self] product in
            guard let product = product else { return }
            self?.pushViewController(with: product.name)
        }).addDisposableTo(disposeBag)
    }

    private func pushViewController(with title: String) {
        let optionsViewController = UIViewController()
        optionsViewController.view.backgroundColor = .purple
        optionsViewController.title = title
        self.navigationController?.pushViewController(optionsViewController, animated: true)
    }

    deinit {
        print("Deallocating...")
    }

}

extension AllProductsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? CustomCollectionViewCell {
            cell.collectionCellViewModel.value = CollectionCellViewModel(collectionViewDataViewModel: self.collectionViewModel, product: self.collectionViewModel.productsCollection.value[indexPath.item])
            cell.imageHeightConstraint?.constant = 100
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collectionViewModel.productsCollection.value.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(indexPath.section) -- \(indexPath.item)")
    }

func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge + 200 >= scrollView.contentSize.height) {
        self.collectionViewModel.loadCategories()
    }
}
}
