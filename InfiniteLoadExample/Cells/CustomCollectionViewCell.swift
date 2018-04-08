import UIKit
import RxSwift
import Kingfisher

class CustomCollectionViewCell: UICollectionViewCell {

    var productImageView: UIImageView
    var productNameLabel: UILabel
    var manufacturerNameLabel: UILabel
    var saleLabel: UILabel
    var salePriceLabel: UILabel
    var originalPriceLabel: UILabel
    var freeShippingLabel: UILabel
    var collectionCellViewModel: Variable<CollectionCellViewModel?>
    var favoriteIconButton: UIButton
    // Ref: https://github.com/ReactiveX/RxSwift/issues/437
    private(set) var disposeBag = DisposeBag()

    var imageHeightConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {

        productImageView = UIImageView()
        productNameLabel = UILabel()
        manufacturerNameLabel = UILabel()
        saleLabel = UILabel()
        salePriceLabel = UILabel()
        originalPriceLabel = UILabel()
        freeShippingLabel = UILabel()
        favoriteIconButton = UIButton()
        collectionCellViewModel = Variable(nil)

        super.init(frame: frame)

        self.backgroundColor = .white
        let strikethroughView = UIView()
        strikethroughView.translatesAutoresizingMaskIntoConstraints = false
        strikethroughView.backgroundColor = .darkGray

        productImageView.translatesAutoresizingMaskIntoConstraints = false
        productNameLabel.translatesAutoresizingMaskIntoConstraints = false
        manufacturerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        saleLabel.translatesAutoresizingMaskIntoConstraints = false
        salePriceLabel.translatesAutoresizingMaskIntoConstraints = false
        originalPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        freeShippingLabel.translatesAutoresizingMaskIntoConstraints = false
        favoriteIconButton.translatesAutoresizingMaskIntoConstraints = false
        productImageView.contentMode = .scaleAspectFit

        self.contentView.addSubview(productImageView)
        configure(label: productNameLabel)
        configure(label: manufacturerNameLabel)
        configure(label: salePriceLabel)
        configure(label: originalPriceLabel)
        configure(label: freeShippingLabel)
        configure(label: saleLabel)

        originalPriceLabel.addSubview(strikethroughView)

        saleLabel.backgroundColor = .red
        saleLabel.text = "Sale"
        saleLabel.textColor = .white
        saleLabel.textAlignment = .center

        manufacturerNameLabel.numberOfLines = 0
        manufacturerNameLabel.font = UIFont.systemFont(ofSize: 14.0)

        favoriteIconButton.setImage(UIImage(named: "unfavorite"), for: .normal)
        favoriteIconButton.backgroundColor = .white
        favoriteIconButton.layer.borderWidth = 1.0
        favoriteIconButton.layer.borderColor = UIColor.lightGray.cgColor

        self.contentView.layer.borderColor = UIColor.lightGray.cgColor
        self.contentView.layer.borderWidth = 2.0

        let freeSwatchesParentView = UIView()
        let freeSwatchesButton = UIButton()
        freeSwatchesParentView.translatesAutoresizingMaskIntoConstraints = false
        freeSwatchesButton.translatesAutoresizingMaskIntoConstraints = false
        freeSwatchesButton.layer.cornerRadius = 5.0
        freeSwatchesButton.layer.borderWidth = 2.0
        freeSwatchesButton.layer.borderColor = UIColor.blue.cgColor
        freeSwatchesButton.titleLabel?.font = manufacturerNameLabel.font
        freeSwatchesButton.setTitle("Get Free Swatches", for: .normal)
        freeSwatchesButton.setTitleColor(.black, for: .normal)
        self.contentView.addSubview(freeSwatchesParentView)
        freeSwatchesParentView.addSubview(freeSwatchesButton)
        freeSwatchesParentView.clipsToBounds = true
        self.contentView.addSubview(favoriteIconButton)

        let views = ["productNameLabel": productNameLabel, "manufacturerNameLabel": manufacturerNameLabel, "productImageView": productImageView, "saleLabel": saleLabel, "salePriceLabel": salePriceLabel, "originalPriceLabel": originalPriceLabel, "strikethroughView": strikethroughView, "freeShippingLabel": freeShippingLabel, "favoriteIconButton": favoriteIconButton, "freeSwatchesParentView": freeSwatchesParentView, "freeSwatchesButton": freeSwatchesButton] as [String : Any]

        let freeSwatchesHeightConstraint = NSLayoutConstraint(item: freeSwatchesParentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
        self.contentView.addConstraint(freeSwatchesHeightConstraint)

        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[saleLabel(50)]", options: [], metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[saleLabel(20)]", options: [], metrics: nil, views: views))

        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[freeSwatchesParentView]-5-|", options: [], metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[freeSwatchesButton]|", options: [], metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5@999-[freeSwatchesButton]|", options: [], metrics: nil, views: views))

        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[productNameLabel]-5-|", options: [], metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[manufacturerNameLabel]-5-|", options: [], metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[productImageView]-5-|", options: [], metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[salePriceLabel(>=0)]-20-[originalPriceLabel(>=0)]", options: [], metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[freeShippingLabel]-5-|", options: [], metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[strikethroughView]|", options: [], metrics: nil, views: views))        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[productImageView]-5-[productNameLabel(>=0)][manufacturerNameLabel(>=0)]-5-[salePriceLabel(20)]-5-[freeShippingLabel(<=20)]-5-[freeSwatchesParentView(>=0)]-5-|", options: [], metrics: nil, views: views))

        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[favoriteIconButton(25)]|", options: [], metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[favoriteIconButton(25)]", options: [], metrics: nil, views: views))

        self.addConstraint(NSLayoutConstraint(item: originalPriceLabel, attribute: .centerY, relatedBy: .equal, toItem: salePriceLabel, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: originalPriceLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 20))

        self.addConstraint(NSLayoutConstraint(item: strikethroughView, attribute: .centerY, relatedBy: .equal, toItem: originalPriceLabel, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: strikethroughView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1))

        imageHeightConstraint = NSLayoutConstraint(item: productImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
        if let imageHeightConstraint = imageHeightConstraint {
            self.contentView.addConstraint(imageHeightConstraint)
        }

        _ = collectionCellViewModel.asObservable().observeOn(MainScheduler.instance).takeUntil(self.rx.deallocated).subscribe(onNext: { cellModel in

            guard let cellModel = cellModel else { return }
            let product = cellModel.product
            self.productNameLabel.text = product.name
            self.manufacturerNameLabel.text = product.manufacturerName
            self.productImageView.kf.indicatorType = .activity
            self.productImageView.kf.setImage(with: URL(string: product.imageURL)!)
            self.saleLabel.isHidden = !product.showSalesBanner
            self.freeShippingLabel.text = product.freeShipText
            self.salePriceLabel.text = "\(product.salePrice)"
            self.originalPriceLabel.text = "\(product.listPrice)"
            let image = UIImage(named: cellModel.collectionViewDataViewModel.favoritedProductSKUs.contains(product.sku) ? "favorite" : "unfavorite")!
            self.favoriteIconButton.setImage(image, for: .normal)
            freeSwatchesHeightConstraint.constant = cellModel.cellHeight
            freeSwatchesButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { _ in
                cellModel.collectionViewDataViewModel.selectedProduct.value = product
            }).disposed(by: self.disposeBag)

            self.favoriteIconButton.rx.controlEvent(.touchUpInside).flatMap({ _ -> Observable<[String: String]> in
                return self.collectionCellViewModel.value?.collectionViewDataViewModel.favorite(product: product) ?? Observable.just(["imageName": "unfavorite"])
            }).subscribe(onNext: { (val) in
                if let imageName = val["imageName"], let image = UIImage(named: imageName) {
                    self.favoriteIconButton.setImage(image, for: .normal)
                }
            }).disposed(by: self.disposeBag)
        })
    }

    private func configure(label: UILabel) {
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14.0)
        self.contentView.addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isSelected: Bool {
        willSet(newValue) {
            super.isSelected = newValue
            if newValue == true {
                //print("YES")
            } else {
                //print("NO")
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        productImageView.image = nil
        productNameLabel.text = ""
        manufacturerNameLabel.text = ""
        saleLabel.isHidden = true
        salePriceLabel.text = ""
        originalPriceLabel.text = ""
        freeShippingLabel.text = ""
        favoriteIconButton.setImage(UIImage(named: "unfavorite"), for: .normal)
        self.collectionCellViewModel.value?.collectionViewDataViewModel.markingFavorite.value = false
    }
}

