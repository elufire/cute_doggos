package com.jbojorquez.cute_doggos

import android.app.Application
import com.jbojorquez.cute_doggos.dagger.NetworkModule
import dagger.Component
import io.flutter.app.FlutterApplication

@Component(modules = [NetworkModule::class])
interface ApplicationComponent {
    fun inject(activity: MainActivity)
}

class DogApplication : FlutterApplication() {
    val appComponent = DaggerApplicationComponent.create()

}