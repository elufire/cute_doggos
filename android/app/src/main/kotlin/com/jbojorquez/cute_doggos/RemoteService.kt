package com.jbojorquez.cute_doggos

import io.reactivex.Observable
import retrofit2.http.GET
import retrofit2.http.Query

interface RemoteService {
    @GET("breeds/search")
    fun getSearchResults(@Query("q")sentSearch: Any):
        Observable<List<DogBreed>>

    @GET("images/search")
    fun getImageResults(@Query("breed_id")passedId: Any):
        Observable<List<DogImage>>

    @GET("breeds")
    fun getAllBreeds():
        Observable<List<DogBreed>>
}