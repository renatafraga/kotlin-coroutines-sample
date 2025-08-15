package edu.renata.fraga.kotlin_coroutines_sample.model

data class Person(
    val id: Long,
    val name: String,
    val email: String,
    val age: Int,
    val city: String
) {
    companion object {
        fun create(id: Long, name: String, email: String, age: Int, city: String): Person {
            return Person(id, name, email, age, city)
        }
    }
}
