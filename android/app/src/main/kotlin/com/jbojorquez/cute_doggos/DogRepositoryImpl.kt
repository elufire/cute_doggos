package com.jbojorquez.cute_doggos

import android.util.Log
import android.util.LruCache
import com.google.gson.Gson
import io.reactivex.Observable
import io.reactivex.ObservableSource
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.PublishSubject
import retrofit2.Retrofit
import retrofit2.adapter.rxjava2.RxJava2CallAdapterFactory
import retrofit2.converter.gson.GsonConverterFactory
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class DogRepositoryImpl @Inject constructor(
        val remoteService: RemoteService
) : DogRepository {

    override fun getAllDogs(): Observable<List<DogBreed>> {
        return remoteService.getAllBreeds()
    }

    override fun searchDogs(passedArgument: Any): Observable<List<DogBreed>> {
        return remoteService.getSearchResults(passedArgument)
    }

    override fun getDogImages(id: Int): Observable<List<DogImage>> {
        return remoteService.getImageResults(id)
    }
}