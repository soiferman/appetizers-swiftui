//
//  AppetizerListView.swift
//  Appetizers
//
//  Created by Max Soiferman on 9/10/23.
//

import SwiftUI

@MainActor final class AppetizerListViewModel: ObservableObject {
    
    @Published var products: [ProductModel] = []
    @Published var alertItem: AlertItem?
    @Published var isLoading = false
    @Published var isShowingDetail = false
    @Published var selectedProduct: ProductModel?
    
    func getProducts() {
        
        isLoading = true
        
        NetworkManager.shared.getProducts { result in
            DispatchQueue.main.async {
                
                self.isLoading = false
                
                switch result {
                case .success(let products):
                    self.products = products
                case .failure(let error):
                    switch error {
                    case .invalidURL:
                        self.alertItem = AlertContext.invalidURL
                    case .invalidResponse:
                        self.alertItem = AlertContext.invalidResponse
                    case .invalidData:
                        self.alertItem = AlertContext.invalidData
                    case .unableToComplete:
                        self.alertItem = AlertContext.unableToComplete
                    }
                }
            }
            
        }
    }
    
    func getProductsAsync() {
        
        isLoading = true
        
        Task {
            do {
                products = try await NetworkManager.shared.getProductsAsync()
                isLoading = false
            } catch {
                if let apiError = error as? APIError {
                    handleError(apiError)
                    isLoading = false
                } else {
                    alertItem = AlertContext.generalError
                }
            }
        }
        
    }
    
    func handleError(_ apiError: APIError) {
        switch apiError {
        case .invalidURL:
            alertItem = AlertContext.invalidURL
        case .invalidResponse:
            alertItem = AlertContext.invalidResponse
        case .invalidData:
            alertItem = AlertContext.invalidData
        case .unableToComplete:
            alertItem = AlertContext.unableToComplete
        }
    }
    
}
