//
//  CategoryFilterCustomCell.swift
//  Pineat
//
//  Created by Faruk on 25.03.2026.
//

import UIKit

final class CategoryFilterCustomCell: UICollectionViewCell {
    
    // MARK: - Static Properties
    
    static let identifier = "CategoryFilterCustomCell"
    
    // MARK: - UI Components
    
    private let circleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.cornerRadius = 45
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        label.textColor = .appTextColor
        label.numberOfLines = 2
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: 24
        ).cgPath
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        iconImageView.image = nil
        updateSelectionUI(isSelected: false, animated: false)
    }
    
    // MARK: - Configuration
    
    func configure(title: String, image: UIImage?, isSelected: Bool) {
        titleLabel.text = title
        iconImageView.image = image
        updateSelectionUI(isSelected: isSelected, animated: true)
    }
}

// MARK: - Setup

private extension CategoryFilterCustomCell {
    
    func setupViews() {
        contentView.addSubview(circleView)
        circleView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            circleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            circleView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.70),
            circleView.heightAnchor.constraint(equalTo: circleView.widthAnchor),
            
            iconImageView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalTo: circleView.widthAnchor, multiplier: 0.80),
            iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: circleView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func setupAppearance() {
        contentView.layer.cornerRadius = 24
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .appSecondary
        
        layer.cornerRadius = 24
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 4, height: 4)
        layer.shadowRadius = 4
    }
}

// MARK: - UI Helpers

private extension CategoryFilterCustomCell {
    
    func updateSelectionUI(isSelected: Bool, animated: Bool) {
        let changes = {
            self.contentView.backgroundColor = isSelected ? .appAccent : .appSecondary
            self.titleLabel.textColor = isSelected ? .white : .appTextColor
            self.circleView.backgroundColor = .white
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: changes)
        } else {
            changes()
        }
    }
}
