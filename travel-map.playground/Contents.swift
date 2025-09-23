//: Travel Itinerary: Paris to Athens

import MapKit
import PlaygroundSupport

// Custom polyline class to hold title information
class TitledPolyline: MKPolyline {
    var routeTitle: String?
}

// Custom annotation types
class CityAnnotation: MKPointAnnotation {
    var isCity: Bool = true
}

class RouteAnnotation: MKPointAnnotation {
    var transportIcon: String = ""
}

// Create an MKMapViewDelegate to provide a renderer for our overlay
class MapViewDelegate: NSObject, MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? TitledPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = .lightGray
            polylineRenderer.lineWidth = 4
            polylineRenderer.lineCap = .round
            polylineRenderer.lineJoin = .round
            return polylineRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let cityAnnotation = annotation as? CityAnnotation {
            // Large white circle for cities
            let identifier = "CityAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }

            annotationView?.annotation = annotation
            annotationView?.canShowCallout = true

            // Create large white circle
            let circleSize: CGFloat = 20
            let circleView = NSView(frame: NSRect(x: 0, y: 0, width: circleSize, height: circleSize))
            circleView.wantsLayer = true
            circleView.layer?.backgroundColor = NSColor.white.cgColor
            circleView.layer?.borderColor = NSColor.white.cgColor
            circleView.layer?.borderWidth = 2
            circleView.layer?.cornerRadius = circleSize / 2

            // Convert NSView to NSImage
            let image = NSImage(size: circleView.bounds.size)
            image.lockFocus()
            circleView.layer?.render(in: NSGraphicsContext.current!.cgContext)
            image.unlockFocus()

            annotationView?.image = image
            return annotationView

        } else if let routeAnnotation = annotation as? RouteAnnotation {
            // Transport icon for route segments
            let identifier = "RouteAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }

            annotationView?.annotation = annotation
            annotationView?.canShowCallout = true

            // Create larger transport icon
            let iconSize: CGFloat = 100
            let iconView = NSView(frame: NSRect(x: 0, y: 0, width: iconSize, height: iconSize))
            iconView.wantsLayer = true
            iconView.layer?.backgroundColor = NSColor.white.cgColor
            iconView.layer?.borderColor = NSColor.gray.cgColor
            iconView.layer?.borderWidth = 2
            iconView.layer?.cornerRadius = 8

            // Add the emoji text
            let label = NSTextField(labelWithString: routeAnnotation.transportIcon)
            label.font = NSFont.systemFont(ofSize: 24)
            label.textColor = NSColor.black
            label.backgroundColor = NSColor.clear
            label.alignment = .center
            label.frame = NSRect(x: 0, y: 0, width: iconSize, height: iconSize)
            iconView.addSubview(label)

            // Convert NSView to NSImage
            let image = NSImage(size: iconView.bounds.size)
            image.lockFocus()
            iconView.layer?.render(in: NSGraphicsContext.current!.cgContext)
            image.unlockFocus()

            annotationView?.image = image
            return annotationView
        }

        return nil
    }
}

// Create a strong reference to a delegate
let delegate = MapViewDelegate()

// Create an MKMapView
let mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: 800, height: 800))
mapView.delegate = delegate

// Configure The Map elevation and emphasis style
let configuration = MKStandardMapConfiguration(elevationStyle: .flat, emphasisStyle: .muted)
mapView.preferredConfiguration = configuration

// Create city annotations as large white circles
let parisAnnotation = CityAnnotation()
parisAnnotation.coordinate = CLLocationCoordinate2DMake(48.8566, 2.3522)
parisAnnotation.title = "Paris"
parisAnnotation.subtitle = "🚂 Departure: 2025-09-12 15:17"
mapView.addAnnotation(parisAnnotation)

let milanAnnotation = CityAnnotation()
milanAnnotation.coordinate = CLLocationCoordinate2DMake(45.4642, 9.1900)
milanAnnotation.title = "Milan"
milanAnnotation.subtitle = "🚂 Transfer point"
mapView.addAnnotation(milanAnnotation)

let bariAnnotation = CityAnnotation()
bariAnnotation.coordinate = CLLocationCoordinate2DMake(41.1171, 16.8719)
bariAnnotation.title = "Bari"
bariAnnotation.subtitle = "⛴️ Ferry to Greece"
mapView.addAnnotation(bariAnnotation)

let patrasAnnotation = CityAnnotation()
patrasAnnotation.coordinate = CLLocationCoordinate2DMake(38.2466, 21.7346)
patrasAnnotation.title = "Patras"
patrasAnnotation.subtitle = "🚌 Bus to Kiato"
mapView.addAnnotation(patrasAnnotation)

let kiatoAnnotation = CityAnnotation()
kiatoAnnotation.coordinate = CLLocationCoordinate2DMake(38.0133, 22.7486)
kiatoAnnotation.title = "Kiato"
kiatoAnnotation.subtitle = "🚂 Train to Athens"
mapView.addAnnotation(kiatoAnnotation)

let athensAnnotation = CityAnnotation()
athensAnnotation.coordinate = CLLocationCoordinate2DMake(37.9838, 23.7275)
athensAnnotation.title = "Athens"
athensAnnotation.subtitle = "🏁 Arrival: 2025-09-14 17:20"
mapView.addAnnotation(athensAnnotation)

// Set map region to show all cities from Paris to Athens
let coordinates = [
    parisAnnotation.coordinate,
    milanAnnotation.coordinate,
    bariAnnotation.coordinate,
    patrasAnnotation.coordinate,
    kiatoAnnotation.coordinate,
    athensAnnotation.coordinate
]

let minLat = coordinates.map { $0.latitude }.min()! - 1
let maxLat = coordinates.map { $0.latitude }.max()! + 1
let minLon = coordinates.map { $0.longitude }.min()! - 2
let maxLon = coordinates.map { $0.longitude }.max()! + 2

let center = CLLocationCoordinate2D(
    latitude: (minLat + maxLat) / 2,
    longitude: (minLon + maxLon) / 2
)
let span = MKCoordinateSpan(
    latitudeDelta: maxLat - minLat,
    longitudeDelta: maxLon - minLon
)

mapView.region = MKCoordinateRegion(center: center, span: span)

// Create MKPolyline overlays for each leg of the journey
let legData = [
    (parisAnnotation.coordinate, milanAnnotation.coordinate, "🚂 Paris → Milan", "🚂"),
    (milanAnnotation.coordinate, bariAnnotation.coordinate, "🚂 Milan → Bari", "🚂"),
    (bariAnnotation.coordinate, patrasAnnotation.coordinate, "⛴️ Bari → Patras", "⛴️"),
    (patrasAnnotation.coordinate, kiatoAnnotation.coordinate, "🚌 Patras → Kiato", "🚌"),
    (kiatoAnnotation.coordinate, athensAnnotation.coordinate, "🚂 Kiato → Athens", "🚂")
]

for (start, end, title, _) in legData {
    let coordinates = [start, end]
    let polyline = TitledPolyline(coordinates: coordinates, count: coordinates.count)
    polyline.routeTitle = title
    mapView.addOverlay(polyline)
}

// Add transport icon annotations at the midpoint of each route
for (start, end, title, icon) in legData {
    let midLat = (start.latitude + end.latitude) / 2
    let midLon = (start.longitude + end.longitude) / 2
    let midPoint = CLLocationCoordinate2D(latitude: midLat, longitude: midLon)

    let routeAnnotation = RouteAnnotation()
    routeAnnotation.coordinate = midPoint
    routeAnnotation.title = title
    routeAnnotation.subtitle = "Route segment"
    routeAnnotation.transportIcon = icon
    // mapView.addAnnotation(routeAnnotation)
}

// Add the created mapView to our Playground Live View
PlaygroundPage.current.liveView = mapView
