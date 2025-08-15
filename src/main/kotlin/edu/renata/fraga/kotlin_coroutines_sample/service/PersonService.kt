package edu.renata.fraga.kotlin_coroutines_sample.service

import edu.renata.fraga.kotlin_coroutines_sample.model.Person
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.asFlow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.reactor.asFlux
import org.springframework.stereotype.Service
import reactor.core.publisher.Flux
import reactor.core.publisher.Mono
import reactor.core.scheduler.Schedulers
import java.time.Duration

@OptIn(ExperimentalStdlibApi::class)
@Service
class PersonService {

    companion object {
        private val NAMES = listOf(
            "João Silva", "Maria Santos", "Pedro Oliveira", "Ana Costa", "Carlos Ferreira",
            "Lucia Rodrigues", "Marcos Lima", "Fernanda Alves", "Roberto Souza", "Patricia Gomes",
            "Daniel Martins", "Juliana Pereira", "Ricardo Barbosa", "Camila Ribeiro", "Fernando Dias",
            "Bianca Moreira", "Gustavo Carvalho", "Leticia Nascimento", "Bruno Araújo", "Sabrina Freitas"
        )

        private val CITIES = listOf(
            "São Paulo", "Rio de Janeiro", "Belo Horizonte", "Salvador", "Brasília",
            "Fortaleza", "Curitiba", "Recife", "Porto Alegre", "Manaus",
            "Belém", "Goiânia", "Campinas", "São Luís", "Maceió"
        )
    }

    /**
     * Simula uma operação blocking mais realista (ex: consulta a banco de dados ou API externa)
     */
    private suspend fun simulateBlockingOperation() {
        delay(500) // Simula 500ms de latência usando coroutines - não-blocking
    }

    /**
     * Simula operação blocking rápida para comparação
     */
    private suspend fun simulateQuickBlockingOperation() {
        delay(100) // Simula 100ms de latência usando coroutines
    }

    /**
     * Implementação tradicional blocking para Spring MVC (usando runBlocking)
     */
    fun getPersonsBlocking(count: Int): List<Person> = runBlocking {
        (0 until count).map { index ->
            createPersonWithDelay(index)
        }
    }

    /**
     * Implementação com Coroutines para processamento concorrente
     */
    suspend fun getPersonsAsync(count: Int): List<Person> = coroutineScope {
        (0 until count).map { index ->
            async {
                createPersonWithDelay(index)
            }
        }.awaitAll()
    }

    /**
     * Implementação com processamento concorrente em batches usando coroutines
     */
    suspend fun getPersonsConcurrent(batches: Int, countPerBatch: Int): List<Person> = coroutineScope {
        (0 until batches).map { batchIndex ->
            async {
                (batchIndex * countPerBatch until (batchIndex + 1) * countPerBatch).map { index ->
                    createPersonWithDelay(index)
                }
            }
        }.awaitAll().flatten()
    }

    /**
     * Implementação reativa para Spring WebFlux usando Flow
     */
    fun getPersonsReactive(count: Int): Flux<Person> {
        return (0 until count).asFlow()
            .map { index ->
                delay(50) // Simula latência de forma não-blocking
                createPerson(index)
            }
            .asFlux()
    }

    /**
     * Implementação com Flow para coroutines
     */
    fun getPersonsFlow(count: Int): Flow<Person> = flow {
        for (index in 0 until count) {
            delay(50) // Simula latência
            emit(createPerson(index))
        }
    }

    /**
     * Implementação reativa com delay maior para comparação
     */
    suspend fun getPersonsReactiveList(count: Int): List<Person> = coroutineScope {
        (0 until count).map { index ->
            async {
                delay(50)
                createPerson(index)
            }
        }.awaitAll()
    }

    /**
     * Implementação reativa com processamento paralelo em batches usando coroutines
     */
    suspend fun getPersonsReactiveList(batches: Int, countPerBatch: Int): List<Person> = coroutineScope {
        (0 until batches).map { batchIndex ->
            async {
                (batchIndex * countPerBatch until countPerBatch).map { index ->
                    simulateBlockingOperation() // Simula operação blocking
                    createPerson(index)
                }
            }
        }.awaitAll().flatten()
    }

    /**
     * Implementação com coroutines intensivas para demonstrar eficiência
     */
    suspend fun getPersonsAsyncIntensive(count: Int): List<Person> = coroutineScope {
        (0 until count).map { index ->
            async { createPersonWithIntensiveDelay(index) }
        }.awaitAll()
    }

    /**
     * Implementação blocking com latência maior para demonstrar vantagens das coroutines
     */
    fun getPersonsBlockingIntensive(count: Int): List<Person> = runBlocking {
        (0 until count).map { index ->
            createPersonWithIntensiveDelay(index)
        }
    }

    /**
     * Implementação blocking rápida para comparação
     */
    fun getPersonsBlockingQuick(count: Int): List<Person> = runBlocking {
        (0 until count).map { index ->
            createPersonWithQuickDelay(index)
        }
    }

    private suspend fun createPersonWithDelay(index: Int): Person {
        simulateQuickBlockingOperation() // Simula operação blocking rápida (100ms)
        return createPerson(index)
    }

    private suspend fun createPersonWithIntensiveDelay(index: Int): Person {
        simulateBlockingOperation() // Simula operação blocking mais intensiva (500ms)
        return createPerson(index)
    }

    private suspend fun createPersonWithQuickDelay(index: Int): Person {
        simulateQuickBlockingOperation() // Simula operação blocking rápida (100ms)
        return createPerson(index)
    }

    private fun createPerson(index: Int): Person {
        return Person.create(
            id = index.toLong(),
            name = NAMES[index % NAMES.size],
            email = generateEmail(index),
            age = 20 + (index % 50), // Idade entre 20 e 69
            city = CITIES[index % CITIES.size]
        )
    }

    private fun generateEmail(index: Int): String {
        val name = NAMES[index % NAMES.size]
            .lowercase()
            .replace(" ", ".")
        return "$name@example.com"
    }

    /**
     * Método para obter estatísticas do thread atual
     */
    fun getCurrentThreadInfo(): String {
        val currentThread = Thread.currentThread()
        return "Thread: ${currentThread.name}, Virtual: ${currentThread.isVirtual}, ThreadId: ${currentThread.threadId()}"
    }

    /**
     * Método para obter informações sobre coroutines
     */
    suspend fun getCoroutineInfo(): String {
        return "Coroutine: ${currentCoroutineContext()[CoroutineName]?.name ?: "unnamed"}, " +
                "Dispatcher: ${currentCoroutineContext()[CoroutineDispatcher]}"
    }
}
