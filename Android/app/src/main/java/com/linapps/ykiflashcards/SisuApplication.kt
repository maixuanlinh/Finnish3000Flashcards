package com.linapps.ykiflashcards

import android.app.Application
import com.linapps.ykiflashcards.data.*
import kotlinx.coroutines.*

class SisuApplication: Application() {
    val repository by lazy { LocalStudyRepository(this) }
    val entitlements: EntitlementRepository by lazy { PlayEntitlementRepository(this) }
    val preferences: Preferences by lazy { LocalPreferences(this) }
    val artwork by lazy { ArtworkRepository(this) }
    val media by lazy { LessonMedia(this) }
    val offline by lazy { OfflineDownloads(this,media,background) }
    val reminders by lazy { Reminders(this,repository,artwork,media) }
    val background = CoroutineScope(SupervisorJob()+Dispatchers.IO)
    override fun onCreate() { super.onCreate();offline }
}
