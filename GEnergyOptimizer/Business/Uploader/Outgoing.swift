//
// Created by Binay Budhthoki on 3/1/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger

class OutgoingRows {
    typealias Row = [String: String]
    enum EType: String {
        case raw, computed
    }
    var header: [String]?
    var rows: [Row]
    var entity: String
    var eType: EType
    var parentFolder: String

    init(rows: [Row], entity: String, type: EType = .computed) {
        self.rows = rows
        self.entity = entity.lowercased()
        self.eType = type
        self.parentFolder = try! AuditFactory.sharedInstance.getIdentifier()
    }

    func setHeader(header: [String]) {
        self.header = header
    }

    func upload(_ completed: @escaping (GError) -> Void) {
        Log.message(.warning, message: "**** Uploading ****")
        let baseDir = getBaseDir()
        var path: String = "\(baseDir)\(parentFolder)/\(eType.rawValue)/\(entity).csv"
        Log.message(.error, message: path.description)

        var buffer: String = header!.joined(separator: ",")
        buffer.append("\r\n")
        for row in rows {
            if let header = self.header {
                var tmp = [String]()
                header.forEach { item in
                    if let value = row[item] {tmp.append(sanitize(value))}
                    else {tmp.append("")}
                }
                buffer.append(tmp.joined(separator: ","))
                buffer.append("\r\n")
            }
        }
        Log.message(.info, message: buffer.debugDescription)

        let dropbox = DropBoxUploader()
        if let data = buffer.data(using: .utf8) {
            dropbox.upload(path: path, data: data) { error in
                completed(error)
            }
            return
        }
        completed(.noData)
    }

    //-- ToDo: What about if there is a quote within the value ?? huh
    func sanitize(_ value: String) -> String {
        var fix: String = value
        if value.contains(",") {
            fix.append("\"\(value)\"")
        }

        return fix
    }

    func getBaseDir() -> String {
        if var baseDir = Settings.auditDataSaveLocation {
            Log.message(.info, message: "Base Dir : \(baseDir)")

            if !(baseDir.starts(with: "/")) {baseDir = "/\(baseDir)"}
            let regex = try! NSRegularExpression(pattern: "^.*/$")
            let match = regex.matches(in: baseDir, range: NSRange(location: 0, length: baseDir.count))
            if !(match.count > 0) {
                baseDir.append("/")
            }

            return baseDir
        } else {return "/Gemini/Energy/Audit/"}
    }
}