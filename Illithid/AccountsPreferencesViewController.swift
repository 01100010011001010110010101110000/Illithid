//
//  AccountsPreferencesViewController.swift
//  Illithid
//
//  Created by Tyler Gregory on 11/20/18.
//  Copyright © 2018 flayware. All rights reserved.
//

import Cocoa

class AccountsPreferencesViewController: NSViewController {
  let defaults = UserDefaults.standard

  @IBOutlet var accountsTableView: NSTableView!

  override func viewDidLoad() {
    super.viewDidLoad()
    accountsTableView.delegate = self
    accountsTableView.dataSource = self
  }
}

extension AccountsPreferencesViewController: NSTableViewDataSource {
  func numberOfRows(in _: NSTableView) -> Int {
    let accounts = defaults.stringArray(forKey: "RedditAccounts")
    return accounts?.count ?? 0
  }
}

extension AccountsPreferencesViewController: NSTableViewDelegate {
  fileprivate enum CellIdentifiers {
    static let UsernameCell = NSUserInterfaceItemIdentifier("UsernameCellID")
  }

  func tableView(_ tableView: NSTableView, viewFor _: NSTableColumn?, row: Int) -> NSView? {
    let accounts = defaults.stringArray(forKey: "RedditAccounts")

    guard let account = accounts?[row] else {
      return nil
    }

    if let cell = tableView.makeView(withIdentifier: CellIdentifiers.UsernameCell, owner: nil) as? NSTableCellView {
      cell.textField?.stringValue = account
      return cell
    } else {
      return nil
    }
  }
}
