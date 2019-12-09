// Welcome to MockFive!

/// Conform to 'Mock' to use MockFive.
///
/// For a function to be hooked by MockFive successfully, it must do three things: pass its arguments to 'stub()', return the result of 'stub()', and pass a closure that generates a default value.  In practice, that looks like this:
/// ```swift
/// func myFunc(arg1: Int, arg2: String) -> String {
///     return stub(arg1, arg2) { "Default Return Value" }
/// }
/// ```
/// - requires: The line 'let mockFiveLock = lock()' must be included in the class or struct.  This registers the instance with MockFive.
public protocol Mock {
    
    /// Add `let mockFiveLock = lock()` to your class or struct.  This var holds the instance's unique identifier.
    var mockFiveLock: String { get }
    
    /// Adds the signature of the containing function to `self.invocations` and performs the block registered for `identifier`, if any.  The return closure receives the method's arguments as an `[Any?]`.
    /// - parameter identifier: The identifier used to register stubs for this method.
    /// - parameter arguments: The arguments passed to this method.  Used for logging in `self.invocations`.
    /// - parameter returns: A closure to be executed by default when this function is invoked.
    func stub<T: NilLiteralConvertible>(identifier identifier: String, arguments: Any?..., function: String, returns: ([Any?]) -> T) -> T
    
    /// Adds the signature of the containing function to `self.invocations` and performs the block registered for `identifier`, if any.  The return closure receives the method's arguments as an `[Any?]`.
    /// - parameter identifier: The identifier used to register stubs for this method.
    /// - parameter arguments: The arguments passed to this method.  Used for logging in `self.invocations`.
    /// - parameter returns: A closure to be executed by default when this function is invoked.
    func stub<T>(identifier identifier: String, arguments: Any?..., function: String, returns: ([Any?]) -> T) -> T
    
    /// Adds the signature of the containing function to `self.invocations` and performs the block registered for `identifier`, if any.  The return closure receives the method's arguments as an `[Any?]`.
    /// - parameter identifier: The identifier used to register stubs for this method.
    /// - parameter arguments: The arguments passed to this method.  Used for logging in `self.invocations`.
    /// - parameter returns: A closure to be executed by default when this function is invoked.
    func stub(identifier identifier: String, arguments: Any?..., function: String, returns: ([Any?]) -> ())
    
    /// Unregisters all stubs and erases the invocation log
    func resetMock()
    
    /// When a method containing 'stub()' is called, an entry is appended to this array.  Example `myMethod(8, argTwo: 2) -> Int`
    var invocations: [String] { get }
    
    /// Call this method to register a stub for a function identified by `identifier`.
    /// - parameter identifier: The identifier passed to `stub()` in the function to be stubbed.
    /// - parameter returns: A block with the same return type as the function being mocked. If a closuer of the incorrect type is registered, a runtime error will result.
    func registerStub<T>(identifier: String, returns: ([Any?]) -> T)
    
    /// Call this method to remove a registered stub, and return a function to its default behavior.
    /// - parameter identifier: The identifier passed to `stub()` in the function to be reset.
    func unregisterStub(identifier: String)
}
