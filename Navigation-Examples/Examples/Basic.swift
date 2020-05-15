import Foundation
import UIKit
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

class BasicViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let origin = CLLocationCoordinate2DMake(21.0298124, 105.8121157)
        let destination = CLLocationCoordinate2DMake(20.9596724, 105.8551936)
        let options = NavigationRouteOptions(coordinates: [origin, destination], profileIdentifier: .automobile)
        
        Directions.shared.calculate(options) { (session, result) in
            switch result {
            case let .success(response):
                guard let routes = response.routes, !routes.isEmpty, case let .route(options) = response.options,
                    let route = routes.first else
                {
                    return
                }
                // For demonstration purposes, simulate locations if the Simulate Navigation option is on.
                let navigationService = MapboxNavigationService(route: route, routeOptions: options)
                let navigationOptions = NavigationOptions(navigationService: navigationService)
                let navigationViewController = NavigationViewController(for: route, routeOptions: options, navigationOptions: navigationOptions)
                navigationViewController.modalPresentationStyle = .fullScreen
                
                self.present(navigationViewController, animated: true, completion: nil)
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
}
