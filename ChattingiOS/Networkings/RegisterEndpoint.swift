//
//  RegisterEndpoint.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 13/12/2024.
//

import Foundation

struct RegisterEndpoint: Endpoint {
    var path: String { apiPath + "/register" }
    var httpMethod: HTTPMethod { .post }
    
    private let boundary = UUID().uuidString
    private var additionalHeaders: [String: String] {
        ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
    }
    var headers: [String: String]? {
        defaultHeaders.merging(additionalHeaders) { $1 }
    }
    
    private let params: RegisterParams
    
    init(params: RegisterParams) {
        self.params = params
    }
    
    var body: Data? {
        var body = Data()
        
        var content = "--\(boundary)\r\n"
        [
            "name": params.name,
            "email": params.email,
            "password": params.password
        ].forEach { key, value in
            content += "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
            content += "\(value)"
        }
        
        body.append(Data(content.utf8))
        
        if let avatar = params.avatar {
            let fieldName = "file"
            let fileName = "avatar.\(avatar.fileType)"
            var avatarContent = "\r\n--\(boundary)\r\n"
            avatarContent += "Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n"
            avatarContent += "Content-Type: image/\(avatar.fileType)\r\n\r\n"
            
            body.append(Data(avatarContent.utf8))
            body.append(avatar.data)
        }
        
        body.append(Data("\r\n--\(boundary)--\r\n".utf8))
        return body
    }
}
