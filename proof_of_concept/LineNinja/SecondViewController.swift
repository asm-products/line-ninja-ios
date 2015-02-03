//
//  SecondViewController.swift
//  LineNinja
//
//  Created by David Sandor on 8/9/14.
//  Copyright (c) 2014 David Sandor. All rights reserved.
//

import UIKit

class SecondViewController: ResponsiveTextFieldViewController, UITableViewDelegate, UITableViewDataSource {
                            
    @IBOutlet weak var lblBigTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var items = ["First", "Second", "Third"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.lblBigTitle.text = "Big Title"
        self.lblSubtitle.text = "Subtitle"
        
        self.tableView.dataSource = self
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.getList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell

        cell.textLabel!.text = self.items[indexPath.row]
        
        return cell
    }

    func getList()
    {
        var url = "http://buildsucceeded.com/nearby.json"
        var request = NSMutableURLRequest()
        
        request.URL = NSURL(string: url)
        request.HTTPMethod = "GET"
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler: {
            (response:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            
            // http://www.binpress.com/tutorial/swiftyjson-how-to-handle-json-in-swift/111
            // https://github.com/lingoer/SwiftyJSON
            // Use swiftyJSON to convert the data string to json then parse.
            
            var json = JSONValue(data)
            
            
            println("Starting JSON dump...")
            
            for row in json.array! {
                var name = row["name"].string
                println("name: \(name)")
                
                self.items.append("\(name!)")
                
            }
            
            Dispatcher(self.tableView.reloadData)
            
            println("End of JSON dump...")
            
        })
    }
}

