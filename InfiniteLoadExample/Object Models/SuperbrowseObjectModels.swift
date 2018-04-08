import Foundation
import Mapper

struct CategoryObject: Mappable {
    let allProductsObject: AllProductsObject

    init(map: Mapper) throws {
        allProductsObject = try map.from("response")
    }
}

struct AllProductsObject: Mappable {
    let categoryId: Int
    let categoryName: String
    let productCount: Int
    let products: [Product]
    let currentPage: Int

    init(map: Mapper) throws {
        currentPage = try map.from("current_page")
        categoryId = try map.from("category_id")
        categoryName = try map.from("category_name")
        productCount = try map.from("product_count")
        products = try map.from("product_collection")
    }
}

struct Product: Mappable {
    let name: String
    let averageOverallRating: CGFloat
    let freeShipText: String
    let imageURL: String
    let listPrice: CGFloat
    let manufacturerName: String
    let showSalesBanner: Bool
    let salePrice: CGFloat
    var isFavorited: Bool
    let numStarRatings: Int
    let sku: String

    init(map: Mapper) throws {
        name = try map.from("name")
        averageOverallRating = try map.from("average_overall_rating", transformation: extractFloatValue)
        freeShipText = try map.from("free_ship_text")
        imageURL = try map.from("image_url")
        listPrice = try map.from("list_price", transformation: extractFloatValue)
        manufacturerName = try map.from("manufacturer_name", transformation: manufacturerNameTransformation)
        showSalesBanner = try map.from("show_sale_banner")
        salePrice = try map.from("sale_price", transformation: extractFloatValue)
        isFavorited = try map.from("is_favorited")
        numStarRatings = try map.from("number_of_reviews")
        sku = try map.from("sku")
    }
}

func extractFloatValue(object: Any?) throws -> CGFloat {
    guard let numberValue = object as? NSNumber else {
        throw MapperError.convertibleError(value: object, type: String.self)
    }

    return CGFloat(truncating: numberValue)
}

func manufacturerNameTransformation(object: Any?) throws -> String {
    guard let manufacturerName = object as? String else {
        throw MapperError.convertibleError(value: object, type: String.self)
    }
    return "by \(manufacturerName)"
}
