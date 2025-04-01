<<<<<<< HEAD
# Diccionario Quechua - QCHUI

QCHUI es una aplicación de traducción de Quechua a Español y viceversa, diseñada para facilitar el aprendizaje del idioma quechua a los estudiantes universitarios de nuestra casa de estudios UAC

## Tecnologías usadas
- **Flutter** (Dart) - Para el desarrollo de la app móvil  
- **Git & GitHub** - Para control de versiones y colaboración  
- ...

---

## Instalación y configuración  

### Requisitos previos  
Antes de comenzar, asegúrate de tener instalado:  
- [Flutter](https://docs.flutter.dev/get-started/install)  
- [Git](https://git-scm.com/)  
- Un editor de código como VS Code o Android Studio  

### Clonar el repositorio  
Ejecuta el siguiente comando en la terminal:  
```sh
git clone https://github.com/tu-usuario/appqchui.git
cd appqchui
```
---

## 🤝Contribuir  
Este proyecto es nuestro compas. <3 

> **Realiza los cambios** que consideres necesarios

Tu apoyo es fundamental para que este proyecto crezca y se convierta en una herramienta útil para la comunidad. ¡Gracias por contribuir!  

=======
# appchua

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

## Iniciamos con la aplicacion de nuestro traductor de quechua QCHUI

## Para iniciar en GIt
#### Primero necesitamos un nombre de Usuario y un correo *(usaremos una configuracion global)*
```
git config --global user.name "Tu usuario"
git config --global user.email "Tu email"
```
Esto es lo basico que necesitamos para iniciar con git en proyectos ***necesitamos una identificacion para trabajar en proyectos colaborativos***
___
Inicializar el contexto de un control de versiones en el directorio donde estamos
```
git init
```
___
**Ahora sobre las rama de Git**
> El codigo que nosoros vamos creando puede seguir diferentes flujos y cada rama tendria un nombre

Al iniciar un contexto de control de versiones con `git init` creamos una rama principal llamada `master` en nuestro caso lo cambiaremos por `main`

```
git branch -m main
```
> En git entenderiamos el flujo de que estamos trabajando en un repositorio, en una rama y la idea principal es que  *tomamos una fotografia en un punto a nuestro proyecto*. 

empezamremos por ver cual es el estado de nuestro proyecto. 
- La rama en la que estamos 
- Los `commits` que se hay
```
git status
```
para poner los cambios que hicimos y que aun no tenemos en estado usaremos:
```
git add
```

lo siguiente es lanzar un `commit`, que seria como hacer la fotografia en este momento
```
git commit -m "este es el primer commit"
```
para situarnos n un punto concreto
```
git checkout

git reset
```


A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
>>>>>>> master
