package com.jbojorquez.cute_doggos.dagger

import com.jbojorquez.cute_doggos.DogRepository
import com.jbojorquez.cute_doggos.DogRepositoryImpl
import com.jbojorquez.cute_doggos.RemoteService
import dagger.Module
import dagger.Provides
import retrofit2.Retrofit
import retrofit2.adapter.rxjava2.RxJava2CallAdapterFactory
import retrofit2.converter.gson.GsonConverterFactory
import javax.inject.Singleton

private const val dogUrl = "https://api.thedogapi.com/v1/"

@Module
class NetworkModule {
    
    @Provides
    fun provideDogRepository(): DogRepository = DogRepositoryImpl(provideDogRemoteService())

    @Singleton
    @Provides
    fun provideDogRemoteService(): RemoteService = Retrofit.Builder()
            .baseUrl(dogUrl)
            .addConverterFactory(GsonConverterFactory.create())
            .addCallAdapterFactory(RxJava2CallAdapterFactory.create())
            .build()
            .create(RemoteService::class.java)
}