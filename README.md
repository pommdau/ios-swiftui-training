## 0. Swift言語の基本
- このセッションでは以降のセッションを円滑に進められるように最低限必要なSwift言語周りの知識について説明します
- 時間のある方は [公式のガイド](https://docs.swift.org/swift-book/LanguageGuide/TheBasics.html) を一読することをお勧めします

### クロージャ
- クロージャとは簡単にいうと受け渡しが可能な関数です
- 以下のような定義になります

```swift
{ (parameters) -> return type in
    statements
}
```

- Swiftではクロージャを受け取る関数が数多く用意されています、その一つの例が [sorted(by:)](https://developer.apple.com/documentation/swift/array/2296815-sorted) です
- 例えば、名前の配列を名前が短い順に並び替える処理は以下のようになります

```swift
let names = ["Chris", "Alex", "Ewa", "Barry", "Daniella"]
var sortedNames = names.sorted(by: { (s1: String, s2: String) -> Bool in
    return s1 > s2
})

// 型推論
sortedNames = names.sorted(by: { s1, s2 in s1 > s2 })

// $による引数参照
sortedNames = names.sorted(by: { $0 > $1 } )

// 引数の最後がクロージャの場合、省略可能
sortedNames = names.sorted { $0 > $1 }
```


#### Associated Values
- 例えば、成功か失敗の状態を表すStateというenumを考え、失敗時のエラーを値として関連付けたいと考えます
- その場合のenumの定義は以下のようになります

```swift
enum State {
  case success
  case failure(Error)
}
```

- Switch文を用いてパターンマッチでエラーの値を取得します

```swift
struct DummyError: Error {}
let state: State = .failure(DummyError())
switch state {
case .success: print("Success")
case let .failure(error): print("Failure: \(error)")
}
```

### 構造体とクラス
- 構造体(struct)とクラス(class)はデータをモデリングする上で必ず必要となってくる機能です
- どちらもpropertyを定義して値を保持したり、メソッドを定義して処理を実行したりできます

```swift
struct SomeStructure {
    // structure definition goes here
}
class SomeClass {
    // class definition goes here
}
```

- Swiftでは基本的にはstructを使用することが推奨されています
- classは、保持するデータの一意性を担保する必要がある場合、あるいはObjective-Cとの互換性が必要な場合に使用するようにしてください
  - 参考: https://developer.apple.com/documentation/swift/choosing_between_structures_and_classes

### 値型と参照型
- クラスとクロージャ以外で定義された型はすべて **値型** です、値の受け渡しはすべてコピーした上で行われます

```swift
struct SomeStructure {
  var value: Int
}

var a = SomeStructure(value: 1)
var b = a

b.value = 2

print("a: \(a.value)")
// a: 1
print("b: \(b.value)")
// b: 2
```

- クラスとクロージャは **参照型** です、値の受け渡しは参照で行われるため、例え異なる変数に格納されていても参照されるインスタンスは同じになります

```swift
class SomeClass {
  var value: Int
  
  init(value: Int) {
    self.value = value
  }
}

var a = SomeClass(value: 1)
var b = a

b.value = 2

print("a: \(a.value)")
// a: 2
print("b: \(b.value)")
// b: 2
```

- Swiftは値型中心の言語です、値がどこからともなく変更される可能性のある参照型よりも値型を使って安全にコーディングしていくことが良いとされています

#### ARC
- Swiftのメモリは `ARC(Automatic Reference Counting)` によって管理されています
- 新しいインスタンスを初期化する際に、ARCはそのインスタンスの型や保有するプロパティに応じたメモリを確保します
- ARCはそれぞれのインスタンスがいくつのプロパティや変数, 定数から参照されているかをカウントし、その参照カウントがゼロにならない限りメモリは解放しないようになっています
- 例えば以下のコードをみてください

```swift
class Person {
    let name: String

    init(name: String) {
        self.name = name
    }

    deinit {
        print("Person \(name) is being deinitialized")
    }
}

class Apartment {
    let person: Person

    init(person: Person) {
        self.person = person
    }

    deinit {
        print("Apartment is being deinitialized")
    }
}

var person: Person? = Person(name: "Tom")
// Personの参照カウント: 1
var apartment: Apartment? = Apartment(person: person!)
// Apartmentの参照カウント: 1
// Personの参照カウント: 2

person = nil
// Personの参照カウント: 1
apartment = nil
// Apartmentの参照カウント: 0
// Prints "Apartment is being deinitialized"
// Personの参照カウント: 0
// Prints "Person Tom is being deinitialized"
```

- `deinit` 時にprintすることでメモリが解放されるタイミングがわかるようになっています、コメントに書いた通りに参照カウントが推移し、0になるタイミングでそれぞれメモリが解放されてprintされていることが確認できます
- では、以下のように `Person` のpropertyに `Apartment` を持たせてみるとどうなるでしょうか

```swift
class Person {
    let name: String
    var apartment: Apartment?

    init(name: String) {
        self.name = name
    }

    deinit {
        print("Person \(name) is being deinitialized")
    }
}

class Apartment {
    let person: Person

    init(person: Person) {
        self.person = person
        person.apartment = self
    }

    deinit {
        print("Apartment is being deinitialized")
    }
}

var person: Person? = Person(name: "Tom")
// Personの参照カウント: 1
var apartment: Apartment? = Apartment(person: person!)
// Apartmentの参照カウント: 2
// Personの参照カウント: 2

person = nil
// Personの参照カウント: 1
apartment = nil
// Apartmentの参照カウント: 1
```

- `Person` と `Apartment` がお互いに参照して循環参照が完成してしまいました、これでは永遠にメモリが解放されることはありません
- これを解決するには **弱参照 (weak参照)** を用います

```diff
class Person {
    let name: String
+   weak var apartment: Apartment?

    init(name: String) {
        self.name = name
    }

    deinit {
        print("Person \(name) is being deinitialized")
    }
}
```

- 弱参照は参照カウントに加算されません、よって循環参照を防ぎメモリリークを解消してくれます

### Generics
- Genericsを扱うことで、任意の型を扱うI/Fを定義できます
- 例えば、データの読み込み状態を表現するデータ構造を作りたいとします
- 状態にはすべてで4つあり、それぞれが以下のようなステータスとなります
  - idle: まだデータを取得しにいっていない
  - loading: 読み込み中
  - loaded: 読み込み完了、読み込まれたデータを保持
  - failed: 読み込み失敗、遭遇したエラーを保持

- これをGenericsで実装するならば以下のようになります

```swift
enum Stateful<Value> {
    case idle
    case loading
    case failed(Error)
    case loaded(Value)
}

var data: Stateful<[String]> = .idle
// データ取得中
data = .loading
// データ取得失敗
data = .failed(DummyError())
// データ取得完了
data = .loaded(["data1", "data2", "data3"])

// 他の型でも利用可能
var anotherData: Stateful<[Int]> = .loaded([1, 2, 3])
```

## Next
[1. SwiftUIの基本 -前準備-](https://github.com/mixigroup/ios-swiftui-training/tree/session-1-prepare)
