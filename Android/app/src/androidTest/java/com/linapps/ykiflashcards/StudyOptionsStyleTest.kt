package com.linapps.ykiflashcards

import android.graphics.Bitmap
import android.os.SystemClock
import androidx.compose.ui.test.*
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.lifecycle.ViewModelProvider
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import com.linapps.ykiflashcards.domain.Entitlement
import com.linapps.ykiflashcards.ui.StudyViewModel
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import java.io.File

/** Read-only visual checks that are safe to run on the owner's connected phone. */
@RunWith(AndroidJUnit4::class)
class StudyOptionsStyleTest {
    @get:Rule val compose=createAndroidComposeRule<MainActivity>()

    @Test fun studyOptionsAndPremiumActionMatchTheAppStyle() {
        lateinit var vm: StudyViewModel
        compose.activityRule.scenario.onActivity { vm=ViewModelProvider(it)[StudyViewModel::class.java] }
        compose.waitUntil(30_000) { !vm.uiState.value.loading && vm.uiState.value.access!=Entitlement.UNKNOWN }

        compose.onNodeWithTag("study.options").performClick()
        compose.onNodeWithText("Study options").assertExists()
        compose.onNodeWithText("Shape this study session").assertExists()
        compose.onNodeWithText("For this session").assertExists()
        capture("study-options.png")

        compose.onNodeWithText("Done").performClick()
        compose.onNodeWithTag("tab.Progress").performClick()
        compose.onNodeWithTag("progress.goPremium").performScrollTo().assertExists()
        capture("go-premium.png")
    }

    private fun capture(name: String) {
        compose.waitForIdle()
        // Let the platform's full-screen dialog transition finish before judging pixels.
        SystemClock.sleep(700)
        val instrumentation=InstrumentationRegistry.getInstrumentation()
        val folder=File(instrumentation.targetContext.getExternalFilesDir(null),"style-check").apply { mkdirs() }
        instrumentation.uiAutomation.takeScreenshot()?.let { image ->
            File(folder,name).outputStream().use { image.compress(Bitmap.CompressFormat.PNG,100,it) }
            image.recycle()
        }
    }
}
