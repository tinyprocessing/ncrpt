import Foundation

struct fileItem: Identifiable, Hashable {
    var id = 0
    var name = ""
    var url: URL? = nil
    var ext = ""
}

extension Dictionary where Value: Equatable {
    func getKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}

class LocalFileEngine: ObservableObject, Identifiable {
    @Published var files: [fileItem] = []
    static let shared = LocalFileEngine()

    func decodeFileExtension(_ ext: String) -> String {
        var header = avalibleExtensions.getKey(forValue: ext) ?? "file"
        return header
    }

    func getFileExtension(url: URL) -> String {
        do {
            let fileURLNCRPTData = try Data(contentsOf: url)
            let fileExtension = String(decoding: fileURLNCRPTData[0...3], as: UTF8.self)
            return decodeFileExtension(fileExtension)
        } catch {
            return "file"
            print(error)
        }
    }

    func getLocalFiles() {
        files.removeAll()
        do {
            // Get the document directory url
            let documentDirectory = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(
                at: documentDirectory,
                includingPropertiesForKeys: nil
            )

            directoryContents.forEach { item in
                let name = item.localizedName ?? ""
                if item.typeIdentifier == "public.folder" && !item.isNCRPT && !name.contains("ncrpt.io.iosviewer") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        do {
                            try FileManager.default.removeItem(atPath: (item.path().removingPercentEncoding)!)
                        } catch {
                            print("removeItem error")
                            print(error)
                        }
                    }
                }
            }

            // if you want to get all ncrpt files located at the documents directory:
            let ncrpt = directoryContents.filter(\.isNCRPT)
            objectWillChange.send()
            autoreleasepool {
                ncrpt.forEach { url in
                    do {
                        let fileURLNCRPTData = try Data(contentsOf: url)
                        let fileExtension = String(decoding: fileURLNCRPTData[0...3], as: UTF8.self)
                        self.objectWillChange.send()
                        files.append(fileItem(name: url.lastPathComponent, url: url, ext: decodeFileExtension(fileExtension)))
//                        print(url)
                    } catch {
//                        print("getLocalFiles error")
                    }
                }
            }
        } catch {
            print(error)
        }
    }
}

extension URL {
    var typeIdentifier: String? { (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier }
    var isNCRPT: Bool { lastPathComponent.contains(".ncrpt") }
    var localizedName: String? { (try? resourceValues(forKeys: [.localizedNameKey]))?.localizedName }
    var hasHiddenExtension: Bool {
        get { (try? resourceValues(forKeys: [.hasHiddenExtensionKey]))?.hasHiddenExtension == true }
        set {
            var resourceValues = URLResourceValues()
            resourceValues.hasHiddenExtension = newValue
            try? setResourceValues(resourceValues)
        }
    }
}
