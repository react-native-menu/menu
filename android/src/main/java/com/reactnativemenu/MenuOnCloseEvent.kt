package com.reactnativemenu

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.events.Event

class MenuOnCloseEvent(surfaceId: Int, viewId: Int, private val targetId: Int) : Event<MenuOnCloseEvent>(surfaceId, viewId) {
  override fun getEventName() = "onCloseMenu"

  override fun getEventData(): WritableMap? {
    return Arguments.createMap()
  }
} 