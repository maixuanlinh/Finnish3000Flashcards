package com.linapps.ykiflashcards.data

import android.content.Context
import androidx.work.*
import com.linapps.ykiflashcards.SisuApplication
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*
import java.io.IOException
import java.util.UUID

data class OfflineStatus(val media: MediaStatus=MediaStatus(),val active: Boolean=false,val waiting: Boolean=false,
    val wifiOnly: Boolean=true,val error: String?=null)

class OfflineDownloads(context: Context,private val media: LessonMedia,scope: CoroutineScope) {
    private val manager=WorkManager.getInstance(context)
    private val preferences=context.getSharedPreferences("offline-lessons",Context.MODE_PRIVATE)
    private val state=MutableStateFlow(OfflineStatus(wifiOnly=preferences.getBoolean("wifiOnly",true)))
    val status=state.asStateFlow()
    init {
        scope.launch {
            combine(media.status,manager.getWorkInfosForUniqueWorkFlow(NAME)) { content,work ->
                OfflineStatus(content,work.any { !it.state.isFinished },work.any { !it.state.isFinished } && work.none { it.state==WorkInfo.State.RUNNING },
                    preferences.getBoolean("wifiOnly",true),work.firstOrNull { it.state==WorkInfo.State.FAILED && preferences.getString("attempt",null) in it.tags }?.outputData?.getString("error"))
            }.collect { state.value=it }
        }
        scope.launch { media.refresh() }
    }
    suspend fun start(wifiOnly: Boolean) = withContext(Dispatchers.IO) {
        pause()
        val attempt=UUID.randomUUID().toString()
        preferences.edit().putBoolean("wifiOnly",wifiOnly).putString("attempt",attempt).apply()
        media.refresh();media.checkSpace()
        val requests=media.missingPacks().map { pack -> OneTimeWorkRequestBuilder<LessonDownloadWorker>()
            .setConstraints(Constraints.Builder().setRequiredNetworkType(if(wifiOnly) NetworkType.UNMETERED else NetworkType.CONNECTED).setRequiresStorageNotLow(true).build())
            .setInputData(workDataOf("pack" to pack.file,"version" to media.catalog.version))
            .addTag(attempt)
            .build() }
        if(requests.isNotEmpty()) {
            var chain=manager.beginUniqueWork(NAME,ExistingWorkPolicy.REPLACE,requests.first())
            requests.drop(1).forEach { chain=chain.then(it) }
            chain.enqueue().result.get()
        }
    }
    suspend fun pause() = withContext(Dispatchers.IO) { manager.cancelUniqueWork(NAME).result.get();media.refresh() }
    suspend fun remove() { pause();media.removeDownloads() }
    companion object { const val NAME="offline-lesson-media" }
}

class LessonDownloadWorker(context: Context,parameters: WorkerParameters): CoroutineWorker(context,parameters) {
    override suspend fun doWork(): Result {
        val media=(applicationContext as SisuApplication).media
        return try {
            check(inputData.getString("version")==media.catalog.version) { "Lessons were updated. Please start the download again." }
            val pack=media.catalog.packs.getValue(inputData.getString("pack").orEmpty())
            media.download(pack)
            Result.success()
        } catch(e: CancellationException) { throw e }
        catch(e: IOException) { if(runAttemptCount<5) Result.retry() else Result.failure(workDataOf("error" to "The connection was interrupted. Tap Download to continue.")) }
        catch(e: Exception) { Result.failure(workDataOf("error" to (e.message ?: "The download could not be completed."))) }
    }
}
