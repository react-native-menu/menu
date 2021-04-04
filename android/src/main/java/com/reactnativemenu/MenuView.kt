package com.reactnativemenu

import android.content.res.ColorStateList
import android.content.res.Resources
import android.graphics.Color
import android.os.Build
import android.text.Spannable
import android.text.SpannableStringBuilder
import android.text.style.ForegroundColorSpan
import android.view.Gravity
import android.view.Menu
import android.view.MotionEvent
import android.widget.PopupMenu
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.events.RCTEventEmitter
import com.facebook.react.views.view.ReactViewGroup
import java.lang.reflect.Field


class MenuView(private val mContext: ReactContext): ReactViewGroup(mContext) {
  private lateinit var mActions: ReadableArray
  private var mIsAnchoredToRight = false
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
    mActions = actions
  }

  fun setIsAnchoredToRight(isAnchoredToRight: Boolean) {
    if (mIsAnchoredToRight == isAnchoredToRight) {
      return
    }
    mIsAnchoredToRight = isAnchoredToRight
  }

  private val getActionsCount: Int
    get() = mActions.size()

  private fun prepareMenu() {
    if (getActionsCount > 0) {
      mPopupMenu.menu.clear()
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        mPopupMenu.gravity = when (mIsAnchoredToRight) {
          true -> Gravity.RIGHT
          false -> Gravity.LEFT
        }
      }
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        mPopupMenu.setForceShowIcon(true)
      }
      var i = 0
      while (i < getActionsCount) {
        val item = mActions.getMap(i)
        val menuItem = mPopupMenu.menu.add(Menu.NONE, Menu.NONE, i, item?.getString("title"))

        val titleColor = when (item?.hasKey("titleColor")) {
          true -> item?.getInt("titleColor")
          false -> null
          null -> null
        }
        val imageName = when (item?.hasKey("image")) {
          true -> item?.getString("image")
          false -> null
          null -> null
        }
        val imageColor = when (item?.hasKey("imageColor")) {
          true -> item?.getInt("imageColor")
          false -> null
          null -> null
        }
        val attributes = when (item?.hasKey("attributes")) {
          true -> item?.getMap("attributes")
          false -> null
          null -> null
        }

        if (titleColor != null) {
          menuItem.title = getMenuItemTextWithColor(menuItem.title.toString(), titleColor)
        }

        if (imageName != null) {
          val resourceId: Int = getDrawableIdWithName(imageName)
          if (resourceId != 0) {
            val icon = resources.getDrawable(resourceId, context.theme)
            if (imageColor != null) {
              icon.setTintList(ColorStateList.valueOf(imageColor))
            }
            menuItem.icon = icon
          }
        }

        if (attributes != null) {
          // actions.attributes.disabled
          val disabled = when (attributes.hasKey("disabled")) {
            true -> attributes.getBoolean("disabled")
            false -> false
          }
          menuItem.isEnabled = !disabled
          if (!menuItem.isEnabled) {
            val disabledColor = 0x77888888
            menuItem.title = getMenuItemTextWithColor(menuItem.title.toString(), disabledColor)
            if (imageName != null) {
              val icon = menuItem.icon
              icon.setTintList(ColorStateList.valueOf(disabledColor))
              menuItem.icon = icon
            }
          }

          // actions.attributes.hidden
          val hidden = when (attributes.hasKey("hidden")) {
            true -> attributes.getBoolean("hidden")
            false -> false
          }
          menuItem.isVisible = !hidden

          // actions.attributes.destructive
          val destructive = when (attributes.hasKey("destructive")) {
            true -> attributes.getBoolean("destructive")
            false -> false
          }
          if (destructive) {
            menuItem.title = getMenuItemTextWithColor(menuItem.title.toString(), Color.RED)
            if (imageName != null) {
              val icon = menuItem.icon
              icon.setTintList(ColorStateList.valueOf(Color.RED))
              menuItem.icon = icon
            }
          }
        }
        i++
      }
      mPopupMenu.setOnMenuItemClickListener { it ->
        mIsMenuDisplayed = false
        var args: WritableMap = Arguments.createMap()
        val selectedItem = mActions.getMap(it.order)
        args.putString("event", selectedItem?.getString("id"))
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

  private fun getDrawableIdWithName(name: String): Int {
    val appResources: Resources = context.resources
    var resourceId = appResources.getIdentifier(name, "drawable", context.packageName)
    if (resourceId == 0) {
      // If drawable is not present in app's resources, check system's resources
      resourceId = getResId(name, android.R.drawable::class.java)
    }
    return resourceId
  }

  private fun getResId(resName: String?, c: Class<*>): Int {
    return try {
      val idField: Field = c.getDeclaredField(resName!!)
      idField.getInt(idField)
    } catch (e: Exception) {
      e.printStackTrace()
      0
    }
  }

  private fun getMenuItemTextWithColor(text: String, color: Int): SpannableStringBuilder {
    val textWithColor = SpannableStringBuilder()
    textWithColor.append(text)
    textWithColor.setSpan(ForegroundColorSpan(color),
      0, text.length, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
    return textWithColor
  }
}
