package com.jbojorquez.cute_doggos

import android.os.Bundle
import android.util.Log
import com.google.firebase.database.FirebaseDatabase
import com.google.firebase.storage.FirebaseStorage
import com.google.firebase.storage.StorageReference
import com.google.gson.Gson

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers
import io.reactivex.disposables.CompositeDisposable
import io.flutter.plugin.common.EventChannel
import io.reactivex.subjects.PublishSubject
import java.util.*
import javax.inject.Inject
import kotlin.collections.ArrayList

const val SEARCH_DOGS = "SEARCH_DOGS"
const val GET_ALL_DOGS = "GET_ALL_DOGS"
const val DOGS_STREAM = "DOGS_STREAM"

class MainActivity: FlutterActivity(), EventChannel.StreamHandler {

    private val CHANNEL = "flutter.native/helper"
    private val gson = Gson()
    private val disposables = CompositeDisposable()
    private val dogEvents = PublishSubject.create<String>()
    lateinit var disposableAllDogs: Disposable
    lateinit var disposableDogImages: Disposable
    lateinit var disposableSearchDogs: Disposable
    lateinit var disposableDogEvents: Disposable
    val database = FirebaseDatabase.getInstance()
    val firebaseStorage = FirebaseStorage.getInstance()
    val storageRef = firebaseStorage.reference
    val myRef = database.getReference("BaseDb")
    @Inject lateinit var dogRepo : DogRepository
    var isComplete = true
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        (applicationContext as DogApplication).appComponent.inject(this)
        Log.d("Jose", "The dog is: ${myRef.child("pomeranian").key}")

        val eventChannel = EventChannel(flutterView, DOGS_STREAM)
        eventChannel.setStreamHandler(this)

        Log.d("KOTLIN", "Made it to Native Code.")
        MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
            val passedArgument = call.arguments
            if (call.method == "helloFromNativeCode") {
                val greetings = helloFromNativeCode(passedArgument)
                result.success(greetings)
            }
            when(call.method) {
                  SEARCH_DOGS -> searchDogs(result, passedArgument)
                  GET_ALL_DOGS -> getAllDogs()
            }
        }
        GeneratedPluginRegistrant.registerWith(this)
  }

    private fun getAllDogs() {

        if(!isComplete) {
            disposableAllDogs.dispose()
            disposableDogImages.dispose()
        }
        isComplete = false
        var data: String = "Hey it failed"
        disposableAllDogs = dogRepo.getAllDogs()
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(
                        {resultCall ->
                            getDogImages(resultCall)
                        },
                        { error -> Log.d("TAG",
                                "ERROR IN API CALL Dog List ${error.message}")}
                )
        disposables.add(
               disposableAllDogs
        )
    }

    private fun getDogImages(resultCall: List<DogBreed>) {
        var dogsFinal = ArrayList<DogBreed>()
        var data: String ?= "Hey it failed"
        var index = 0
        disposableDogImages = Observable.fromIterable(resultCall)
                .flatMap {
                    dogRepo.getDogImages(it.id)
                }
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .doOnComplete{ isComplete = true }
                .subscribe { imageList ->

                    if(imageList.isNotEmpty()){
                        if (!imageList[0].url.isEmpty()) {
                            resultCall[index].imageUrl = imageList[0].url
                            dogsFinal.add(resultCall[index])
                        } else {
                            Log.d("Jose", "Missing dog image url is ${storageRef.child(resultCall[index].name.toLowerCase(Locale.ROOT).replace(" ", "_")).downloadUrl.result.toString()}")
//                            myRef.child(resultCall[index].name.toLowerCase(Locale.ROOT).replace(" ", "_")).key?.let {
//                                resultCall[index].imageUrl = it
//                            }
                            dogsFinal.add(resultCall[index])
                        }
                    } else {
//                        resultCall[index].imageUrl =
//                                "https://www.clipartqueen.com/image-files/dog-silhouette-" +
//                                        "${resultCall[index].breed_group}.jpg"
                        Log.d("Jose", "Missing dog image url is ${storageRef.child(resultCall[index].name.toLowerCase(Locale.ROOT).replace(" ", "_")).downloadUrl.result.toString()}")
//                        storageRef.child(resultCall[index].name.toLowerCase(Locale.ROOT).replace(" ", "_")).downloadUrl.result.toString() let {
//                            resultCall[index].imageUrl = it
//                        }
                        dogsFinal.add(resultCall[index])
                    }
                    index++
                    data = gson.toJson(dogsFinal)
                    dogEvents.onNext(gson.toJson(dogsFinal))
                }
        disposables.add(disposableDogImages)
    }

    private fun searchDogs(result: MethodChannel.Result, passedArgument: Any) {
        var data: String ?= "Hey it failed"
        disposableAllDogs.dispose()
        disposableDogImages.dispose()
        disposableSearchDogs = dogRepo.searchDogs(passedArgument)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(
                        {resultCall ->
                            getDogImages(resultCall)
                        },
                        { error -> Log.d("TAG", "ERROR IN API CALL Dog List " +
                                "${error.message}")}
                )
        disposables.add(
            disposableSearchDogs
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

    override fun onListen(p0: Any?, events: EventChannel.EventSink) {
        Log.d("Jose", "adding listener")
        disposableDogEvents = dogEvents
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe {
                    events.success(it)
                }
    }

    override fun onCancel(p0: Any?) {
        Log.d("Jose", "cancelling listener")
    }

    override fun onDestroy() {
        super.onDestroy()
        disposables.clear()
    }
}
