import Foundation

func fileSize(forURL url: Any) -> Double {
    var fileURL: URL?
    var fileSize = 0.0
    if (url is URL) || (url is String) {
        if url is URL {
            fileURL = url as? URL
        } else {
            fileURL = URL(fileURLWithPath: url as! String)
        }
        var fileSizeValue = 0.0
        try? fileSizeValue = (fileURL?.resourceValues(forKeys: [URLResourceKey.fileSizeKey]).allValues.first?.value as! Double?)!
        if fileSizeValue > 0.0 {
            fileSize = (Double(fileSizeValue) / (1024 * 1024))
        }
    }
    return fileSize
}
