//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

@freestanding(expression)
public macro FileID<T: ExpressibleByStringLiteral>() -> T =
  #externalMacro(
    module: "MacrosImplementation",
    type: "NativeFileIDMacro"
  )

@freestanding(expression)
public macro FilePath<T: ExpressibleByStringLiteral>() -> T =
  #externalMacro(
    module: "MacrosImplementation",
    type: "NativeFilePathMacro"
  )

@freestanding(expression)
public macro Line<T: ExpressibleByIntegerLiteral>() -> T =
  #externalMacro(
    module: "MacrosImplementation",
    type: "NativeLineMacro"
  )

@freestanding(expression)
public macro Column<T: ExpressibleByIntegerLiteral>() -> T =
  #externalMacro(
    module: "MacrosImplementation",
    type: "NativeColumnMacro"
  )
