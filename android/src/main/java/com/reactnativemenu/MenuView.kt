package com.reactnativemenu

import android.view.Menu
import android.view.MotionEvent
import android.widget.PopupMenu
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.events.RCTEventEmitter
import com.facebook.react.views.view.ReactViewGroup

class MenuView(context: ReactContext): ReactViewGroup(context) {
  private lateinit var mActions: ReadableArray
  private var mContext: ReactContext = context as ReactContext
  private val mPopupMenu: PopupMenu = PopupMenu(context, this)
  private var mIsMenuDisplayed = false

  override fun onInterceptTouchEvent(ev: MotionEvent?): Boolean {
    return true
  }

  override fun onTouchEvent(ev: MotionEvent?): Boolean {
    prepareMenu()
    return false
  }

  override fun onDetachedFromWindow() {
    super.onDetachedFromWindow()
    if (mIsMenuDisplayed) {
      mPopupMenu.dismiss()
    }
  }

  fun setActions(actions: ReadableArray) {
    this.mActions = actions
  }

  private val getActionsCount: Int
    get() = mActions.size()

  private fun prepareMenu() {
    if (getActionsCount > 0) {
      var i = 0
      mPopupMenu.menu.clear()
      while (i < getActionsCount) {
        val item = mActions.getMap(i)
        mPopupMenu.menu.add(Menu.NONE, Menu.NONE, i, item.getString("title"))
        i++
      }
      mPopupMenu.setOnMenuItemClickListener { it ->
        mIsMenuDisplayed = false
        var args: WritableMap = Arguments.createMap()
        val selectedItem = mActions.getMap(it.order)
        args.putString("event", selectedItem.getString("id"))
        args.putString("target", "$id")
        mContext
          .getJSModule(RCTEventEmitter::class.java)
          .receiveEvent(id, "onPressAction", args)
        true
      }
      mPopupMenu.setOnDismissListener {
        mIsMenuDisplayed = false
      }
      mIsMenuDisplayed = true
      mPopupMenu.show()
    }
  }
}
