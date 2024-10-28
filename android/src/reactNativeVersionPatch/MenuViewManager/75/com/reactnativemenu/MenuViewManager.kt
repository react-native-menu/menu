package com.reactnativemenu

import com.facebook.react.views.view.ReactViewGroup
import com.facebook.yoga.YogaConstants
import com.facebook.react.uimanager.ThemedReactContext

class MenuViewManager : MenuViewManagerBase() {
  override fun createViewInstance(reactContext: ThemedReactContext): MenuView {
    return MenuView(reactContext)
  }

  override fun setBorderColor(view: ReactViewGroup, index: Int, color: Int?) {
    val rgbComponent = color?.let { (it and 0x00FFFFFF).toFloat() } ?: YogaConstants.UNDEFINED
    val alphaComponent = color?.let { (it ushr 24).toFloat() } ?: YogaConstants.UNDEFINED
    view.setBorderColor(SPACING_TYPES[index], rgbComponent, alphaComponent)
  }
}
