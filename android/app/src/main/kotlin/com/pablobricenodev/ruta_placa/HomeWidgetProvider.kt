package com.pablobricenodev.ruta_placa

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.res.Resources
import android.graphics.Color
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class HomeWidgetProvider : AppWidgetProvider() {

    companion object {
        const val COLOR_GREEN  = "#1DB954"
        const val COLOR_RED    = "#E53935"
        const val COLOR_ORANGE = "#FF9800"
        const val COLOR_GRAY   = "#AAAAAA"

        const val MEDIUM_MIN_WIDTH_DP   = 110
        const val LARGE_MIN_WIDTH_DP    = 145

        // Alto <= 50dp → modo compacto (ocultar título, chips en una línea)
        const val COMPACT_MAX_HEIGHT_DP = 50
        // Alto >= 100dp → texto más grande
        const val TALL_MIN_HEIGHT_DP    = 100
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (id in appWidgetIds) {
            try {
                updateWidget(context, appWidgetManager, id)
            } catch (e: Exception) {
                showErrorState(context, appWidgetManager, id)
            }
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: android.os.Bundle
    ) {
        updateWidget(context, appWidgetManager, appWidgetId)
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int
    ) {
        val data = HomeWidgetPlugin.getData(context)

        val city        = data.getString("widget_city",         "---") ?: "---"
        val todayLabel  = data.getString("widget_today_label",  "Hoy") ?: "Hoy"
        val todayDigits = data.getString("widget_today_digits", "---") ?: "---"
        val todayType   = data.getString("widget_today_type",   "none") ?: "none"
        val day2Label   = data.getString("widget_day2_label",   "---") ?: "---"
        val day2Digits  = data.getString("widget_day2_digits",  "---") ?: "---"
        val day2Type    = data.getString("widget_day2_type",    "none") ?: "none"
        val day3Label   = data.getString("widget_day3_label",   "---") ?: "---"
        val day3Digits  = data.getString("widget_day3_digits",  "---") ?: "---"
        val day3Type    = data.getString("widget_day3_type",    "none") ?: "none"

        val options   = appWidgetManager.getAppWidgetOptions(widgetId)
        val minWidth  = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH,  0)
        val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0)
        val density   = Resources.getSystem().displayMetrics.density
        val widthDp   = if (density > 0) (minWidth  / density).toInt() else minWidth
        val heightDp  = if (density > 0) (minHeight / density).toInt() else minHeight

        val showDay2    = widthDp  >= MEDIUM_MIN_WIDTH_DP
        val showDay3    = widthDp  >= LARGE_MIN_WIDTH_DP
        val compactMode = heightDp <= COMPACT_MAX_HEIGHT_DP
        val isTall      = heightDp >= TALL_MIN_HEIGHT_DP

        val labelSize  = if (isTall) 13f else 10f
        val digitsSize = if (isTall) 12f else  9f

        val views = RemoteViews(context.packageName, R.layout.widget_small)

        views.setTextViewText(R.id.ws_city, city)

        // ✅ Ocultar título "RutaPlaca" en modo compacto
        views.setViewVisibility(
            R.id.ws_app_title,
            if (compactMode) View.GONE else View.VISIBLE
        )

        applyChip(
            views,
            R.id.ws_chip_today, R.id.ws_today_label, R.id.ws_today_digits,
            todayLabel, todayDigits, todayType,
            visible     = true,
            labelSize   = labelSize,
            digitsSize  = digitsSize,
            compactMode = compactMode,
        )

        applyChip(
            views,
            R.id.ws_chip_day2, R.id.ws_day2_label, R.id.ws_day2_digits,
            day2Label, day2Digits, day2Type,
            visible     = showDay2,
            labelSize   = labelSize,
            digitsSize  = digitsSize,
            compactMode = compactMode,
        )

        applyChip(
            views,
            R.id.ws_chip_day3, R.id.ws_day3_label, R.id.ws_day3_digits,
            day3Label, day3Digits, day3Type,
            visible     = showDay3,
            labelSize   = labelSize,
            digitsSize  = digitsSize,
            compactMode = compactMode,
        )

        appWidgetManager.updateAppWidget(widgetId, views)
    }

    private fun applyChip(
        views: RemoteViews,
        chipId: Int,
        labelId: Int,
        digitsId: Int,
        label: String,
        digits: String,
        type: String,
        visible: Boolean,
        labelSize: Float,
        digitsSize: Float,
        compactMode: Boolean,
    ) {
        views.setViewVisibility(chipId, if (visible) View.VISIBLE else View.GONE)

        if (!visible) return

        val (bg, color) = chipStyle(type)
        views.setInt(chipId, "setBackgroundResource", bg)

        if (compactMode) {
            // ✅ Modo compacto: "Hoy · 4·5" en una sola línea
            // ocultar segunda línea de dígitos
            views.setTextViewText(labelId,  "$label · $digits")
            views.setViewVisibility(digitsId, View.GONE)
            views.setTextColor(labelId, Color.parseColor(color))
            views.setFloat(labelId, "setTextSize", labelSize)
        } else {
            // Modo normal: label arriba, dígitos abajo
            views.setTextViewText(labelId,  label)
            views.setTextViewText(digitsId, digits)
            views.setViewVisibility(digitsId, View.VISIBLE)
            views.setTextColor(labelId,  Color.parseColor(color))
            views.setTextColor(digitsId, Color.parseColor(color))
            views.setFloat(labelId,  "setTextSize", labelSize)
            views.setFloat(digitsId, "setTextSize", digitsSize)
        }
    }

    private fun chipStyle(type: String): Pair<Int, String> = when (type) {
        "restricted" -> Pair(R.drawable.widget_chip_red,    COLOR_RED)
        "free"       -> Pair(R.drawable.widget_chip_green,  COLOR_GREEN)
        "all"        -> Pair(R.drawable.widget_chip_orange, COLOR_ORANGE)
        else         -> Pair(R.drawable.widget_chip_gray,   COLOR_GRAY)
    }

    private fun showErrorState(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int
    ) {
        try {
            val views = RemoteViews(context.packageName, R.layout.widget_small)
            views.setTextViewText(R.id.ws_city,         "")
            views.setTextViewText(R.id.ws_today_label,  "Abre la app")
            views.setViewVisibility(R.id.ws_app_title,  View.GONE)
            views.setViewVisibility(R.id.ws_chip_day2,  View.GONE)
            views.setViewVisibility(R.id.ws_chip_day3,  View.GONE)
            appWidgetManager.updateAppWidget(widgetId, views)
        } catch (_: Exception) { }
    }
}