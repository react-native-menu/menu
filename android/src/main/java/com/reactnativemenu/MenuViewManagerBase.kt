package com.reactnativemenu

import android.annotation.TargetApi
import android.graphics.Rect
import android.os.Build
import android.view.View
import androidx.annotation.NonNull
import androidx.annotation.Nullable
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.common.MapBuilder
import com.facebook.react.uimanager.*
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.uimanager.annotations.ReactPropGroup
import com.facebook.react.views.view.ReactClippingViewManager
import com.facebook.react.views.view.ReactDrawableHelper
import com.facebook.react.views.view.ReactViewGroup
import com.facebook.yoga.YogaConstants

abstract class MenuViewManagerBase : ReactClippingViewManager<MenuView>() {
  override fun getName() = "MenuView"

  @ReactProp(name = "actions")
  fun setActions(view: MenuView, actions: ReadableArray) {
    view.setActions(actions)
  }

  @ReactProp(name = "isAnchoredToRight", defaultBoolean = false)
  fun setIsAnchoredToRight(view: MenuView, isAnchoredToRight: Boolean) {
    view.setIsAnchoredToRight(isAnchoredToRight)
  }

  @ReactProp(name = "shouldOpenOnLongPress", defaultBoolean = false)
  fun setIsOnLongPress(view: MenuView, isOnLongPress: Boolean) {
    view.setIsOpenOnLongPress(isOnLongPress)
  }

  override fun getExportedCustomDirectEventTypeConstants(): MutableMap<String, Any> {
    return MapBuilder.of(
            "onPressAction",
            MapBuilder.of("registrationName", "onPressAction"),
            "onCloseMenu",
            MapBuilder.of("registrationName", "onCloseMenu"),
            "onOpenMenu",
            MapBuilder.of("registrationName", "onOpenMenu")
    )
  }

  // ---- Rest of regular view props ----//
  @ReactProp(name = "accessible")
  fun setAccessible(view: MenuView, accessible: Boolean) {
    view.isFocusable = accessible
  }

  @ReactProp(name = "hasTVPreferredFocus")
  fun setTVPreferredFocus(view: ReactViewGroup, hasTVPreferredFocus: Boolean) {
    if (hasTVPreferredFocus) {
      view.isFocusable = true
      view.isFocusableInTouchMode = true
      view.requestFocus()
    }
  }

  @ReactProp(name = "nextFocusDown", defaultInt = View.NO_ID)
  fun nextFocusDown(view: ReactViewGroup, viewId: Int) {
    view.nextFocusDownId = viewId
  }

  @ReactProp(name = "nextFocusForward", defaultInt = View.NO_ID)
  fun nextFocusForward(view: ReactViewGroup, viewId: Int) {
    view.nextFocusForwardId = viewId
  }

  @ReactProp(name = "nextFocusLeft", defaultInt = View.NO_ID)
  fun nextFocusLeft(view: ReactViewGroup, viewId: Int) {
    view.nextFocusLeftId = viewId
  }

  @ReactProp(name = "nextFocusRight", defaultInt = View.NO_ID)
  fun nextFocusRight(view: ReactViewGroup, viewId: Int) {
    view.nextFocusRightId = viewId
  }

  @ReactProp(name = "nextFocusUp", defaultInt = View.NO_ID)
  fun nextFocusUp(view: ReactViewGroup, viewId: Int) {
    view.nextFocusUpId = viewId
  }

  @ReactPropGroup(
          names =
                  [
                          ViewProps.BORDER_RADIUS,
                          ViewProps.BORDER_TOP_LEFT_RADIUS,
                          ViewProps.BORDER_TOP_RIGHT_RADIUS,
                          ViewProps.BORDER_BOTTOM_RIGHT_RADIUS,
                          ViewProps.BORDER_BOTTOM_LEFT_RADIUS,
                          ViewProps.BORDER_TOP_START_RADIUS,
                          ViewProps.BORDER_TOP_END_RADIUS,
                          ViewProps.BORDER_BOTTOM_START_RADIUS,
                          ViewProps.BORDER_BOTTOM_END_RADIUS]
  )
  fun setBorderRadius(view: ReactViewGroup, index: Int, borderRadius: Float) {
    var borderRadius = borderRadius
    if (!YogaConstants.isUndefined(borderRadius) && borderRadius < 0) {
      borderRadius = YogaConstants.UNDEFINED
    }
    if (!YogaConstants.isUndefined(borderRadius)) {
      borderRadius = PixelUtil.toPixelFromDIP(borderRadius)
    }
    if (index == 0) {
      view.setBorderRadius(borderRadius)
    } else {
      view.setBorderRadius(borderRadius, index - 1)
    }
  }

  @ReactProp(name = "borderStyle")
  fun setBorderStyle(view: ReactViewGroup, @Nullable borderStyle: String?) {
    view.setBorderStyle(borderStyle)
  }

  @ReactProp(name = "hitSlop")
  fun setHitSlop(view: ReactViewGroup, @Nullable hitSlop: ReadableMap?) {
    if (hitSlop == null) {
      // We should keep using setters as `Val cannot be reassigned`
      view.setHitSlopRect(null)
    } else {
      view.setHitSlopRect(
              Rect(
                      if (hitSlop.hasKey("left"))
                              PixelUtil.toPixelFromDIP(hitSlop.getDouble("left")).toInt()
                      else 0,
                      if (hitSlop.hasKey("top"))
                              PixelUtil.toPixelFromDIP(hitSlop.getDouble("top")).toInt()
                      else 0,
                      if (hitSlop.hasKey("right"))
                              PixelUtil.toPixelFromDIP(hitSlop.getDouble("right")).toInt()
                      else 0,
                      if (hitSlop.hasKey("bottom"))
                              PixelUtil.toPixelFromDIP(hitSlop.getDouble("bottom")).toInt()
                      else 0
              )
      )
    }
  }

  @ReactProp(name = "nativeBackgroundAndroid")
  fun setNativeBackground(view: ReactViewGroup, @Nullable bg: ReadableMap?) {
    view.setTranslucentBackgroundDrawable(
            if (bg == null) null
            else ReactDrawableHelper.createDrawableFromJSDescription(view.context, bg)
    )
  }

  @TargetApi(Build.VERSION_CODES.M)
  @ReactProp(name = "nativeForegroundAndroid")
  fun setNativeForeground(view: ReactViewGroup, @Nullable fg: ReadableMap?) {
    view.foreground =
            if (fg == null) null
            else ReactDrawableHelper.createDrawableFromJSDescription(view.context, fg)
  }

  @ReactProp(name = ViewProps.NEEDS_OFFSCREEN_ALPHA_COMPOSITING)
  fun setNeedsOffscreenAlphaCompositing(
          view: ReactViewGroup,
          needsOffscreenAlphaCompositing: Boolean
  ) {
    view.setNeedsOffscreenAlphaCompositing(needsOffscreenAlphaCompositing)
  }

  @ReactPropGroup(
          names =
                  [
                          ViewProps.BORDER_WIDTH,
                          ViewProps.BORDER_LEFT_WIDTH,
                          ViewProps.BORDER_RIGHT_WIDTH,
                          ViewProps.BORDER_TOP_WIDTH,
                          ViewProps.BORDER_BOTTOM_WIDTH,
                          ViewProps.BORDER_START_WIDTH,
                          ViewProps.BORDER_END_WIDTH]
  )
  fun setBorderWidth(view: ReactViewGroup, index: Int, width: Float) {
    var width = width
    if (!YogaConstants.isUndefined(width) && width < 0) {
      width = YogaConstants.UNDEFINED
    }
    if (!YogaConstants.isUndefined(width)) {
      width = PixelUtil.toPixelFromDIP(width)
    }
    view.setBorderWidth(SPACING_TYPES[index], width)
  }

  @ReactPropGroup(
          names =
                  [
                          ViewProps.BORDER_COLOR,
                          ViewProps.BORDER_LEFT_COLOR,
                          ViewProps.BORDER_RIGHT_COLOR,
                          ViewProps.BORDER_TOP_COLOR,
                          ViewProps.BORDER_BOTTOM_COLOR,
                          ViewProps.BORDER_START_COLOR,
                          ViewProps.BORDER_END_COLOR],
          customType = "Color"
  )
  abstract fun setBorderColor(view: ReactViewGroup, index: Int, color: Int?)

  @ReactProp(name = ViewProps.OVERFLOW)
  fun setOverflow(view: ReactViewGroup, overflow: String?) {
    view.setOverflow(overflow)
  }

  @ReactProp(name = "backfaceVisibility")
  fun setBackfaceVisibility(view: ReactViewGroup, backfaceVisibility: String) {
    view.setBackfaceVisibility(backfaceVisibility)
  }

  @ReactProp(name = "themeVariant")
  fun setThemeVariant(view: MenuView, themeVariant: String?) {
    view.setThemeVariant(themeVariant)
  }

  @ReactProp(name = "uiKit")
  fun setUiKit(view: MenuView, uiKit: String?) {
    view.setUiKit(uiKit)
  }

  override fun setOpacity(@NonNull view: MenuView, opacity: Float) {
    view.setOpacityIfPossible(opacity)
  }

  override fun setTransform(@NonNull view: MenuView, @Nullable matrix: ReadableArray?) {
    super.setTransform(view, matrix)
    view.setBackfaceVisibilityDependantOpacity()
  }

  override fun getCommandsMap(): MutableMap<String, Int>? {
    return MapBuilder.of("show", COMMAND_SHOW)
  }

  override fun receiveCommand(root: MenuView, commandId: Int, args: ReadableArray?) {
    when (commandId) {
      COMMAND_SHOW -> root.show()
    }
  }

  companion object {
    val COMMAND_SHOW = 1
    val SPACING_TYPES =
            arrayOf(
                    Spacing.ALL,
                    Spacing.LEFT,
                    Spacing.RIGHT,
                    Spacing.TOP,
                    Spacing.BOTTOM,
                    Spacing.START,
                    Spacing.END
            )
  }
}
