//
//  TrackListViewController.swift
//  HerCycle
//
//  Created by Ana on 9/8/24.
//

import UIKit

final class TrackListViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var searchController: UISearchController!
    
    let allTracks: [AudioTrack] = [
        AudioTrack(title: "What Men & Women NEED To Know About The Menstrual Cycle", artist: "Dr. Mindy Pelz", filename: "podcast1", coverImageName: "cover1", duration: 180),
        AudioTrack(title: "What ACTUALLY Happens During Your Monthly Cycle", artist: " Mel Robbins Podcast Clips", filename: "podcast2", coverImageName: "cover2", duration: 200),
        AudioTrack(title: "working out on your period + training around your menstrual cycle", artist: "Know Your Power Podcast", filename: "podcast3", coverImageName: "cover3", duration: 240),
        AudioTrack(title: "A taboo-free way to talk about periods", artist: "TEDxGatewayWomen", filename: "podcast4", coverImageName: "cover4", duration: 220),
        AudioTrack(title: "Why do women have periods?", artist: "Samantha Armen", filename: "podcast6", coverImageName: "cover6", duration: 220),
        AudioTrack(title: "The Power of the Period ", artist: "Lucy Peach | TEDxPerth", filename: "podcast5", coverImageName: "cover5", duration: 220),
        AudioTrack(title: "Girl talk - periods", artist: "GIRL TALK", filename: "podcast7", coverImageName: "cover7", duration: 220),
        AudioTrack(title: "Family tourism", artist: "Always never", filename: "song3", coverImageName: "cover1", duration: 220)
    ]
    
    private var filteredTracks: [AudioTrack] = []
    
    private var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupSearchController()
        title = "Podcasts"
        
        view.backgroundColor = UIColor(named: "mainBackgroundColor")
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        collectionView.register(TrackCollectionViewCell.self, forCellWithReuseIdentifier: "TrackCell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
    }
    
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search podcasts"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredTracks = allTracks.filter { track in
            return track.title.lowercased().contains(searchText.lowercased())
        }
        collectionView.reloadData()
    }
}

extension TrackListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isFiltering ? filteredTracks.count : allTracks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackCell", for: indexPath) as? TrackCollectionViewCell else {
            fatalError("Unable to dequeue TrackCollectionViewCell")
        }
        
        let track = isFiltering ? filteredTracks[indexPath.item] : allTracks[indexPath.item]
        cell.configure(with: track)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = 16.0 * 3
        let availableWidth = collectionView.bounds.width - paddingSpace
        let widthPerItem = availableWidth / 2
        return CGSize(width: widthPerItem, height: widthPerItem + 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTrack = isFiltering ? filteredTracks[indexPath.item] : allTracks[indexPath.item]
        let selectedTrackIndex = allTracks.firstIndex(where: { $0.title == selectedTrack.title }) ?? 0
        let viewModel = AudioPlayerViewModel(tracks: allTracks, currentTrackIndex: selectedTrackIndex)
        let playerVC = AudioPlayerViewController(viewModel: viewModel)
        
        playerVC.modalPresentationStyle = .pageSheet
        playerVC.modalTransitionStyle = .coverVertical
        
        present(playerVC, animated: true, completion: nil)
    }
}

extension TrackListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}
