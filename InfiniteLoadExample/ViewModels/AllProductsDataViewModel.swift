import Foundation
import RxSwift
import Moya

private let batchSize: Int = 10

class AllProductsDataViewModel {

    var productsCollection: Variable<[Product]>
    var currentBeginningIndex: Int
    var currentEndingIndex: Int
    var productsCount: Variable<Int>
    let categoryIdentifier: String
    var pageNumber: Int
    var loadingProducts: Variable<Bool>
    var categoryName: Variable<String>
    var selectedProduct: Variable<Product?>    
    var markingFavorite: Variable<Bool>
    var favoritedProductSKUs: [String] = []
    var favoritedProduct: Variable<Product?>
    var pageLoadFinished: Variable<Bool>
    var numberOfItemsLoaded: Variable<String>

    init(categoryIdentifier: String, page: Int) {
        productsCollection = Variable([])
        currentBeginningIndex = 0
        currentEndingIndex = 0
        productsCount = Variable(0)
        categoryName = Variable("No Name")
        selectedProduct = Variable(nil)        
        markingFavorite = Variable(false)
        favoritedProduct = Variable(nil)
        pageLoadFinished = Variable(false)
        numberOfItemsLoaded = Variable("0/0 Loaded")

        self.categoryIdentifier = categoryIdentifier
        self.pageNumber = page
        self.loadingProducts = Variable(false)        

        loadCategories()
    }

    func loadCategories() {
        guard !loadingProducts.value, !pageLoadFinished.value else { return }

        let endpointClosure = { (target: WebAPIService) -> Endpoint<WebAPIService> in
            let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
            return defaultEndpoint.adding(newHTTPHeaderFields: ["Accept": "application/json"])
        }

        let productsResponseProviderReactive = RxMoyaProvider<WebAPIService>(endpointClosure: endpointClosure)

        let customPageData: Observable<CategoryObject> = productsResponseProviderReactive.request(.category(identifier: self.categoryIdentifier, page: self.pageNumber)).debug().mapObject(type: CategoryObject.self)
        self.loadingProducts.value = true
    _ = customPageData.subscribe { response in
        switch response {
        case .next(let result):
            let allProducts = result.allProductsObject.products
            self.currentBeginningIndex = self.productsCollection.value.count
            self.currentEndingIndex = self.currentBeginningIndex + result.allProductsObject.products.count - 1
            self.productsCount.value = result.allProductsObject.productCount
            self.categoryName.value = result.allProductsObject.categoryName
            self.productsCollection.value.append(contentsOf: allProducts)
            self.pageNumber = self.pageNumber + 1
            self.loadingProducts.value = false
            self.pageLoadFinished.value = allProducts.count < batchSize
            self.numberOfItemsLoaded.value = "\(self.productsCollection.value.count)/\(self.productsCount.value) Loaded"
            case .error(let error):
                print("Error occurred with description \(error.localizedDescription)")
                self.loadingProducts.value = false
            default:
                break
            }
        }
    }

    func favorite(product: Product) -> Observable<[String: String]> {
        self.markingFavorite.value = true
        var imageName: String = "favorite"
        if favoritedProductSKUs.contains(product.sku) {
            if let index = self.favoritedProductSKUs.index(of: product.sku) {
                self.favoritedProductSKUs.remove(at: index)
            }
            imageName = "unfavorite"
        } else {
            self.favoritedProductSKUs.append(product.sku)
        }
        return Observable.just(["imageName": imageName]).delay(2.0, scheduler: MainScheduler.instance).do(onNext: { (val) in
            self.markingFavorite.value = false
        })
    }
}

