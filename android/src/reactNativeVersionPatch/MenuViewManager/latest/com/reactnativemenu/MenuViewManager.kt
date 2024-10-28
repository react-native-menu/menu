package com.reactnativemenu

import com.facebook.react.views.view.ReactViewGroup
import com.facebook.react.uimanager.ThemedReactContext

class MenuViewManager : MenuViewManagerBase() {
  override fun createViewInstance(reactContext: ThemedReactContext): MenuView {
    return MenuView(reactContext)
  }

  override fun setBorderColor(view: ReactViewGroup, index: Int, color: Int?) {
    view.setBorderColor(index, color)
  }
}
