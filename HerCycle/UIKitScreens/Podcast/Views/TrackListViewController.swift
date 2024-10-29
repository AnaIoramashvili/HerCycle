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
    
    private let weeksPodcasts: [AudioTrack] = [
        AudioTrack(title: "What Men & Women NEED To Know About The Menstrual Cycle", artist: "Dr. Mindy Pelz", filename: "podcast1", coverImageName: "cover1", duration: 680),
        AudioTrack(title: "What ACTUALLY Happens During Your Monthly Cycle", artist: "Mel Robbins Podcast Clips", filename: "podcast2", coverImageName: "cover2", duration: 655)
    ]

    private let popularNowPodcasts: [AudioTrack] = [
        AudioTrack(title: "working out on your period + training around your menstrual cycle", artist: "Know Your Power Podcast", filename: "podcast3", coverImageName: "cover3", duration: 1397),
        AudioTrack(title: "A taboo-free way to talk about periods", artist: "TEDxGatewayWomen", filename: "podcast4", coverImageName: "cover4", duration: 687),
        AudioTrack(title: "Why do women have periods?", artist: "Samantha Armen", filename: "podcast6", coverImageName: "cover6", duration: 285),
        AudioTrack(title: "The Power of the Period", artist: "Lucy Peach | TEDxPerth", filename: "podcast5", coverImageName: "cover5", duration: 553)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
            if sectionIndex == 0 {
                // Week's Podcast section
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .absolute(200))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPaging
                section.interGroupSpacing = 16
                section.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 16, bottom: 16, trailing: 16)
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]
                
                return section
            } else {
                // Popular Now section
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(108)) 

                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 12
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 16, trailing: 16)
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]
                
                return section
            }
        }
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .mainBackground
        
        collectionView.register(WeeksPodcastCell.self, forCellWithReuseIdentifier: "WeeksPodcastCell")
        collectionView.register(PopularNowCell.self, forCellWithReuseIdentifier: "PopularNowCell")
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
    }
}

extension TrackListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? weeksPodcasts.count : popularNowPodcasts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeeksPodcastCell", for: indexPath) as? WeeksPodcastCell else {
                fatalError("Unable to dequeue WeeksPodcastCell")
            }
            let track = weeksPodcasts[indexPath.item]
            cell.configure(with: track)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularNowCell", for: indexPath) as? PopularNowCell else {
                fatalError("Unable to dequeue PopularNowCell")
            }
            let track = popularNowPodcasts[indexPath.item]
            cell.configure(with: track)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as? SectionHeaderView else {
            fatalError("Unable to dequeue SectionHeaderView")
        }
        
        if indexPath.section == 0 {
            headerView.configure(title: "Week's Podcast", fontSize: 30)
        } else {
            headerView.configure(title: "Popular Now 🔥", fontSize: 20)
        }
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTrack: AudioTrack
        let allTracks: [AudioTrack]
        
        if indexPath.section == 0 {
            selectedTrack = weeksPodcasts[indexPath.item]
            allTracks = weeksPodcasts + popularNowPodcasts
        } else {
            selectedTrack = popularNowPodcasts[indexPath.item]
            allTracks = popularNowPodcasts + weeksPodcasts
        }
        
        let selectedTrackIndex = allTracks.firstIndex(where: { $0.title == selectedTrack.title }) ?? 0
        let viewModel = AudioPlayerViewModel(tracks: allTracks, currentTrackIndex: selectedTrackIndex)
        let playerVC = AudioPlayerViewController(viewModel: viewModel)
        
        playerVC.modalPresentationStyle = .pageSheet
        playerVC.modalTransitionStyle = .coverVertical
        
        present(playerVC, animated: true, completion: nil)
    }
}
