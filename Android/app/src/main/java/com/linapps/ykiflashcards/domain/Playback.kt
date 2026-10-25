package com.linapps.ykiflashcards.domain

import kotlinx.coroutines.delay

interface Speech {
    fun beginSession(onInterruption: () -> Unit) {}
    fun endSession() {}
    suspend fun say(text: String, language: String, rate: Float)
    fun stop()
    fun close()
}

data class PlaybackSettings(
    val recallSeconds: Int = 3, val answerSeconds: Int = 2,
    val readPrompt: Boolean = true, val readAnswer: Boolean = true,
    val readSentence: Boolean = true, val rate: Float = 1f
)
/** One cancellable cycle. The caller owns selection/navigation; this never writes progress. */
class PlaybackCycle(private val speech: Speech, private val wait: suspend (Long) -> Unit = { delay(it) }) {
    suspend fun play(word: Word, englishFirst: Boolean, settings: PlaybackSettings, reveal: () -> Unit) {
        if(settings.readPrompt) speech.say(if(englishFirst) word.english else word.finnish, if(englishFirst) "en-US" else "fi-FI", settings.rate)
        wait(settings.recallSeconds.coerceIn(1,15)*1000L)
        reveal()
        if(settings.readAnswer) speech.say(if(englishFirst) word.finnish else word.english, if(englishFirst) "fi-FI" else "en-US", settings.rate)
        if(settings.readSentence) speech.say(word.sentence,"fi-FI",settings.rate)
        wait(settings.answerSeconds.coerceIn(1,15)*1000L)
    }
}
