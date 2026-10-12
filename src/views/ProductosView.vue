<script setup>
import { onBeforeUnmount, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '@/supabase'

const router = useRouter()

const productos = ref([])
const nombre = ref('')
const descripcion = ref('')
const precio = ref('')
const stock = ref(0)
const activo = ref(true)

const archivoImagen = ref(null)
const vistaPrevia = ref('')
const imagenUrlExistente = ref('')
const imagenRutaExistente = ref('')
const inputImagen = ref(null)

const productoEditandoId = ref(null)
const cargando = ref(false)
const procesandoImagen = ref(false)
const mensaje = ref('')
const errorMensaje = ref('')

const TIPOS_PERMITIDOS = ['image/jpeg', 'image/png', 'image/webp']
const TAMANO_MAXIMO = 5 * 1024 * 1024
const LADO_MAXIMO = 1600
const EXTENSIONES = {
  'image/jpeg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
}

async function cargarProductos(limpiarMensaje = true) {
  cargando.value = true
  errorMensaje.value = ''
  if (limpiarMensaje) mensaje.value = ''

  const { data, error } = await supabase
    .from('productos')
    .select('*')
    .order('creado_en', { ascending: false })

  if (error) {
    errorMensaje.value = error.message
  } else {
    productos.value = data
  }

  cargando.value = false
}

// Las fotos del celular suelen pesar más de 5 MB: se reducen antes de subirlas.
async function reducirImagen(archivo) {
  if (archivo.size <= 1024 * 1024) return archivo

  try {
    const bitmap = await createImageBitmap(archivo, { imageOrientation: 'from-image' })
    const escala = Math.min(1, LADO_MAXIMO / Math.max(bitmap.width, bitmap.height))
    const canvas = document.createElement('canvas')
    canvas.width = Math.round(bitmap.width * escala)
    canvas.height = Math.round(bitmap.height * escala)
    canvas.getContext('2d').drawImage(bitmap, 0, 0, canvas.width, canvas.height)
    bitmap.close()

    const blob = await new Promise((resolve) => canvas.toBlob(resolve, 'image/jpeg', 0.85))
    if (!blob || blob.size >= archivo.size) return archivo

    return new File([blob], 'producto.jpg', { type: 'image/jpeg' })
  } catch {
    return archivo
  }
}

async function seleccionarImagen(evento) {
  errorMensaje.value = ''
  const original = evento.target.files?.[0]

  if (!original) {
    archivoImagen.value = null
    vistaPrevia.value = ''
    return
  }

  if (!TIPOS_PERMITIDOS.includes(original.type)) {
    errorMensaje.value = 'La imagen debe ser JPG, PNG o WEBP.'
    evento.target.value = ''
    return
  }

  procesandoImagen.value = true
  const archivo = await reducirImagen(original)
  procesandoImagen.value = false

  if (archivo.size > TAMANO_MAXIMO) {
    errorMensaje.value = 'La imagen no puede superar los 5 MB.'
    evento.target.value = ''
    return
  }

  if (vistaPrevia.value) URL.revokeObjectURL(vistaPrevia.value)

  archivoImagen.value = archivo
  vistaPrevia.value = URL.createObjectURL(archivo)
}

async function subirImagen() {
  if (!archivoImagen.value) return null

  const {
    data: { user },
    error: errorUsuario,
  } = await supabase.auth.getUser()

  if (errorUsuario || !user) {
    throw new Error('No hay un usuario autenticado.')
  }

  const extension = EXTENSIONES[archivoImagen.value.type]
  const ruta = `${user.id}/${crypto.randomUUID()}.${extension}`

  const { error: errorSubida } = await supabase.storage
    .from('productos')
    .upload(ruta, archivoImagen.value, {
      cacheControl: '3600',
      upsert: false,
    })

  if (errorSubida) throw errorSubida

  const { data } = supabase.storage.from('productos').getPublicUrl(ruta)

  return {
    url: data.publicUrl,
    ruta,
  }
}

async function guardarProducto() {
  errorMensaje.value = ''
  mensaje.value = ''

  if (!nombre.value.trim()) {
    errorMensaje.value = 'El nombre es obligatorio.'
    return
  }

  if (precio.value === '' || Number(precio.value) < 0) {
    errorMensaje.value = 'Ingresá un precio válido.'
    return
  }

  if (Number(stock.value) < 0) {
    errorMensaje.value = 'El stock no puede ser negativo.'
    return
  }

  if (!productoEditandoId.value && !archivoImagen.value) {
    errorMensaje.value = 'Seleccioná una imagen para el producto.'
    return
  }

  cargando.value = true
  let nuevaImagen

  try {
    nuevaImagen = await subirImagen()

    const datosProducto = {
      nombre: nombre.value.trim(),
      descripcion: descripcion.value.trim() || null,
      precio: Number(precio.value),
      stock: Number(stock.value),
      activo: activo.value,
      imagen_url: nuevaImagen?.url ?? imagenUrlExistente.value,
      imagen_ruta: nuevaImagen?.ruta ?? imagenRutaExistente.value,
    }

    let error

    if (productoEditandoId.value) {
      ;({ error } = await supabase
        .from('productos')
        .update(datosProducto)
        .eq('id', productoEditandoId.value))
    } else {
      ;({ error } = await supabase.from('productos').insert(datosProducto))
    }

    if (error) {
      if (nuevaImagen?.ruta) {
        await supabase.storage.from('productos').remove([nuevaImagen.ruta])
      }
      throw error
    }

    if (productoEditandoId.value && nuevaImagen?.ruta && imagenRutaExistente.value) {
      await supabase.storage.from('productos').remove([imagenRutaExistente.value])
    }

    mensaje.value = productoEditandoId.value
      ? 'Producto actualizado correctamente.'
      : 'Producto creado correctamente.'

    limpiarFormulario()
    await cargarProductos(false)
  } catch (error) {
    errorMensaje.value = error.message
  } finally {
    cargando.value = false
  }
}

function editarProducto(producto) {
  productoEditandoId.value = producto.id
  nombre.value = producto.nombre
  descripcion.value = producto.descripcion ?? ''
  precio.value = producto.precio
  stock.value = producto.stock
  activo.value = producto.activo
  imagenUrlExistente.value = producto.imagen_url ?? ''
  imagenRutaExistente.value = producto.imagen_ruta ?? ''
  archivoImagen.value = null
  errorMensaje.value = ''
  mensaje.value = ''

  if (vistaPrevia.value) URL.revokeObjectURL(vistaPrevia.value)
  vistaPrevia.value = ''

  if (inputImagen.value) inputImagen.value.value = ''
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

async function eliminarProducto(producto) {
  const confirmado = window.confirm(`¿Querés eliminar el producto "${producto.nombre}"?`)

  if (!confirmado) return

  cargando.value = true
  errorMensaje.value = ''
  mensaje.value = ''

  const { error } = await supabase.from('productos').delete().eq('id', producto.id)

  if (error) {
    errorMensaje.value = error.message
    cargando.value = false
    return
  }

  if (producto.imagen_ruta) {
    const { error: errorImagen } = await supabase.storage
      .from('productos')
      .remove([producto.imagen_ruta])

    if (errorImagen) {
      errorMensaje.value = 'El producto se eliminó, pero no se pudo borrar su imagen.'
    }
  }

  if (!errorMensaje.value) mensaje.value = 'Producto eliminado correctamente.'

  if (productoEditandoId.value === producto.id) limpiarFormulario()
  await cargarProductos(false)
  cargando.value = false
}

function limpiarFormulario() {
  nombre.value = ''
  descripcion.value = ''
  precio.value = ''
  stock.value = 0
  activo.value = true
  productoEditandoId.value = null
  archivoImagen.value = null
  imagenUrlExistente.value = ''
  imagenRutaExistente.value = ''

  if (vistaPrevia.value) URL.revokeObjectURL(vistaPrevia.value)
  vistaPrevia.value = ''

  if (inputImagen.value) inputImagen.value.value = ''
}

function cancelarEdicion() {
  limpiarFormulario()
  mensaje.value = ''
  errorMensaje.value = ''
}

async function cerrarSesion() {
  const { error } = await supabase.auth.signOut()

  if (error) {
    errorMensaje.value = error.message
    return
  }

  router.push('/login')
}

onMounted(cargarProductos)

onBeforeUnmount(() => {
  if (vistaPrevia.value) URL.revokeObjectURL(vistaPrevia.value)
})
</script>

<template>
  <main class="pagina-productos">
    <nav class="barra">
      <RouterLink to="/inicio">← Inicio</RouterLink>
      <button type="button" class="secundario chico" @click="cerrarSesion">Cerrar sesión</button>
    </nav>

    <section class="panel">
      <p class="etiqueta">Administración</p>
      <h1>{{ productoEditandoId ? 'Editar producto' : 'Nuevo producto' }}</h1>
      <p class="introduccion">Completá los datos y guardá una imagen JPG, PNG o WEBP.</p>

      <form class="formulario" @submit.prevent="guardarProducto">
        <label>
          Nombre
          <input v-model="nombre" type="text" maxlength="120" required />
        </label>

        <label>
          Descripción
          <textarea v-model="descripcion" rows="3"></textarea>
        </label>

        <div class="fila">
          <label>
            Precio
            <input v-model="precio" type="number" inputmode="decimal" min="0" step="0.01" required />
          </label>

          <label>
            Stock
            <input v-model="stock" type="number" inputmode="numeric" min="0" step="1" required />
          </label>
        </div>

        <label>
          Imagen del producto
          <input
            ref="inputImagen"
            type="file"
            accept="image/jpeg,image/png,image/webp"
            @change="seleccionarImagen"
          />
          <small>
            {{
              procesandoImagen
                ? 'Procesando imagen...'
                : 'Desde el celular podés sacar la foto o elegirla de la galería. Máximo 5 MB.'
            }}
          </small>
        </label>

        <div v-if="vistaPrevia || imagenUrlExistente" class="contenedor-vista-previa">
          <img
            :src="vistaPrevia || imagenUrlExistente"
            alt="Vista previa del producto"
            class="vista-previa"
          />
          <span v-if="vistaPrevia">Nueva imagen seleccionada</span>
          <span v-else>Imagen actual</span>
        </div>

        <label class="check">
          <input v-model="activo" type="checkbox" />
          Producto activo
        </label>

        <p v-if="errorMensaje" class="aviso error">{{ errorMensaje }}</p>
        <p v-if="mensaje" class="aviso exito">{{ mensaje }}</p>

        <div class="acciones-formulario">
          <button type="submit" :disabled="cargando || procesandoImagen">
            {{
              cargando
                ? 'Guardando...'
                : productoEditandoId
                  ? 'Actualizar producto'
                  : 'Crear producto'
            }}
          </button>

          <button
            v-if="productoEditandoId"
            type="button"
            class="secundario"
            @click="cancelarEdicion"
          >
            Cancelar
          </button>
        </div>
      </form>
    </section>

    <section class="panel">
      <div class="cabecera-listado">
        <div>
          <p class="etiqueta">Inventario</p>
          <h2>Mis productos</h2>
        </div>
        <button
          type="button"
          class="secundario chico"
          :disabled="cargando"
          @click="cargarProductos()"
        >
          Actualizar
        </button>
      </div>

      <p v-if="cargando && !productos.length">Cargando productos...</p>
      <p v-else-if="!productos.length" class="vacio">Todavía no creaste productos.</p>

      <div v-else class="tabla-contenedor">
        <table>
          <thead>
            <tr>
              <th>Imagen</th>
              <th>Producto</th>
              <th>Precio</th>
              <th>Stock</th>
              <th>Estado</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="producto in productos" :key="producto.id">
              <td class="celda-imagen">
                <img
                  v-if="producto.imagen_url"
                  :src="producto.imagen_url"
                  :alt="producto.nombre"
                  class="miniatura"
                />
                <span v-else class="sin-imagen">Sin imagen</span>
              </td>
              <td class="celda-nombre">
                <strong>{{ producto.nombre }}</strong>
                <small>{{ producto.descripcion || 'Sin descripción' }}</small>
              </td>
              <td data-etiqueta="Precio">${{ Number(producto.precio).toFixed(2) }}</td>
              <td data-etiqueta="Stock">{{ producto.stock }}</td>
              <td data-etiqueta="Estado">
                <span :class="['estado', producto.activo ? 'activo' : 'inactivo']">
                  {{ producto.activo ? 'Activo' : 'Inactivo' }}
                </span>
              </td>
              <td class="celda-acciones">
                <div class="acciones-tabla">
                  <button type="button" class="editar" @click="editarProducto(producto)">
                    Editar
                  </button>
                  <button type="button" class="eliminar" @click="eliminarProducto(producto)">
                    Eliminar
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
  </main>
</template>

<style scoped>
.pagina-productos {
  max-width: 960px;
  margin: 0 auto;
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.barra {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.panel {
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 10px 30px rgba(15, 23, 42, 0.08);
}

.etiqueta {
  margin: 0 0 4px;
  font-size: 0.75rem;
  font-weight: 700;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: #059669;
}

h2 {
  margin: 0;
  font-size: 1.3rem;
}

.introduccion {
  margin: 0 0 20px;
  color: #64748b;
}

.formulario {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.formulario label {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.formulario input,
.formulario textarea {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid #cbd5e1;
  border-radius: 8px;
  font: inherit;
  font-weight: 400;
}

.formulario textarea {
  resize: vertical;
}

.formulario small {
  font-weight: 400;
  color: #64748b;
}

.fila {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}

.check {
  flex-direction: row !important;
  align-items: center;
}

.check input {
  width: 20px;
  height: 20px;
}

.contenedor-vista-previa {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 6px;
  font-size: 0.85rem;
  color: #64748b;
}

.vista-previa {
  width: 100%;
  max-width: 240px;
  aspect-ratio: 1;
  object-fit: cover;
  border-radius: 8px;
  border: 1px solid #e2e8f0;
}

.aviso {
  margin: 0;
  padding: 10px 12px;
  border-radius: 8px;
  font-size: 0.9rem;
}

.aviso.exito {
  background: #dcfce7;
  color: #166534;
}

.aviso.error {
  background: #fee2e2;
  color: #991b1b;
}

.acciones-formulario {
  display: flex;
  gap: 8px;
}

button.chico {
  width: auto;
  padding: 8px 14px;
  font-size: 0.9rem;
}

.cabecera-listado {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  margin-bottom: 16px;
}

.vacio {
  color: #64748b;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th,
td {
  padding: 10px 8px;
  text-align: left;
  border-bottom: 1px solid #e2e8f0;
  vertical-align: middle;
}

th {
  font-size: 0.8rem;
  color: #64748b;
}

td small {
  display: block;
  color: #64748b;
}

.miniatura {
  width: 56px;
  height: 56px;
  object-fit: cover;
  border-radius: 8px;
}

.sin-imagen {
  font-size: 0.75rem;
  color: #94a3b8;
}

.estado {
  display: inline-block;
  padding: 2px 10px;
  border-radius: 999px;
  font-size: 0.8rem;
  font-weight: 600;
}

.estado.activo {
  background: #dcfce7;
  color: #166534;
}

.estado.inactivo {
  background: #e2e8f0;
  color: #475569;
}

.acciones-tabla {
  display: flex;
  gap: 8px;
}

.acciones-tabla button {
  width: auto;
  padding: 8px 14px;
  font-size: 0.9rem;
}

.editar {
  background: #0ea5e9;
}

.editar:hover:not(:disabled) {
  background: #0284c7;
}

.eliminar {
  background: #ef4444;
}

.eliminar:hover:not(:disabled) {
  background: #dc2626;
}

/* Celular: cada fila de la tabla pasa a ser una tarjeta. */
@media (max-width: 700px) {
  thead {
    display: none;
  }

  table,
  tbody,
  tr,
  td {
    display: block;
  }

  tr {
    display: grid;
    grid-template-columns: 72px 1fr;
    column-gap: 12px;
    padding: 12px 0;
    border-bottom: 1px solid #e2e8f0;
  }

  td {
    padding: 2px 0;
    border: none;
  }

  .celda-imagen {
    grid-row: span 4;
  }

  .miniatura {
    width: 72px;
    height: 72px;
  }

  td[data-etiqueta]::before {
    content: attr(data-etiqueta) ': ';
    color: #64748b;
    font-size: 0.85rem;
  }

  .celda-acciones {
    grid-column: 1 / -1;
    margin-top: 10px;
  }

  .acciones-tabla button {
    flex: 1;
    padding: 12px;
  }
}
</style>
