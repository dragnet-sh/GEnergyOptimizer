//
// Created by Binay Budhthoki on 2/27/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation

struct Constants {
    struct Dropbox {
        static let kDBAppKey = "o1peu8t9r6jrl12"
    }

    struct Parse {
        struct Local {
            static let applicationId = "NLI214vDqkoFTJSTtIE2xLqMme6Evd0kA1BbJ20S"
            static let clientKey = "lgEhciURXhAjzITTgLUlXAEdiMJyIF4ZBXdwfpUr"
            static let server = "http://localhost:1337/parse"
        }

        struct Prod {
            static let applicationId = "47f916f7005d19ddd78a6be6b4bdba3ca49615a0"
            static let clientKey = "275302fd8b2b56dca85f127a6123f281b670c787"
            static let server = "http://ec2-18-220-200-115.us-east-2.compute.amazonaws.com:80/parse"
        }
    }
}
