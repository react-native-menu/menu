package com.reactnativemenu

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.events.Event

class MenuOnOpenEvent(surfaceId: Int, viewId: Int, private val targetId: Int) : Event<MenuOnOpenEvent>(surfaceId, viewId) {
  override fun getEventName() = "onOpenMenu"

  override fun getEventData(): WritableMap? {
    return Arguments.createMap()
  }
} 