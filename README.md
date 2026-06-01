# RetroScrape Modern

Aplicacion Flutter de scraping para bibliotecas retro, inspirada en el flujo de Skraper / SkraperUI.

## Funciones principales

- Interfaz moderna en una sola pantalla con biblioteca, sistemas, progreso, opciones, gamelist y vista previa.
- Icono profesional propio integrado en la build de Windows.
- Selector de idioma funcional: Espanol, English y Francais.
- Integracion con ScreenScraper usando busqueda por hashes y fallback por nombre de ROM.
- La llamada a ScreenScraper usa el idioma activo de la app (`es`, `en` o `fr`) para los metadatos.
- Contador diario de uso de la API ScreenScraper con llamadas usadas, limite real de la cuenta y aviso al alcanzar el tope.
- Calculo de CRC32, MD5, SHA1 y tamano de ROM.
- Escaneo recursivo de carpetas y ROMs dentro de `.zip`.
- Deteccion de sistema por carpeta y extension con IDs ScreenScraper actualizados.
- Mas de 75 sistemas de consola, portatil, arcade, ordenador y CD retro registrados.
- Panel de sistemas con selector visual, alta manual y ruta independiente por sistema.
- Cada sistema puede tener su propia ruta de ROMs.
- Los medios se guardan dentro de la carpeta de cada sistema, no en la raiz general.
- Descarga seleccionable de caja 2D, caja 3D, caja frontal, screenshot, screenshot titulo, logo/wheel, fanart, video, manual y mix.
- Cache local en `.retroscrape_cache` dentro de cada carpeta de sistema.
- Reutilizacion de medios ya descargados si no activas sobrescritura.
- Opciones de metadata: mayusculas/minusculas, decoraciones del nombre, region, articulos y sinopsis.
- Opciones de media: cache, sobrescritura, limpieza, optimizacion y procesos simultaneos.
- Exportacion a `gamelist.xml` para EmulationStation, Batocera, Recalbox y Retropie.
- Exportacion `LaunchBox.xml`.
- El `gamelist.xml` refleja los medios descargados: `image`, `thumbnail`, `marquee`, `video`, `manual`, `fanart`, `titleshot`, `boxart`, `screenshot`, `mix`, `wheel`, `box2d` y `box3d`.
- El nombre exportado del juego se limpia para usar el titulo real cuando ScreenScraper lo devuelve.
- Vista previa con imagen, titulo, plataforma, descripcion y datos basicos.

## Uso

1. Ejecuta la app con `flutter run -d windows`.
2. Elige la carpeta raiz de ROMs.
3. Abre configuracion y guarda tu usuario y contraseña de ScreenScraper.
4. Revisa los sistemas detectados o agrega sistemas manualmente.
5. Ajusta las opciones de Metadata, Media y Gamelist.
6. Pulsa `Iniciar scraping`.
7. Pulsa `Exportar` para generar el XML del frontend elegido.

Los medios se guardan en `media/` dentro de la carpeta de cada sistema. Por ejemplo: `roms/megadrive/media/`, `roms/nes/media/`, `roms/snes/media/`.

## Build Windows

Para compilar una version release:

```powershell
flutter build windows --release --dart-define=SS_DEV_ID=tu_id_dev --dart-define=SS_DEV_PASSWORD=tu_password_dev
```

La aplicacion final solo pide usuario y contraseña normal de ScreenScraper. Los valores `SS_DEV_ID` y `SS_DEV_PASSWORD` son credenciales internas del software y no deben publicarse en GitHub.

Ejecutable generado:

```text
build\windows\x64\runner\Release\retroscape_modern.exe
```

Para compilar y probar en modo debug:

```powershell
flutter build windows --debug
flutter run -d windows
```

## Notas conocidas

- Flutter puede mostrar avisos del paquete `file_picker` sobre implementaciones por defecto de Windows, Linux y macOS. Son avisos del paquete externo y no impiden compilar ni ejecutar la app.
- El limite diario de ScreenScraper se consulta desde la API oficial (`ssuserInfos.php`) mediante los campos `requeststoday` y `maxrequestsperday`, por lo que puede variar segun el nivel de la cuenta.
