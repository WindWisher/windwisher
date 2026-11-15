package com.windwisher.app

import org.junit.Assert.assertEquals
import org.junit.Test

class GarminResponseDispatchTest {
    private fun response(index: Int, request: String = "current") =
        mapOf("requestId" to request, "lineIndex" to index)

    @Test fun processesEveryMatchingResponseInOrder() {
        val indices = mutableListOf<Any?>()
        dispatchGarminResponses(
            listOf(null, "invalid", response(9, "stale"), response(0), response(1)),
            "current", { true }, { indices.add(it["lineIndex"]) },
        )
        assertEquals(listOf(0, 1), indices)
    }

    @Test fun completionOrFailureStopsOldTransferDispatch() {
        var active = true
        var count = 0
        dispatchGarminResponses(
            listOf(response(0), response(1)), "current", { active },
            { count++; active = false },
        )
        assertEquals(1, count)
    }

    @Test fun inactiveTransferDoesNotConsumeResponses() {
        var count = 0
        dispatchGarminResponses(listOf(response(0)), "current", { false }, { count++ })
        assertEquals(0, count)
    }
}
