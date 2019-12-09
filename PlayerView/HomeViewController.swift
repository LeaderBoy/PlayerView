//
//  HomeViewController.swift
//  PlayerView
//
//  Created by 杨 on 2019/12/9.
//  Copyright © 2019 BaQiWL. All rights reserved.
//

import UIKit

struct MovieModel : Decodable {
    let movieName : String
    let coverImg : String
    let url : String
    let hightUrl : String
    let videoTitle : String
    let videoLength : Int
}


class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let HomeListCellID = "HomeListCell"
    
    var dataSource : [MovieModel] = []
    
    var playerView : PlayerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchMovieModel()
    }
    
    func setupTableView() {
        let nib = UINib(nibName: "HomeListCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: HomeListCellID)
        tableView.backgroundColor = .groupTableViewBackground
        tableView.delaysContentTouches = false
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    /// fetch models from movie.json file
    func fetchMovieModel() {
        let jsonPath = Bundle.main.path(forResource: "movie", ofType: "json")!
        let jsonURL = URL(fileURLWithPath: jsonPath)
        
        let data = try! Data(contentsOf: jsonURL)
        let models = try! JSONDecoder().decode([MovieModel].self, from: data)
        dataSource = models
        tableView.reloadData()
    }

}

extension HomeViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeListCellID) as! HomeListCell
        cell.model = dataSource[indexPath.row]
        cell.delegate = self
        return cell
    }
}

extension HomeViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detail = VideoDetailViewController(playerView: playerView)
        detail.model = dataSource[indexPath.row]
        navigationController?.pushViewController(detail, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
}
extension HomeViewController : CellClick {
    func click(at container: UIView,url:String) {
        
        if playerView == nil {
            playerView = PlayerView()
        }
        
        container.addSubview(playerView!)
        playerView!.edges(to: container)
        if let url = URL(string: url) {
            playerView!.prepare(url: url)
        }
    }
}
