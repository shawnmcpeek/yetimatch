package com.daddoodev.yetimatch.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.daddoodev.yetimatch.auth.sendPasswordResetEmail
import com.daddoodev.yetimatch.auth.signInWithEmail
import kotlinx.coroutines.launch

@Composable
fun SignInScreen(
    message: String,
    onSuccess: () -> Unit,
    onGoToSignUp: () -> Unit,
    onCancel: () -> Unit
) {
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var error by remember { mutableStateOf<String?>(null) }
    var isLoading by remember { mutableStateOf(false) }
    var showForgotPassword by remember { mutableStateOf(false) }
    var forgotPasswordEmail by remember { mutableStateOf("") }
    var forgotPasswordError by remember { mutableStateOf<String?>(null) }
    var forgotPasswordSuccess by remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()
    val scrollState = rememberScrollState()

    Column(
        modifier = Modifier.padding(24.dp).verticalScroll(scrollState),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text(
            text = message,
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onSurface,
            textAlign = TextAlign.Center,
            modifier = Modifier.fillMaxWidth()
        )
        Spacer(modifier = Modifier.height(8.dp))

        OutlinedTextField(
            value = email,
            onValueChange = { email = it; error = null },
            label = { Text("Email") },
            singleLine = true,
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email),
            modifier = Modifier.fillMaxWidth()
        )
        OutlinedTextField(
            value = password,
            onValueChange = { password = it; error = null },
            label = { Text("Password") },
            singleLine = true,
            visualTransformation = PasswordVisualTransformation(),
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
            modifier = Modifier.fillMaxWidth()
        )

        error?.let { msg ->
            Text(
                text = msg,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.error,
                modifier = Modifier.fillMaxWidth()
            )
        }

        Button(
            onClick = {
                if (email.isBlank() || password.isBlank()) {
                    error = "Enter email and password"
                    return@Button
                }
                isLoading = true
                error = null
                scope.launch {
                    val result = signInWithEmail(email, password)
                    isLoading = false
                    result.fold(
                        onSuccess = { onSuccess() },
                        onFailure = { e -> error = e.message ?: "Sign in failed" }
                    )
                }
            },
            modifier = Modifier.fillMaxWidth(),
            enabled = !isLoading
        ) {
            Text("Sign in")
        }

        TextButton(onClick = onGoToSignUp) {
            Text("Need an account? Sign up")
        }

        TextButton(onClick = { showForgotPassword = true; forgotPasswordEmail = email; forgotPasswordError = null; forgotPasswordSuccess = false }) {
            Text("Forgot password?")
        }

        Spacer(modifier = Modifier.height(16.dp))
        TextButton(onClick = onCancel) {
            Text("Cancel")
        }
    }

    if (showForgotPassword) {
        AlertDialog(
            onDismissRequest = { showForgotPassword = false },
            title = { Text("Reset password") },
            text = {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    if (forgotPasswordSuccess) {
                        Text("Check your email for a link to reset your password.")
                    } else {
                        OutlinedTextField(
                            value = forgotPasswordEmail,
                            onValueChange = { forgotPasswordEmail = it; forgotPasswordError = null },
                            label = { Text("Email") },
                            singleLine = true,
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email),
                            modifier = Modifier.fillMaxWidth()
                        )
                        forgotPasswordError?.let { msg ->
                            Text(msg, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.error)
                        }
                    }
                }
            },
            confirmButton = {
                if (forgotPasswordSuccess) {
                    TextButton(onClick = { showForgotPassword = false }) { Text("OK") }
                } else {
                    Button(
                        onClick = {
                            if (forgotPasswordEmail.isBlank()) {
                                forgotPasswordError = "Enter your email"
                                return@Button
                            }
                            scope.launch {
                                forgotPasswordError = null
                                sendPasswordResetEmail(forgotPasswordEmail).fold(
                                    onSuccess = { forgotPasswordSuccess = true },
                                    onFailure = { e -> forgotPasswordError = e.message ?: "Failed to send reset email" }
                                )
                            }
                        }
                    ) { Text("Send reset link") }
                }
            },
            dismissButton = {
                TextButton(onClick = { showForgotPassword = false }) { Text("Cancel") }
            }
        )
    }
}
