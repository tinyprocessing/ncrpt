//
//  LocalStorageEngine.swift
//  EncryptFile
//
//  Created by Kirill Anisimov on 17.12.2022.
//

import Foundation


enum StorageDataType: String {
    case templates, users
}

class LocalStorageEngine {

    private static func fileURL(for type: StorageDataType) throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("\(type.rawValue).data")
    }
    
    //Templates
    static func loadTemplates(completion: @escaping (Result<[Template], Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL(for: .templates)
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }
                let templates = try JSONDecoder().decode([Template].self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(templates))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func saveTemplates(templates: [Template], completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(templates)
                let outfile = try fileURL(for: .templates)
                try data.write(to: outfile)
                DispatchQueue.main.async {
                    completion(.success(templates.count))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    //Users
    static func loadUsers(completion: @escaping (Result<[User], Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL(for: .users)
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }
                let users = try JSONDecoder().decode([User].self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(users))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func saveUsers(users: [User], completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(users)
                let outfile = try fileURL(for: .users)
                try data.write(to: outfile)
                DispatchQueue.main.async {
                    completion(.success(users.count))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
