package com.daddoodev.yetimatch.preferences

import platform.Foundation.NSHomeDirectory
import platform.Foundation.NSString
import platform.Foundation.NSUTF8StringEncoding
import platform.Foundation.stringWithContentsOfFile
import platform.Foundation.writeToFile

private const val FILENAME = "yetimatch_age_verified.txt"

private fun ageVerifiedPath(): String {
    val home = NSHomeDirectory()
    return "$home/Documents/$FILENAME"
}

actual fun getAgeVerified(): Boolean {
    val path = ageVerifiedPath()
    val content = NSString.stringWithContentsOfFile(path, NSUTF8StringEncoding, null) as? String ?: return false
    return content.trim() == "true"
}

actual fun setAgeVerified(verified: Boolean) {
    val path = ageVerifiedPath()
    (verified.toString() as NSString).writeToFile(path, atomically = true, encoding = NSUTF8StringEncoding.toLong(), error = null)
}
