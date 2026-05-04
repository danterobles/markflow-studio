# Workspace Spec

## Objetivo

Permitir que el usuario defina dónde se almacenan los datos.

## Features

- Seleccionar carpeta base
- Persistir configuración
- Detectar cambios externos
- Compatible con iCloud/Drive

## Estructura sugerida

workspace/
├── database/
├── assets/
├── exports/
├── config.json

## Reglas

- No depender del filesystem para lógica
- Separar DB de assets
