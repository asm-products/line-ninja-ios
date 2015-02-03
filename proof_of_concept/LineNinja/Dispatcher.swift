//
//  Dispatcher.swift
//  LineNinja
//
//  Created by David Sandor on 8/17/14.
//  Copyright (c) 2014 David Sandor. All rights reserved.
//

import Foundation

func Dispatcher(functionToRunOnMainThread: () -> ())
{
    dispatch_async(dispatch_get_main_queue(), functionToRunOnMainThread)
}