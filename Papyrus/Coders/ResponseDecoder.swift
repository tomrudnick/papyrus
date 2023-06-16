import Foundation

public protocol ResponseDecoder: KeyMappable {
    func decode<D: Decodable>(_ type: D.Type, from: Data) throws -> D
}

extension ResponseDecoder {
    public func decode<D: Decodable>(_ type: D.Type = D.self, from response: Response) throws -> D {
        if let error = response.error {
            throw error
        }

        guard let data = response.body else {
            throw PapyrusError("Unable to decode `\(Self.self)` from a `Response`; body was nil.")
        }

        return try decode(type, from: data)
    }
}

extension ResponseDecoder where Self == JSONDecoder {
    public static func json(_ decoder: JSONDecoder) -> Self {
        decoder
    }
}

extension JSONDecoder: ResponseDecoder {
    public func with(keyMapping: KeyMapping) -> Self {
        let copy = copy()
        copy.keyDecodingStrategy = keyMapping.jsonDecodingStrategy
        return copy as! Self
    }
}

extension JSONDecoder {
    fileprivate func copy() -> JSONDecoder {
        let new = JSONDecoder()
        new.keyDecodingStrategy = keyDecodingStrategy
        new.userInfo = userInfo
        new.dataDecodingStrategy = dataDecodingStrategy
        new.dateDecodingStrategy = dateDecodingStrategy
        new.nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy
#if os(Linux)
#else
        if #available(iOS 15.0, macOS 12.0, *) {
            new.assumesTopLevelDictionary = assumesTopLevelDictionary
            new.allowsJSON5 = allowsJSON5
        }
#endif
        return new
    }
}
