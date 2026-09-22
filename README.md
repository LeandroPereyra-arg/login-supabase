# Login y Registro con Supabase

Aplicación en Vue 3 con registro, inicio de sesión, recuperación de contraseña y una página privada, usando Supabase Auth.

## Funcionalidades

- Registro con correo y contraseña (`/registro`)
- Inicio de sesión (`/login`)
- Recuperación de contraseña por correo (`/recuperar` y `/nueva-contrasena`)
- Página privada con el correo del usuario y cierre de sesión (`/inicio`)
- Protección de rutas con `router.beforeEach`

## Configuración

1. Crear un proyecto en [Supabase](https://supabase.com) y copiar la Project URL y la Publishable Key desde **Connect**.
2. Copiar `.env.example` como `.env` y completar los valores:

   ```
   VITE_SUPABASE_URL=https://tu-proyecto.supabase.co
   VITE_SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
   ```

3. En **Authentication → URL Configuration → Redirect URLs**, agregar `http://localhost:5173/nueva-contrasena`.

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
