//
//  PalnetView.swift
//  PlanetViewTest
//
//  Created by 박상은 on 25/04/2019.
//  Copyright © 2019 박상은. All rights reserved.
//

import UIKit
import CommonCrypto

@IBDesignable
class PlanetView: UIView {
    
    @IBInspectable var data: String = "" {
        didSet {
            let sha256Hash = Crypto.sha256(self.data.data(using: .utf8)!)
            self.hashArray = Array(sha256Hash)
            self.backgroundColor = UIColor.clear
            self.layer.masksToBounds = true;
            setNeedsDisplay();
        }
    }
    
    var width : CGFloat = 0;
    var height : CGFloat = 0;
    var hashArray : Array<UInt8> = [];
    
    private let patterns = [0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    
    private let colors = [
        "#FFFD00",
        "#FEB900",
        "#EFA288",
        "#EEA5B0",
        "#FF99D6",
        "#DD9278",
        "#FC8F79",
        "#E45641",
        "#E62D38",
        "#F94A62",
        "#EB526F",
        "#FF54B0",
        "#FA198C",
        "#C5147D",
        "#E1A9E8",
        "#9B5FE5",
        "#7C00C7",
        "#531CB3",
        "#CCFF66",
        "#00E291",
        "#35D1BF",
        "#028A81",
        "#0A3748",
        "#4F51B3",
        "#1D00FF",
        "#090080",
        "#0A104D",
        "#575756"
    ];
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewInit()
    }
    
    func viewInit() {
        self.backgroundColor = UIColor.clear
        self.layer.masksToBounds = true;
        self.layer.cornerRadius = self.frame.width/2.0;
        self.data = ""
        setNeedsDisplay();
    }
    
    override func draw(_ rect: CGRect) {
        self.layer.sublayers?.removeAll();
        width = rect.height
        height = rect.width
        
        self.layer.cornerRadius = self.bounds.width/2.0;
        
        // Main
        let pattern = patterns[ getValueFromByte( input: hashArray[ 0 ], range: patterns.count )  ];
        let colorCode = colors[ getValueFromByte( input: hashArray[ 1 ], range: colors.count ) ];
        drawMain(layer: self.layer, pattern: pattern, colorCode: colorCode);
        
        // Circle 1
        let visibleCircle1 = getValueFromByte(input: hashArray[8], range: 10) <= 9;
        if( visibleCircle1 ){
            let outlineRadius = 90.0 + CGFloat(getValueFromByte(input: hashArray[9], range: 40))*0.5
            let degree = CGFloat(getValueFromByte(input: hashArray[10], range: 360))
            let scale = 90.0 + CGFloat(getValueFromByte(input: hashArray[11], range: 40))*0.5
            let colorCode = colors[ getValueFromByte( input: hashArray[ 12 ], range: colors.count ) ];
            drawCircle(layer: self.layer, outlineRadius: outlineRadius, degree: degree, scale: scale, colorCode: colorCode)
        }
        
        // Circle 2
        let visibleCircle2 = getValueFromByte(input: hashArray[16], range: 10) <= 7
        if( visibleCircle2 ){
            let outlineRadius = 90.0 + CGFloat(getValueFromByte(input: hashArray[17], range: 40))*0.5
            let degree = CGFloat(getValueFromByte(input: hashArray[18], range: 360))
            let scale = 90.0 + CGFloat(getValueFromByte(input: hashArray[19], range: 40))*0.5
            let colorCode = colors[ getValueFromByte( input: hashArray[ 20 ], range: colors.count ) ];
            drawCircle(layer: self.layer, outlineRadius: outlineRadius, degree: degree, scale: scale, colorCode: colorCode)
        }
        
        let visibleMask = getValueFromByte(input: hashArray[24], range: 10) <= 5;
        if( visibleMask ){
            let outlineRadius = 30.0 + CGFloat(getValueFromByte(input: hashArray[25], range: 90))*0.5
            let degree = CGFloat(getValueFromByte(input: hashArray[26], range: 360))
            let scale = 60.0 + CGFloat(getValueFromByte(input: hashArray[27], range: 80))*0.5
            drawMaskCircle(layer: self.layer, outlineRadius: outlineRadius, degree: degree, scale: scale)
        }else{
            self.layer.mask = nil;
        }
        
    }
    
    
    func drawMain( layer:CALayer, pattern:Int, colorCode:String ){
        //———————————————————
        if( pattern == 0 ){
            
            let patternPath = UIBezierPath( rect: CGRect(x: 0, y: 0, width: width, height: height) );
            let patternLayer = CAShapeLayer()
            patternLayer.fillColor = hexStringToRGB(hexString: colorCode).cgColor
            patternLayer.path = patternPath.cgPath
            layer.addSublayer(patternLayer);
            
            
        }else if( pattern == 1 ){
            
            let patternPath = UIBezierPath()
            let patternLayer = CAShapeLayer()
            
            let waveWidth = width / 16;
            let waveHeight = height / 42;
            let waveCount:Int = Int(ceil(width/waveWidth))
            let pathCount:Int = Int(ceil(height/waveHeight))
            
            for j in 0...pathCount{
                let path = UIBezierPath()
                let pointY = waveHeight * CGFloat(j) * 2;
                path.move(to: CGPoint(x: -waveWidth, y: pointY))
                for i in 0...waveCount{
                    path.addQuadCurve(
                        to:CGPoint(
                            x: ( CGFloat(i) * waveWidth * 4 ) + waveWidth * 1,
                            y: pointY + waveHeight / 2.0 ),
                        controlPoint:  CGPoint(
                            x: ( CGFloat(i) * waveWidth * 4 ) + waveWidth * 0,
                            y: pointY - waveHeight + waveHeight / 2.0)
                    )
                    path.addQuadCurve(
                        to: CGPoint(
                            x: ( CGFloat(i) * waveWidth * 4 ) + waveWidth * 3,
                            y: pointY + waveHeight / 2.0),
                        controlPoint:CGPoint(
                            x: ( CGFloat(i) * waveWidth * 4 ) + waveWidth * 2,
                            y: pointY + waveHeight + waveHeight / 2.0)
                    )
                }
                patternPath.append(path);
            }
            patternLayer.path = patternPath.cgPath
            patternLayer.strokeColor = hexStringToRGB(hexString: colorCode).cgColor
            patternLayer.fillColor = UIColor.clear.cgColor
            patternLayer.lineWidth = CGFloat(height / 42.0)
            layer.addSublayer(patternLayer);
            
        }
            //———————————————————
        else if( pattern == 2 ){
            
            let patternPath = UIBezierPath()
            let patternLayerFill = CAShapeLayer()
            let patternLayerStroke = CAShapeLayer()
            
            let pathWidth = sqrt(pow(width, 2) + pow(height, 2)) / 42;
            let centerX = width/2.0;
            let centerY = height/2.0;
            
            let path = UIBezierPath();
            path.move(to: CGPoint(x:centerX ,y:centerY - pathWidth))
            path.addLine(to: CGPoint(x: centerX + pathWidth , y:centerY ))
            path.addLine(to: CGPoint(x: centerX , y:centerY + pathWidth ))
            path.addLine(to: CGPoint(x: centerX - pathWidth , y:centerY ))
            
            patternLayerFill.path = path.cgPath;
            patternLayerFill.fillColor = hexStringToRGB(hexString: colorCode).cgColor
            patternLayerFill.lineWidth = 0;
            patternLayerFill.strokeColor = UIColor.clear.cgColor;
            layer.addSublayer(patternLayerFill);
            
            for i in 0...14{
                let path = UIBezierPath();
                let multi = ( CGFloat(i) * 3 )
                path.move(to: CGPoint(x:centerX ,y:centerY - pathWidth*multi))
                path.addLine(to: CGPoint(x: centerX + pathWidth * multi , y:centerY ))
                path.addLine(to: CGPoint(x: centerX , y:centerY + pathWidth * multi ))
                path.addLine(to: CGPoint(x: centerX - pathWidth * multi, y:centerY ))
                path.close()
                patternPath.append(path);
            }
            
            patternLayerStroke.path = patternPath.cgPath
            patternLayerStroke.strokeColor = hexStringToRGB(hexString: colorCode).cgColor
            patternLayerStroke.fillColor = UIColor.clear.cgColor
            patternLayerStroke.lineWidth = pathWidth
            layer.addSublayer(patternLayerStroke);
            
            
        }
            //———————————————————
        else if( pattern == 3 ) {
            let patternPath = UIBezierPath()
            
            let pathWidth = width / 56
            
            let patternLayer = CAShapeLayer()
            patternLayer.lineWidth = pathWidth * 2
            patternLayer.strokeColor = hexStringToRGB(hexString: colorCode).cgColor
            
            for i in 0..<28 {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: pathWidth * ( CGFloat(i) * 4 + 1), y: 0))
                path.addLine(to: CGPoint(x: pathWidth * ( CGFloat(i) * 4 + 1), y: height))
                path.close()
                patternPath.append(path)
            }
            
            patternLayer.path = patternPath.cgPath
            layer.addSublayer(patternLayer)
        }
            //———————————————————
        else if (pattern == 4) {
            let patternPath = UIBezierPath()
            
            let pathWidth = width / 56
            
            let patternLayer = CAShapeLayer()
            patternLayer.lineWidth = pathWidth * 2
            patternLayer.strokeColor = hexStringToRGB(hexString: colorCode).cgColor
            
            for i in 0..<28 {
                let upperPath = UIBezierPath()
                upperPath.move(to: CGPoint(x: pathWidth * ( CGFloat(i) * 4 + 1), y: 0))
                upperPath.addLine(to: CGPoint(x: pathWidth * ( CGFloat(i) * 4 + 1), y: height / 2.0))
                upperPath.close()
                
                let downPath = UIBezierPath()
                downPath.move(to: CGPoint(x: pathWidth * ( CGFloat(i) * 4 + 3), y: height / 2.0))
                downPath.addLine(to: CGPoint(x: pathWidth * ( CGFloat(i) * 4 + 3), y: height))
                downPath.close()
                
                patternPath.append(upperPath)
                patternPath.append(downPath)
            }
            
            patternLayer.path = patternPath.cgPath
            layer.addSublayer(patternLayer)
        }
            //———————————————————
        else if (pattern == 5) {
            let patternPath = UIBezierPath()
            
            let pathWidth = sqrt(pow(width, 2) + pow(height, 2)) / 42.0
            
            let patternLayer = CAShapeLayer()
            patternLayer.lineWidth = pathWidth
            patternLayer.strokeColor = hexStringToRGB(hexString: colorCode).cgColor
            
            for i in 0..<24 {
                let path = UIBezierPath()
                path.move(to:
                    CGPoint(x: width + pathWidth - ( ( CGFloat(i) - 12 ) * 3 ) * pathWidth,
                            y: -pathWidth)
                )
                path.addLine(to:
                    CGPoint(x: 0 - pathWidth - ( ( CGFloat(i) - 12 ) * 3 ) * pathWidth,
                            y: height + pathWidth)
                )
                path.close()
                
                patternPath.append(path)
            }
            
            patternLayer.path = patternPath.cgPath
            layer.addSublayer(patternLayer)
        }
            //———————————————————
        else if (pattern == 6) {
            let patternPath = UIBezierPath()
            
            let patternLayer = CAShapeLayer()
            patternLayer.fillColor = hexStringToRGB(hexString: colorCode).cgColor
            
            let boxWidth = width / 24
            //            l,t,r,b
            
            for j in 0..<12 {
                for i in 0..<12 {
                    
                    let rectPath1 = UIBezierPath(rect: CGRect(x: boxWidth * ( CGFloat(i) * 2 ),
                                                              y: boxWidth * ( CGFloat(j) * 2 ),
                                                              width: boxWidth,
                                                              height: boxWidth))
                    rectPath1.close()
                    
                    let rectPath2 = UIBezierPath(rect: CGRect(x: boxWidth * ( CGFloat(i) * 2 + 1 ),
                                                              y: boxWidth * ( CGFloat(j) * 2 + 1 ),
                                                              width: boxWidth,
                                                              height: boxWidth))
                    rectPath2.close()
                    
                    patternPath.append(rectPath1)
                    patternPath.append(rectPath2)
                }
            }
            
            patternLayer.path = patternPath.cgPath
            layer.addSublayer(patternLayer)
        }
            //———————————————————
        else if (pattern == 7) {
            let patternPath = UIBezierPath()
            
            let patternLayer = CAShapeLayer()
            patternLayer.fillColor = hexStringToRGB(hexString: colorCode).cgColor
            
            let patternWidth = width / 32
            let patternHeight = height / 8
            let patternDiagonal = sqrt(pow(patternWidth, 2))
            
            for j in 0..<5 {
                for i in 0..<16 {
                    
                    let leftPath = UIBezierPath()
                    leftPath.move(to:
                        CGPoint(x: patternWidth * ( CGFloat(i) * 2 ),
                                y: patternHeight * ( CGFloat(j) * 2 ) - patternHeight / 2.0)
                    )
                    leftPath.addLine(to:
                        CGPoint(x: patternWidth * ( CGFloat(i) * 2 + 1 ),
                                y: patternHeight * ( CGFloat(j) * 2 ) - patternHeight / 2.0 + patternDiagonal)
                    )
                    leftPath.addLine(to:
                        CGPoint(x: patternWidth * ( CGFloat(i) * 2 + 1 ),
                                y: patternHeight * ( CGFloat(j) * 2 ) - patternHeight / 2.0 + patternHeight + patternDiagonal)
                    )
                    leftPath.addLine(to:
                        CGPoint(x: patternWidth * ( CGFloat(i) * 2 ),
                                y: patternHeight * ( CGFloat(j) * 2 ) - patternHeight / 2.0 + patternHeight)
                    )
                    leftPath.close()
                    
                    let rightPath = UIBezierPath()
                    rightPath.move(to:
                        CGPoint(x: patternWidth * ( CGFloat(i) * 2 + 1 ),
                                y: patternHeight * ( CGFloat(j) * 2 ) - patternHeight / 2.0 + patternHeight + patternDiagonal )
                    )
                    rightPath.addLine(to:
                        CGPoint(x: patternWidth * ( CGFloat(i) * 2 + 2 ),
                                y: patternHeight * ( CGFloat(j) * 2 ) - patternHeight / 2.0 + patternHeight )
                    )
                    rightPath.addLine(to:
                        CGPoint(x: patternWidth * ( CGFloat(i) * 2 + 2 ),
                                y: patternHeight * ( CGFloat(j) * 2 ) - patternHeight / 2.0 + patternHeight + patternHeight )
                    )
                    rightPath.addLine(to:
                        CGPoint(x: patternWidth * ( CGFloat(i) * 2 + 1),
                                y: patternHeight * ( CGFloat(j) * 2 ) - patternHeight / 2.0 + patternHeight + patternHeight + patternDiagonal )
                    )
                    rightPath.close()
                    
                    patternPath.append(leftPath)
                    patternPath.append(rightPath)
                    
                }
            }
            
            patternLayer.path = patternPath.cgPath
            layer.addSublayer(patternLayer)
        }
            //———————————————————
        else if (pattern == 8) {
            let patternPath = UIBezierPath()
            
            let patternLayer = CAShapeLayer()
            patternLayer.fillColor = hexStringToRGB(hexString: colorCode).cgColor
            
            let pathWidth = (width / 16) * 3.0 / 5.0
            let gapWidth = (width / 16) * 2.0 / 5.0
            
            for j in 0..<18 {
                for i in 0..<18 {
                    
                    let leftPath = UIBezierPath()
                    leftPath.move(to:
                        CGPoint(x: ( gapWidth * ( CGFloat(i) + 1 ) ) + ( pathWidth * CGFloat(i) ) + ( ( pathWidth / 2.0 ) * 1 ) - gapWidth / 2.0,
                                y: ( ( pathWidth / 2.0 ) * -1 ) + ( gapWidth + pathWidth ) * CGFloat(j))
                    )
                    leftPath.addLine(to:
                        CGPoint(x: ( gapWidth * ( CGFloat(i) + 1 ) ) + ( pathWidth * CGFloat(i) ) + ( ( pathWidth / 2.0 ) * 2 ) - gapWidth / 2.0,
                                y: ( ( pathWidth / 2.0 ) * 0 ) + ( gapWidth + pathWidth ) * CGFloat(j))
                    )
                    leftPath.addLine(to:
                        CGPoint(x: ( gapWidth * ( CGFloat(i) + 1 ) ) + ( pathWidth * CGFloat(i) ) + ( ( pathWidth / 2.0 ) * 1 ) - gapWidth / 2.0,
                                y: ( ( pathWidth / 2.0 ) * 1 ) + ( gapWidth + pathWidth ) * CGFloat(j))
                    )
                    leftPath.addLine(to:
                        CGPoint(x: ( gapWidth * ( CGFloat(i) + 1 ) ) + ( pathWidth * CGFloat(i) ) + ( ( pathWidth / 2.0 ) * 0 ) - gapWidth / 2.0,
                                y: ( ( pathWidth / 2.0 ) * 0 ) + ( gapWidth + pathWidth ) * CGFloat(j))
                    )
                    leftPath.close()
                    
                    let rightPath = UIBezierPath()
                    rightPath.move(to:
                        CGPoint(x: ( gapWidth * ( CGFloat(i) + 1 ) ) + ( pathWidth * CGFloat(i) ) + ( ( pathWidth / 2.0 ) * 1 ) - gapWidth - pathWidth / 2.0,
                                y: ( gapWidth / 2.0 + pathWidth / 2.0 ) + ( ( pathWidth / 2.0 ) * -1 ) + ( gapWidth + pathWidth ) * CGFloat(j) )
                    )
                    rightPath.addLine(to:
                        CGPoint(x: ( gapWidth * ( CGFloat(i) + 1 ) ) + ( pathWidth * CGFloat(i) ) + ( ( pathWidth / 2.0 ) * 2 ) - gapWidth - pathWidth / 2.0,
                                y: ( gapWidth / 2.0 + pathWidth / 2.0 ) + ( ( pathWidth / 2.0 ) * 0 ) + ( gapWidth + pathWidth ) * CGFloat(j) )
                    )
                    rightPath.addLine(to:
                        CGPoint(x: ( gapWidth * ( CGFloat(i) + 1 ) ) + ( pathWidth * CGFloat(i) ) + ( ( pathWidth / 2.0 ) * 1 ) - gapWidth - pathWidth / 2.0,
                                y: ( gapWidth / 2.0 + pathWidth / 2.0 ) + ( ( pathWidth / 2.0 ) * 1 ) + ( gapWidth + pathWidth ) * CGFloat(j) )
                    )
                    rightPath.addLine(to:
                        CGPoint(x: ( gapWidth * ( CGFloat(i) + 1 ) ) + ( pathWidth * CGFloat(i) ) + ( ( pathWidth / 2.0 ) * 0 ) - gapWidth - pathWidth / 2.0,
                                y: ( gapWidth / 2.0 + pathWidth / 2.0 ) + ( ( pathWidth / 2.0 ) * 0 ) + ( gapWidth + pathWidth ) * CGFloat(j) )
                    )
                    rightPath.close()
                    
                    patternPath.append(leftPath)
                    patternPath.append(rightPath)
                    
                }
            }
            
            patternLayer.path = patternPath.cgPath
            layer.addSublayer(patternLayer)
        }
            //———————————————————
        else if (pattern == 9) {
            let patternPath = UIBezierPath()
            
            let pathWidth = sqrt(pow(width, 2) + pow(height, 2)) / 42.0
            
            let patternLayerStroke = CAShapeLayer()
            let patternLayerFill = CAShapeLayer()
            
            patternLayerStroke.strokeColor = hexStringToRGB(hexString: colorCode).cgColor
            patternLayerStroke.lineWidth = pathWidth
            
            patternLayerFill.fillColor = hexStringToRGB(hexString: colorCode).cgColor
            
            for i in 0..<13 {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: width + pathWidth + ( CGFloat(i - 12) * 3 ) * pathWidth - pathWidth * 2,
                                      y: -pathWidth))
                path.addLine(to: CGPoint(x: 0 - pathWidth + ( CGFloat( i - 12 ) * 3 ) * pathWidth - pathWidth * 2,
                                         y: height + pathWidth))
                patternPath.append(path)
            }
            
            
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: width, y: 0))
            path.addLine(to: CGPoint(x: width, y: height))
            path.addLine(to: CGPoint(x: 0, y: height))
            path.close()
            
            patternLayerFill.path = path.cgPath
            patternLayerStroke.path = patternPath.cgPath
            layer.addSublayer(patternLayerStroke)
            layer.addSublayer(patternLayerFill)
        }
            //———————————————————
        else if (pattern == 10) {
            let patternPath = UIBezierPath()
            
            let patternLayer = CAShapeLayer()
            patternLayer.fillColor = hexStringToRGB(hexString: colorCode).cgColor
            
            let patternWidth = width / 16
            let patternHeight = height / 16
            
            for i in 0..<8 {
                let path1 = UIBezierPath()
                path1.move(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 1,
                                       y: ( patternHeight * 4 ) * 0 + patternHeight * 0 ))
                path1.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 2,
                                          y: ( patternHeight * 4 ) * 0 + patternHeight * 0 ))
                path1.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 1,
                                          y: ( patternHeight * 4 ) * 0 + patternHeight * 1 ))
                path1.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 2,
                                          y: ( patternHeight * 4 ) * 0 + patternHeight * 2 ))
                path1.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 1,
                                          y: ( patternHeight * 4 ) * 0 + patternHeight * 3 ))
                path1.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 2,
                                          y: ( patternHeight * 4 ) * 0 + patternHeight * 4 ))
                path1.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 1,
                                          y: ( patternHeight * 4 ) * 0 + patternHeight * 4 ))
                path1.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 0,
                                          y: ( patternHeight * 4 ) * 0 + patternHeight * 3 ))
                path1.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 1,
                                          y: ( patternHeight * 4 ) * 0 + patternHeight * 2 ))
                path1.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 0,
                                          y: ( patternHeight * 4 ) * 0 + patternHeight * 1 ))
                path1.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 1,
                                          y: ( patternHeight * 4 ) * 0 + patternHeight * 0 ))
                path1.close()
                
                let path2 = UIBezierPath()
                path2.move(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 0,
                                       y: ( patternHeight * 4 ) * 1 + patternHeight * 0 ))
                path2.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 1,
                                          y: ( patternHeight * 4 ) * 1 + patternHeight * 0 ))
                path2.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 2,
                                          y: ( patternHeight * 4 ) * 1 + patternHeight * 1 ))
                path2.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 1,
                                          y: ( patternHeight * 4 ) * 1 + patternHeight * 2 ))
                path2.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 2,
                                          y: ( patternHeight * 4 ) * 1 + patternHeight * 3 ))
                path2.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 1,
                                          y: ( patternHeight * 4 ) * 1 + patternHeight * 4 ))
                path2.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 0,
                                          y: ( patternHeight * 4 ) * 1 + patternHeight * 4 ))
                path2.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 1,
                                          y: ( patternHeight * 4 ) * 1 + patternHeight * 3 ))
                path2.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 0,
                                          y: ( patternHeight * 4 ) * 1 + patternHeight * 2 ))
                path2.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 1,
                                          y: ( patternHeight * 4 ) * 1 + patternHeight * 1 ))
                path2.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 0,
                                          y: ( patternHeight * 4 ) * 1 + patternHeight * 0 ))
                path2.close()
                
                let path3 = UIBezierPath()
                path3.move(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 1,
                                       y: ( patternHeight * 4 ) * 2 + patternHeight * 0 ))
                path3.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 2,
                                          y: ( patternHeight * 4 ) * 2 + patternHeight * 0 ))
                path3.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 1,
                                          y: ( patternHeight * 4 ) * 2 + patternHeight * 1 ))
                path3.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 2,
                                          y: ( patternHeight * 4 ) * 2 + patternHeight * 2 ))
                path3.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 1,
                                          y: ( patternHeight * 4 ) * 2 + patternHeight * 3 ))
                path3.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 2,
                                          y: ( patternHeight * 4 ) * 2 + patternHeight * 4 ))
                path3.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 1,
                                          y: ( patternHeight * 4 ) * 2 + patternHeight * 4 ))
                path3.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 0,
                                          y: ( patternHeight * 4 ) * 2 + patternHeight * 3 ))
                path3.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 1,
                                          y: ( patternHeight * 4 ) * 2 + patternHeight * 2 ))
                path3.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 0,
                                          y: ( patternHeight * 4 ) * 2 + patternHeight * 1 ))
                path3.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 1,
                                          y: ( patternHeight * 4 ) * 2 + patternHeight * 0 ))
                path3.close()
                
                let path4 = UIBezierPath()
                path4.move(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 0,
                                       y: ( patternHeight * 4 ) * 3 + patternHeight * 0 ))
                path4.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 1,
                                          y: ( patternHeight * 4 ) * 3 + patternHeight * 0 ))
                path4.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 2,
                                          y: ( patternHeight * 4 ) * 3 + patternHeight * 1 ))
                path4.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 1,
                                          y: ( patternHeight * 4 ) * 3 + patternHeight * 2 ))
                path4.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 2,
                                          y: ( patternHeight * 4 ) * 3 + patternHeight * 3 ))
                path4.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 1,
                                          y: ( patternHeight * 4 ) * 3 + patternHeight * 4 ))
                path4.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 0,
                                          y: ( patternHeight * 4 ) * 3 + patternHeight * 4 ))
                path4.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 1,
                                          y: ( patternHeight * 4 ) * 3 + patternHeight * 3 ))
                path4.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 0,
                                          y: ( patternHeight * 4 ) * 3 + patternHeight * 2 ))
                path4.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 1,
                                          y: ( patternHeight * 4 ) * 3 + patternHeight * 1 ))
                path4.addLine(to: CGPoint(x: ( patternWidth * 2 * CGFloat(i) ) + patternWidth * 0,
                                          y: ( patternHeight * 4 ) * 3 + patternHeight * 0 ))
                path4.close()
                
                patternPath.append(path1)
                patternPath.append(path2)
                patternPath.append(path3)
                patternPath.append(path4)
            }
            
            patternLayer.path = patternPath.cgPath
            layer.addSublayer(patternLayer)
        }
            //———————————————————
        else if( pattern == 11 ){
            let patternWidth = width / 12.0
            
            let patternPath = UIBezierPath()
            let patternLayer = CAShapeLayer()
            patternLayer.fillColor = hexStringToRGB(hexString: colorCode).cgColor
            
            for j in 0..<12{
                for i in 0..<12 {
                    let path = UIBezierPath()
                    path.move(to: CGPoint(x: patternWidth * CGFloat(i), y: patternWidth * CGFloat(j) ))
                    path.addLine(to: CGPoint(x: patternWidth * CGFloat(i + 1), y: patternWidth * CGFloat(j) ))
                    path.addLine(to: CGPoint(x: patternWidth * CGFloat(i), y: patternWidth * CGFloat(j + 1) ))
                    path.close()
                    patternPath.append(path)
                }
            }
            patternLayer.path = patternPath.cgPath
            layer.addSublayer(patternLayer);
        }
            //———————————————————
        else if( pattern == 12 ){
            let pathWidth = width / 56.0
            
            let patternPath = UIBezierPath()
            let patternLayer = CAShapeLayer()
            patternLayer.lineWidth = pathWidth * 2
            patternLayer.strokeColor = hexStringToRGB(hexString: colorCode).cgColor
            
            for i in 0..<28{
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 0, y: pathWidth * (CGFloat(i) * 4 + 1) ))
                path.addLine(to: CGPoint(x: width, y: pathWidth * (CGFloat(i) * 4 + 1) ))
                path.close()
                patternPath.append(path)
            }
            
            patternLayer.path = patternPath.cgPath
            layer.addSublayer(patternLayer);
            
        }
    }
    
    func drawCircle( layer:CALayer, outlineRadius:CGFloat, degree:CGFloat, scale:CGFloat, colorCode:String ){
        let radius = scale / 100.0 * ( width/2.0 )
        let circlePath = UIBezierPath(roundedRect: CGRect(
            x: width/2.0 + ( outlineRadius / 100.0 * ( width/2.0 ) ) * cos(degree * CGFloat.pi / 180) - radius,
            y: width/2.0 + ( outlineRadius / 100.0 * ( width/2.0 ) ) * sin(degree * CGFloat.pi / 180) - radius,
            width: radius*2,
            height: radius*2),
                                      cornerRadius: radius);
        let circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath;
        circleLayer.fillColor = hexStringToRGB(hexString: colorCode).cgColor
        layer.addSublayer(circleLayer);
    }
    
    
    func drawMaskCircle( layer:CALayer, outlineRadius:CGFloat, degree:CGFloat, scale:CGFloat ){
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: width, height: height), cornerRadius: 0)
        let radius = scale / 100.0 * ( width/2.0 )
        let circlePath = UIBezierPath(roundedRect: CGRect(
            x: width/2.0 + ( outlineRadius / 100.0 * ( width/2.0 ) ) * cos(degree * CGFloat.pi / 180) - radius,
            y: width/2.0 + ( outlineRadius / 100.0 * ( width/2.0 ) ) * sin(degree * CGFloat.pi / 180) - radius,
            width: radius*2,
            height: radius*2),
                                      cornerRadius: radius);
        path.append(circlePath)
        path.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
        fillLayer.fillColor = UIColor.red.cgColor
        
        layer.mask = fillLayer;
    }
    
    func getValueFromByte( input:UInt8, range:Int )->Int {
        if ( range == 0 ) {
            return 0;
        }
        let percent = 256.0 / Double(range);
        for i in 0...range{
            if( Double(i)*percent < Double(input) &&  Double(input) < Double(i+1)*percent ){
                return i
            }
        }
        return 0;
    }
    
    func hexStringToRGB(hexString:String)->UIColor{
        let scanner = Scanner(string: hexString)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0);
    }
    
}
