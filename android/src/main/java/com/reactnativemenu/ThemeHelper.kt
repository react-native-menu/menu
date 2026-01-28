package com.reactnativemenu

import android.content.Context
import android.content.res.Configuration

object ThemeHelper {
  fun isNight(context: Context): Boolean {
    val mask = context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK
    return mask == Configuration.UI_MODE_NIGHT_YES
  }

  private fun styleIdOrZero(className: String, fieldName: String): Int {
    return try {
      val cls = Class.forName(className) // exp: "com.google.android.material.R$style"
      val f = cls.getField(fieldName)    // exp: "ThemeOverlay_Material3_Dark"
      f.getInt(null)
    } catch (_: Throwable) {
      0
    }
  }

  fun material3(dark: Boolean): Int {
    // Reflection ile: Material3 varsa al, yoksa 0 döner
    val name = if (dark) "ThemeOverlay_Material3_Dark" else "ThemeOverlay_Material3_Light"
    return styleIdOrZero("com.google.android.material.R\$style", name)
  }

  fun appcompat(dark: Boolean): Int {
    // AppCompat reflection (RN projelerinde zaten var)
    val name = if (dark) "ThemeOverlay_AppCompat_Dark" else "ThemeOverlay_AppCompat_Light"
    return styleIdOrZero("androidx.appcompat.R\$style", name)
  }
}
