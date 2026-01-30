package com.daddoodev.yetimatch

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform