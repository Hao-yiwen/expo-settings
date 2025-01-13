import ExpoModulesCore
import SwiftUI
import MarkdownUI

class ExpoSettingsView: ExpoView {
    let hostingController: UIHostingController<MarkdownContentView>
    let onLoad = EventDispatcher()
    
    // 添加上次更新时间记录
    private var lastUpdateTime: TimeInterval = 0
    private var updateTimer: Timer?
    private let throttleInterval: TimeInterval = 0.2 // 200ms
    
    var content: String = "" {
        didSet {
            updateContent(content)
        }
    }
    
    required init(appContext: AppContext? = nil) {
        let markdownView = MarkdownContentView(content: "")
        hostingController = UIHostingController(rootView: markdownView)
        
        super.init(appContext: appContext)
        
        // 如果只想让 SwiftUI 视图撑满自身，就和 WebView 示例一样
        addSubview(hostingController.view)
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 让 SwiftUI 子视图占满 ExpoSettingsView 的可用空间
        hostingController.view.frame = bounds
    }
    
    private func updateContent(_ newContent: String) {
        // 立即更新内容显示
        DispatchQueue.main.async {
            self.hostingController.rootView = MarkdownContentView(content: newContent)
        }
        
        let currentTime = Date().timeIntervalSince1970
        
        // 如果距离上次更新已经超过节流间隔，立即更新
        if currentTime - lastUpdateTime >= throttleInterval {
            updateHeight()
            lastUpdateTime = currentTime
        } else {
            // 否则设置一个定时器在到达间隔时更新
            updateTimer?.invalidate()
            updateTimer = Timer.scheduledTimer(withTimeInterval: throttleInterval, repeats: false) { [weak self] _ in
                self?.updateHeight()
            }
        }
    }
    
    private func updateHeight() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 获取实际内容大小
            let fittingSize = self.hostingController.sizeThatFits(in: CGSize(width: self.bounds.width, height: UIView.layoutFittingCompressedSize.height))
            
            // 添加额外的缓冲区高度
            let bufferHeight: CGFloat = 20
            let targetHeight = fittingSize.height + bufferHeight
            
            UIView.animate(withDuration: 0.2) {
                // 更新视图高度
                let newFrame = CGRect(x: self.frame.origin.x,
                                    y: self.frame.origin.y,
                                    width: self.frame.width,
                                    height: targetHeight)  // 使用添加了缓冲区的高度
                self.frame = newFrame
                
                // 更新 hostingController 视图的 frame
                self.hostingController.view.frame = CGRect(origin: .zero, size: CGSize(width: fittingSize.width, height: targetHeight))
            }
            
            self.lastUpdateTime = Date().timeIntervalSince1970
        }
    }
}

struct MarkdownContentView: View {
    let content: String
    
    var body: some View {
        Markdown {
            content
        }
        .markdownTheme(.gitHub)
        .fixedSize(horizontal: false, vertical: true)
    }
}

// 添加属性设置方法
extension ExpoSettingsView {
    @objc
    func setContent(_ content: String) {
        self.content = content
    }
    
    // 添加这个方法来处理从 React Native 传入的样式
    override func didSetProps(_ changedProps: Array<String>) {
        super.didSetProps(changedProps)
        layoutSubviews()
    }
}
