//
//  ViewController.swift
//  NativeRequest
//
//  Created by Ángel González on 13/05/22.
//

import UIKit
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return personajes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:ri, for:indexPath)
        let dict = personajes[indexPath.row]
        cell.textLabel?.text = dict["name"] as? String ?? "Un personaje"
        return cell
    }
}

class ViewController: UIViewController {
    var tablev = UITableView()
    var personajes = [[ String : Any ]]()
    let ri = "reuseId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // esta llamada es para que se comience el monitoreo de Internet, y que cuando la vista ya se muestra, el estatus ya esté actualizado
        let _ = InternetStatus.instance
        // Establecer el frame para que la tabla ocupe todo el tamaño de la vista
        /*
        self.view.frame // propiedades "generales" respecto al superview
        self.view.bounds // propiedades "especificas" respecto a su propia orientacion
         */
        tablev.frame = self.view.bounds
        self.view.addSubview(tablev)
        tablev.register(UITableViewCell.self, forCellReuseIdentifier:ri )
        tablev.dataSource = self
        tablev.delegate = self
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
                        self.personajes = json["results"] as! [[String:Any]]
                        DispatchQueue.main.async {
                            self.tablev.reloadData()
                        }
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



