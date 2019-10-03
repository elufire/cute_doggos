package com.jbojorquez.cute_doggos

data class DogBreed(
        val bred_for: String,
        val breed_group: String,
        val height: Height,
        val id: Int,
        val life_span: String,
        val name: String,
        val temperament: String,
        val weight: Weight,
        var imageUrl: String
)