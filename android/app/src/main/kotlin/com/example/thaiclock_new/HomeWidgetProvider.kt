package com.example.thaiclock_new

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File

class HomeWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(
                context.packageName,
                R.layout.widget_layout
            )

            // ウィジェットタップでアプリを起動する設定（PendingIntent）
            val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            if (intent != null) {
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_image, pendingIntent)
            }

            // 保存されているPNGのパスを取得
            val imagePath = widgetData.getString("filename", null)

            // PNGをBitmapとして読み込み＆セット
            if (!imagePath.isNullOrEmpty()) {
                val imgFile = File(imagePath)
                if (imgFile.exists()) {
                    val options = BitmapFactory.Options().apply {
                        inMutable = true
                    }
                    val bitmap = BitmapFactory.decodeFile(imgFile.absolutePath, options)
                    if (bitmap != null) {
                        views.setImageViewBitmap(R.id.widget_image, bitmap)
                    }
                }
            } else {
                // 写真が削除された場合は画像をクリア
                views.setImageViewBitmap(R.id.widget_image, null)
            }

            // AndroidへWidget更新を反映
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}