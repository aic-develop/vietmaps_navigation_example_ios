import Foundation
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

class EmbeddedExampleViewController: UIViewController {
 
    @IBOutlet weak var reroutedLabel: UILabel!
    @IBOutlet weak var enableReroutes: UISwitch!
    @IBOutlet weak var container: UIView!
    var route: Route?

    lazy var options: NavigationRouteOptions = {
        let origin = CLLocationCoordinate2DMake(21.0298124, 105.8121157)
        let destination = CLLocationCoordinate2DMake(20.9596724, 105.8551936)
        return NavigationRouteOptions(coordinates: [origin, destination], profileIdentifier: .automobile)
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(EmbeddedExampleViewController.flashReroutedLabel(_:)), name: .routeControllerDidReroute, object: nil)
        reroutedLabel.isHidden = true
        calculateDirections()
    }

    
    func calculateDirections() {
        
        Directions.shared.calculate(options) { (session, result) in
            switch result {
            case let .success(response):
                guard let routes = response.routes, !routes.isEmpty, case let .route(options) = response.options,
                    let route = routes.first else
                {
                    return
                }
                self.route = route
                self.startEmbeddedNavigation(options)
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
    @objc func flashReroutedLabel(_ sender: Any) {
        reroutedLabel.isHidden = false
        reroutedLabel.alpha = 1.0
        UIView.animate(withDuration: 1.0, delay: 1, options: .curveEaseIn, animations: {
            self.reroutedLabel.alpha = 0.0
        }, completion: { _ in
            self.reroutedLabel.isHidden = true
        })
    }
    
    func startEmbeddedNavigation(_ routeOptions: RouteOptions) {
        // For demonstration purposes, simulate locations if the Simulate Navigation option is on.
        guard let route = route else { return }
        let navigationService = MapboxNavigationService(route: route, routeOptions: routeOptions)
        let navigationOptions = NavigationOptions(navigationService: navigationService)
        let navigationViewController = NavigationViewController(for: route, routeOptions: routeOptions, navigationOptions: navigationOptions)
        
        navigationViewController.delegate = self
        addChild(navigationViewController)
        container.addSubview(navigationViewController.view)
        navigationViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navigationViewController.view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0),
            navigationViewController.view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0),
            navigationViewController.view.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
            navigationViewController.view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0)
            ])
        self.didMove(toParent: self)
    }
}

extension EmbeddedExampleViewController: NavigationViewControllerDelegate {
    func navigationViewController(_ navigationViewController: NavigationViewController, shouldRerouteFrom location: CLLocation) -> Bool {
        return enableReroutes.isOn
    }
}
