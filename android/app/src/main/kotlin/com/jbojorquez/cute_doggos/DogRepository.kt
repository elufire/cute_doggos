package com.jbojorquez.cute_doggos

import io.reactivex.Observable
import javax.inject.Singleton

@Singleton
interface DogRepository {

    fun getAllDogs(): Observable<List<DogBreed>>

    fun searchDogs(passedArgument: Any): Observable<List<DogBreed>>

    fun getDogImages(id: Int): Observable<List<DogImage>>
}