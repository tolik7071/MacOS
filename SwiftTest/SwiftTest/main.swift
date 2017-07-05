//
//  main.swift
//  SwiftTest
//
//  Created by Anatoliy Goodz on 12/1/14.
//  Copyright (c) 2014 tolik7071. All rights reserved.
//

import Foundation

func PrintMessage(message  : String)/* -> Void */
{
    print(message);
}

let message : String = "Hello, World!"
var value = 4
let fullMessage = message + "\t" + String(value)
print(fullMessage)

let someValue : Float = 5.9999
let text = "This is a value \(someValue + 0.999)"
print(text)

var myDict = [
    1 : "One",
    2 : "Two",
    3 : "Three"
]

//sort(&myDict, )

for key in myDict.keys
{
    PrintMessage(myDict[key]!)
}

enum Values : Int {
    case One = 1
    case Two
    case Three
}

let val = Values.One
print(val.rawValue)

extension Int {
    func Print() {
        print(self);
    }
}

let someInt : Int = 99
someInt.Print()

let cat = "🐱"
print(cat)


print(UInt64.max)
print(UInt.max)

protocol ConvertableToString {
    func ToString() -> String
}

enum MyColors : ConvertableToString {
    case Red
    case Green
    case Blue
    
    func ToString() -> String {
        var result : String = ""
        
        if (self == .Red)
        {
            result = "Red"
        }
        else if (self == .Green)
        {
            result = "Green"
        }
        if (self == .Blue)
        {
            result = "Blue"
        }
        
        return result
    }
}

var color : MyColors = MyColors.Green
print(color.ToString())

// prints é
print("\u{65}\u{301}")

// prints USA flag
print("\u{1F1FA}\u{1F1F8}")

print("test string".characters.count)

print("\u{45}\u{65}")

var array1 : [Int] = [ 1, 5, 0, -2]
let array2 : Array<Int> = [ 1, 5, 0, -2]

array1.sortInPlace()
for (index, value) in array1.enumerate() {
    print("\(index) : \(value)")
}

func minMax(array : [Int]) -> (min : Int, max : Int)? {
    if array.isEmpty {
        return nil
    }
    
    var minValue = array[0]
    var maxValue = array[0]
    
    for currentValue in array[1..<array.count] {
        if currentValue < minValue {
            minValue = currentValue
        }
        if currentValue > maxValue {
            maxValue = currentValue
        }
    }
    
    return (minValue, maxValue)
}

if let result = minMax([10, -1, 88, 6, -10]) {
    print(result)
}

struct Point {
    var x = 0.0, y = 0.0
    
    mutating func moveBy(deltaX : Double, y deltaY : Double) {
        self = Point(x : x + deltaX, y : y + deltaY)
    }
}

var somePoint = Point(x : 2, y : 3)
withUnsafePointer(&somePoint) { ptr in print(ptr) }

somePoint.moveBy(1, y: 2)
withUnsafePointer(&somePoint) { ptr in print(ptr) }

class ShoppingListItem {
    
    var name: String?
    
    func PrintName() {
        print(name)
    }
}

var list = ShoppingListItem()
list.PrintName()

// ***** ***** ***** ***** ***** ***** //

class Person {
    var name: String!
    
    init(name: String!) {
        self.name = name
    }
    
    deinit {
        print("Person.deinit: \(self.name)")
    }
}

var person: Person?
person = Person(name: "Smith")
print(person?.name)
person = nil

var person1: Optional<Person>
person1 = Person(name: "Smith1")
print(person1?.name)

var person2: Person
person2 = Person(name: nil)
//print(person2.name)

//var person3: Person!
//println(person3!.name)

for var i in 0..<10 {

    var person = Person(name: "Person #\(i)")
    print(person.name)
//    person = nil
}

// ***** ***** ***** ***** ***** ***** //

func Add(first : Int, second : Int = 11) -> Int {
    return (first + second)
}

print(Add(12))
print(Add(11, second: 9))

// ***** ***** ***** ***** ***** ***** //

let someDouble : Double = 3.14
let someFloat : Float = 3.14

print(sizeof(Double)) // 8 bytes
print(sizeof(Float))  // 4 bytes
print("D: \(someDouble), F: \(someFloat)")

// ***** ***** ***** ***** ***** ***** //

let x1 = 24
var s1 : String

s1 = "Test string: " + String(x1)
print(s1)

// ***** ***** ***** ***** ***** ***** //

class SomeClass {
    
    var description : String!
    
    init(description : String) {
        self.description = description
    }
}

var insance1 = SomeClass(description : "Haha")
print(insance1.description)

let insance2 = SomeClass(description : "FFF")
print(insance2.description)

var insance3 : SomeClass = SomeClass(description : "AaA")
print(insance3.description)

// ***** ***** ***** ***** ***** ***** //

class Base {
    
    func description () {
        print("Base.description")
    }
}

class Inherited : Base {
    
    override func description () {
        print("Inherited.description")
        super.description()
    }
}

let b1 = Inherited()
b1.description()

// ***** ***** ***** ***** ***** ***** //

enum SomeColors : Int {
    case Red
    case Greeb
    case Blue
}

var someColor : SomeColors = .Red
print("RAW: \(someColor.rawValue); \(someColor)")

// ***** ***** ***** ***** ***** ***** //

protocol AbsoluteProtocol {
    
    func Abs() -> Int
    mutating func AddOne()
    func ReturnAddOne() -> Int
}

extension Int : AbsoluteProtocol {
    
    func Abs() -> Int {
        return abs(self)
    }
    
    mutating func AddOne() {
        self += 1
    }
    
    func ReturnAddOne() -> Int {
        return self + 1;
    }
}

print((-1).Abs())
var iii = 42
iii.AddOne()
print(iii)

var ptrToAbs : AbsoluteProtocol = -55
print(ptrToAbs.Abs())
print(77.ReturnAddOne())

// ***** ***** ***** ***** ***** ***** //

print("Int \(sizeof(Int))")
print("Int16 \(sizeof(Int16))")
print("Int32 \(sizeof(Int32))")
print("Int64 \(sizeof(Int64)) \(Int.min) \(Int.max)")

var intPi : Int
intPi = Int(3.14)
print(intPi)

// ***** ***** ***** ***** ***** ***** //

func PRINT_MAX () {
    print("PRINT_MAX")
}

func PRINT_MAX (value : Int = 0) {
    print("PRINT_MAX(Int)")
}

PRINT_MAX(7)

// ***** ***** ***** ***** ***** ***** //

let v1 = (1, "One")
let v2 = (1, "Two")

if v1.0 == v2.0
{
    print("equal")
}
else
{
    print("not equal")
}

var v3 : (Int, String)
v3 = v2

print("0: \(v3.0), 1: \(v3.1)")

let (_, someString) = v1
print(someString)

// ***** ***** ***** ***** ***** ***** //

let someNumber = "123"
let convertedValue : Optional<Int> = Int(someNumber)
print(convertedValue)

struct SomeData {
    var id : Int?
}

var someData : SomeData?
print(someData)

someData = SomeData()
print(someData?.id)

someData?.id = 45
print(someData?.id)

var someData2 : SomeData?
//println(someData2!.id)

// ***** ***** ***** ***** ***** ***** //

// iOS, OSX, watchOS
if #available(OSX 10.12, *) {
    print("10.12 allowed")
}

// ***** ***** ***** ***** ***** ***** //

func Mult<T: IntegerArithmeticType>(first: T, second: T) -> T {
    return first * second;
}

print(Mult(2, second: 3))
print(Mult(55, second: 3))

// ***** ***** ***** ***** ***** ***** //

func PrintString(someString: String?) {
    print(someString)
}

PrintString("ABC")
PrintString(nil)

// ***** ***** ***** ***** ***** ***** //

func MinMax<T: Comparable>(array: [T]) -> (min: T, max: T)? {
    if array.isEmpty {
        return nil
    }
    
    return (array.minElement()!, array.maxElement()!)
}

let result: (Int, Int) = MinMax([-4, 10, -6, 0 ,99, -1, 100])!
print("min: \(result.0), max: \(result.1)")

let result2 = MinMax([-4, 10, -6, 0 ,99, -1, 100])!
print("min: \(result2.min), max: \(result2.max)")

let data: [Int] = []
if let result3 = MinMax(data) {
    print("min: \(result3.min), max: \(result3.max)")
}
else {
    print("Array is empty")
}

// ***** ***** ***** ***** ***** ***** //

func findElement<T: Comparable>(array: [T], _ element: T) -> Bool {
    return array.contains(element)
}

if findElement([1, 3, 55, -1, 0, -8], 55) {
    print("55 has been found")
}

// ***** ***** ***** ***** ***** ***** //

func Swap<T: Comparable>(inout first: T, inout _ second: T) {
    let temp = first
    first = second
    second = temp
}

var vv1 = 5
var vv2 = 51

Swap(&vv1, &vv2)

print("vv1 = \(vv1), vv2 = \(vv2)")

var vvv1 = "First"
var vvv2 = "Second"

Swap(&vvv1, &vvv2)

print("vvv1 = \(vvv1), vvv2 = \(vvv2)")

// ***** ***** ***** ***** ***** ***** //

var iii2 : Int = Int(2.5)

public protocol ArithmeticType : Comparable {

    @warn_unused_result
    func +(lhs: Self, rhs: Self) -> Self

    @warn_unused_result
    func -(lhs: Self, rhs: Self) -> Self

    @warn_unused_result
    func *(lhs: Self, rhs: Self) -> Self

    @warn_unused_result
    func /(lhs: Self, rhs: Self) -> Self
    
    associatedtype T
    static func Get2() -> T
}

extension Int : ArithmeticType {
    
    public typealias T = Int
    
    public static func Get2() -> Int {
        return 2
    }
}

extension Double : ArithmeticType {
    
    public typealias T = Double
    
    public static func Get2() -> Double {
        return 2.0
    }
}

//func MultBy2<T: ArithmeticType>(val: T) -> T {
//    
//    return T.Get2()
//}
//
//print("!!! INT: \(MultBy2(11))")
//print("!!! DOUBLE: \(MultBy2(11.99))")

// ***** ***** ***** ***** ***** ***** //

class SomeClass1 {
    var count: Int
    
    init(count: Int) {
        self.count = count
    }
}

func clearCount(data: SomeClass1) {
    data.count = 0
}

let someClass1 = SomeClass1(count: 55)
print("before: \(someClass1.count)")
clearCount(someClass1)
print("after: \(someClass1.count)")

// ***** ***** ***** ***** ***** ***** //

var someClass2 = SomeClass1(count : 11)
var someClass3 = SomeClass1(count : 11)
print(unsafeAddressOf(someClass2))
let address3 = unsafeAddressOf(someClass3)
print(unsafeAddressOf(someClass3))
print(address3)

// ***** ***** ***** ***** ***** ***** //

class PropertyTest {
    let constValue = 99
    
    lazy var varValue = 10
    
    var computedValue : Int {
        get {
            return constValue + varValue
        }
    }
    
    var overValue : Int = 0 {
        willSet {
            
        }
        
        didSet {
            
        }
    }
    
    func description() -> String {
        return String(computedValue)
    }
}

var propertyTest = PropertyTest()
propertyTest.varValue += 1;
print(propertyTest.description())

// ***** ***** ***** ***** ***** ***** //

class SomeMethods {
    
    static func Add(first: Int, _ second: Int) -> Int {
        return first + second
    }
    
    static func Add(first: Int, second: Int) -> Int {
        return first + second
    }
    
}

print(SomeMethods.Add(2, 3))
print(SomeMethods.Add(2, second: 3))

// ***** ***** ***** ***** ***** ***** //

@objc class SomeMethodsObjC : NSObject {
    @objc(addX:andY:) func addX(x: Int, andY y: Int) -> Int {
        return x + y
    }
}

var someObjCSelector : Selector = #selector(SomeMethodsObjC.addX(_:andY:))
print(someObjCSelector.description)

// ***** ***** ***** ***** ***** ***** //

class/*struct*/ MyArray {
    
    subscript (index : Int) -> Int {
        return index
    }
    
    subscript (string : String) -> Int {
        return string.characters.count
    }
    
}

var someArray = MyArray()
for i in 0..<10 {
    print("\(someArray[i])\t\(someArray[String(count : i, repeatedValue : Character("X"))])")
}

// ***** ***** ***** ***** ***** ***** //

var ddd : Range<Int> = 0..<10
print(ddd)

// ***** ***** ***** ***** ***** ***** //

class SomeClassX{

    var Description : String {
        get {
            return #file
        }
    }
    
    func description() -> String {
        return #file
    }
    
}

var someInstance = SomeClassX()
print(someInstance.description())

class SomeClassY : SomeClassX {

    override var Description : String {
        get {
            return super.Description + ":#" + String(#line)
        }
    }
    
    override func description() -> String {
        return super.description() + ":#" + String(#line)
    }

}

var someInstance1 = SomeClassY()
print(someInstance1.description())
print(someInstance1.Description)

var someInstance2 : SomeClassX = SomeClassY()

var someInstance3 = _reflect(someInstance2).valueType
print(someInstance3)

// ***** ***** ***** ***** ***** ***** //

class BaseClass {
    
    var name : String?
    
    init (name : String) {
        self.name = name
    }
    
}

class ChildClass : BaseClass {
    
    override init (name : String) {
        super.init(name : name)
    }
    
    init (age : Int) {
        super.init(name: "Some User " + String(age) + " years old")
    }
    
}

print(ChildClass(name : "Some User").name)
print(ChildClass(age : 45).name)

// ***** ***** ***** ***** ***** ***** //

class SomePerson {
    
    var name : String
    var age : UInt16
    
    init (name : String, age : UInt16) {
        self.name = name
        self.age = age
    }
    
    deinit {
//        print("Person \(self.description()) has been destroyed!")
        print("Person \(self.name) has been destroyed!")
    }
    
    lazy var description : () -> String = {
        [unowned self] in
        
        return (self.name + "; " + String(self.age) + " years")
    }
}

var somePerson : SomePerson? = SomePerson(name: "Smith", age: 42)
print(somePerson!.description())
somePerson = nil

// ***** ***** ***** ***** ***** ***** //

class ClassWithName {
    
    var name : String?
    
    func printName() {
        if name != nil {
            print(self.name!)
        }
        else {
            print("no name")
        }
    }
}

var someClassWithName = ClassWithName()
someClassWithName.printName()

someClassWithName.name = "Sr. Jonh Smith"
someClassWithName.printName()

// ***** ***** ***** ***** ***** ***** //

// Valid values: 1, 2, 4, 5
enum BadNumber : ErrorType {
    
    case LessThanOne
    case EqualToThree
    case GreatThanFive
    
}

func CheckValue(value : Int) throws -> Int {
    
    if (value < 1) {
        throw BadNumber.LessThanOne
    }
    else if (value == 3) {
        throw BadNumber.EqualToThree
    }
    else if (value > 5) {
        throw BadNumber.GreatThanFive
    }
    
    return value
}

let valuesToTest : [Int] = [0, 1, 2, 3, 4, 5, 6]

for currentValue in valuesToTest {
    
    let res = try? CheckValue(currentValue)
    if res != nil {
        print("\(currentValue) is valid")
    }
    else {
        print("\(currentValue) is invalid")
    }

}

// ***** ***** ***** ***** ***** ***** //

let someIntValue = 45

func Pow2<T : ArithmeticType>(value : T) -> T {
    return (value * value)
}

// ***** ***** ***** ***** ***** ***** //

extension Int {
    
    func repeatIt(task : () -> Void) {
        
        for _ in 0..<self {
            task()
        }
    }
    
}

7.repeatIt( { print("Hi") } )

// ***** ***** ***** ***** ***** ***** //

for _ in 0..<10 {
    print(arc4random())
}

// ***** ***** ***** ***** ***** ***** //

protocol IPowerOf2 {
    associatedtype T
    
    func pow2() -> T
}

//extension IPowerOf2 {
//    
//    func pow2<T : ArithmeticType>() -> T {
//        return self * self
//    }
//}

extension Int : IPowerOf2 {
//    typealias T = Int
    
    func pow2() -> Int {
        return (self * self)
    }
}

extension Double : IPowerOf2 {
//    typealias T = Double
    
    func pow2() -> Double {
        return (self * self)
    }
}

print(19.pow2())
print(19.13.pow2())

// ***** ***** ***** ***** ***** ***** //

@objc protocol ToString {
    optional func toString() -> String
}

class MyObjCClass : NSObject, ToString {
//    func toString() -> String {
//        return description
//    }
}

var objCInstance : ToString = MyObjCClass()
if let description = objCInstance.toString?() {
    print(description)
}

// ***** ***** ***** ***** ***** ***** //

//var maxIntValue = UInt8.max
//let resultingValue = try? maxIntValue + 1
//if resultingValue == nil {
//    print("overflow")
//}

// ***** ***** ***** ***** ***** ***** //

class SomeBaseClass {
    class func printClassName() {
        print("SomeBaseClass")
    }
}

class SomeSubClass : SomeBaseClass {
    class override func printClassName() {
        print("SomeSubClass")
    }
}

SomeBaseClass.printClassName()
SomeSubClass.printClassName()

var someInstance4 : SomeBaseClass = SomeSubClass()
someInstance4.dynamicType.printClassName()

let xxx = someInstance4.dynamicType
print(xxx.printClassName())

print(SomeBaseClass.self)
print(someInstance4.self)

// ***** ***** ***** ***** ***** ***** //

#if os(OSX) && arch(x86_64)
    print("On Mac OS X 64 bits")
#endif
