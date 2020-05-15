import Foundation
import UIKit
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

class CustomDestinationMarkerController: UIViewController {
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
                navigationViewController.mapView?.delegate = self
                
                self.present(navigationViewController, animated: true, completion: nil)
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
}

extension CustomDestinationMarkerController: MGLMapViewDelegate {
    func navigationViewController(_ navigationViewController: NavigationViewController, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        var annotationImage = navigationViewController.mapView!.dequeueReusableAnnotationImage(withIdentifier: "marker")
        
        if annotationImage == nil {
            // Leaning Tower of Pisa by Stefan Spieler from the Noun Project.
            var image = UIImage(named: "marker")!
            
            // The anchor point of an annotation is currently always the center. To
            // shift the anchor point to the bottom of the annotation, the image
            // asset includes transparent bottom padding equal to the original image
            // height.
            //
            // To make this padding non-interactive, we create another image object
            // with a custom alignment rect that excludes the padding.
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height / 2, right: 0))
            
            // Initialize the ‘pisa’ annotation image with the UIImage we just loaded.
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "marker")
        }
        
        return annotationImage
    }
}
