//
//  CurrentUser.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 20/01/2025.
//

import Foundation

struct CurrentUser {
    let user: User
    let accessToken: AccessToken
    let refreshToken: String
    
    var id: Int { user.id }
}
