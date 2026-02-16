# ✅ Checklist Pre-Push a GitHub

## 🔐 **Seguridad (CRÍTICO)**

- [x] `.env` está en `.gitignore` ✅
- [x] No hay API Keys hardcodeadas en código ✅
- [x] `.env` no será subido a git ✅
- [ ] **Verificar que NO tienes archivos `.jks` o `.keystore` en el repo:**
  ```bash
  find . -name "*.jks" -o -name "*.keystore"
  ```
  Si aparecen, **ELIMÍNALOS** y verifica que estén en `.gitignore`

- [ ] **Verificar `local.properties`:**
  ```bash
  cat android/local.properties
  ```
  No debería subirse (está en `.gitignore`)

---

## 📝 **Archivos Necesarios**

- [x] `.env.example` con estructura de variables (sin valores reales) ✅
- [x] `SEGURIDAD.md` con documentación sobre protección de credenciales ✅
- [x] `.gitignore` exhaustivo ✅
- [ ] `README.md` (OPCIONAL pero recomendado):
  ```markdown
  # Gestión de Puestos EMSA
  
  App Flutter para gestión de puestos de trabajo con:
  - Google Maps integrado
  - Persistencia SQLite
  - Geocoding inverso
  - Direcciones por día
  
  ## Instalación
  
  1. Copia `.env.example` a `.env`
  2. Agrega tu API Key de Google Maps en `.env`
  3. `flutter pub get`
  4. `flutter run`
  ```

---

## 🔄 **Comandos Pre-Push**

```bash
# 1. Limpiar compilación anterior
flutter clean

# 2. Obtener dependencias
flutter pub get

# 3. Analizar código en busca de problemas
flutter analyze

# 4. Formatear código
dart format .

# 5. Verificar que NO vas a subir archivos sensibles
git status | grep -E "\\.env$|\\.jks$|\\.keystore$|local\\.properties$"

# 6. Hacer staging de archivos seguros
git add .

# 7. Verificar qué va a subirse
git status

# 8. Commit inicial
git commit -m "Initial commit: App Flutter para gestión de puestos EMSA"

# 9. Push a GitHub (reemplaza USERNAME/REPO)
git push -u origin main
```

---

## ⚠️ **IMPORTANTE: Variables Sensibles**

**NUNCA subas:**
- `.env` (usa `.env.example` como template)
- `*.jks` o `*.keystore` (claves de firma)
- `google-services.json` (si usas Firebase)
- `local.properties`
- Cualquier código con API Keys, tokens, passwords

**TODO DEBE IR EN `.env` LOCAL (no tracked)**

---

## 📋 **Verificación Final**

- [ ] `.env` existe localmente con API Key real
- [ ] `.env` está en `.gitignore`
- [ ] `.env.example` tiene estructura pero sin valores reales
- [ ] No hay archivos `.jks` o `.keystore` en el repo
- [ ] Código compila sin errores: `flutter run`
- [ ] SQLite persiste datos correctamente
- [ ] Google Maps funciona con API Key del `.env`

---

## ✅ **Estás Listo Para GitHub Cuando:**

1. ✅ Código compilable y funcionando locally
2. ✅ Credenciales en `.env` (no en código)
3. ✅ `.env` NO está en git (`.gitignore`)
4. ✅ `.env.example` existe como template
5. ✅ No hay certificados/claves privadas en repo
6. ✅ `SEGURIDAD.md` documentado
7. ✅ `README.md` con instrucciones de instalación

**Si todo está ✅, tu código es seguro para GitHub!**
