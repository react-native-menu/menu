package com.reactnativemenu

import com.facebook.react.views.view.ReactViewGroup

class MenuViewManager : MenuViewManagerBase() {

  override fun setBorderColor(view: ReactViewGroup, index: Int, color: Int?) {
    view.setBorderColor(index, color)
  }
}
