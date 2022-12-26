//
//  ViewController.swift
//  GifSearch
//
//  Created by Pauls Slankis on 25/12/2022.
//

import UIKit

struct APIResponse: Codable {
    let data: [Data]
}

struct Data: Codable {
    let id: String
    let images: Images
}

struct Images: Codable {
    let downsized_large: Downsized_large
}

struct Downsized_large: Codable {
    let url: String
}

class ViewController: UIViewController, UICollectionViewDataSource, UISearchBarDelegate{
    
    private var collectionView: UICollectionView?
    
    var data: [Data] = []
    
    let searchbar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchbar.delegate = self
        view.addSubview(searchbar)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.frame.size.width-10, height: (view.frame.size.width)/1.6)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(GifCollectionViewCell.self, forCellWithReuseIdentifier: GifCollectionViewCell.identifier)
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        self.collectionView = collectionView
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchbar.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.frame.size.width-20, height: 50)
        collectionView?.frame = CGRect(x: 0, y: view.safeAreaInsets.top+55, width: view.frame.size.width, height: view.frame.size.height-55)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchbar.resignFirstResponder()
        if let text = searchbar.text {
            
            //Adding + between the words so it works as a search term
            let seperatedText = text.components(separatedBy: " ")
            let fullText = seperatedText.joined(separator: "+")
            
            data = []
            collectionView?.reloadData()
            fetchGifs(searchTerm: fullText)
        }
    }
    
    func fetchGifs(searchTerm: String) {
        let apiKey: String = "ECVoPb83SluWlzRB0kyGYPDmGVWgUwmL"
        let urlString = "https://api.giphy.com/v1/gifs/search?api_key=\(apiKey)&q=\(searchTerm)&limit=15&offset=0&rating=g&lang=en"
        guard let url = URL(string: urlString) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let jsonData = try JSONDecoder().decode(APIResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.data = jsonData.data
                    self?.collectionView?.reloadData()
                }
            }
            catch {
                print(error)
            }
        }
        
        task.resume()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let gifURLString = data[indexPath.row].images.downsized_large.url
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GifCollectionViewCell.identifier, for: indexPath) as? GifCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: gifURLString)
        return cell
    }
}

