package edu.renata.fraga.kotlin_coroutines_sample.controller

import edu.renata.fraga.kotlin_coroutines_sample.service.PersonService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import java.time.LocalDateTime

@RestController
@RequestMapping("/api")
class MainController(private val personService: PersonService) {

    /**
     * Endpoint de documentação principal
     */
    @GetMapping("/")
    fun welcome(): Map<String, Any> {
        return mapOf(
            "message" to "Kotlin Coroutines vs WebFlux Comparison API",
            "timestamp" to LocalDateTime.now(),
            "profiles" to mapOf(
                "mvc-coroutines" to "Spring MVC with Kotlin Coroutines",
                "webflux-coroutines" to "Spring WebFlux with Kotlin Coroutines",
                "webflux-traditional" to "Spring WebFlux with traditional reactive approach"
            ),
            "endpoints" to mapOf(
                "Spring MVC + Coroutines" to mapOf(
                    "blocking" to "/api/mvc/persons/blocking",
                    "blocking-intensive" to "/api/mvc/persons/blocking-intensive",
                    "async" to "/api/mvc/persons/async",
                    "async-intensive" to "/api/mvc/persons/async-intensive",
                    "concurrent" to "/api/mvc/persons/concurrent",
                    "threadInfo" to "/api/mvc/thread-info"
                ),
                "Spring WebFlux + Coroutines" to mapOf(
                    "stream" to "/api/webflux/persons/stream",
                    "list" to "/api/webflux/persons/list",
                    "parallel" to "/api/webflux/persons/parallel",
                    "flow-stream" to "/api/webflux/persons/flow-stream",
                    "traditional-stream" to "/api/webflux/persons/traditional-stream",
                    "threadInfo" to "/api/webflux/thread-info"
                ),
                "Benchmark" to mapOf(
                    "coroutines-vs-blocking" to "/api/benchmark/coroutines-vs-blocking",
                    "webflux-vs-mvc" to "/api/benchmark/webflux-vs-mvc"
                )
            ),
            "examples" to mapOf(
                "Basic usage" to listOf(
                    "curl 'http://localhost:8080/api/mvc/persons/blocking?count=5'",
                    "curl 'http://localhost:8080/api/mvc/persons/async?count=5'",
                    "curl 'http://localhost:8080/api/webflux/persons/list?count=5'",
                    "curl 'http://localhost:8080/api/webflux/persons/stream?count=5'"
                ),
                "Performance comparison" to listOf(
                    "curl 'http://localhost:8080/api/mvc/persons/blocking-intensive?count=20'",
                    "curl 'http://localhost:8080/api/mvc/persons/async-intensive?count=20'",
                    "curl 'http://localhost:8080/api/benchmark/coroutines-vs-blocking?count=50'"
                ),
                "Concurrent processing" to listOf(
                    "curl 'http://localhost:8080/api/mvc/persons/concurrent?batches=3&countPerBatch=10'",
                    "curl 'http://localhost:8080/api/webflux/persons/parallel?batches=3&countPerBatch=10'"
                )
            )
        )
    }

    /**
     * Health check endpoint
     */
    @GetMapping("/health")
    suspend fun health(): ResponseEntity<Map<String, Any>> {
        val threadInfo = personService.getCurrentThreadInfo()
        val coroutineInfo = personService.getCoroutineInfo()

        val response = mapOf(
            "status" to "UP",
            "timestamp" to LocalDateTime.now(),
            "threadInfo" to threadInfo,
            "coroutineInfo" to coroutineInfo,
            "version" to "1.0.0"
        )

        return ResponseEntity.ok(response)
    }
}
