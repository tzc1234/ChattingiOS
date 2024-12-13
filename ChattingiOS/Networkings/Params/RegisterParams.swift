//
//  RegisterParams.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 13/12/2024.
//

import Foundation

struct RegisterParams {
    let name: String
    let email: String
    let password: String
    let avatar: AvatarParams?
}

struct AvatarParams {
    let data: Data
    let fileType: String
}
