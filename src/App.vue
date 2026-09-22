<template>
  <RouterView />
</template>

<style>
* {
  box-sizing: border-box;
}

body {
  margin: 0;
  font-family:
    system-ui,
    -apple-system,
    'Segoe UI',
    Roboto,
    sans-serif;
  background: #f1f5f9;
  color: #0f172a;
}

.pagina-login,
.pagina-registro,
.pagina-inicio {
  min-height: 100vh;
  display: grid;
  place-items: center;
  padding: 16px;
}

.tarjeta-login,
.tarjeta-registro,
.tarjeta-inicio {
  width: 100%;
  max-width: 400px;
  background: #fff;
  border-radius: 12px;
  padding: 32px 28px;
  box-shadow: 0 10px 30px rgba(15, 23, 42, 0.08);
}

.tarjeta-inicio {
  text-align: center;
}

h1 {
  margin: 0 0 8px;
  font-size: 1.6rem;
}

.descripcion {
  margin: 0 0 24px;
  color: #64748b;
}

.campo {
  display: flex;
  flex-direction: column;
  gap: 6px;
  margin-bottom: 16px;
}

label {
  font-size: 0.9rem;
  font-weight: 600;
}

input {
  padding: 10px 12px;
  border: 1px solid #cbd5e1;
  border-radius: 8px;
  font-size: 1rem;
}

input:focus {
  outline: 2px solid #10b981;
  border-color: transparent;
}

button {
  width: 100%;
  padding: 11px;
  border: none;
  border-radius: 8px;
  background: #10b981;
  color: #fff;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
}

button:hover:not(:disabled) {
  background: #059669;
}

button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.mensaje {
  margin: 16px 0 0;
  padding: 10px 12px;
  border-radius: 8px;
  font-size: 0.9rem;
}

.mensaje.exito {
  background: #dcfce7;
  color: #166534;
}

.mensaje.error {
  background: #fee2e2;
  color: #991b1b;
}

.enlace-registro {
  margin: 20px 0 0;
  text-align: center;
  font-size: 0.9rem;
}

.enlace-olvido {
  margin: -6px 0 16px;
  text-align: right;
  font-size: 0.85rem;
}

a {
  color: #059669;
  font-weight: 600;
}

.icono {
  width: 56px;
  height: 56px;
  margin: 0 auto 16px;
  border-radius: 50%;
  background: #dcfce7;
}

.datos-usuario {
  display: flex;
  flex-direction: column;
  gap: 4px;
  margin: 24px 0;
  padding: 12px;
  border-radius: 8px;
  background: #f8fafc;
  word-break: break-all;
}

.datos-usuario span {
  font-size: 0.8rem;
  color: #64748b;
}
</style>
