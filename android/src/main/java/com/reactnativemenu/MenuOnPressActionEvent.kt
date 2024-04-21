package com.reactnativemenu

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.events.Event

class MenuOnPressActionEvent(
  surfaceId: Int,
  viewTag: Int,
  private val event: String?,
  private val target: Int
) : Event<MenuOnPressActionEvent>(surfaceId, viewTag) {

  override fun getEventName(): String = "onPressAction"
  override fun getEventData(): WritableMap = Arguments.createMap().apply {
    if (event != null) {
      putString("event", event)
    }
    putString("target", target.toString())
  }
}
