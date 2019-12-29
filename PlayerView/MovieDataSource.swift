//
//  MovieDataSource.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/12/17.
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
    let type : [String]
    var indexPath : IndexPath?
}

class MovieDataSource: NSObject {
    var models : [MovieModel] = []
    let HomeListCellID = "HomeListCell"
    let TextCellID = "TextCell"
    weak var delegate : CellClick?
    
    override init() {
        super.init()
        fetchMovieModel()
    }
    
    init(with delegate :  CellClick) {
        self.delegate = delegate
        super.init()
        fetchMovieModel()
    }
    
    /// fetch models from movie.json file
    func fetchMovieModel() {
        let jsonPath = Bundle.main.path(forResource: "movie", ofType: "json")!
        let jsonURL = URL(fileURLWithPath: jsonPath)
        
        let data = try! Data(contentsOf: jsonURL)
        let models = try! JSONDecoder().decode([MovieModel].self, from: data)
        self.models = models
    }
}

extension MovieDataSource : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row % 4
        var model = models[indexPath.row]
        model.indexPath = indexPath
        
        if index == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TextCellID) as! TextCell
            cell.model = model
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeListCellID) as! HomeListCell
            cell.model = model
            cell.delegate = self.delegate
            return cell
        }
    }
}
