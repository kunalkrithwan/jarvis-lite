package com.jarvis.lite.services

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.util.Log

/**
 * Silent background service for continuous voice listening
 * Uses minimal resources and respects battery optimization settings
 */
class VoiceListeningService : Service() {
    companion object {
        private const val TAG = "VoiceListeningService"
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Voice listening service started")
        // Implement foreground service with notification
        // In production, this would handle continuous audio processing
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Voice listening service stopped")
    }
}

/**
 * Background task service for executing scheduled tasks
 */
class BackgroundTaskService : Service() {
    companion object {
        private const val TAG = "BackgroundTaskService"
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Background task service started")
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Background task service stopped")
    }
}
