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

- **En la misma red Wi-Fi:** `npm run dev` ya expone el servidor en la red (`host: true`). Abrir en el celular la dirección `Network` que muestra Vite (por ejemplo `http://192.168.0.10:5173`).
- **Desde cualquier lugar:** desplegar en Vercel/Netlify con las variables `VITE_SUPABASE_URL` y `VITE_SUPABASE_PUBLISHABLE_KEY`, y agregar un rewrite de todas las rutas a `index.html`.
- En **Authentication → URL Configuration**, agregar la URL que uses (`http://192.168.0.10:5173/login`, la de producción, etc.) a *Redirect URLs*. Si no está, el mail de confirmación apunta al *Site URL*.
- En el celular, el campo de imagen permite sacar la foto en el momento; se reduce automáticamente antes de subirla.

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
    RecuperarView.vue
    RegistroView.vue
  App.vue
  main.js
  supabase.js
```
