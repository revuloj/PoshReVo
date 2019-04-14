//
//  AgordojViewController.swift
//  PoshReVo
//
//  Created by Robin Hill on 3/12/16.
//  Copyright © 2016 Sinuous Rill. All rights reserved.
//

import Foundation
import UIKit

let agordojChelIdent = "agordaChelo"

/*
    Pagho por agordi la programon
*/
class AgordojViewController : UIViewController, Chefpagho, Stilplena {
    
    @IBOutlet var tabelo: UITableView?
    
    init() {
        super.init(nibName: "AgordojViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
        tabelo?.delegate = self
        tabelo?.dataSource = self
        tabelo?.register(UITableViewCell.self, forCellReuseIdentifier: agordojChelIdent)
        
        NotificationCenter.default.addObserver(self, selector: #selector(preferredContentSizeDidChange(forChildContentContainer:)), name: UIContentSizeCategory.didChangeNotification, object: nil)

        efektivigiStilon()
    }
    
    func aranghiNavigaciilo() {
        
        parent?.title = NSLocalizedString("agordoj titolo", comment: "")
        parent?.navigationItem.rightBarButtonItem = nil
    }
    
    func efektivigiStilon() {
        
        tabelo?.indicatorStyle = UzantDatumaro.stilo.scrollKoloro
        tabelo?.backgroundColor = UzantDatumaro.stilo.fonKoloro
        tabelo?.separatorColor = UzantDatumaro.stilo.apartigiloKoloro
        tabelo?.reloadData()
    }
    
    func nuligiHistorion() {
        let mesagho: UIAlertController = UIAlertController(title: NSLocalizedString("agordoj nuligi historion averto", comment: ""), message: nil, preferredStyle: .actionSheet)
        mesagho.addAction( UIAlertAction(title: NSLocalizedString("Jes", comment: ""), style: .destructive, handler: { (ago: UIAlertAction) -> Void in
            UzantDatumaro.historio.removeAll()
        }))
        mesagho.addAction( UIAlertAction(title: NSLocalizedString("Ne", comment: ""), style: .cancel, handler: nil))
        
        if let prezentilo = mesagho.popoverPresentationController,
            let chelo = tabelo?.cellForRow(at: IndexPath(item: 0, section: 0)) {
            prezentilo.sourceView = chelo;
            prezentilo.sourceRect = chelo.bounds;
        }
        
        present(mesagho, animated: true, completion: nil)
    }
    
    func nuligiKonservitajn() {
        let mesagho: UIAlertController = UIAlertController(title: NSLocalizedString("agordoj nuligi konservitajn averto", comment: ""), message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        mesagho.addAction( UIAlertAction(title: NSLocalizedString("Jes", comment: ""), style: UIAlertAction.Style.destructive, handler: { (ago: UIAlertAction) -> Void in
            UzantDatumaro.konservitaj.removeAll()
        }))
        mesagho.addAction( UIAlertAction(title: NSLocalizedString("Ne", comment: ""), style: UIAlertAction.Style.cancel, handler: nil))
        
        if let prezentilo = mesagho.popoverPresentationController,
            let chelo = tabelo?.cellForRow(at: IndexPath(item: 1, section: 0)) {
                prezentilo.sourceView = chelo;
                prezentilo.sourceRect = chelo.bounds;
        }
        
        present(mesagho, animated: true, completion: nil)
    }
}

extension AgordojViewController : UITableViewDelegate, UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 2
        case 1:
            return 2
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("agordoj datumoj etikedo", comment: "")
        case 1:
            return NSLocalizedString("agordoj lingvoj etikedo", comment: "")
        case 2:
            return NSLocalizedString("agordoj aspekto etikedo", comment: "")
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let novaChelo = UITableViewCell(style: .value1, reuseIdentifier: agordojChelIdent)
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                novaChelo.textLabel?.text = NSLocalizedString("agordoj nuligi historion etikedo", comment: "")
            }
            else if indexPath.row == 1 {
                novaChelo.textLabel?.text = NSLocalizedString("agordoj nuligi konservitajn etikedo", comment: "")
            }
            novaChelo.accessoryType = .none
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                novaChelo.textLabel?.text = NSLocalizedString("agordoj elekti serch-lingvon etikedo", comment: "")
                novaChelo.detailTextLabel?.text = UzantDatumaro.serchLingvo.nomo
            }
            else if indexPath.row == 1 {
                novaChelo.textLabel?.text = NSLocalizedString("agordoj elekti traduk-lingvojn etikedo", comment: "")
                if UzantDatumaro.tradukLingvoj.count == 1 {
                    novaChelo.detailTextLabel?.text = UzantDatumaro.tradukLingvoj.first?.nomo
                } else {
                    novaChelo.detailTextLabel?.text = String(format: NSLocalizedString("agordoj traduk-lingvoj subetikedo", comment: ""), arguments: [String(UzantDatumaro.tradukLingvoj.count)])
                }
            }
            novaChelo.accessoryType = .disclosureIndicator
        }
        else if indexPath.section == 2 {
            if indexPath.row == 0 {
                novaChelo.textLabel?.text = NSLocalizedString("agordoj elekti stilon etikedo", comment: "")
                novaChelo.detailTextLabel?.text = UzantDatumaro.stilo.nomo
            }
            novaChelo.accessoryType = .disclosureIndicator
        }
        
        novaChelo.backgroundColor = UzantDatumaro.stilo.bazKoloro
        novaChelo.textLabel?.textColor = UzantDatumaro.stilo.tekstKoloro
        novaChelo.isAccessibilityElement = true
        novaChelo.accessibilityLabel = novaChelo.textLabel?.text
        if let teksto = novaChelo.detailTextLabel?.text, teksto != "" {
            novaChelo.accessibilityLabel! += ", " + teksto
        }
        
        return novaChelo
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                nuligiHistorion()

            }
            else if indexPath.row == 1 {
                nuligiKonservitajn()
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let elektilo = SerchLingvoElektiloViewController()
                elektilo.delegate = self
                navigationController?.pushViewController(elektilo, animated: true)
            }
            else if indexPath.row == 1{
                let elektilo = TradukLingvojElektiloViewController()
                elektilo.delegate = self
                navigationController?.pushViewController(elektilo, animated: true)
            }
        }
        else if indexPath.section == 2 {
            if indexPath.row == 0 {
                let elektilo = StiloElektiloViewController()
                navigationController?.pushViewController(elektilo, animated: true)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension AgordojViewController : SerchLingvoElektiloDelegate {
    
    func elektisSerchLingvon() {
        tabelo?.reloadRows(at: [IndexPath(item: 0, section: 1)], with: .none)
    }
}

extension AgordojViewController : TradukLingvojElektiloDelegate {
    
    func elektisTradukLingvojn() {
        tabelo?.reloadRows(at: [IndexPath(item: 1, section: 1)], with: .none)
    }
}

// Respondi al mediaj shanghoj
extension AgordojViewController {
    
    func didChangePreferredContentSize(notification: NSNotification) -> Void {
        tabelo?.reloadData()
    }
}

