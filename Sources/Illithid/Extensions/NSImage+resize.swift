//
// NSImage+resize.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 3/21/20
//

import Cocoa
import Foundation

extension NSImage {
  /// The height of the image.
  var height: CGFloat {
    size.height
  }

  /// The width of the image.
  var width: CGFloat {
    size.width
  }

  /// A PNG representation of the image.
  var PNGRepresentation: Data? {
    if let tiff = tiffRepresentation, let tiffData = NSBitmapImageRep(data: tiff) {
      return tiffData.representation(using: .png, properties: [:])
    }

    return nil
  }

  // MARK: Resizing

  /// Resize the image to the given size.
  ///
  /// - Parameter size: The size to resize the image to.
  /// - Returns: The resized image.
  func resize(withSize targetSize: NSSize) -> NSImage? {
    let frame = NSRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
    guard let representation = bestRepresentation(for: frame, context: nil, hints: nil) else {
      return nil
    }

    let image = NSImage(size: targetSize, flipped: false) { (_) -> Bool in
      representation.draw(in: frame)
    }

    return image
  }

  /// Copy the image and resize it to the supplied size, while maintaining it's
  /// original aspect ratio.
  ///
  /// - Parameter size: The target size of the image.
  /// - Returns: The resized image.
  func resizeMaintainingAspectRatio(to targetSize: NSSize) -> NSImage? {
    let newSize: NSSize
    let widthRatio = targetSize.width / width
    let heightRatio = targetSize.height / height

    if widthRatio > heightRatio {
      newSize = NSSize(width: floor(width * widthRatio),
                       height: floor(height * widthRatio))
    } else {
      newSize = NSSize(width: floor(width * heightRatio),
                       height: floor(height * heightRatio))
    }
    return resize(withSize: newSize)
  }

  // MARK: Cropping

  /// Resize the image, to nearly fit the supplied cropping size
  /// and return a cropped copy the image.
  ///
  /// - Parameter size: The size of the new image.
  /// - Returns: The cropped image.
  func crop(to targetSize: NSSize) -> NSImage? {
    guard let resizedImage = resizeMaintainingAspectRatio(to: targetSize) else {
      return nil
    }
    let x = floor((resizedImage.width - targetSize.width) / 2)
    let y = floor((resizedImage.height - targetSize.height) / 2)
    let frame = NSRect(x: x, y: y, width: targetSize.width, height: targetSize.height)

    guard let representation = resizedImage.bestRepresentation(for: frame, context: nil, hints: nil) else {
      return nil
    }

    let image = NSImage(size: targetSize,
                        flipped: false,
                        drawingHandler: { (destinationRect: NSRect) -> Bool in
                          representation.draw(in: destinationRect)
    })

    return image
  }

  // MARK: Saving

  /// Save the images PNG representation the the supplied file URL:
  ///
  /// - Parameter url: The file URL to save the png file to.
  /// - Throws: An unwrappingPNGRepresentationFailed when the image has no png representation.
  func savePngTo(url: URL) throws {
    if let png = PNGRepresentation {
      try png.write(to: url, options: .atomicWrite)
    } else {
      throw NSImageExtensionError.unwrappingPNGRepresentationFailed
    }
  }
}

/// Exceptions for the image extension class.
///
/// - creatingPngRepresentationFailed: Is thrown when the creation of the png representation failed.
enum NSImageExtensionError: Error {
  case unwrappingPNGRepresentationFailed
}
