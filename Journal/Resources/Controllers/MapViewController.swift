//
//  MapViewController.swift
//  Journal
//
//  Created by Cagri Sahan on 4/30/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Variables
    var annotations: [EntryAnnotation]!
    var delegate: HomeViewController!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.register(EntryAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(EntryAnnotationClusterView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        mapView.addAnnotations(annotations)
        
        for item in mapView.annotations {
            let annotation = item as! EntryAnnotation
            annotation.delegate = self
        }
    }
}

extension MapViewController: AnnotationDelegate {
    func filterFromMap(recordNames: [String]) {
        self.delegate.searchFilter = self.delegate.entries.filter { recordNames.contains($0.recordName) }
        self.delegate.tableView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
}
