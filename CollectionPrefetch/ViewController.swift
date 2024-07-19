//
//  ViewController.swift
//  CollectionPrefetch
//
//  Created by Erik Flores on 18/07/24.
//

import UIKit

class ViewController: UIViewController {
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: getLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    let registerCell = UICollectionView.CellRegistration<UICollectionViewCell, Item> { cell, indexPath, itemIdentifier in
        cell.contentConfiguration = UIHostingConfiguration {
            ItemCell(index: indexPath.row)
        }
    }
    lazy var dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { [weak self] collectionView, indexPath, itemIdentifier in
        guard let self else { return UICollectionViewCell() }
        return collectionView.dequeueConfiguredReusableCell(using: registerCell, for: indexPath, item: itemIdentifier)
    }
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addData()
    }
    
    func setupView() {
        snapshot.appendSections([.first])
        collectionView.prefetchDataSource = self
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func addData() {
        snapshot.appendItems((1...5).map { _ in Item() }, toSection: .first)
        dataSource.apply(snapshot)
    }
    
    func getLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(250))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension ViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            print("prefetchItemsAt indexPath \(indexPath)")
            if indexPath.row == 9 {
                addData()
            }
            if indexPath.row == 0 {
                snapshot.appendItems((1...5).map { _ in Item() }, toSection: .first)
                dataSource.apply(snapshot)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        print("cancelPrefetchingForItemsAt indexPath \(indexPaths)")
    }
}

import SwiftUI

struct ItemCell: View {
    let index: Int
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.gray)
            Text("\(index)").foregroundStyle(.white)
        }
        
    }
}

enum Section {
    case first
    case second
    case third
    case four
}

struct Item: Identifiable, Hashable {
    let id: UUID = UUID()
}

