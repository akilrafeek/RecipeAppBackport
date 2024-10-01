import UIKit
import RxSwift
import RxCocoa

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

class PickerViewDataSource<T>: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    let items: [T]
    let titleForRow: (Int, T) -> String

    init(items: [T], titleForRow: @escaping (Int, T) -> String) {
        self.items = items
        self.titleForRow = titleForRow
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return titleForRow(row, items[row])
    }
}

extension UIImage {
    func resized(toMaxDimension maxDimension: CGFloat) -> UIImage {
        let size = self.size
        let aspectRatio = size.width / size.height

        var newSize: CGSize
        if aspectRatio > 1 {
            // Landscape
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            // Portrait
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.7)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
