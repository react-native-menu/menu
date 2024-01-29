package com.reactnativemenu

import android.view.View

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.viewmanagers.MenuViewManagerDelegate
import com.facebook.react.viewmanagers.MenuViewManagerInterface

abstract class MenuViewManagerSpec<T : View> : SimpleViewManager<T>(), MenuViewManagerInterface<T> {
  private val mDelegate: ViewManagerDelegate<T>

  init {
    mDelegate = MenuViewManagerDelegate(this)
  }

  override fun getDelegate(): ViewManagerDelegate<T>? {
    return mDelegate
  }
}
