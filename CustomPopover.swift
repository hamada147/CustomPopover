//
//  PopOverMe.swift
//  B2B_Merchant
//
//  Created by Ahmed Moussa on 2/6/19.
//  Copyright © 2019 Codelabsys. All rights reserved.
//

@objc protocol CustomPopoverDelegate {
    /*!
     Popover notifies the delegate, that the popover needs to reposition it's location.
     */
    @objc optional func popoverPresentationController(_ popoverPresentationController: UIPopoverPresentationController, willRepositionPopoverTo rect: UnsafeMutablePointer<CGRect>, in view: AutoreleasingUnsafeMutablePointer<UIView>)
    /*!
     Popover asks the delegate, whether it should dismiss itself.
     */
    @objc optional func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool
    /*!
     Popover notifies the delegate, that popover did dismiss itself.
     */
    @objc optional func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController)
}

class CustomPopover: UIViewController, UIPopoverPresentationControllerDelegate {
    
    /*
     Use this method to put your custom views into popover.
     @param content Use this block to supply your custom elements, that will be shown inside popover element.
     @param popover Reference to CustomPopover, so you could add element to it's subview.
     @param popoverPresentedSize Popover's size after it is being presented.
     @param popoverArrowHeight Height of the arrow.
     @warning Be sure to call insertContentIntoPopover: only after you have presented it, otherwise popoverPresentationSize frame might be of wrong size.
     @code
 
        popoverController.insertContent(intoPopover: { popover in
        var button = UIButton(type: .roundedRect)
        button.setTitle("Works?", for: .normal)
        button.sizeToFit()
        button.center = CGPoint(x: 50, y: 25)
        button.addTarget(popover, action: #selector(self.close), for: .touchUpInside)
        popover?.view.addSubview(button)
        })
     @endcode
     */
    
    // Popover's delegate.
    var delegate: CustomPopoverDelegate?
    // Use this property to configure where popover's arrow should be pointing.
    var arrowDirection: UIPopoverArrowDirection?
    // The view containing the anchor rectangle for the popover.
    weak var sourceView: UIView?
    // The rectangle in the specified view in which to anchor the popover.
    var sourceRect = CGRect.zero
    // The preferred size for the popover’s view.
    var contentSize = CGSize.zero
    // The color of the popover’s backdrop view.
    var backgroundColor: UIColor?
    // An array of views that the user can interact with while the popover is visible.
    var passthroughViews: [UIView] = []
    // The margins that define the portion of the screen in which it is permissible to display the popover.
    var layoutMargins: UIEdgeInsets?
    
    // MARK: Initialization
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initializePopover()
    }
    
    required convenience init?(coder: NSCoder) {
        self.init(coder: coder)
        self.initializePopover()
    }
    
    func initializePopover() {
        self.modalPresentationStyle = .popover
        self.popoverPresentationController?.delegate = self
    }
    
    // MARK: - Actions
    @objc func close() {
        self.dismiss(animated: true)
    }
    
    func insertContent(intoPopover content: @escaping (_ popover: CustomPopover?, _ popoverPresentedSize: CGSize, _ presentationArrowHeight: CGFloat) -> Void) {
        let presentationArrowHeight: CGFloat = 12.0
        let width = popoverPresentationController?.frameOfPresentedViewInContainerView.width
        let height = popoverPresentationController?.frameOfPresentedViewInContainerView.height
        let popoverSize = CGSize(width: width!, height: height!)
        
        content(self, popoverSize, presentationArrowHeight)
    }
    
    // MARK: - Popover Presentation Controller Delegate
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        self.popoverPresentationController?.sourceView = (self.sourceView != nil) ? self.sourceView : self.view
        self.popoverPresentationController?.sourceRect = sourceRect
        preferredContentSize = contentSize
        
        popoverPresentationController.permittedArrowDirections = (self.arrowDirection != nil) ? self.arrowDirection! : .any
        popoverPresentationController.passthroughViews = self.passthroughViews
        popoverPresentationController.backgroundColor = self.backgroundColor
        popoverPresentationController.popoverLayoutMargins = (self.layoutMargins != nil) ? self.layoutMargins! : UIEdgeInsets.zero
    }
    
    func popoverPresentationController(_ popoverPresentationController: UIPopoverPresentationController, willRepositionPopoverTo rect: UnsafeMutablePointer<CGRect>, in view: AutoreleasingUnsafeMutablePointer<UIView>) {
        self.delegate?.popoverPresentationController!(popoverPresentationController, willRepositionPopoverTo: rect, in: view)
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        guard let value = self.delegate?.popoverPresentationControllerShouldDismissPopover!(popoverPresentationController) else {
            return true
        }
        return value
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        self.delegate?.popoverPresentationControllerDidDismissPopover!(popoverPresentationController)
    }
    
    // MARK: - Adaptive Presentation Controller Delegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // This method is called in iOS 8.3 or later regardless of trait collection, in which case use the original presentation style (UIModalPresentationNone signals no adaptation)
        return .none
    }
    
}
