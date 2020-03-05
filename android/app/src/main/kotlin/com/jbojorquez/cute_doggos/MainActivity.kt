package com.jbojorquez.cute_doggos

import android.os.Bundle
import android.util.Log
import com.google.firebase.database.FirebaseDatabase
import com.google.gson.Gson

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import io.reactivex.Observable
import io.reactivex.ObservableSource
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.functions.Function
import io.reactivex.schedulers.Schedulers
import retrofit2.Retrofit
import retrofit2.adapter.rxjava2.RxJava2CallAdapterFactory
import retrofit2.converter.gson.GsonConverterFactory
import com.google.firebase.database.DatabaseReference
import io.reactivex.disposables.CompositeDisposable
import io.flutter.plugin.common.EventChannel
import android.icu.lang.UCharacter.GraphemeClusterBreak.T
import sun.jvm.hotspot.utilities.IntArray




const val SEARCH_DOGS = "SEARCH_DOGS"
const val GET_ALL_DOGS = "GET_ALL_DOGS"
const val DOGS_STREAM = "DOGS_STREAM"

class MainActivity: FlutterActivity() {
  private val CHANNEL = "flutter.native/helper"
  //var disposable: Disposable? = null
  var dogs = ArrayList<DogBreed>()
    var dogsFinal = ArrayList<DogBreed>()
  val gson = Gson()
    val disposables = CompositeDisposable()
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

      val database = FirebaseDatabase.getInstance()
      val myRef = database.getReference("BaseDb")
      Log.d("Jose", "The dog is: ${myRef.child("pomeranian").key}")

      EventChannel(flutterView, DOGS_STREAM).setStreamHandler(
              object : EventChannel.StreamHandler {
                  override fun onListen(args: Any, events: EventChannel.EventSink) {
                      Log.w("Jose", "adding listener")
                  }

                  override fun onCancel(args: Any) {
                      Log.w("Jose", "cancelling listener")
                  }
              }
      )

      Log.d("KOTLIN", "Made it to Native Code.")
    MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
      val passedArgument = call.arguments
      if (call.method == "helloFromNativeCode") {
        val greetings = helloFromNativeCode(passedArgument)
        result.success(greetings)
      }
      when(call.method) {
          SEARCH_DOGS -> searchDogs(result, passedArgument)
          GET_ALL_DOGS -> getAllDogs(result)
      }
//      if(call.method == SEARCH_DOGS){
//
//
//        //val data = getDogData(passedArgument)
////          if(disposable.isDisposed){
////
////          }
//      }
    }
    GeneratedPluginRegistrant.registerWith(this)
  }

    private fun getAllDogs(result: MethodChannel.Result) {
        var data: String ?= "Hey it failed"
        disposables.add(
                getRemoteService("https://api.thedogapi.com/v1/").getAllBreeds()
                        .subscribeOn(Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        //.doOnNext((List<DogBreed>) -> )
                        //.doOnNext { reCall ->  }
                        .subscribe(
                                {resultCall ->
                                    //data = gson.toJson(resultCall)
                                    //Log.d("getDogData", returnSearch)

                                    ///dogs.addAll(resultCall)
                                    //dogs.flatMap {  }

                                    Observable.fromIterable(resultCall)
                                            .flatMap(Function<DogBreed, ObservableSource<List<DogImage>>>(){
                                                getRemoteService("https://api.thedogapi.com/v1/").getImageResults(it.id)//.onErrorReturnItem(listOf(DogImage(0,"0","https://www.clipartqueen.com/image-files/dog-silhouette-dalmatiner.jpg", 0)))//.onErrorReturn { listOf(DogImage(0,"0","https://www.clipartqueen.com/image-files/dog-silhouette-dalmatiner.jpg", 0)) }
                                            })
                                            .toList()
                                            .subscribeOn(Schedulers.io())
                                            .observeOn(AndroidSchedulers.mainThread())
                                            .subscribe ({ imageList ->
                                                Log.d("Jose", "The image url is ${imageList[0][0].url}")
                                                var index = 0
                                                if (imageList.isNotEmpty()) {
                                                    //Log.d("onImageCall", "Image list size should be ${resultCall.size}, it really is ${imageList[1].isEmpty()}")
                                                    resultCall.forEach {
                                                        if (imageList[index].isNotEmpty()) {
                                                            it.imageUrl = imageList[index][0].url
                                                            dogsFinal.add(it)
                                                        } else {
                                                            it.imageUrl = "https://www.clipartqueen.com/image-files/dog-silhouette-${it.breed_group}.jpg"
                                                            dogsFinal.add(it)
                                                        }

                                                        index++
                                                    }
                                                    data = gson.toJson(dogsFinal)
                                                    dogsFinal.clear()
                                                    result.success(data)
                                                }
                                            },
                                                { error -> Log.d("Jose", "ERROR IN API CALL Dog List ${error.message}")}

                                                )

//                          Log.d("getDogData", "Returned data is: ${dogs.get(1).name}")
//                          Log.d("DOGDATA", "Dog data is: $data")
//                          dogs = getImages(dogs)
                                    //dogs.clear()
                                    //Log.d("getDogData", "Temp dog list first name: ${tempDogs[0].name}")
                                    //val data = gson.toJson(tempDogs)
//                            Log.d("getDogData", "After images added to dog list: ${tempDogs[0].name}")
                                    //tempDogs.clear()
                                    //result.success(data)
                                },
                                { error -> Log.d("TAG", "ERROR IN API CALL Dog List ${error.message}")}
                                //{result.success(data)}
                        )
        )
    }

    private fun searchDogs(result: MethodChannel.Result, passedArgument: Any) {
        var data: String ?= "Hey it failed"
        disposables.add(getRemoteService("https://api.thedogapi.com/v1/").getSearchResults(passedArgument)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                //.doOnNext((List<DogBreed>) -> )
                //.doOnNext { reCall ->  }
                .subscribe(
                        {resultCall ->
                            //data = gson.toJson(resultCall)
                            //Log.d("getDogData", returnSearch)

                            ///dogs.addAll(resultCall)
                            //dogs.flatMap {  }

                            Observable.fromIterable(resultCall)
                                    .flatMap(Function<DogBreed, ObservableSource<List<DogImage>>>(){
                                        getRemoteService("https://api.thedogapi.com/v1/").getImageResults(it.id)//.onErrorReturnItem(listOf(DogImage(0,"0","https://www.clipartqueen.com/image-files/dog-silhouette-dalmatiner.jpg", 0)))//.onErrorReturn { listOf(DogImage(0,"0","https://www.clipartqueen.com/image-files/dog-silhouette-dalmatiner.jpg", 0)) }
                                    })
                                    .toList()
                                    .subscribeOn(Schedulers.io())
                                    .observeOn(AndroidSchedulers.mainThread())
                                    .subscribe { imageList ->
                                        var index = 0
                                        if(imageList.isNotEmpty()){
                                            //Log.d("onImageCall", "Image list size should be ${resultCall.size}, it really is ${imageList[1].isEmpty()}")
                                            resultCall.forEach{
                                                if (imageList[index].isNotEmpty()){
                                                    it.imageUrl = imageList[index][0].url
                                                    dogsFinal.add(it)
                                                } else{
                                                    it.imageUrl = "https://www.clipartqueen.com/image-files/dog-silhouette-${it.breed_group}.jpg"
                                                    dogsFinal.add(it)
                                                }

                                                index++
                                            }
                                            data = gson.toJson(dogsFinal)
                                            dogsFinal.clear()
                                            result.success(data)
                                        }

                                    }

//                          Log.d("getDogData", "Returned data is: ${dogs.get(1).name}")
//                          Log.d("DOGDATA", "Dog data is: $data")
//                          dogs = getImages(dogs)
                            //dogs.clear()
                            //Log.d("getDogData", "Temp dog list first name: ${tempDogs[0].name}")
                            //val data = gson.toJson(tempDogs)
//                            Log.d("getDogData", "After images added to dog list: ${tempDogs[0].name}")
                            //tempDogs.clear()
                            //result.success(data)
                        },
                        { error -> Log.d("TAG", "ERROR IN API CALL Dog List ${error.message}")}
                        //{result.success(data)}
                )
        )
    }

  private fun helloFromNativeCode(passedCase: Any): String {
    if(passedCase.equals("first")){
      Log.d("KOTLIN", "Made it to Native Code.")
      return "Hello from Native Android Code"
    }
    else if(passedCase.equals("second")){
      Log.d("KOTLIN", "Second Argument received")
      return "Second Argument received!"
    }
    else{
      Log.d("KOTLIN", "Search pass success: $passedCase")
      return "Search Success: $passedCase"
    }
  }

//  private fun getDogData(passedSearch: Any): String?{
//    var returnSearch: String
//
//    return returnSearch
//  }

//    fun getImages(dogBreeds: List<DogBreed>): ArrayList<DogBreed> {
//        var tempDogs = ArrayList<DogBreed>()
//        for (dog: DogBreed in dogBreeds){
//            getRemoteService().getImageResults(dog.id)
//                    .subscribeOn(Schedulers.io())
//                    .observeOn(AndroidSchedulers.mainThread())
//                    .subscribe(
//                            {dogImageList ->
//                                                                              if(dogImageList[0] != null){
//
//                                              }
//                                              Log.d("DogImageCall", "Breed id ${dog.id} image is: ${dogImageList[0].url}")
//                                                dog.imageUrl = dogImageList[0].url
//                                dog.imageUrl = "assets/minpin.jpeg"
//                                tempDogs.add(dog)
//                                Log.d("imageUrl", "image Url is: ${tempDogs.last().imageUrl}")
//                                //tempDogs.add(dog)
//                            },
//                            { error -> Log.d("TAG", "ERROR IN API CALL Photo ${error.message}")}
//                    )
//        }
//        return tempDogs
//    }

  private fun getRetrofit(url: String): Retrofit = Retrofit.Builder()
          .baseUrl(url)
          .addConverterFactory(GsonConverterFactory.create())
          .addCallAdapterFactory(RxJava2CallAdapterFactory.create())
          .build()

  private fun getRemoteService(url: String): RemoteService = getRetrofit(url).create(RemoteService::class.java)

    override fun onDestroy() {
        super.onDestroy()
        disposables.clear()
    }

//  private fun createRetrofit(): {
//
//  }
}
