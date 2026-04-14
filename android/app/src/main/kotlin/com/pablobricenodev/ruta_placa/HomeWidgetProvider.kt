package com.pablobricenodev.ruta_placa

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.res.Resources
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import java.text.SimpleDateFormat
import java.util.*

class HomeWidgetProvider : AppWidgetProvider() {

    companion object {
        // Colores
        const val COLOR_GREEN  = "#1DB954"
        const val COLOR_RED    = "#E53935"
        const val COLOR_ORANGE = "#FF9800"
        const val COLOR_GRAY   = "#AAAAAA"
        const val COLOR_WHITE  = "#FFFFFF"

        // Umbral de ancho para decidir layout
        const val LARGE_MIN_WIDTH_DP = 200
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
                // Nunca dejar que el widget quede en blanco
                // por un crash — mostrar estado de error
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
        // Se llama cuando el usuario redimensiona el widget
        updateWidget(context, appWidgetManager, appWidgetId)
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int
    ) {
        val data = HomeWidgetPlugin.getData(context)

        // Leer datos con defaults seguros
        val city         = data.getString("widget_city",         "---") ?: "---"
        val plate        = data.getString("widget_plate",        "---") ?: "---"

        val todayLabel   = data.getString("widget_today_label",  "Hoy") ?: "Hoy"
        val todayDigits  = data.getString("widget_today_digits", "Sin datos") ?: "Sin datos"
        val todayType    = data.getString("widget_today_type",   "none") ?: "none"

        val day2Label    = data.getString("widget_day2_label",   "---") ?: "---"
        val day2Digits   = data.getString("widget_day2_digits",  "---") ?: "---"
        val day2Type     = data.getString("widget_day2_type",    "none") ?: "none"

        val day3Label    = data.getString("widget_day3_label",   "---") ?: "---"
        val day3Digits   = data.getString("widget_day3_digits",  "---") ?: "---"
        val day3Type     = data.getString("widget_day3_type",    "none") ?: "none"

        // Detectar tamaño del widget
        val options  = appWidgetManager.getAppWidgetOptions(widgetId)
        val minWidth = options.getInt(
            AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0)
        val density  = Resources.getSystem().displayMetrics.density
        val widthDp  = (minWidth / density).toInt()

        val isLarge  = widthDp >= LARGE_MIN_WIDTH_DP

        val views = if (isLarge) {
            buildSmallWidget(
                context, city,
                todayLabel, todayDigits, todayType,
                day2Label,  day2Digits,  day2Type,
                day3Label,  day3Digits,  day3Type
            )
        } else {
            buildSmallWidget(
                context, city,
                todayLabel, todayDigits, todayType,
                day2Label,  day2Digits,  day2Type,
                day3Label,  day3Digits,  day3Type
            )
        }

        appWidgetManager.updateAppWidget(widgetId, views)
    }

    private fun buildSmallWidget(
        context: Context,
        city: String,
        todayLabel: String, todayDigits: String, todayType: String,
        day2Label: String,  day2Digits: String,  day2Type: String,
        day3Label: String,  day3Digits: String,  day3Type: String
    ): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_small)

        views.setTextViewText(R.id.ws_city, city)

        // Chip hoy
        views.setTextViewText(R.id.ws_today_label,  todayLabel)
        views.setTextViewText(R.id.ws_today_digits, todayDigits)
        val (chip1Bg, color1) = chipStyle(todayType)
        views.setInt(R.id.ws_chip_today, "setBackgroundResource", chip1Bg)
        views.setTextColor(R.id.ws_today_label,  Color.parseColor(color1))
        views.setTextColor(R.id.ws_today_digits, Color.parseColor(color1))

        // Chip día 2
        views.setTextViewText(R.id.ws_day2_label,  day2Label)
        views.setTextViewText(R.id.ws_day2_digits, day2Digits)
        val (chip2Bg, color2) = chipStyle(day2Type)
        views.setInt(R.id.ws_chip_day2, "setBackgroundResource", chip2Bg)
        views.setTextColor(R.id.ws_day2_label,  Color.parseColor(color2))
        views.setTextColor(R.id.ws_day2_digits, Color.parseColor(color2))

        // Chip día 3
        views.setTextViewText(R.id.ws_day3_label,  day3Label)
        views.setTextViewText(R.id.ws_day3_digits, day3Digits)
        val (chip3Bg, color3) = chipStyle(day3Type)
        views.setInt(R.id.ws_chip_day3, "setBackgroundResource", chip3Bg)
        views.setTextColor(R.id.ws_day3_label,  Color.parseColor(color3))
        views.setTextColor(R.id.ws_day3_digits, Color.parseColor(color3))

        return views
    }

    // Retorna (drawableRes, colorHex) según el tipo de restricción
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
        // Usa el layout pequeño como fallback seguro
        try {
            val views = RemoteViews(
                context.packageName, R.layout.widget_small)
            views.setTextViewText(R.id.ws_city, "")
            views.setTextViewText(R.id.ws_today_label, "RutaPlaca")
            views.setTextViewText(R.id.ws_today_digits, "Abre la app")
            views.setTextViewText(R.id.ws_day2_label, "RutaPlaca")
            views.setTextViewText(R.id.ws_day2_digits, "Abre la app")
            views.setTextViewText(R.id.ws_day3_label, "RutaPlaca")
            views.setTextViewText(R.id.ws_day3_digits, "Abre la app")
            appWidgetManager.updateAppWidget(widgetId, views)
        } catch (_: Exception) { }
    }
}