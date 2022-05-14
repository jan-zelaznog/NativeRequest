//
//  ViewController.swift
//  NativeRequest
//
//  Created by Ángel González on 13/05/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // esta llamada es para que se comience el monitoreo de Internet, y que cuando la vista ya se muestra, el estatus ya esté actualizado
        let _ = InternetStatus.instance
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if InternetStatus.instance.internetType == .none {
            let alert = UIAlertController(title: "ERRRORRRRRR!!!", message: "no hay conexión a internet!!!!!!", preferredStyle: .alert)
            let boton = UIAlertAction(title: "Ok", style: .default) { alert in
                // se cierra el app (es como provocar un crash)
                exit(666)
            }
            alert.addAction(boton)
            self.present(alert, animated:true)
        }
        else if InternetStatus.instance.internetType == .cellular {
            let alert = UIAlertController(title: "Confirme", message: "Solo hay conexión a internet por datos celulares", preferredStyle: .alert)
            let boton1 = UIAlertAction(title: "Continuar", style: .default) { alert in
                self.descargar()
            }
            let boton2 = UIAlertAction(title: "Cancelar", style: .cancel)
            alert.addAction(boton1)
            alert.addAction(boton2)
            self.present(alert, animated:true)
        }
        else {
            self.descargar()
        }
    }

    func descargar() {
        if let url = URL(string: "https://rickandmortyapi.com/api/character") {
            // la clase NSMutableURLRequest es la clase de Obj-C que permite hacer request
            let request = NSMutableURLRequest(url: url)
            // es mutable porque nos permite modificar sus propiedades una vez creada, por ejemplo, el método por el que se hará el request
            request.httpMethod = "GET"
            // el objeto compartido, administra todas las descargas que esté haciendo el dispositivo
            let sesion = URLSession.shared
            // definimos un objeto Task y lo agregamos a la sesión de descargas
            let tarea = sesion.dataTask(with: request as URLRequest) { datos, respuesta, error in
                if error != nil {
                    print ("algo salió mal \(error?.localizedDescription)")
                }
                else {
                    do {
                        let json = try JSONSerialization.jsonObject(with:datos!, options: .fragmentsAllowed) as! [String : Any]
                        // TODO: presentar apropiadamente la info
                    print (json)
                    }
                    catch {
                        print ("algo salió mal al convertir el JSON \(error.localizedDescription)")
                    }
                }
            }
            // indicamos que la tarea está lista para iniciar, en el momento que el objeto URLSession le de priorida
            tarea.resume()
        }
    }
}

