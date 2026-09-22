<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '@/supabase'

const router = useRouter()

const contrasena = ref('')
const repetirContrasena = ref('')

const cargando = ref(false)
const mensaje = ref('')
const cambioExitoso = ref(false)

async function guardarContrasena() {
  mensaje.value = ''
  cambioExitoso.value = false

  if (contrasena.value !== repetirContrasena.value) {
    mensaje.value = 'Las contraseñas no coinciden.'
    return
  }

  if (contrasena.value.length < 6) {
    mensaje.value = 'La contraseña debe tener al menos 6 caracteres.'
    return
  }

  try {
    cargando.value = true

    const { error } = await supabase.auth.updateUser({
      password: contrasena.value,
    })

    if (error) {
      throw error
    }

    cambioExitoso.value = true
    mensaje.value = 'Contraseña actualizada correctamente.'

    router.push('/inicio')
  } catch (error) {
    if (error.message === 'New password should be different from the old password.') {
      mensaje.value = 'La nueva contraseña tiene que ser distinta de la anterior.'
    } else {
      mensaje.value = error.message
    }
  } finally {
    cargando.value = false
  }
}
</script>

<template>
  <main class="pagina-login">
    <section class="tarjeta-login">
      <h1>Nueva contraseña</h1>

      <p class="descripcion">Elegí una nueva contraseña para tu cuenta.</p>

      <form @submit.prevent="guardarContrasena">
        <div class="campo">
          <label for="contrasena">Nueva contraseña</label>

          <input
            id="contrasena"
            v-model="contrasena"
            type="password"
            placeholder="Mínimo 6 caracteres"
            autocomplete="new-password"
            required
          />
        </div>

        <div class="campo">
          <label for="repetir-contrasena">Repetir contraseña</label>

          <input
            id="repetir-contrasena"
            v-model="repetirContrasena"
            type="password"
            placeholder="Volvé a escribir la contraseña"
            autocomplete="new-password"
            required
          />
        </div>

        <button type="submit" :disabled="cargando">
          {{ cargando ? 'Guardando...' : 'Guardar contraseña' }}
        </button>
      </form>

      <p v-if="mensaje" class="mensaje" :class="{ exito: cambioExitoso, error: !cambioExitoso }">
        {{ mensaje }}
      </p>
    </section>
  </main>
</template>
