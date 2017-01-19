//
//  TopInRedditTests.swift
//  TopInRedditTests
//
//  Created by Cleber Santos on 1/17/17.
//  Copyright © 2017 Deviget. All rights reserved.
//

import XCTest
@testable import TopInReddit

class TopInRedditTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testModelCreatingWithBasicInfo() {
        let model = Post(guid: "5oq8ak", title: "A two for one special")
        let viewModel = PostViewModel(post: model)
        
        XCTAssertEqual(model.guid, "5oq8ak")
        XCTAssertEqual(viewModel.post.guid, "5oq8ak")
        XCTAssertEqual(viewModel.titleString, "A two for one special")
    }
    
    func testPostModelWithEmptyJSON() {
        let fakeJSON = [String: AnyObject]()
        let model = Post.createFromJSON(fakeJSON)
        
        XCTAssert(model == nil, "Model should be nil")
    }
    
    func testPostModelWithNilPropertiesFromJSON() {
        let fakeJSON: [String: AnyObject] = [
            "title" : "A two for one special" as AnyObject,
            "id" : "5oq8ak" as AnyObject
        ]
        
        let model = Post.createFromJSON(fakeJSON)
        
        XCTAssert(model != nil, "Model is nil")
    }
    
    func testLoadPostsAndCount() {
        let api = RedditAPI()
        api.getTopPosts { (data, error) in
            XCTAssert(data!.count > 0, "Failed to load posts")
        }
    }
    
    func testLoadingPostsPerformance() {
        let api = RedditAPI()
        
        self.measure {
            api.getTopPosts { (data, error) in
                print("Finished loading posts")
            }
        }
    }
    
}
