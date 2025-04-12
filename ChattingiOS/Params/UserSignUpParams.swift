//
//  UserSignUpParams.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 13/12/2024.
//

import Foundation

struct UserSignUpParams: Equatable {
    let name: String
    let email: String
    let password: String
    let avatar: AvatarParams?
}

struct AvatarParams: Equatable {
    let data: Data
    let fileType: String
}
