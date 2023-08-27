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
    
    func loadCarteras() async {
        
        let id_cartera = UserDefaults.standard.integer(forKey: "cartera")
        
        guard let url = URL(string: "https://hamperblock.com/django/carteras" ) else {
            print("Invalid URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode(ResponseCar.self, from: data) {
                carteras = decodedResponse.results
                selectedCartera = carteras.filter {$0.id == id_cartera}.first
            }
        } catch {
            print("ERROR: No hay carteras")
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section() {
                    VStack() {
                        Image("logo")
                            .resizable()
                            .frame(width: 50, height: 50)
                        Text("HBLOCK50")
                        Text("v0.1 beta").font(.footnote)
                        
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
                            }
                            HStack {
                                Button("Cargar CVS IBKR") { isImporting.toggle() }
                                Spacer()
                                Image(systemName: "arrow.up.doc")
                            }
                        }
                        NavigationLink(destination: Text("Pendiente...")) {
                            Label("Modelo 720", systemImage: "list.clipboard.fill")
                        }
                        NavigationLink(destination: Text("Pendiente...")) {
                            Label("Avanzado", systemImage: "slider.horizontal.3")
                        }
                        NavigationLink(destination: Text("Pendiente...")) {
                            Label("Modo oscuro", systemImage: "paintpalette")
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 350)
                    
                }
                .navigationBarTitle("Opciones")
                .navigationBarTitleDisplayMode(.inline)
            }
            .accentColor(.accentColor)
            .task {
                await loadCarteras()
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.plainText],
                allowsMultipleSelection: false
            ) { result in
                do {
                    guard let selectedFile: URL = try result.get().first else { return }
                    guard let message = String(data: try Data(contentsOf: selectedFile), encoding: .utf8) else { return }
                    
                    document.message = message
                } catch {
                    // Handle failure.
                }
            }
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
