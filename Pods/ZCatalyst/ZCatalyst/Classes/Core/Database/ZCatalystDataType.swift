//
//  Value.swift
//  Catalyst
//
//  Created by Giridhar on 07/06/19.
//

import Foundation


public protocol ZCatalystDataType
{
}

extension String:ZCatalystDataType{}
extension Int: ZCatalystDataType{}
extension Double: ZCatalystDataType{}
extension Date: ZCatalystDataType{}
extension Bool: ZCatalystDataType{}
extension Int64 : ZCatalystDataType{}
