package com.reactnativemenu

import android.content.res.ColorStateList
import android.content.res.Resources
import android.graphics.Color
import android.graphics.Rect
import android.os.Build
import android.text.Spannable
import android.text.SpannableStringBuilder
import android.text.style.ForegroundColorSpan
import android.text.style.TextAppearanceSpan
import android.util.TypedValue
import android.view.*
import android.widget.PopupMenu
import com.facebook.react.bridge.*
import com.facebook.react.uimanager.UIManagerHelper
import com.facebook.react.views.view.ReactViewGroup
import java.lang.reflect.Field


class MenuView(private val mContext: ReactContext) : ReactViewGroup(mContext) {
  private lateinit var mActions: ReadableArray
  private var mIsAnchoredToRight = false
  private val mPopupMenu: PopupMenu = PopupMenu(context, this)
  private var mIsMenuDisplayed = false
  private var mIsOnLongPress = false
  private var mGestureDetector: GestureDetector
  private var mHitSlopRect: Rect? = null
    set(value) {
      field = value
      updateTouchDelegate()
    }

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

  fun show(){
    prepareMenu()
  }

  override fun addView(child: View?, index: Int, params: ViewGroup.LayoutParams?) {
    super.addView(child, index, params)
    // Make child views trigger menu when clicked via TalkBack
    child?.let {
      it.isClickable = true
      it.isFocusable = true
      it.setOnClickListener {
        performClick()
      }
    }
  }

  override fun onInterceptTouchEvent(ev: MotionEvent): Boolean {
    return true
  }

  override fun onTouchEvent(ev: MotionEvent): Boolean {
    mGestureDetector.onTouchEvent(ev)
    return true
  }

  override fun performClick(): Boolean {
    super.performClick()
    if (!mIsOnLongPress) {
      prepareMenu()
    }
    return true
  }

  override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
    super.onSizeChanged(w, h, oldw, oldh)
    updateTouchDelegate()
  }

  override fun onAttachedToWindow() {
    super.onAttachedToWindow()
    updateTouchDelegate()
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
    val menuState = config?.getString("state")

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
      if (disabled) {
        disableMenuItem(menuItem)
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

    // Handle menuState for checkable items
    when (menuState) {
      "on", "off" -> {
        menuItem.isCheckable = true
        menuItem.isChecked = menuState == "on"
      }
      else -> menuItem.isCheckable = false
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
            setOnPressAction(subMenuItem, subMenuConfig)
          }
        }
        i++
      }
    }
  }

  private fun disableMenuItem(menuItem: MenuItem) {
    val disabledColor = 0x77888888
    menuItem.isEnabled = false
    menuItem.title = getMenuItemTextWithColor(menuItem.title.toString(), disabledColor)
    // Drawables from the same resource share state, without mutate() the tint leaks to other items
    val icon = menuItem.icon?.mutate()
    if (icon != null) {
      icon.setTintList(ColorStateList.valueOf(disabledColor))
      menuItem.icon = icon
    }
  }

  private fun setOnPressAction(menuItem: MenuItem, config: ReadableMap?) {
    menuItem.setOnMenuItemClickListener {
      if (!it.hasSubMenu()) {
        mIsMenuDisplayed = false
        val dispatcher = UIManagerHelper.getEventDispatcherForReactTag(mContext, id)
        val surfaceId: Int = UIManagerHelper.getSurfaceId(this)
        dispatcher?.dispatchEvent(
          MenuOnPressActionEvent(surfaceId, id, config?.getString("id"), id)
        )
        true
      } else {
        false
      }
    }
  }

  private fun setInlineTitleStyle(menuItem: MenuItem) {
    val headerStyle = TypedValue()
    context.theme.resolveAttribute(android.R.attr.textAppearancePopupMenuHeader, headerStyle, true)
    val text = SpannableStringBuilder(menuItem.title)
    text.setSpan(
      TextAppearanceSpan(context, headerStyle.resourceId),
      0, text.length, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE or (1 shl Spannable.SPAN_PRIORITY_SHIFT)
    )
    menuItem.title = text
    menuItem.isEnabled = false
  }

  private fun addInlineSubactions(
    groupId: Int,
    order: Int,
    config: ReadableMap,
    subactions: ReadableArray
  ): Boolean {
    val title = config.getString("title").orEmpty()
    val titleItem = mPopupMenu.menu.add(groupId, Menu.NONE, order, title)
    prepareMenuItem(titleItem, config)
    if (!titleItem.isVisible) {
      return false
    }

    val disabled = !titleItem.isEnabled
    if (title.isNotEmpty()) {
      setInlineTitleStyle(titleItem)
    }
    var hasVisibleItems = false
    for (i in 0 until subactions.size()) {
      if (!subactions.isNull(i)) {
        val subaction = subactions.getMap(i)
        val menuItem = mPopupMenu.menu.add(groupId, Menu.NONE, order, subaction?.getString("title"))
        prepareMenuItem(menuItem, subaction)
        if (disabled) {
          disableMenuItem(menuItem)
        }
        setOnPressAction(menuItem, subaction)
        hasVisibleItems = hasVisibleItems || menuItem.isVisible
      }
    }
    titleItem.isVisible = hasVisibleItems && title.isNotEmpty()
    return hasVisibleItems
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
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
        mPopupMenu.menu.setGroupDividerEnabled(true)
      }
      var groupId = Menu.NONE
      var i = 0
      while (i < getActionsCount) {
        if (!mActions.isNull(i)) {
          val item = mActions.getMap(i)
          val subactions = when (item != null && item.hasKey("subactions") && !item.isNull("subactions")) {
            true -> item.getArray("subactions")
            else -> null
          }
          val displayInline = when (item != null && item.hasKey("displayInline") && !item.isNull("displayInline")) {
            true -> item.getBoolean("displayInline")
            else -> false
          }
          if (item != null && subactions != null && subactions.size() > 0 && displayInline) {
            // Dividers are drawn between groups, so the actions after the inline ones need a new group too
            if (addInlineSubactions(groupId + 1, i, item, subactions)) {
              groupId += 2
            }
          } else {
            val menuItem = when (subactions != null) {
              true -> mPopupMenu.menu.addSubMenu(groupId, Menu.NONE, i, item?.getString("title")).item
              else -> mPopupMenu.menu.add(groupId, Menu.NONE, i, item?.getString("title"))
            }
            prepareMenuItem(menuItem, item)
            setOnPressAction(menuItem, item)
          }
        }
        i++
      }
      mPopupMenu.setOnDismissListener {
        mIsMenuDisplayed = false
        val dispatcher = UIManagerHelper.getEventDispatcherForReactTag(mContext, id)
        val surfaceId: Int = UIManagerHelper.getSurfaceId(this)
        dispatcher?.dispatchEvent(MenuOnCloseEvent(surfaceId, id, id))
      }
      mIsMenuDisplayed = true
      val dispatcher = UIManagerHelper.getEventDispatcherForReactTag(mContext, id)
      val surfaceId: Int = UIManagerHelper.getSurfaceId(this)
      dispatcher?.dispatchEvent(MenuOnOpenEvent(surfaceId, id, id))
      mPopupMenu.show()
    }
  }

  private fun updateTouchDelegate() {
    post {
      val hitRect = Rect()
      getHitRect(hitRect)

      mHitSlopRect?.let {
        hitRect.left -= it.left
        hitRect.top -= it.top
        hitRect.right += it.right
        hitRect.bottom += it.bottom
      }

      (parent as? ViewGroup)?.let {
        it.touchDelegate = TouchDelegate(hitRect, this)
      }
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
