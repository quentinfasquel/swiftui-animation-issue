//
//  ViewController.swift
//  AnimationIssue
//
//  Created by Quentin Fasquel on 31/08/2020.
//  Copyright © 2020 QF Codes. All rights reserved.
//

import SwiftUI
import Combine
import UIKit


// MARK: -

struct CustomShape: Shape {

    let complexShape: Bool
    var rect: CGRect
    
    var animatableData: CGRect.AnimatableData {
        get { return rect.animatableData }
        set { rect = CGRect(x: newValue.first.first, y: newValue.first.second, width: newValue.second.first, height: newValue.second.second) }
    }
    
    func path(in rect: CGRect) -> Path {
        if complexShape {
            return Path { path in
                path.addRect(rect.insetBy(dx: 60, dy: 60))
                path.addRect(rect.insetBy(dx: 30, dy: 30))
            }
        } else {
            return Path { path in
                path.addRect(rect.insetBy(dx: 30, dy: 30))
            }
        }
    }
}

class ViewController: UIViewController {

    var isExpanded: Bool = false {
        didSet { view.setNeedsUpdateConstraints() }
    }

    @IBOutlet var expandConstraint: NSLayoutConstraint!
    @IBOutlet var equalConstraint: NSLayoutConstraint!
    @IBOutlet var containerView: UIView!

    var hostingController: UIHostingController<AnyView>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add SwiftUI to containerView which gets animated
        hostingController = UIHostingController(rootView:AnyView(
            SwiftUIResizeView()
                .edgesIgnoringSafeArea(.all)
        ))

        addChild(hostingController)

        containerView.addSubview(hostingController.view)

        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostingController.view.backgroundColor = .yellow
        hostingController.view.frame = containerView.bounds

        hostingController.didMove(toParent: self)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()

        if isExpanded { // Cannot expand when in landscape
            equalConstraint.isActive = false
            expandConstraint.isActive = true
        } else {
            expandConstraint.isActive = false
            equalConstraint.isActive = true
        }
    }

    @IBAction func toggleExpand() {
        isExpanded.toggle()

        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.view.layoutIfNeeded()
        })
    }

}

// MARK: -

struct SwiftUIResizeView: View {
    var body: some View {
        ZStack {
            Color.gray

            // Draw something and make sure animation happens
            GeometryReader { proxy in
                CustomShape(complexShape: false, rect: proxy.frame(in: .local))
                    .stroke(lineWidth: 10)
                    .foregroundColor(Color.yellow)
            }
        }
    }
}

#if DEBUG

struct SwiftUIPreview: View {
    @State var height: CGFloat? = nil

    func toggleHeight() {
        withAnimation {
            height = height == nil ? 400 : nil
        }
    }
    
    func toggleButton() -> some View {
        Text("CLICK ME")
        .background(Color.red)
    }
    
    var body: some View {
        ZStack {
            SwiftUIResizeView()
                .frame(width: nil, height: height)
            
            VStack(alignment: .center) {
                Button(action: toggleHeight, label: toggleButton)
                Spacer()
            }
        }
    }
}

struct SwiftUIResizeView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIPreview()
    }
}

#endif
