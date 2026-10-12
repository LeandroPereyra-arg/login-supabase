# Login y Registro con Supabase

Aplicación en Vue 3 con registro, inicio de sesión, recuperación de contraseña y una página privada, usando Supabase Auth.

## Funcionalidades

- Registro con correo y contraseña (`/registro`)
- Inicio de sesión (`/login`)
- Recuperación de contraseña por correo (`/recuperar` y `/nueva-contrasena`)
- Página privada con el correo del usuario y cierre de sesión (`/inicio`)
- ABM de productos con imagen (`/productos`): alta, listado, edición y baja, usando Supabase Database + Storage
- Protección de rutas con `router.beforeEach`

## Configuración

1. Crear un proyecto en [Supabase](https://supabase.com) y copiar la Project URL y la Publishable Key desde **Connect**.
2. Copiar `.env.example` como `.env` y completar los valores:

   ```
   VITE_SUPABASE_URL=https://tu-proyecto.supabase.co
   VITE_SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
   ```

3. En **Authentication → URL Configuration → Redirect URLs**, agregar `http://localhost:5173/nueva-contrasena`.

4. En **SQL Editor**, ejecutar el contenido de `supabase/productos.sql` (tabla `productos`, políticas RLS, bucket `productos` y políticas de Storage).

## Usarlo desde el celular

- **En la misma red Wi-Fi:** `npm run dev` expone el servidor en la red (`host: true`). Abrir en el celular la dirección `Network` que muestra Vite (por ejemplo `http://192.168.0.10:5173`) y agregarla a *Redirect URLs* en Supabase.
- **Desde cualquier lugar:** desplegar en Vercel (ver la siguiente sección).
- En el celular, el campo de imagen permite sacar la foto en el momento; se reduce automáticamente antes de subirla.

## Desplegar en Vercel

El repo ya incluye `vercel.json`, que redirige todas las rutas a `index.html` (sin eso, entrar directo a `/productos` o `/login` da error 404).

1. Entrar a [vercel.com/new](https://vercel.com/new) e iniciar sesión con GitHub.
2. Importar el repositorio `login-supabase`. Vercel detecta Vite automáticamente (build: `npm run build`, salida: `dist`).
3. En **Environment Variables**, antes de desplegar, cargar las mismas variables del `.env`:

   | Nombre | Valor |
   | --- | --- |
   | `VITE_SUPABASE_URL` | `https://tu-proyecto.supabase.co` |
   | `VITE_SUPABASE_PUBLISHABLE_KEY` | `sb_publishable_...` |

4. Hacer clic en **Deploy**. Vercel entrega una URL como `https://login-supabase-xxxx.vercel.app`.
5. En Supabase, en **Authentication → URL Configuration**:
   - **Site URL:** la URL de Vercel.
   - **Redirect URLs:** agregar `https://TU-URL.vercel.app/**`.

   Sin este paso, los mails de confirmación y de recuperación de contraseña abren `localhost` en lugar de la app desplegada.
6. Si todavía no se hizo, ejecutar `supabase/productos.sql` en el **SQL Editor** de Supabase.
7. Abrir la URL de Vercel en el celular, registrarse, confirmar el correo e iniciar sesión. Desde `/productos` se pueden crear, editar y eliminar productos.

Cada `git push` a `main` vuelve a desplegar la aplicación automáticamente. Si se cambian las variables de entorno en Vercel, hay que hacer un **Redeploy** para que se apliquen.

### Problemas frecuentes

- **El mail de confirmación abre `localhost`:** falta configurar *Site URL* y *Redirect URLs* en Supabase (paso 5).
- **Pantalla en blanco o "Invalid API key":** faltan o están mal las variables de entorno en Vercel; corregirlas y hacer *Redeploy*.
- **`new row violates row-level security policy` o error al subir imagen:** no se ejecutó `supabase/productos.sql`.
- **Error 404 al recargar `/productos`:** verificar que `vercel.json` esté en la raíz del repositorio.

## Ejecución

```sh
npm install
npm run dev
```

## Estructura

```
src/
  router/index.js
  views/
    InicioView.vue
    LoginView.vue
    NuevaContrasenaView.vue
    ProductosView.vue
    RecuperarView.vue
    RegistroView.vue
  App.vue
  main.js
  supabase.js
```
