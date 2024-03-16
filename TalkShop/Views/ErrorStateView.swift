//
//  ErrorStateView.swift
//  TalkShop
//
//  Created by V!jay on 15/03/24.
//

import Foundation
import UIKit

class EmptyView : UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration - UI
    private func setupView() {
        self.backgroundColor = .black
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "empty-ic")
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont(name: "AvenirNext-Regular", size: 20)
        titleLabel.text = "Oops, something went wrong"
        titleLabel.textColor = .white
        
        let subtitleLabel = UILabel()
        subtitleLabel.font = UIFont(name: "AvenirNext-Regular", size: 18)
        subtitleLabel.text = "Please try again later"
        subtitleLabel.textColor = .white
        
        [titleLabel, subtitleLabel].forEach{ label in
            label.textAlignment = .center
            label.numberOfLines = 0
        }
        
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 60),
            stackView.widthAnchor.constraint(equalTo: self.widthAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 140),
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -20),
        ])
    }
}
