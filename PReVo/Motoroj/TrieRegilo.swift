//
//  TrieRegilo.swift
//  PReVo
//
//  Created by Robin Hill on 3/10/16.
//  Copyright © 2016 Sinuous Rill. All rights reserved.
//

import Foundation
import CoreData

/*
    La trie regilo faras la trie parton de la datumbazo, kaj havas kapablon traserchi
    ghin por trovi vortojn
*/
class TrieRegilo {
    
    static var konteksto: NSManagedObjectContext?
    
    // ====================================
    // Trie farado
    // ====================================
    
    static func konstruiChiuTrie(kodoj: [String]) {
        
        /*for lingvo in kodoj {
            konstruiTriePorLingvo(lingvo)
        }*/
        konstruiTriePorLingvo("es")
    }
    
    static func konstruiTriePorLingvo(kodo: String) {
        
        if let tradukoDos = NSBundle.mainBundle().pathForResource("indekso_" + kodo, ofType: "dat") {
            
            let lingvoObjekto = DatumLegilo.lingvoPorKodo(kodo)
            if lingvoObjekto == nil {
                return
            }
            
            do {
                if let tradukoDat = NSData(contentsOfFile: tradukoDos) {
                    let tradukoJ = try NSJSONSerialization.JSONObjectWithData(tradukoDat, options: NSJSONReadingOptions())
                    
                    if let tradukoj = tradukoJ as? NSArray {
                        
                        var nunNodo: NSManagedObject? = nil
                        for traduko in tradukoj {
                            
                            if let enhavoj = traduko as? NSDictionary {
                                // Kiel dict: indekso, senco, teksto, marko
                                
                                let videbla = enhavoj["videbla"] as? String
                                let teksto = enhavoj["teksto"] as? String
                                let nomo = enhavoj["nomo"] as? String
                                let indekso = enhavoj["indekso"] as? String
                                let marko = enhavoj["marko"] as? String
                                let senco = enhavoj["senco"] as! Int
                                
                                for nunLitero in teksto!.lowercaseString.characters {
                                    
                                    var sekvaNodo: NSManagedObject? = nil
                                    if nunNodo == nil {
                                        if let trovNodo = komencaNodoElLingvo(lingvoObjekto!, kunLitero: String(nunLitero)) {
                                            sekvaNodo = trovNodo
                                        }
                                    } else {
                                        if let trovNodo = sekvaNodoElNodo(nunNodo!, kunLitero: String(nunLitero)) {
                                            sekvaNodo = trovNodo
                                        }
                                    }
                                    
                                    if sekvaNodo == nil {
                                        sekvaNodo = NSEntityDescription.insertNewObjectForEntityForName("TrieNodo", inManagedObjectContext: konteksto!)
                                        sekvaNodo?.setValue(String(nunLitero), forKey: "litero")
                                        
                                        if nunNodo == nil {
                                            lingvoObjekto?.mutableSetValueForKey("komencajNodoj").addObject(sekvaNodo!)
                                        } else {
                                            nunNodo?.mutableSetValueForKey("sekvajNodoj").addObject(sekvaNodo!)
                                        }
                                    }
                                    
                                    nunNodo = sekvaNodo
                                    
                                }
                                
                                if indekso != nil {
                                    let novaDestino = NSEntityDescription.insertNewObjectForEntityForName("Destino", inManagedObjectContext: konteksto!)
                                    novaDestino.setValue(videbla, forKey: "teksto")
                                    novaDestino.setValue(indekso, forKey: "indekso")
                                    novaDestino.setValue(nomo, forKey: "nomo")
                                    novaDestino.setValue(marko, forKey: "marko")
                                    novaDestino.setValue(String(senco), forKey: "senco")
                                    if let artikolo = DatumLegilo.artikoloPorIndekso(indekso!) {
                                        novaDestino.setValue(artikolo, forKey: "artikolo")
                                    }
                                    nunNodo?.mutableOrderedSetValueForKey("destinoj").addObject(novaDestino)
                                }
                                
                                nunNodo = nil
                                
                            } // Enhavoj de la traduko
                            
                            try konteksto?.save()
                        } // Chiu traduko
                        
                        //konteksto?.save()
                    }
                }
            } catch {
                NSLog("ERARO")
            }
        }

    }
    
    // ====================================
    // Trie navigaciado
    // ====================================
    
    static func serchi(lingvoKodo: String, teksto: String, limo: Int) -> [(String, [NSManagedObject])] {
        
        var nunNodo: NSManagedObject? = nil
        var sekvaNodo: NSManagedObject? = nil
        
        for nunLitero in teksto.characters {
            
            sekvaNodo = nil
            if nunNodo == nil {
                if let lingvo = DatumLegilo.lingvoPorKodo(lingvoKodo) {
                    sekvaNodo = komencaNodoElLingvo(lingvo , kunLitero: String(nunLitero))
                }
            } else {
                sekvaNodo = sekvaNodoElNodo(nunNodo!, kunLitero: String(nunLitero))
            }
            
            if sekvaNodo != nil {
                nunNodo = sekvaNodo
            } else {
                return [(String, [NSManagedObject])]()
            }
        }
        
        if nunNodo != nil {
            return chiuFinajho(nunNodo!, limo: limo ) /*.sort({ (unua: (String, NSManagedObject), dua: (String, NSManagedObject)) -> Bool in
                return unua.0 < dua.0
            })*/
        } else {
            return [(String, [NSManagedObject])]()
        }
    }
    
    // Trovi chiun vorton kiu havas komence la jam trovitan tekston
    static func chiuFinajho(nodo: NSManagedObject, limo: Int) -> [(String, [NSManagedObject])] {
        
        var rezultoj = [(String, [NSManagedObject])]()
        
        var trovoj = [String : [NSManagedObject]]()
        for destino in nodo.mutableOrderedSetValueForKey("destinoj") ?? [] {
            if let veraDestino = destino as? NSManagedObject, let destTeksto = veraDestino.valueForKey("teksto") as? String {
                if trovoj[destTeksto] == nil { trovoj[destTeksto] = [NSManagedObject]() }
                trovoj[destTeksto]?.append(veraDestino)
            }
        }
        for (teksto, destinoj) in trovoj {
            rezultoj.append( (teksto, destinoj))
        }
        
        if let sekvaj = ((nodo.valueForKey("sekvajNodoj") as? NSSet)?.allObjects as? [NSManagedObject])?.sort({ (unua: NSManagedObject, dua: NSManagedObject) -> Bool in
            return (unua.valueForKey("litero") as? String) < (dua.valueForKey("litero") as? String)
        }) {
            
            for sekvaNodo in sekvaj {
                
                rezultoj.appendContentsOf(chiuFinajho(sekvaNodo, limo: limo))
                if rezultoj.count > limo {
                    return Array(rezultoj.prefix(limo))
                }
            }
        }
        
        return rezultoj
    }
    
    static func komencajNodojPorLingvo(lingvo: NSManagedObject) -> [NSManagedObject] {
        
        return Array(lingvo.valueForKey("komencajNodoj") as! Set)
    }
    
    static func komencaNodoElLingvo(lingvo: NSManagedObject, kunLitero litero: String) -> NSManagedObject? {
        
        let nodoj = komencajNodojPorLingvo(lingvo)

        if let trovo = nodoj.indexOf ( {
            (kontrol: NSManagedObject) -> Bool in
            return kontrol.valueForKey("litero") as? String == litero
        }) {
            return nodoj[trovo]
        }
        
        return nil
    }
    
    static func sekvaNodoElNodo(nodo: NSManagedObject, kunLitero litero: String) -> NSManagedObject? {
        
        if let sekvaj: [NSManagedObject] = (nodo.valueForKey("sekvajNodoj") as? NSSet)?.allObjects as? [NSManagedObject] {
        
            if let trov = sekvaj.indexOf( {
                (kontrol: NSManagedObject) -> Bool in
                return kontrol.valueForKey("litero") as? String == litero
            }) {
                return sekvaj[trov]
            }
        }
        
        return nil
    }

}

