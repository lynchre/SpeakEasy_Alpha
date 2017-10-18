//
//  SettingTableViewController.swift
//  OpenEarsSampleAppSwift
//
//  Created by Christopher James Lebioda on 10/14/17.
//  Copyright © 2017 Politepix. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {
    
    var settings = [Setting]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    /*
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return settings.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SettingTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SettingTableViewCell else {
            fatalError("The dequeued cell is not an instance of SettingTableViewCell.")
        }
        let setting = settings[indexPath.row]
        cell.nameLabel.text = setting.name
        cell.photoImageView.image = setting.photo
            
        return cell
    }
     */
 
    private func loadSettings() {
        let setting1 = UIImage(named: "Font_color_icon")
        let setting2 = UIImage(named: "font_size_icon")
        let setting3 = UIImage(named: "font_icon")
        let setting4 = UIImage(named: "Background_Color_icon")
        
        guard let fontColor = Setting(name: "Font Color", photo: setting1) else {
            fatalError("Unable to instantiate fontColor")
        }
        
        guard let fontSize = Setting(name: "Font Size", photo: setting2) else {
            fatalError("Unable to instantiate fontSize")
        }
        
        guard let font = Setting(name: "Font", photo: setting3) else {
            fatalError("Unable to instantiate font")
        }
        
        guard let backgroundColor = Setting(name: "Background Color", photo: setting4) else {
            fatalError("Unable to instantiate backgroundColor")
        }
        
        settings += [fontColor, fontSize, font, backgroundColor]
        
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
