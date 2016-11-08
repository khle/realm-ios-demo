////////////////////////////////////////////////////////////////////////////
//
// Copyright 2016 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

import Cartography
import Cocoa

class ListCellView: ItemCellView {

    private let countLabel = NSTextField()
    private let badgeView = ColorView(backgroundColor: NSColor(white: 1, alpha: 0.15))

    private(set) var acceptsEditing = false {
        didSet {
            textView.backgroundColor = acceptsEditing ? NSColor(white: 0, alpha: 0.15) : .clearColor()
            window?.invalidateCursorRectsForView(self)
        }
    }

    override var editable: Bool {
        didSet {
            acceptsEditing = false
        }
    }

    override var isUserInteractionEnabled: Bool {
        didSet {
            if !isUserInteractionEnabled {
                acceptsEditing = false
            }
        }
    }

    required init(identifier: String) {
        super.init(identifier: identifier)

        setupCountBadge()
        setupTextView()

        textView.layer?.cornerRadius = 5
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCountBadge() {
        contentView.addSubview(badgeView)
        constrain(badgeView) { badgeBackgroundView in
            badgeBackgroundView.top == badgeBackgroundView.superview!.top
            badgeBackgroundView.bottom == badgeBackgroundView.superview!.bottom
            badgeBackgroundView.right == badgeBackgroundView.superview!.right
            badgeBackgroundView.width == 44
        }

        countLabel.usesSingleLineMode = true
        countLabel.bordered = false
        countLabel.focusRingType = .None
        countLabel.font = .systemFontOfSize(18)
        countLabel.textColor = .whiteColor()
        countLabel.backgroundColor = .clearColor()
        countLabel.alignment = .Center
        countLabel.editable = false

        badgeView.addSubview(countLabel)
        constrain(countLabel) { countLabel in
            countLabel.width == countLabel.superview!.width
            countLabel.height == 19
            countLabel.center == countLabel.superview!.center
        }
    }

    private func setupTextView() {
        constrain(textView, badgeView, replace: textViewConstraintGroup) { textView, badgeView in
            textView.left == textView.superview!.left + 13
            textView.top == textView.superview!.top + 11
            textView.bottom == textView.superview!.bottom - 11
            textView.right == badgeView.left - 13
        }

        // It's not a good idea but seems to work
        textView.wantsLayer = true
        textView.layer?.cornerRadius = 4
    }

    override func configure(item: CellPresentable) {
        guard let list = item as? TaskList else {
            fatalError("Wrong item type")
        }

        super.configure(list)

        countLabel.integerValue = list.items.filter("completed == false").count
        editable = false

        updateTextColor()
    }

    private func updateTextColor() {
        let textAlphaValue: CGFloat = countLabel.integerValue > 0 || editable ? 1 : 0.3

        NSView.animate(duration: 0.1) {
            countLabel.alphaValue = textAlphaValue
            textView.alphaValue = textAlphaValue
        }
    }

    override func resetCursorRects() {
        super.resetCursorRects()
        addCursorRect(bounds, cursor: acceptsEditing ? .IBeamCursor() : .arrowCursor())
    }

    override func mouseEntered(theEvent: NSEvent) {
        super.mouseEntered(theEvent)

        guard !editable else {
            return
        }

        NSView.animate(duration: 0.1) {
            countLabel.alphaValue = 1
            textView.alphaValue = 1
        }

        performSelector(#selector(delayedSetAcceptsEditing), withObject: nil, afterDelay: 1.2)
    }

    override func mouseExited(theEvent: NSEvent) {
        super.mouseExited(theEvent)

        guard !editable else {
            return
        }

        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(delayedSetAcceptsEditing), object: nil)
        acceptsEditing = false

        updateTextColor()
    }

    private dynamic func delayedSetAcceptsEditing() {
        if isUserInteractionEnabled {
            acceptsEditing = true
        }
    }

    override func textFieldDidBecomeFirstResponder(textField: NSTextField) {
        super.textFieldDidBecomeFirstResponder(textField)

        updateTextColor()
    }

}
