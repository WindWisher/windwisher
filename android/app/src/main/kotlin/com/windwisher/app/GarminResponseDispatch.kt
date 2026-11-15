package com.windwisher.app

internal fun dispatchGarminResponses(
    messages: List<*>,
    requestId: String,
    isActive: () -> Boolean,
    handle: (Map<*, *>) -> Unit,
) {
    for (message in messages) {
        // A completion or failure must stop dispatch into the old transfer.
        if (!isActive()) break
        val response = message as? Map<*, *> ?: continue
        if (response["requestId"] == requestId) handle(response)
    }
}
