# 🔐 Guía de Seguridad - Información Sensible

## ⚠️ IMPORTANTE: Protección de Credenciales

Este proyecto contiene información sensible como **API Keys de Google Maps**. Sigue estos pasos para mantener tu proyecto seguro:

### 1. **Archivos que NUNCA deben subirse a GitHub**

```
✗ .env                          (configuración local con credenciales)
✗ .env.local                    (configuración local específica)
✗ google-services.json          (credenciales de Google)
✗ key.properties                (claves de firma)
✗ local.properties              (propiedades locales)
✗ *.jks, *.keystore             (almacenes de claves)
✗ secrets.json                  (cualquier archivo de secretos)
✗ AndroidManifest.xml           (contiene API Keys)
```

### 2. **Archivo .gitignore**

El archivo `.gitignore` ya está configurado para excluir archivos sensibles. Si necesitas agregar más exclusiones, edítalo.

### 3. **Cómo Manejar la API Key de Google Maps de Forma Segura**

#### Opción A: Restricciones en Google Cloud Console (Recomendado Ahora)

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona tu proyecto
3. Ve a **APIs & Services > Credenciales**
4. Haz clic en tu API Key
5. En **Restricciones de aplicación**, selecciona **Android app**
6. Agrega:
   - **Package name**: `com.example.horarios_emsa`
   - **SHA-1 certificate fingerprint**: Obtén esto ejecutando:
     ```bash
     keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
     ```
7. En **Restricciones de API**, selecciona:
   - ✅ Maps SDK for Android
   - ✅ Geocoding API
   - ❌ Cualquier otra API

Esto limita el uso de tu API Key solo a tu app con ese cert específico.

#### Opción B: Variables de Entorno (Mejor para Desarrollo)

1. Copia `.env.example` a `.env.local`:
   ```bash
   cp .env.example .env.local
   ```

2. Edita `.env.local` y agrega tus valores reales:
   ```
   GOOGLE_MAPS_API_KEY=AIzaSy...TuClaveAqui
   ```

3. **NUNCA hagas commit de `.env.local`** (ya está en .gitignore)

4. Para usar en tu app, tendrás que crear un package/sistema para leer estas variables

#### Opción C: Archivos Locales Ignorados

Crea un archivo `lib/config/secrets.dart.example`:
```dart
// No subir este archivo a git, es solo un ejemplo
class AppSecrets {
  static const String googleMapsApiKey = 'TU_API_KEY_AQUI';
}
```

Copía como `lib/config/secrets.dart` (ignorado por git)

### 4. **Antes de hacer Push a GitHub**

```bash
# Verifica que no hay archivos sensibles
git status

# Revisa qué archivos se van a subir
git diff --cached --name-only

# Si accidentalmente agregaste un archivo sensible:
git rm --cached .env
git commit --amend
```

### 5. **Si Ya Subiste Credenciales a GitHub**

⚠️ **ACCIÓN INMEDIATA REQUERIDA:**

1. Rota/elimina inmediatamente la API Key comprometida en Google Cloud Console
2. Genera una API Key nueva
3. Ejecuta:
   ```bash
   git filter-branch --tree-filter 'rm -f .env' HEAD
   git push --force
   ```
4. Avisa a GitHub: Settings > Security > Secret scanning

### 6. **Checklist antes de hacer Push**

- [ ] `.gitignore` está actualizado
- [ ] .env.local NO está en git
- [ ] API Keys NO están en AndroidManifest.xml (usar .env o config segura)
- [ ] No hay archivos .jks/.keystore en git
- [ ] `git status` no muestra archivos sensibles
- [ ] Has revisado `git diff --cached`

### 7. **Documentación para Desarrolladores**

Crea un `SETUP.md` en tu repo:

```markdown
## Setup para Desarrollo

1. Clone el proyecto
2. Copia `.env.example` a `.env.local`
3. Rellena `.env.local` con tus credenciales locales
4. Ejecuta `flutter pub get`
5. Abre con `flutter run`

**IMPORTANTE:** Nunca hagas commit de `.env.local`
```

---

## ✅ Resumen Rápido

| Archivo | ¿Subir a Git? | Razón |
|---------|---------------|-------|
| `.env.local` | ❌ NO | Contiene credenciales reales |
| `.env.example` | ✅ SÍ | Solo muestra qué variables se necesitan |
| `google-services.json` | ❌ NO | Credenciales de Google |
| `AndroidManifest.xml` | ⚠️ CUIDADO | Actualizar sin la API Key real |
| `key.properties` | ❌ NO | Claves de firma |
| `lib/config/secrets.dart` | ❌ NO | Si contiene credenciales reales |
| `lib/config/secrets.dart.example` | ✅ SÍ | Ejemplo para otros devs |

---

## 🔗 Recursos Útiles

- [Google Cloud Security Best Practices](https://cloud.google.com/docs/authentication/best-practices-applications)
- [GitHub Secret Scanning](https://docs.github.com/es/code-security/secret-scanning)
- [OWASP: Sensitive Data Exposure](https://owasp.org/www-project-top-ten/2017/A3_2017-Sensitive_Data_Exposure)

---

**Última actualización**: 12 de febrero de 2026
**Responsable**: Equipo de Desarrollo EMSA
