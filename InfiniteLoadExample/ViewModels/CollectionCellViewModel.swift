import UIKit
import RxOptional
import RxSwift

class CollectionCellViewModel {
    let collectionViewDataViewModel: AllProductsDataViewModel
    let product: Product
    var cellHeight: CGFloat = 0    

    init(collectionViewDataViewModel: AllProductsDataViewModel, product: Product) {
        self.collectionViewDataViewModel = collectionViewDataViewModel
        self.product = product
        self.cellHeight = 0.0
    }    
}

