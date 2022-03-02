import Cocoa

// Associated Values

enum State {
  case success
  case failure(Error)
}

struct DummyError: Error {
}
let state: State = .failure(DummyError())

switch state {
case .success: print("Success")
case let .failure(error): print("Failure: \(error)")
}

// Generics

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
