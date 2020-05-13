import Foundation
import UIKit
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

class WaypointArrivalScreenViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let waypointOne = Waypoint(coordinate: CLLocationCoordinate2DMake(38.913175, -77.032405))
        let waypointTwo = Waypoint(coordinate: CLLocationCoordinate2DMake(38.8977, -77.0365))
        
        let options = NavigationRouteOptions(waypoints: [waypointOne, waypointTwo], profileIdentifier: .automobile)
        
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
                navigationViewController.delegate = self
                self.present(navigationViewController, animated: true, completion: nil)
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
}

extension WaypointArrivalScreenViewController: NavigationViewControllerDelegate {
    // Show an alert when arriving at the waypoint and wait until the user to start next leg.
    func navigationViewController(_ navigationViewController: NavigationViewController, didArriveAt waypoint: Waypoint) -> Bool {
        let alert = UIAlertController(title: "Arrived at \(String(describing: waypoint.name))", message: "Would you like to continue?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            // Begin the next leg once the driver confirms
            navigationViewController.navigationService.routeProgress.legIndex += 1
        }))
        navigationViewController.present(alert, animated: true, completion: nil)
        
        return false
    }
}
