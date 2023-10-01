//
//  ProfileView.swift
//  Dividendos
//
//  Created by juancarlos on 27/8/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct ProfileView: View {
    
    @State private var carteras = [Cartera]()
    @State private var selectedCartera:Cartera?
    @State private var document: MessageDocument = MessageDocument(message: "Hello, World!")
    @State private var isImporting: Bool = false
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State var isAuthenticated: Bool = false
    @State var userId = 1
    @State var newUser = User(id: 0, password: "", username: "username", first_name: "Nombre", last_name: "Apellidos", email: "algo@gmail.com")
    @State private var showingAlertNewUser = false
    
    @State private var nombreCartera: String = ""
    @State private var capitalInicial: String = "0"
    @State private var showingAlertNewCartera = false
    
    @State private var showAlert = false

    
    func loadCarteras(username: String) async {
        print("entro a cargar carteras de: ", username)
        let id_cartera = UserDefaults.standard.integer(forKey: "cartera")
        let url = URL(string: "https://hamperblock.com/django/carteras/")!
        let token = UserDefaults.standard.value(forKey: "token")
        //print(token)
        var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Token \( token ?? "")", forHTTPHeaderField: "Authorization")
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let decodedResponse = try? JSONDecoder().decode(ResponseCar.self, from: data) {
                carteras = decodedResponse.results.filter {$0.user?.username == username}
                selectedCartera = carteras.filter {$0.id == id_cartera}.first
            }
        } catch {
            print("ERROR: No hay carteras")
        }
    }
    
    func getToken(user: String, pass: String) async {
        print(user, pass)
        let url = URL(string: "https://hamperblock.com/django/users/login/")!
        let body: [String: String] = ["username": user, "password": pass]
        let finalBody = try! JSONSerialization.data(withJSONObject: body)
        var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = finalBody
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print("hay problemas de conexión con la BBDD")
                return
            }

            let result = try? JSONDecoder().decode(LoginResponse.self, from: data)
                    if let result = result {
                        DispatchQueue.main.async {
                            print(result.user)
                            userId = result.user.id
                            username = result.user.username
                            //self.email = result.user.email
                            UserDefaults.standard.setValue(result.user.id, forKey: "userId")
                            UserDefaults.standard.setValue(result.access_token, forKey: "token")
                            UserDefaults.standard.setValue(true, forKey: "isAuthenticated")
                            isAuthenticated = true
                            print("carteras", carteras)
                            Task {
                                await loadCarteras(username: user)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            print(error as Any)
                        }
                    }
                }.resume()
    }
    
    func register(user: User) async {
        let url = URL(string: "https://hamperblock.com/django/users/signup/")!
        let body: [String: String] = ["username": user.username, "password": user.password, "password_confirmation": user.password, "email": user.email, "first_name": user.first_name, "last_name": user.last_name]
        let finalBody = try! JSONSerialization.data(withJSONObject: body)
        var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = finalBody
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print("hay problemas de conexión con la BBDD")
                return
            }

            let result = try? JSONDecoder().decode(UserShor.self, from: data)
                    if let result = result {
                        DispatchQueue.main.async {
                            showingAlertNewUser = true
                            print("User creado correctamente")
                        }
                    } else {
                        DispatchQueue.main.async {
                            print(error as Any)
                        }
                    }
                }.resume()
    }
    
    func deleteUser(user: String) async {
        let url = URL(string: "https://hamperblock.com/django/users/delete")!
        let body: [String: String] = ["username": user]
        let finalBody = try! JSONSerialization.data(withJSONObject: body)
        var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = finalBody
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print("hay problemas de conexión con la BBDD")
                return
            }
            print("aqui")
            let result = try? JSONDecoder().decode(Request.self, from: data)
            print(result as Any)
                    if let result = result {
                        DispatchQueue.main.async {
                            print(result)
                        }
                    } else {
                        DispatchQueue.main.async {
                            print(error as Any)
                        }
                    }
                }.resume()
    }
    
    func saveCartera(cartera: Cartera) {
        let url = URL(string: "https://hamperblock.com/django/carteras/")!
        let body = ["user": UserDefaults.standard.integer(forKey: "userId"), "nombre": cartera.nombre, "capital_inicial": cartera.capital_inicial] as [String : Any]
        let finalBody = try! JSONSerialization.data(withJSONObject: body)
        var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = finalBody
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Token \( UserDefaults.standard.value(forKey: "token") ?? "")", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print("hay problemas de conexión con la BBDD", error as Any)
                return
            }
            let result = try? JSONDecoder().decode(Cartera.self, from: data)
            print(result)
                    if let result = result {
                        DispatchQueue.main.async {
                            showingAlertNewCartera = true
//                            if result == nil {
//                                Alert(title: Text("La cartera tiene que tener un nombre y un capital, asi como antes entrar como usuario"))
//                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            print(error as Any)
                        }
                    }
                }.resume()
    }
    
    var body: some View {
        NavigationView {
            List {
                Section() {
                    VStack() {
                        Image("logo")
                            .resizable()
                            .frame(width: 50, height: 50)
                        Text("HBLOCK50 v0.1 beta")
                        Divider()
                        Text("Bienvenido \(selectedCartera?.user?.username ?? "¡Elige una Cartera o Crea una nueva")!")
                        if selectedCartera?.user?.first_name.isEmpty == false {
                            HStack{
                                Text((selectedCartera?.user!.first_name)!).font(.footnote)
                                Text((selectedCartera?.user!.last_name)!).font(.footnote)
                            }
                            Text((selectedCartera?.user!.email)!).font(.footnote).bold()
                        }
                        HStack{
                            Button("Cambiar Usuario", action: {
                                Task {
                                    await getToken(user: username, pass: password)
                                }
                            })
                                .buttonStyle(.bordered)
                                .foregroundColor(.white)
                                .background(.green)
                                .font(.footnote)
                                .cornerRadius(22)
                            Spacer()
                            Button("Eliminar Usuario", action: {
                                showAlert = true
                                Task {
                                    await deleteUser(user: username)
                                }
                            })
                            .alert("Usuario borrado", isPresented: $showAlert) {
                                        Button("OK") { }
                                    }
                                .buttonStyle(.bordered)
                                .foregroundColor(.white)
                                .background(.red)
                                .font(.footnote)
                                .cornerRadius(22)
                        }
                        
                        Form {
                            Picker("Cartera:", selection: $selectedCartera) {
                                Text("Select")
                                    .tag(-1)
                                ForEach(carteras, id: \.self) { cartera in
                                    Text(cartera.nombre).tag(cartera as Cartera?)
                                }
                            }
                            .onChange(of: selectedCartera) {
                                print("ID Cartera select: \(selectedCartera?.id ?? 0)")
                                UserDefaults.standard.set(selectedCartera?.id, forKey: "cartera")
                                if let encoded = try? JSONEncoder().encode(selectedCartera!) {
                                    UserDefaults.standard.set(encoded, forKey: "carteraObjeto")
                                }
                            }
//                            HStack {
//                                Button("Cargar CVS IBKR") { isImporting.toggle() }
//                                Spacer()
//                                Image(systemName: "arrow.up.doc")
//                            }
//                            NavigationLink(destination: Text("Pendiente...")) {
//                                Label("Crear usuario", systemImage: "user")
//                            }
//                            NavigationLink(destination: Text("Pendiente...")) {
//                                Label("Modelo 720", systemImage: "list.clipboard.fill")
//                            }
//                            NavigationLink(destination: Text("Pendiente...")) {
//                                Label("Avanzado", systemImage: "slider.horizontal.3")
//                            }
//                            NavigationLink(destination: Text("Pendiente...")) {
//                                Label("Modo oscuro", systemImage: "paintpalette")
//                            }
                            Section(header: Text("CAMBIA USUARIO")){
                                HStack {
                                    Text("username")
                                    Spacer()
                                    TextField("", text: $username)
                                        .multilineTextAlignment(.trailing)
                                        .textInputAutocapitalization(.never)
                                }
                                HStack {
                                    Text("password")
                                    Spacer()
                                    SecureField("Enter a password", text: $password).multilineTextAlignment(.trailing)
                                }
                            }
                            Section(header: Text("CREAR CARTERA")){
                                HStack {
                                    Text("Nombre")
                                    Spacer()
                                    TextField("", text: $nombreCartera)
                                        .multilineTextAlignment(.trailing)
                                }
                                HStack {
                                    Text("Capital Inicial")
                                    Spacer()
                                    TextField("", text: $capitalInicial)
                                        .multilineTextAlignment(.trailing)
                                }
                                Button("Crear Cartera", action: {
                                    Task {
                                        await saveCartera(cartera: Cartera(id: 1, nombre: nombreCartera, capital_inicial: capitalInicial))
                                    }
                                })
                                .alert(isPresented: $showingAlertNewUser) {
                                    Alert(title: Text("Cartera creada correctamente"), dismissButton: .default(Text("OK")))
                                }
                                    .buttonStyle(.bordered)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.white)
                                    .background(.green)
                                    .font(.footnote)
                                    .cornerRadius(22)
                            }
                            Section(header: Text("CREAR NUEVO USUARIO")){
                                HStack {
                                    Text("Usuario")
                                    Spacer()
                                    TextField("Username", text: $newUser.username)
                                        .multilineTextAlignment(.trailing)
                                        .textInputAutocapitalization(.never)
                                }
                                HStack {
                                    Text("Password")
                                    Spacer()
                                    SecureField("Password", text: $newUser.password)
                                        .multilineTextAlignment(.trailing)
                                }
                                HStack {
                                    Text("Email")
                                    Spacer()
                                    TextField("Email", text: $newUser.email)
                                        .multilineTextAlignment(.trailing)
                                        .textInputAutocapitalization(.never)
                                }
                                Button("Crear Usuario", action: {
                                    Task {
                                        print(newUser)
                                        await register(user: newUser)
                                    }
                                })
                                    .alert(isPresented: $showingAlertNewUser) {
                                        Alert(title: Text("Usuario"),
                                              message: Text("User creado correctamente"),
                                              dismissButton: .default(Text("OK"))
                                        )
                                    }
                                    .buttonStyle(.bordered)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.white)
                                    .background(.green)
                                    .font(.footnote)
                                    .cornerRadius(22)
                            }
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 600)
                    
                }
                .navigationBarTitle("Opciones")
                .navigationBarTitleDisplayMode(.inline)
            }
            .accentColor(.accentColor)
//            .task {
//                await loadCarteras(username: UserDefaults.standard.string(forKey: "username") ?? "admin")
//            }
            
//            .fileImporter(
//                isPresented: $isImporting,
//                allowedContentTypes: [.plainText],
//                allowsMultipleSelection: false
//            ) { result in
//                do {
//                    guard let selectedFile: URL = try result.get().first else { return }
//                    guard let message = String(data: try Data(contentsOf: selectedFile), encoding: .utf8) else { return }
//                    
//                    document.message = message
//                } catch {
//                    // Handle failure.
//                }
//            }
        }
    }
    
}

struct MessageDocument: FileDocument {
    
    static var readableContentTypes: [UTType] { [.plainText] }

    var message: String

    init(message: String) {
        self.message = message
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        message = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: message.data(using: .utf8)!)
    }
    
}

#Preview {
    ProfileView()
}
