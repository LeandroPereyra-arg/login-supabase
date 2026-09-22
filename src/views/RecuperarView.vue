<script setup>
import { ref } from 'vue'
import { supabase } from '@/supabase'

const correo = ref('')

const cargando = ref(false)
const mensaje = ref('')
const envioExitoso = ref(false)

async function enviarEnlace() {
  mensaje.value = ''
  envioExitoso.value = false

  try {
    cargando.value = true

    const { error } = await supabase.auth.resetPasswordForEmail(correo.value, {
      redirectTo: `${window.location.origin}/nueva-contrasena`,
    })

    if (error) {
      throw error
    }

    envioExitoso.value = true
    mensaje.value =
      'Si el correo está registrado, vas a recibir un enlace para crear una nueva contraseña.'

    correo.value = ''
  } catch (error) {
    mensaje.value = error.message
  } finally {
    cargando.value = false
  }
}
</script>

<template>
  <main class="pagina-login">
    <section class="tarjeta-login">
      <h1>Recuperar contraseña</h1>

      <p class="descripcion">
        Escribí tu correo electrónico y te enviaremos un enlace para restablecerla.
      </p>

      <form @submit.prevent="enviarEnlace">
        <div class="campo">
          <label for="correo">Correo electrónico</label>

          <input
            id="correo"
            v-model="correo"
            type="email"
            placeholder="nombre@correo.com"
            autocomplete="email"
            required
          />
        </div>

        <button type="submit" :disabled="cargando">
          {{ cargando ? 'Enviando...' : 'Enviar enlace' }}
        </button>
      </form>

      <p v-if="mensaje" class="mensaje" :class="{ exito: envioExitoso, error: !envioExitoso }">
        {{ mensaje }}
      </p>

      <p class="enlace-registro">
        ¿Te acordaste?

        <RouterLink to="/login">Volver al login</RouterLink>
      </p>
    </section>
  </main>
</template>
