package com.example.smart_fuel_app_kotlin

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

import android.os.Bundle
import android.widget.Button
import android.widget.ProgressBar
import android.widget.TextView
import android.os.Handler
import android.view.View
import java.text.DecimalFormat

import kotlinx.android.synthetic.main.widget_layout.*

class AppWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {

                // Open App on Widget Click
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(context,
                        MainActivity::class.java)
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)

                val counter = widgetData.getInt("_counter", 0)


                var counterText = "None"

                val first = counter / 1000
                val sec = counter - (first * 1000)

                if(first == 0) {
                    counterText = "${sec} ml"
                } else {
                    counterText = "${first}.${sec} ml"
                }


                val goal = 2000


                setTextViewText(R.id.tv_counter, counterText)
                setProgressBar(R.id.progressBar, goal, counter, false)
//                setInt(R.id.widget_root,"setBackgroundResource",
//                        R.drawable.success_rounded_shape);
//                if (counter > goal) {
//                    setInt(R.id.success, "setAlpha", 1000)
//                } else {
//                    setInt(R.id.success, "setAlpha", 0)
//                }


                // Pending intent to update counter on button click
                val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(context,
                        Uri.parse("myAppWidget://updatecounter"))
                //setOnClickPendingIntent(R.id.bt_update, backgroundIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}