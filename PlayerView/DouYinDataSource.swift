//
//  DouYinDataSource.swift
//  PlayerView
//
//  Created by 杨志远 on 2020/1/1.
//  Copyright © 2020 BaQiWL. All rights reserved.
//

import UIKit

struct DouYinListModel : Decodable {
    let aweme_list : [DouYinModel]
}

struct DouYinModel : Decodable {
    let desc : String
    let video : DouYinVideoModel
    let statistics : DouYinVideoStatistics
}

struct DouYinVideoStatistics : Decodable {
    let digg_count : Int
    let share_count : Int
}

/// video
struct DouYinVideoModel : Decodable {
    let duration : Int
    let cover : DouYinVideoCover
    let origin_cover : DouYinVideoOriginCover
    let dynamic_cover : DouYinVideoDynamicCover
    let play_addr : DouYinVideoAddress
    let width : Int
    let height : Int
}

/// Video play address
struct DouYinVideoAddress : Decodable {
    let uri : String
    let url_list : [String]
}

/// Video Cover
struct DouYinVideoCover : Decodable {
    let uri : String
    let url_list : [String]
}

/// Video origin cover
struct DouYinVideoOriginCover : Decodable {
    let uri : String
    let url_list : [String]
}

/// Video dynamic cover
struct DouYinVideoDynamicCover : Decodable{
    let uri : String
    let url_list : [String]
}

/// Video download address

class DouYinDataSource: NSObject {
    var models : [DouYinModel] = []
    
    override init() {
        super.init()
        fetchDouYinModel()
    }
    
    /// fetch models from douyin.json file
    private func fetchDouYinModel() {
        let jsonPath = Bundle.main.path(forResource: "douyin", ofType: "json")!
        let jsonURL = URL(fileURLWithPath: jsonPath)
        let data = try! Data(contentsOf: jsonURL)
        let model = try! JSONDecoder().decode(DouYinListModel.self, from: data)
        self.models = model.aweme_list
    }
}
