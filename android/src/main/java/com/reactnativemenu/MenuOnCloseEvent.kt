package com.reactnativemenu

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.events.Event

class MenuOnCloseEvent(surfaceId: Int, viewId: Int, private val targetId: Int) : Event<MenuOnCloseEvent>(surfaceId, viewId) {
  override fun getEventName() = "onMenuClose"

  override fun getEventData(): WritableMap? {
    val eventData = Arguments.createMap()
    eventData.putInt("target", targetId)
    return eventData
  }
} 