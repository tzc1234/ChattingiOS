//
//  UserSignUpEndpoint.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 13/12/2024.
//

import Foundation

struct UserSignUpEndpoint: Endpoint {
    var path: String { apiPath + "register" }
    var httpMethod: HTTPMethod { .post }
    
    private let boundary = UUID().uuidString
    var headers: [String: String]? {
        let multipartFormDataHeaders = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
        return defaultHeaders.merging(multipartFormDataHeaders) { $1 }
    }
    
    let apiConstants: APIConstants
    private let params: UserSignUpParams
    
    init(apiConstants: APIConstants = APIConstants(), params: UserSignUpParams) {
        self.apiConstants = apiConstants
        self.params = params
    }
    
    var body: Data? {
        var body = Data()
        
        let content = [
            "name": params.name,
            "email": params.email,
            "password": params.password
        ].reduce("") { partialResult, pair in
            partialResult +
                "--\(boundary)\r\n" +
                "Content-Disposition: form-data; name=\"\(pair.key)\"\r\n\r\n" +
                "\(pair.value)\r\n"
        }
        
        body.append(Data(content.utf8))
        
        if let avatar = params.avatar {
            let fieldName = "avatar"
            let fileName = "avatar.\(avatar.fileType)"
            let avatarContent = "--\(boundary)\r\n" +
                "Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n" +
                "Content-Type: image/\(avatar.fileType)\r\n\r\n"
            
            body.append(Data(avatarContent.utf8))
            body.append(avatar.data)
            body.append(Data("\r\n".utf8))
        }
        
        body.append(Data("--\(boundary)--\r\n".utf8))
        return body
    }
}
