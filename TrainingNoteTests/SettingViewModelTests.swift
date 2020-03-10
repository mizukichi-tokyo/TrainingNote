//
//  SettingViewModelTests.swift
//  TrainingNoteTests
//
//  Created by Mizuki Kubota on 2020/03/10.
//  Copyright © 2020 MizukiKubota. All rights reserved.
//
import XCTest
import RxSwift
import RxCocoa
import RxTest

@testable import GymNote

class SettingViewModelTests: XCTestCase {
    var viewModel: SettingViewModel!
    let scheduler = TestScheduler(initialClock: 0)

    final class MockSettingModel: SettingModelType, SettingModelOutput {
        struct Dependency {}
        var outputs: SettingModelOutput?

        init(with dependency: Dependency) {
            self.outputs = self
        }
        func setup(input: SettingModelInput) {
            return
        }

        var exerciseObservable: Observable<[String]?> {
            return Observable.just(SettingViewModelTests.mockExerciseData())
        }
    }

    static let mockExerciseData = { () -> [String]? in
        return [R.string.appDelegate.defaultsExercise1(),
                R.string.appDelegate.defaultsExercise2()]
    }

    override func setUp() {
        super.setUp()

        let dependency = MockSettingModel(with: MockSettingModel.Dependency.init())
        viewModel = SettingViewModel(with: dependency)

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testLordRecord() {
        let disposeBag = DisposeBag()
        let sectionModels = scheduler.createObserver([SectionOfExerciseData].self)

        viewModel.outputs?.sectionDataDriver
            .drive(sectionModels)
            .disposed(by: disposeBag)

        scheduler.start()

        // 想定されるテスト結果の定義
        let items = [R.string.appDelegate.defaultsExercise1(),
                     R.string.appDelegate.defaultsExercise2()]
        var mock: [ExerciseData] = []
        for item in items {
            mock.append(ExerciseData(exerciseName: item))
        }
        let expectedItems = [Recorded.next(0, mock)]
        print("expectedItems.first!.value.element![0]: ", expectedItems.first!.value.element![0])

        // 実際の実行結果
        let element = sectionModels.events.first!.value.element

        print("element!.first!.items[0]: ", element!.first!.items[0])
        // 想定結果と実行結果の比較
        XCTAssertEqual(element!.first!.items[0], expectedItems.first!.value.element![0])
        XCTAssertEqual(element!.first!.items[1], expectedItems.first!.value.element![1])
    }

}

extension ExerciseData: Equatable {
    public static func==(lhs: ExerciseData, rhs: ExerciseData) -> Bool {
        return lhs.exerciseName == rhs.exerciseName
    }
}
