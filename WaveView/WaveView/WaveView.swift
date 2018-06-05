//
//  WaveView.swift
//  WaveView
//
//  Created by Fernando on 2018/6/5.
//  Copyright © 2018年 Liteng. All rights reserved.
//

import UIKit

class WaveView: UIView, CAAnimationDelegate {
    var waveLayers = [CAShapeLayer]()
    var colors = [UIColor(rgba: 0xC3D800FF), UIColor(rgba: 0x99BC04B2), UIColor(rgba: 0xC3D800B2)] {
        didSet {
            for i in 0..<countOfWave {
                lineLayers[i].fillColor = colors[i].cgColor
                lineLayers[i].strokeColor = colors[i].cgColor
            }
        }
    }
    
    var countOfWave:Int = 3
    var isAnimating: Bool = false
    var waveLengths: [CGFloat] = [375.0 * 0.7, 375.0, 375.0 * 1.5]
    var finalXs = [CGFloat]()// = 0.0
    var minAmplitudes: [CGFloat] = [15.0, 40.0, 20.0]
    var maxAmplitudes: [CGFloat] = [30.0, 20.0, 30.0]
    var startAmplitudes: [CGFloat] = [0.0, 0.0, 0.0]
    var amplitudeIncrement: CGFloat = 5.0
    var amplitudes = [[CGFloat]]()
    var horizontalAnimationDurations: [CFTimeInterval] = [8.5, 30.5, 90.0]
    var startElevation: CGFloat = 0.0 {
        didSet {
            for i in 0..<countOfWave {
                var frame = lineLayers[i].frame
                frame.size.height = frame.height * (1.0 - startElevation)
                lineLayers[i].frame = frame
            }
        }
    }
    var fillLevel: CGFloat = 0.0
    var fillDuration: CGFloat = 0.75
    
    fileprivate var lineLayers = [CAShapeLayer]()
    fileprivate var waveTimer: Timer?
    fileprivate var waveAnimations = [CAKeyframeAnimation]()
    fileprivate var verticalFillAnimations = [CAKeyframeAnimation]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
        guard colors.count == 3 else {
            fatalError("Must set 3 colors for wave color")
        }
        
        clipsToBounds = true
        
        for i in 0..<countOfWave {
            let lineLayer = CAShapeLayer()
            lineLayer.fillColor = colors[i].cgColor
            lineLayer.strokeColor = colors[i].cgColor
            lineLayers.append(lineLayer)
            //waveLengths = bounds.width// * 1.5
            finalXs.append(waveLengths[i] * 5.0)
            amplitudes.append([CGFloat]())
            for j in stride(from: minAmplitudes[i], to: maxAmplitudes[i], by: amplitudeIncrement) {
                amplitudes[i].append(j)
            }
            lineLayer.anchorPoint = CGPoint.zero
            lineLayer.frame = CGRect(x: 0.0, y: bounds.width, width: finalXs[i], height: bounds.height)
        }
    }
    
    func fill(to percent: CGFloat) {
        let diff = abs(percent - fillLevel)
        if diff == 0.0 {
            return
        }
        
        for i in 0..<countOfWave {
            let verticalAnimation = CAKeyframeAnimation(keyPath: "position.y")
            let duration = CFTimeInterval(fillDuration * diff)
            verticalAnimation.duration = duration
            verticalAnimation.autoreverses = false
            verticalAnimation.repeatCount = 0
            verticalAnimation.isRemovedOnCompletion = false
            verticalAnimation.fillMode = kCAFillModeForwards
            
            fillLevel = percent
            var finalPosition: CGFloat = (1.0 - percent) * bounds.height
            if fillLevel == 1.0 {
                finalPosition -= 2.0 * maxAmplitudes[i]
            } else if 0.98 < fillLevel {
                finalPosition -= maxAmplitudes[i]
            }
            
            let initLayer = lineLayers[i]
            verticalAnimation.values = [initLayer.position.y, finalPosition]
            lineLayers[i].add(verticalAnimation, forKey: "verticalFillAnimation")
            verticalFillAnimations.append(verticalAnimation)
            
            DispatchQueue.global().asyncAfter(deadline: .now() + duration * 2.0) {
                self.updown(index: i, finalPosition: finalPosition)
            }
        }
    }
    
    func updown(index: Int, finalPosition: CGFloat) {
        let lineLayer = lineLayers[index]
        lineLayer.removeAnimation(forKey: "verticalFillAnimation")
        
        let verticalAnimation = CAKeyframeAnimation(keyPath: "position.y")
        verticalAnimation.duration = CFTimeInterval(1.5 * CGFloat(index))
        verticalAnimation.autoreverses = true
        verticalAnimation.repeatCount = HUGE
        verticalAnimation.isRemovedOnCompletion = false
        verticalAnimation.fillMode = kCAFillModeForwards
        verticalAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        verticalAnimation.values = [finalPosition, finalPosition - 2.0 * CGFloat(index), finalPosition]
        verticalAnimation.keyTimes = [0.0, 0.5, 1.0]
        lineLayer.add(verticalAnimation, forKey: "verticalUpDownAnimation")
    }
    
    func updateStartElevation(_ startElevation: CGFloat) {
        
    }
    
    func startAnimation() {
        guard !isAnimating else {
            return
        }
        
        let horizontalAnimation = CAKeyframeAnimation(keyPath: "position.x")
        print("horizontal -> \(horizontalAnimation)")
        horizontalAnimation.repeatCount = Float.infinity
        horizontalAnimation.isRemovedOnCompletion = false
        horizontalAnimation.fillMode = kCAFillModeForwards
        
        for i in 0..<countOfWave {
            startAmplitudes[i] = maxAmplitudes[i]
            horizontalAnimation.duration = horizontalAnimationDurations[i]
            horizontalAnimation.values = [lineLayers[i].position.x - waveLengths[i] * 2.0, lineLayers[i].position.x - waveLengths[i]]
            lineLayers[i].add(horizontalAnimation, forKey: "horizaontalAnimation")
            
            let waveAnimation = CAKeyframeAnimation(keyPath: "path")
            waveAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            waveAnimation.values = getWavePaths(i)
            waveAnimation.duration = 0.5
            waveAnimation.isRemovedOnCompletion = false
            waveAnimation.fillMode = kCAFillModeForwards
            waveAnimation.delegate = self
            lineLayers[i].add(waveAnimation, forKey: "waveAnimation")
            waveAnimations.append(waveAnimation)
            
            //        self.waveTimer = Timer(timeInterval: self.waveAnimation!.duration,
            //                               target: self,
            //                               selector: #selector(self.updateWaveAnimation),
            //                               userInfo: nil,
            //                               repeats: true)
            //        RunLoop.main.add(self.waveTimer!, forMode: .defaultRunLoopMode)
            //        updateWaveAnimation()
            //        self.waveTimer!.fire()
            layer.addSublayer(lineLayers[i])
        }
        isAnimating = true
    }
    
    //    @objc func updateWaveAnimation() {
    //        guard let lineLayer = lineLayer, let waveAnimation = waveAnimation else {
    //            print("animation update canceled!")
    //            return
    //        }
    //        print("animation update!")
    //        lineLayer.removeAnimation(forKey: "waveAnimation")
    //        waveAnimation.values = getWavePaths()
    //        lineLayer.add(waveAnimation, forKey: "waveAnimation")
    //    }
    //
    func stopAnimation() {
        if waveTimer != nil {
            waveTimer?.invalidate()
            waveTimer = nil
        }
        for lineLayer in lineLayers {
            lineLayer.removeAnimation(forKey: "horizaontalAnimation")
            lineLayer.removeAnimation(forKey: "waveAnimation")
        }
        waveAnimations.removeAll()
        isAnimating = false
    }
    
    func getWavePaths(_ index: Int) -> [CGPath] {
        var res = [CGPath]()
        let startPoint = CGPoint.zero
        //        var tmp = Int(arc4random_uniform(UInt32(amplitudes[index].count)))
        //        if amplitudes[index][tmp] == startAmplitudes[index] {
        //            tmp = (tmp + 1) % amplitudes.count
        //        }
        //        let finalAmplitude = amplitudes[index][tmp]
        let finalAmplitude = minAmplitudes[index]
        
        if finalAmplitude <= startAmplitudes[index] {
            for i in stride(from: startAmplitudes[index], to: finalAmplitude, by: -amplitudeIncrement) {
                let line = UIBezierPath()
                line.move(to: startPoint)
                
                var tmp = i
                for j in stride(from: waveLengths[index] / 2.0, to: finalXs[index], by: waveLengths[index] / 2.0) {
                    line.addQuadCurve(to: CGPoint(x: startPoint.x + j, y: startPoint.y),
                                      controlPoint: CGPoint(x: startPoint.x + j - (waveLengths[index] / 4.0), y: startPoint.y + tmp))
                    tmp = -tmp
                }
                
                line.addLine(to: CGPoint(x: finalXs[index], y: 5.0 * bounds.width - maxAmplitudes[index]))
                line.addLine(to: CGPoint(x: 0.0, y: 5.0 * bounds.width - maxAmplitudes[index]))
                line.close()
                
                res.append(line.cgPath)
            }
        } else {
            for i in stride(from: startAmplitudes[index], to: finalAmplitude, by: amplitudeIncrement) {
                let line = UIBezierPath()
                line.move(to: startPoint)
                
                var tmp = i
                for j in stride(from: waveLengths[index] / 2.0, to: finalXs[index], by: waveLengths[index] / 2.0) {
                    line.addQuadCurve(to: CGPoint(x: startPoint.x + j, y: startPoint.y),
                                      controlPoint: CGPoint(x: startPoint.x + j - (waveLengths[index] / 4.0), y: startPoint.y + tmp))
                    tmp = -tmp
                }
                
                line.addLine(to: CGPoint(x: finalXs[index], y: 5.0 * bounds.width - maxAmplitudes[index]))
                line.addLine(to: CGPoint(x: 0.0, y: 5.0 * bounds.width - maxAmplitudes[index]))
                line.close()
                
                res.append(line.cgPath)
            }
            
        }
        startAmplitudes[index] = finalAmplitude
        
        return res
    }
}

//extension WaveView {
//    func animationDidStart(_ anim: CAAnimation) {
//        print("animation started anim->\(anim)")
//        if let keyAnimation = anim as? CAKeyframeAnimation,
//            let index = verticalFillAnimations.index(of: keyAnimation) {
//            print("started vertical file index->\(index)")
//        }
//    }
//
//    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//        print("animation stoped anim->\(anim)")
//        if let keyAnimation = anim as? CAKeyframeAnimation,
//            let index = verticalFillAnimations.index(of: keyAnimation) {
//            print("Stoped vertical file index->\(index)")
//        }
//    }
//
//}
