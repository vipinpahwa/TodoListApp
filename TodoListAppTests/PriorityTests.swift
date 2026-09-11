//
//  PriorityTests.swift
//  TodoListAppTests
//
//  Created by Vipin Pahwa on 11/09/26.
//

import Testing
@testable import TodoListApp

struct PriorityTests {

    @Test func priorityOrderingIsLowLessThanMediumLessThanHigh() {
        #expect(Priority.low < Priority.medium)
        #expect(Priority.medium < Priority.high)
        #expect(Priority.low < Priority.high)
    }

    @Test func allCasesContainsExactlyThreeLevelsInAscendingOrder() {
        #expect(Priority.allCases == [.low, .medium, .high])
    }

    @Test func rawValueRoundTripsThroughInitializer() {
        for priority in Priority.allCases {
            #expect(Priority(rawValue: priority.rawValue) == priority)
        }
    }
}
