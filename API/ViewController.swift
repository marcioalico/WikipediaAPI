//
//  ViewController.swift
//  API
//  @AUTOR: Marcio
//
//  Created by Applica on 13/12/2019.
//  Copyright © 2019 Applica. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate {

    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var textSearch: UITextField!

    var palabra: String?
    
    override func loadView() {
        //Constante con la configuración para WKWebView
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
       //Se le delega a webView el protocolo uiDelegate
        webView.uiDelegate = self
        view = webView
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func btnDoSearch(_ sender: Any) {
        //Validamos que haya una palabra.
            if !textSearch.text!.isEmpty {palabra = textSearch.text!}
            
        //Crea el URL con el API de Wikipedia
        //Le pasa la variable palabra unwraped y le reemplaza los espacios por %20
        let urlFull = "https://es.wikipedia.org/w/api.php?action=query&prop=extracts&format=json&exintro=&titles=\(palabra!.replacingOccurrences(of: " ", with: "%20"))"
            
            let objectUrl = URL(string:urlFull)
            
        //CREAR UNA TAREA CON EL URLSession
            let task = URLSession.shared.dataTask(with: objectUrl!) { (datos, respuesta, error) in
                if error != nil { print (error!) } else {
                    do {
            //Creación de variable para JSON, se pasa a un mapa Clave:Valor de String:Any
                        let json = try JSONSerialization.jsonObject(with: datos!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:Any]
            //Bajada de a un nivel en el JSON para llegar al "Extract" en este caso.
                        let querySubJson = json["query"] as! [String:Any]
                        let pagesSubJson = querySubJson["pages"] as! [String:Any]
            //Objetemos la key de pagesSubJson
                        let pageId = pagesSubJson.keys
            //Obtenemos llave de la primera consulta
                        let firstKey = pageId.first!
                        let idSubJson = pagesSubJson[firstKey] as! [String:Any]
            //Solo obtenemos el String y no [String:Any] como en los anteriores.
                        let extractStringHtml = idSubJson["extract"] as! String
                        
            //Se envía a la vista sincrónicamente.
                        DispatchQueue.main.sync( execute: {
                            self.webView.loadHTMLString(extractStringHtml, baseURL: nil)
                        })
                        
                    } catch { print("El procesamiento del JSON tuvo un error") }
                }
            }
        //Indicamos que ejecute la Task
            task.resume()
        }
    }
    


