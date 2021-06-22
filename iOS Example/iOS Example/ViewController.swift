//
//  ViewController.swift
//  iOS Example
//
//  Created by MainasuK Cirno on 2021-6-7.
//

import UIKit
import MetaTextView
import Combine

class ViewController: UIViewController {

    var disposeBag = Set<AnyCancellable>()

    let metaText = MetaText()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "MetaTextView"
        
        metaText.textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(metaText.textView)
        NSLayoutConstraint.activate([
            metaText.textView.topAnchor.constraint(equalTo: view.topAnchor),
            metaText.textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            metaText.textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            metaText.textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let syncConfiguration = Future<MetaText.SyncConfiguration, Never> { promise in
            let emojiDict: [String: URL] = [
                ":apple_inc:": URL(string: "https://media.mstdn.jp/custom_emojis/images/000/002/171/original/b848520ba07a354c.png")!,
                ":awesome:": URL(string: "https://media.mstdn.jp/custom_emojis/images/000/002/757/original/3e0e01274120ad23.png")!
            ]
            let string = Array(repeating: "Hello, World! \(emojiDict.keys.joined(separator: " "))\n", count: 10).joined()
            let entities: [Meta.Entity] = {
                var entities: [Meta.Entity] = []
                for (shortcode, url) in emojiDict {
                    let ranges = string.ranges(of: shortcode)
                    for range in ranges {
                        let entity = Meta.Entity(range: NSRange(range, in: string), meta: .emoji(shortcode, url: url.absoluteString, userInfo: nil))
                        entities.append(entity)
                    }
                }
                return entities
            }()

            let attributedString = NSMutableAttributedString(
                string: string,
                attributes: [
                    .font: UIFont.preferredFont(forTextStyle: .body),
                    .foregroundColor: UIColor.label,
                ]
            )


            let configuration = MetaText.SyncConfiguration(
                attributedString: attributedString,
                entities: entities
            )
            promise(.success(configuration))
        }.eraseToAnyPublisher()
        metaText.configure(syncConfiguration: syncConfiguration).store(in: &disposeBag)
    }

}

extension StringProtocol {
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex, let range = self[startIndex...].range(of: string, options: options) {
            result.append(range)
            startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
