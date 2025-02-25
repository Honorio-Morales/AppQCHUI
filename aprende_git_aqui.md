# 📌 Guía Básica de Git

## 🚀 Introducción a Git
Git es un sistema de control de versiones distribuido que permite gestionar el historial de cambios en proyectos de software.

## 🔹 Configuración Inicial de Git
Antes de usar Git, necesitamos configurar nuestro nombre de usuario y correo electrónico globalmente:

```bash
git config --global user.name "Tu Usuario"
git config --global user.email "tuemail@example.com"
```
Estos datos nos identifican en proyectos colaborativos.

---

## 🏗️ Iniciar un Repositorio en Git
Para inicializar un repositorio en el directorio actual, usamos:

```bash
git init
```
Esto crea una carpeta oculta `.git`, que almacena el historial del proyecto.

---

## 🌿 Ramas en Git
En Git, las ramas permiten desarrollar funcionalidades en paralelo sin afectar la versión principal.

Al iniciar un repositorio, se crea automáticamente una rama llamada `master`, pero es común cambiar su nombre a `main`:

```bash
git branch -m main
```
Para verificar en qué rama estamos y qué cambios existen:

```bash
git status
```

### 🔹 Creación y Cambio de Ramas
Para crear una nueva rama y movernos a ella:

```bash
git branch nueva_rama
```
```bash
git checkout nueva_rama
```
O de manera más eficiente:

```bash
git switch -c nueva_rama
```

---

## 📸 Guardar Cambios en Git
### 🔹 Agregar Cambios al Área de Preparación (*Staging*)
Para añadir archivos al área de preparación:

```bash
git add archivo.txt  # Agregar un archivo específico
git add .            # Agregar todos los cambios
```

### 🔹 Crear un Commit
Un *commit* es una instantánea de nuestro código en un momento específico:

```bash
git commit -m "Descripción del cambio"
```

---

## 🔄 Desplazamiento entre Versiones
Para movernos entre versiones específicas:

```bash
git checkout <ID_DEL_COMMIT>
git switch --detach <ID_DEL_COMMIT>
git switch main  # Volver a la rama principal
```

---

## 🔥 Restauración de Cambios
### 🔹 Deshacer Cambios en el Área de Preparación
Para eliminar archivos del *staging*:

```bash
git reset HEAD archivo.txt
```

### 🔹 Deshacer Commits
Para movernos a un commit anterior y descartar los cambios posteriores:

```bash
git reset --hard <ID_DEL_COMMIT>
```
⚠️ **Cuidado:** `--hard` elimina cambios definitivamente.

Si queremos ver el historial de cambios y recuperar un commit borrado:

```bash
git reflog
```

---

## 🏷️ Uso de Tags en Git
Los *tags* sirven para marcar versiones importantes del proyecto.

```bash
git tag -a v1.0 -m "Versión 1.0"
git tag  # Listar todas las etiquetas
```

---

## 🔀 Fusionar Ramas (*Merge*)
Para combinar una rama con `main`:

```bash
git checkout main  # Ir a la rama principal
git merge nueva_rama
```

Si hay conflictos, debemos resolverlos manualmente, luego:

```bash
git add archivo_resuelto.txt
git commit -m "Resolviendo conflicto"
```

---

## 📂 Ignorar Archivos con `.gitignore`
Para evitar que ciertos archivos sean rastreados por Git, creamos un archivo `.gitignore`:

```bash
touch .gitignore
```
Ejemplo de contenido:

```
/node_modules/
*.log
*.env
```

---

## 📥 Guardar Cambios Temporalmente (*Git Stash*)
Si necesitamos cambiar de rama sin perder los cambios actuales:

```bash
git stash  # Guardar cambios sin hacer commit
git stash pop  # Recuperar los cambios
```
Para eliminar el stash:

```bash
git stash drop
```

---

## 🗑️ Eliminar Ramas
Cuando terminamos de trabajar en una rama, podemos eliminarla:

```bash
git branch -d nombre_rama
```
Si la rama no ha sido fusionada, usamos `-D`:

```bash
git branch -D nombre_rama
```

---

## 🔍 Ver Diferencias entre Cambios
Para comparar diferencias entre archivos o commits:

```bash
git diff  # Muestra los cambios no confirmados
git diff rama1 rama2  # Compara dos ramas
```

---

## 🛠️ Alias en Git
Para hacer comandos más cortos, podemos crear alias:

```bash
git config --global alias.tree "log --graph --pretty=oneline"
```
Ahora podemos ejecutar:

```bash
git tree
```

---

## 🔄 Investigar sobre `git revert`
📌 `git revert` se usa para deshacer un commit sin perder el historial. Recomendado en lugar de `git reset --hard`.

```bash
git revert <ID_DEL_COMMIT>
```
Esto crea un nuevo commit que revierte los cambios del anterior.

---

## 🚀 Reintegración de Ramas en `main`
Para integrar cambios de una rama secundaria a `main`:

```bash
git checkout main
git merge nombre_rama
```

---

📌 **¡Ahora ya tienes un resumen completo de los comandos esenciales de Git!** 🎉
