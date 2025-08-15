package edu.renata.fraga.kotlin_coroutines_sample.controller

import edu.renata.fraga.kotlin_coroutines_sample.model.Person
import edu.renata.fraga.kotlin_coroutines_sample.service.PersonService
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.runBlocking
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import java.time.LocalDateTime

@RestController
@RequestMapping("/api/mvc")
class MvcController(private val personService: PersonService) {

    /**
     * Spring MVC - Abordagem blocking tradicional
     */
    @GetMapping("/persons/blocking")
    fun getMvcPersonsBlocking(@RequestParam(defaultValue = "10") count: Int): ResponseEntity<Map<String, Any>> {
        val startTime = System.currentTimeMillis()
        val threadInfo = personService.getCurrentThreadInfo()

        val persons = personService.getPersonsBlocking(count)

        val endTime = System.currentTimeMillis()

        val response = mapOf(
            "approach" to "mvc-blocking",
            "persons" to persons,
            "count" to persons.size,
            "executionTimeMs" to (endTime - startTime),
            "threadInfo" to threadInfo,
            "timestamp" to LocalDateTime.now()
        )

        return ResponseEntity.ok(response)
    }

    /**
     * Spring MVC - Abordagem blocking com I/O intensivo (demonstra vantagens das coroutines)
     */
    @GetMapping("/persons/blocking-intensive")
    fun getMvcPersonsBlockingIntensive(@RequestParam(defaultValue = "10") count: Int): ResponseEntity<Map<String, Any>> {
        val startTime = System.currentTimeMillis()
        val threadInfo = personService.getCurrentThreadInfo()

        val persons = personService.getPersonsBlockingIntensive(count)

        val endTime = System.currentTimeMillis()

        val response = mapOf(
            "approach" to "mvc-blocking-intensive",
            "persons" to persons,
            "count" to persons.size,
            "executionTimeMs" to (endTime - startTime),
            "threadInfo" to threadInfo,
            "timestamp" to LocalDateTime.now()
        )

        return ResponseEntity.ok(response)
    }

    /**
     * Spring MVC - Abordagem async usando coroutines
     */
    @GetMapping("/persons/async")
    suspend fun getMvcPersonsAsync(@RequestParam(defaultValue = "10") count: Int): ResponseEntity<Map<String, Any>> {
        val startTime = System.currentTimeMillis()
        val threadInfo = personService.getCurrentThreadInfo()
        val coroutineInfo = personService.getCoroutineInfo()

        val persons = personService.getPersonsAsync(count)

        val endTime = System.currentTimeMillis()

        val response = mapOf(
            "approach" to "mvc-async-coroutines",
            "persons" to persons,
            "count" to persons.size,
            "executionTimeMs" to (endTime - startTime),
            "threadInfo" to threadInfo,
            "coroutineInfo" to coroutineInfo,
            "timestamp" to LocalDateTime.now()
        )

        return ResponseEntity.ok(response)
    }

    /**
     * Spring MVC - Abordagem async com I/O intensivo usando coroutines
     */
    @GetMapping("/persons/async-intensive")
    suspend fun getMvcPersonsAsyncIntensive(@RequestParam(defaultValue = "10") count: Int): ResponseEntity<Map<String, Any>> {
        val startTime = System.currentTimeMillis()
        val threadInfo = personService.getCurrentThreadInfo()
        val coroutineInfo = personService.getCoroutineInfo()

        val persons = personService.getPersonsAsyncIntensive(count)

        val endTime = System.currentTimeMillis()

        val response = mapOf(
            "approach" to "mvc-async-coroutines-intensive",
            "persons" to persons,
            "count" to persons.size,
            "executionTimeMs" to (endTime - startTime),
            "threadInfo" to threadInfo,
            "coroutineInfo" to coroutineInfo,
            "timestamp" to LocalDateTime.now()
        )

        return ResponseEntity.ok(response)
    }

    /**
     * Spring MVC - Processamento concorrente em batches usando coroutines
     */
    @GetMapping("/persons/concurrent")
    suspend fun getMvcPersonsConcurrent(
        @RequestParam(defaultValue = "5") batches: Int,
        @RequestParam(defaultValue = "10") countPerBatch: Int
    ): ResponseEntity<Map<String, Any>> {
        val startTime = System.currentTimeMillis()
        val threadInfo = personService.getCurrentThreadInfo()
        val coroutineInfo = personService.getCoroutineInfo()

        val persons = personService.getPersonsConcurrent(batches, countPerBatch)

        val endTime = System.currentTimeMillis()

        val response = mapOf(
            "approach" to "mvc-concurrent-coroutines",
            "persons" to persons,
            "count" to persons.size,
            "batches" to batches,
            "countPerBatch" to countPerBatch,
            "executionTimeMs" to (endTime - startTime),
            "threadInfo" to threadInfo,
            "coroutineInfo" to coroutineInfo,
            "timestamp" to LocalDateTime.now()
        )

        return ResponseEntity.ok(response)
    }

    /**
     * Spring MVC - Informações sobre thread atual
     */
    @GetMapping("/thread-info")
    suspend fun getMvcThreadInfo(): ResponseEntity<Map<String, Any>> {
        val threadInfo = personService.getCurrentThreadInfo()
        val coroutineInfo = personService.getCoroutineInfo()

        val response = mapOf(
            "threadInfo" to threadInfo,
            "coroutineInfo" to coroutineInfo,
            "timestamp" to LocalDateTime.now()
        )

        return ResponseEntity.ok(response)
    }
}
