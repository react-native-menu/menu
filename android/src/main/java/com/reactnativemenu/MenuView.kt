package com.reactnativemenu

import android.content.res.ColorStateList
import android.content.res.Resources
import android.graphics.Color
import android.os.Build
import android.text.Spannable
import android.text.SpannableStringBuilder
import android.text.style.ForegroundColorSpan
import android.view.*
import android.widget.PopupMenu
import com.facebook.react.bridge.*
import com.facebook.react.uimanager.events.RCTEventEmitter
import com.facebook.react.views.view.ReactViewGroup
import java.lang.reflect.Field


class MenuView(private val mContext: ReactContext): ReactViewGroup(mContext) {
  private lateinit var mActions: ReadableArray
  private var mIsAnchoredToRight = false
  private val mPopupMenu: PopupMenu = PopupMenu(context, this)
  private var mIsMenuDisplayed = false
  private var mIsOnLongPress = false
  private var mGestureDetector: GestureDetector

  init {
    mGestureDetector = GestureDetector(mContext, object : GestureDetector.SimpleOnGestureListener() {
      override fun onLongPress(e: MotionEvent) {
        if (!mIsOnLongPress) {
          return
        }
        prepareMenu()
      }

      override fun onSingleTapUp(e: MotionEvent): Boolean {
        if (!mIsOnLongPress) {
          prepareMenu()
        }
        return true
      }
    })
  }

  override fun onInterceptTouchEvent(ev: MotionEvent?): Boolean {
    return true
  }

  override fun onTouchEvent(ev: MotionEvent): Boolean {
    mGestureDetector.onTouchEvent(ev)
    return true
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

  fun setIsOpenOnLongPress(isLongPress: Boolean) {
    mIsOnLongPress = isLongPress
  }

  private val getActionsCount: Int
    get() = mActions.size()

  private fun prepareMenuItem(menuItem: MenuItem, config: ReadableMap?) {
    val titleColor = when (config != null && config.hasKey("titleColor") && !config.isNull("titleColor")) {
      true -> config.getInt("titleColor")
      else -> null
    }
    val imageName = when (config != null && config.hasKey("image") && !config.isNull("image")) {
      true -> config.getString("image")
      else -> null
    }
    val imageColor = when (config != null && config.hasKey("imageColor") && !config.isNull("imageColor")) {
      true -> config.getInt("imageColor")
      else -> null
    }
    val attributes = when (config != null && config.hasKey("attributes") && !config.isNull(("attributes"))) {
      true -> config.getMap("attributes")
      else -> null
    }
    val subactions = when (config != null && config.hasKey("subactions") && !config.isNull(("subactions"))) {
      true -> config.getArray("subactions")
      else -> null
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
      val disabled = when (attributes.hasKey("disabled") && !attributes.isNull("disabled")) {
        true -> attributes.getBoolean("disabled")
        else -> false
      }
      menuItem.isEnabled = !disabled
      if (!menuItem.isEnabled) {
        val disabledColor = 0x77888888
        menuItem.title = getMenuItemTextWithColor(menuItem.title.toString(), disabledColor)
        if (imageName != null) {
          val icon = menuItem.icon
          icon?.setTintList(ColorStateList.valueOf(disabledColor))
          menuItem.icon = icon
        }
      }

      // actions.attributes.hidden
      val hidden = when (attributes.hasKey("hidden") && !attributes.isNull("hidden")) {
        true -> attributes.getBoolean("hidden")
        else -> false
      }
      menuItem.isVisible = !hidden

      // actions.attributes.destructive
      val destructive = when (attributes.hasKey("destructive") && !attributes.isNull("destructive")) {
        true -> attributes.getBoolean("destructive")
        else -> false
      }
      if (destructive) {
        menuItem.title = getMenuItemTextWithColor(menuItem.title.toString(), Color.RED)
        if (imageName != null) {
          val icon = menuItem.icon
          icon?.setTintList(ColorStateList.valueOf(Color.RED))
          menuItem.icon = icon
        }
      }
    }

    // On Android SubMenu cannot contain another SubMenu, so even if there are subactions provided
    // we are checking if item has submenu (which will occur only for 1 lvl nesting)
    if (subactions != null && menuItem.hasSubMenu()) {
      var i = 0
      val subactionsCount = subactions.size()
      while (i < subactionsCount) {
        if (!subactions.isNull(i)) {
          val subMenuConfig = subactions.getMap(i)
          val subMenuItem = menuItem.subMenu?.add(Menu.NONE, Menu.NONE, i, subMenuConfig?.getString("title"))
          if (subMenuItem != null) {
            prepareMenuItem(subMenuItem, subMenuConfig)
            subMenuItem.setOnMenuItemClickListener {
              if (!it.hasSubMenu()) {
                mIsMenuDisplayed = false
                val args: WritableMap = Arguments.createMap()
                if (!subactions.isNull(it.order)) {
                  val selectedItem = subactions.getMap(it.order)
                  args.putString("event", selectedItem?.getString("id"))
                  args.putString("target", "$id")
                  mContext
                    .getJSModule(RCTEventEmitter::class.java)
                    .receiveEvent(id, "onPressAction", args)
                }
                true
              } else {
                false
              }
            }
          }
        }
        i++
      }
    }
  }

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
        if (!mActions.isNull(i)) {
          val item = mActions.getMap(i)
          val menuItem = when (item != null && item.hasKey("subactions") && !item.isNull("subactions")) {
            true -> mPopupMenu.menu.addSubMenu(Menu.NONE, Menu.NONE, i, item.getString("title")).item
            else -> mPopupMenu.menu.add(Menu.NONE, Menu.NONE, i, item?.getString("title"))
          }
          prepareMenuItem(menuItem, item)
          menuItem.setOnMenuItemClickListener {
            if (!it.hasSubMenu()) {
              mIsMenuDisplayed = false
              val args: WritableMap = Arguments.createMap()
              if (!mActions.isNull(it.order)) {
                val selectedItem = mActions.getMap(it.order)
                args.putString("event", selectedItem?.getString("id"))
                args.putString("target", "$id")
                mContext
                  .getJSModule(RCTEventEmitter::class.java)
                  .receiveEvent(id, "onPressAction", args)
              }
              true
            } else {
              false
            }
          }
        }
        i++
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
