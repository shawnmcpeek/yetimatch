package com.daddoodev.yetimatch

import platform.Foundation.NSBundle
import platform.Foundation.NSUTF8StringEncoding
import platform.Foundation.NSString

actual fun loadManifestJson(): String {
    val path = NSBundle.mainBundle.pathForResource("manifest", "json", null)
        ?: error("manifest.json not found in bundle")
    return NSString.stringWithContentsOfFile(path, NSUTF8StringEncoding, null) as String
}

actual fun loadQuizJson(path: String): String {
    val slash = path.lastIndexOf('/')
    val subpath = if (slash >= 0) path.substring(0, slash) else null
    val filename = if (slash >= 0) path.substring(slash + 1) else path
    val dot = filename.lastIndexOf('.')
    val name = if (dot >= 0) filename.substring(0, dot) else filename
    val ext = if (dot >= 0) filename.substring(dot + 1) else "json"
    val resPath = NSBundle.mainBundle.pathForResource(name, ext, subpath)
        ?: error("Resource not found: $path")
    return NSString.stringWithContentsOfFile(resPath, NSUTF8StringEncoding, null) as String
}
