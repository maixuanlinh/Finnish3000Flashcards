package com.linapps.ykiflashcards.ui

import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import kotlinx.coroutines.*

internal fun mediaSize(bytes: Long) = if(bytes>=1_000_000_000) String.format(java.util.Locale.ENGLISH,"%.1f GB",bytes/1e9) else "${(bytes+999_999)/1_000_000} MB"

@Composable internal fun OfflineOptions(vm: StudyViewModel,onClose: ()->Unit) {
    val app=LocalApp.current
    val status by app.offline.status.collectAsStateWithLifecycle()
    val media=status.media
    val scope=rememberCoroutineScope()
    var wifiOnly by remember { mutableStateOf(status.wifiOnly) }
    var busy by remember { mutableStateOf(false) }
    var confirmRemove by remember { mutableStateOf(false) }
    fun action(block: suspend ()->Unit) {
        busy=true;vm.pause()
        scope.launch {
            try { block() }
            catch(e: CancellationException) { throw e }
            catch(e: Exception) { vm.message(e.message ?: "The download could not be completed.") }
            finally { busy=false }
        }
    }
    Panel("Offline study",onClose) {
        Column(Modifier.weight(1f).verticalScroll(rememberScrollState()).padding(20.dp),verticalArrangement=Arrangement.spacedBy(20.dp)) {
            SectionTitle("Learn wherever you are")
            Text("Download images and audio to study without an internet connection. Downloads are optional and occupy storage space on your phone.",color=Muted)
            SectionCard {
                Text("Images and pronunciation",fontWeight=FontWeight.SemiBold)
                if(media.loading) CircularProgressIndicator()
                else {
                    Text("Complete collection: ${mediaSize(media.totalBytes)}",modifier=Modifier.testTag("offline.total"))
                    Text("${mediaSize(media.installedBytes)} included with the app · ${mediaSize(media.storageUsedBytes)} downloaded",fontSize=12.sp,color=Muted)
                    if(media.ready) Text("Available offline",color=Forest,modifier=Modifier.testTag("offline.ready"))
                    else {
                        LinearProgressIndicator(progress={ if(media.totalBytes==0L) 0f else (media.storageUsedBytes+media.installedBytes).toFloat()/media.totalBytes },modifier=Modifier.fillMaxWidth())
                        Text(if(status.active) { if(status.waiting) "Waiting to download${if(status.wifiOnly) " over Wi-Fi" else ""}…" else "Downloading lessons…" } else "${mediaSize(media.remainingBytes)} left to download",fontSize=12.sp,color=Muted)
                    }
                    media.error?.let { Text(it,color=Muted) }
                    status.error?.let { Text(it,color=Muted) }
                }
                Text("Finnish and English recordings are included. There is no need to install a speech voice on your phone.",fontSize=12.sp,color=Muted)
                Text("Downloading keeps your current lesson access. Premium lessons still require Premium.",fontSize=12.sp,color=Muted)
            }
            if(!media.ready) {
                Toggle("Download over Wi-Fi only",wifiOnly,enabled=!status.active && !busy) { wifiOnly=it }
                Text("Keep the app installed to retain downloaded lessons. You can pause and continue later; completed downloads are kept.",fontSize=12.sp,color=Muted)
                FilledAction(if(status.active) "Pause download" else if(media.storageUsedBytes>0) "Continue download" else "Download for offline study",
                    { action { if(status.active) app.offline.pause() else app.offline.start(wifiOnly) } },
                    Modifier.testTag("offline.download"),enabled=!busy && !media.loading && media.error==null)
            }
            if(media.storageUsedBytes>0) TextButton(onClick={ confirmRemove=true },enabled=!busy,modifier=Modifier.testTag("offline.remove")) { Text("Remove offline downloads · ${mediaSize(media.storageUsedBytes)}") }
            Text("Removing downloads keeps your learning progress, personal artwork and the lessons included with the app. Online lessons may use mobile data and recently used media may be cached temporarily.",fontSize=12.sp,color=Muted)
        }
    }
    if(confirmRemove) AlertDialog(onDismissRequest={ confirmRemove=false },title={ Text("Remove offline downloads?") },
        text={ Text("This frees ${mediaSize(media.storageUsedBytes)}. Your learning progress and personal artwork will stay on this phone.") },
        confirmButton={ TextButton(onClick={ confirmRemove=false;action { app.offline.remove() } }) { Text("Remove downloads") } },
        dismissButton={ TextButton(onClick={ confirmRemove=false }) { Text("Keep downloads") } })
}
