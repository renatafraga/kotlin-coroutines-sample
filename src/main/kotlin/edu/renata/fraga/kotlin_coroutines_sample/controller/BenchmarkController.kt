package edu.renata.fraga.kotlin_coroutines_sample.controller

import edu.renata.fraga.kotlin_coroutines_sample.service.PersonService
import kotlinx.coroutines.*
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import java.time.LocalDateTime
import kotlin.system.measureTimeMillis

@RestController
@RequestMapping("/api/benchmark")
class BenchmarkController(private val personService: PersonService) {

    /**
     * Benchmark: Coroutines vs Blocking
     */
    @GetMapping("/coroutines-vs-blocking")
    suspend fun benchmarkCoroutinesVsBlocking(
        @RequestParam(defaultValue = "50") count: Int
    ): ResponseEntity<Map<String, Any>> {
        
        // Teste com Coroutines
        val coroutinesTime = measureTimeMillis {
            personService.getPersonsAsync(count)
        }
        
        // Teste com Blocking
        val blockingTime = measureTimeMillis {
            personService.getPersonsBlocking(count)
        }
        
        val threadInfo = personService.getCurrentThreadInfo()
        val coroutineInfo = personService.getCoroutineInfo()
        
        val response = mapOf(
            "benchmark" to "coroutines-vs-blocking",
            "count" to count,
            "results" to mapOf(
                "coroutines" to mapOf(
                    "executionTimeMs" to coroutinesTime,
                    "approach" to "async-coroutines"
                ),
                "blocking" to mapOf(
                    "executionTimeMs" to blockingTime,
                    "approach" to "traditional-blocking"
                )
            ),
            "performance" to mapOf(
                "improvementPercent" to if (blockingTime > 0) ((blockingTime - coroutinesTime).toDouble() / blockingTime * 100) else 0.0,
                "speedupFactor" to if (coroutinesTime > 0) (blockingTime.toDouble() / coroutinesTime) else 0.0
            ),
            "threadInfo" to threadInfo,
            "coroutineInfo" to coroutineInfo,
            "timestamp" to LocalDateTime.now()
        )
        
        return ResponseEntity.ok(response)
    }

    /**
     * Benchmark: WebFlux vs MVC
     */
    @GetMapping("/webflux-vs-mvc")
    suspend fun benchmarkWebFluxVsMvc(
        @RequestParam(defaultValue = "50") count: Int
    ): ResponseEntity<Map<String, Any>> {
        
        // Teste com WebFlux (usando coroutines)
        val webfluxTime = measureTimeMillis {
            personService.getPersonsReactiveList(count)
        }
        
        // Teste com MVC (usando coroutines)
        val mvcTime = measureTimeMillis {
            personService.getPersonsAsync(count)
        }
        
        val threadInfo = personService.getCurrentThreadInfo()
        val coroutineInfo = personService.getCoroutineInfo()
        
        val response = mapOf(
            "benchmark" to "webflux-vs-mvc",
            "count" to count,
            "results" to mapOf(
                "webflux" to mapOf(
                    "executionTimeMs" to webfluxTime,
                    "approach" to "webflux-coroutines"
                ),
                "mvc" to mapOf(
                    "executionTimeMs" to mvcTime,
                    "approach" to "mvc-coroutines"
                )
            ),
            "performance" to mapOf(
                "difference" to kotlin.math.abs(webfluxTime - mvcTime),
                "faster" to if (webfluxTime < mvcTime) "webflux" else "mvc"
            ),
            "threadInfo" to threadInfo,
            "coroutineInfo" to coroutineInfo,
            "timestamp" to LocalDateTime.now()
        )
        
        return ResponseEntity.ok(response)
    }

    /**
     * Benchmark: Intensive Operations
     */
    @GetMapping("/intensive-operations")
    suspend fun benchmarkIntensiveOperations(
        @RequestParam(defaultValue = "20") count: Int
    ): ResponseEntity<Map<String, Any>> {
        
        // Teste com Coroutines Intensivo
        val coroutinesIntensiveTime = measureTimeMillis {
            personService.getPersonsAsyncIntensive(count)
        }
        
        // Teste com Blocking Intensivo
        val blockingIntensiveTime = measureTimeMillis {
            personService.getPersonsBlockingIntensive(count)
        }
        
        val threadInfo = personService.getCurrentThreadInfo()
        val coroutineInfo = personService.getCoroutineInfo()
        
        val response = mapOf(
            "benchmark" to "intensive-operations",
            "count" to count,
            "results" to mapOf(
                "coroutines-intensive" to mapOf(
                    "executionTimeMs" to coroutinesIntensiveTime,
                    "approach" to "async-coroutines-intensive"
                ),
                "blocking-intensive" to mapOf(
                    "executionTimeMs" to blockingIntensiveTime,
                    "approach" to "traditional-blocking-intensive"
                )
            ),
            "performance" to mapOf(
                "improvementPercent" to if (blockingIntensiveTime > 0) ((blockingIntensiveTime - coroutinesIntensiveTime).toDouble() / blockingIntensiveTime * 100) else 0.0,
                "speedupFactor" to if (coroutinesIntensiveTime > 0) (blockingIntensiveTime.toDouble() / coroutinesIntensiveTime) else 0.0
            ),
            "threadInfo" to threadInfo,
            "coroutineInfo" to coroutineInfo,
            "timestamp" to LocalDateTime.now()
        )
        
        return ResponseEntity.ok(response)
    }

    /**
     * Benchmark: Concurrent Batches
     */
    @GetMapping("/concurrent-batches")
    suspend fun benchmarkConcurrentBatches(
        @RequestParam(defaultValue = "10") batches: Int,
        @RequestParam(defaultValue = "5") countPerBatch: Int
    ): ResponseEntity<Map<String, Any>> {
        
        // Teste com Coroutines Concorrentes
        val concurrentTime = measureTimeMillis {
            personService.getPersonsConcurrent(batches, countPerBatch)
        }
        
        // Teste Sequencial para comparação
        val sequentialTime = measureTimeMillis {
            repeat(batches) {
                personService.getPersonsAsync(countPerBatch)
            }
        }
        
        val threadInfo = personService.getCurrentThreadInfo()
        val coroutineInfo = personService.getCoroutineInfo()
        
        val totalCount = batches * countPerBatch
        
        val response = mapOf(
            "benchmark" to "concurrent-batches",
            "batches" to batches,
            "countPerBatch" to countPerBatch,
            "totalCount" to totalCount,
            "results" to mapOf(
                "concurrent" to mapOf(
                    "executionTimeMs" to concurrentTime,
                    "approach" to "concurrent-coroutines"
                ),
                "sequential" to mapOf(
                    "executionTimeMs" to sequentialTime,
                    "approach" to "sequential-coroutines"
                )
            ),
            "performance" to mapOf(
                "improvementPercent" to if (sequentialTime > 0) ((sequentialTime - concurrentTime).toDouble() / sequentialTime * 100) else 0.0,
                "speedupFactor" to if (concurrentTime > 0) (sequentialTime.toDouble() / concurrentTime) else 0.0
            ),
            "threadInfo" to threadInfo,
            "coroutineInfo" to coroutineInfo,
            "timestamp" to LocalDateTime.now()
        )
        
        return ResponseEntity.ok(response)
    }
}
