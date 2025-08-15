package edu.renata.fraga.kotlin_coroutines_sample.controller

import edu.renata.fraga.kotlin_coroutines_sample.model.Person
import edu.renata.fraga.kotlin_coroutines_sample.service.PersonService
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.reactor.asFlux
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import reactor.core.publisher.Flux
import reactor.core.publisher.Mono
import java.time.LocalDateTime

@RestController
@RequestMapping("/api/webflux")
class WebFluxController(private val personService: PersonService) {

    /**
     * Spring WebFlux - Stream de pessoas usando Flow + Flux
     */
    @GetMapping("/persons/stream", produces = [MediaType.APPLICATION_NDJSON_VALUE])
    fun getWebFluxPersonsStream(@RequestParam(defaultValue = "10") count: Int): Flux<Person> {
        val startTime = System.currentTimeMillis()
        
        return personService.getPersonsFlow(count)
            .asFlux()
            .doOnComplete {
                val endTime = System.currentTimeMillis()
                println("WebFlux Stream - Generated $count persons in ${endTime - startTime}ms")
            }
    }

    /**
     * Spring WebFlux - Lista de pessoas usando coroutines
     */
    @GetMapping("/persons/list")
    suspend fun getWebFluxPersonsList(@RequestParam(defaultValue = "10") count: Int): ResponseEntity<Map<String, Any>> {
        val startTime = System.currentTimeMillis()
        val threadInfo = personService.getCurrentThreadInfo()
        val coroutineInfo = personService.getCoroutineInfo()

        val persons = personService.getPersonsReactiveList(count)

        val endTime = System.currentTimeMillis()

        val response = mapOf(
            "approach" to "webflux-list-coroutines",
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
     * Spring WebFlux - Processamento paralelo em batches usando coroutines
     */
    @GetMapping("/persons/parallel")
    suspend fun getWebFluxPersonsParallel(
        @RequestParam(defaultValue = "5") batches: Int,
        @RequestParam(defaultValue = "10") countPerBatch: Int
    ): ResponseEntity<Map<String, Any>> {
        val startTime = System.currentTimeMillis()
        val threadInfo = personService.getCurrentThreadInfo()
        val coroutineInfo = personService.getCoroutineInfo()

        val persons = personService.getPersonsReactiveList(batches, countPerBatch)

        val endTime = System.currentTimeMillis()

        val response = mapOf(
            "approach" to "webflux-parallel-coroutines",
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
     * Spring WebFlux - Stream tradicional usando Flux (sem coroutines)
     */
    @GetMapping("/persons/traditional-stream", produces = [MediaType.APPLICATION_NDJSON_VALUE])
    fun getWebFluxPersonsTraditionalStream(@RequestParam(defaultValue = "10") count: Int): Flux<Person> {
        val startTime = System.currentTimeMillis()
        
        return personService.getPersonsReactive(count)
            .doOnComplete {
                val endTime = System.currentTimeMillis()
                println("WebFlux Traditional Stream - Generated $count persons in ${endTime - startTime}ms")
            }
    }

    /**
     * Spring WebFlux - Stream com Flow personalizado
     */
    @GetMapping("/persons/flow-stream", produces = [MediaType.APPLICATION_NDJSON_VALUE])
    fun getWebFluxPersonsFlowStream(@RequestParam(defaultValue = "10") count: Int): Flux<Map<String, Any>> {
        val startTime = System.currentTimeMillis()
        
        return personService.getPersonsFlow(count)
            .map { person ->
                mapOf(
                    "person" to person,
                    "threadInfo" to personService.getCurrentThreadInfo(),
                    "processedAt" to LocalDateTime.now()
                )
            }
            .asFlux()
            .doOnComplete {
                val endTime = System.currentTimeMillis()
                println("WebFlux Flow Stream - Generated $count persons in ${endTime - startTime}ms")
            }
    }

    /**
     * Spring WebFlux - Informações sobre thread atual
     */
    @GetMapping("/thread-info")
    suspend fun getWebFluxThreadInfo(): ResponseEntity<Map<String, Any>> {
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
