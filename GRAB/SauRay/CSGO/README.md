# Introduction

This is the CSGO SauRay plugin for SourceMod.

For more information please visit: [sauray.tech](http://sauray.tech).

This plugin uses [IPC](https://en.wikipedia.org/wiki/Inter-process_communication) to communicate with the core SauRay binary. For the binary, [contact us](http://sauray.tech) directly.

# Features

* Accurate anti-wallhack (tackles dependent visibility and much more: see [here](http://sauray.tech) for more details).
* Ultra-high-latency support via specialized lookaheads
* Anti-anti-flash support
* Smoke support
* Sound origin (footsteps, gunfire) randomization
* Radar data randomization
* Supports instances with more than one daemon (see [Server launch procedure](#server-launch-procedure))
* A simple pipeline for map conversion to SauRay consumable form (see [Content preparation pipeline](#content-preparation-pipeline))

# Potential features (will be implemented with sufficient demand)

* Support for entities affecting visibility (i.e. doors)
* Linux support
* [traceroute](https://en.wikipedia.org/wiki/Traceroute) support for detecting artificially-high-latency players.

# Compilation procedure (Windows)

First, ensure than python3 is installed and that it is not from the Windows store.
If python3 from the Windows store is present, fully remove it from the system and re-install via officially provided packages from [here](https://www.python.org/downloads/).

Following that, execute the following batch script from the topmost level of a disk drive. This is to avoid running into max path length issues during build.

```
@echo off

rmdir /S /Q alliedmodders
mkdir alliedmodders
cd alliedmodders

:: If you don't have ambuild, do the following only once
:: git clone --recursive https://github.com/alliedmodders/ambuild
:: pip install ./ambuild

:: If you want YOUR sourcemod fork, change this url
git clone --recursive http://github.com/alliedmodders/sourcemod
git clone --recursive https://github.com/alliedmodders/metamod-source
git clone --recursive http://github.com/alliedmodders/hl2sdk hl2sdk-sdk2013
git clone --recursive --branch csgo http://github.com/alliedmodders/hl2sdk hl2sdk-csgo
git clone --recursive --branch tf2 http://github.com/alliedmodders/hl2sdk hl2sdk-tf2
git clone --recursive --branch l4d2 http://github.com/alliedmodders/hl2sdk hl2sdk-l4d2
git clone --recursive --branch css http://github.com/alliedmodders/hl2sdk hl2sdk-css

:: Make sure this path exists, and you have Visual Studio 2017 C++ build tools. You may have to find vcvars32.bat in your filesystem yourself
CALL "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars32.bat"
cd sourcemod
mkdir build
cd build

:: This command configures and builds SM, don't edit this

python ../configure.py --no-mysql -s sdk2013,csgo,tf2,css,l4d2
ambuild
```

Once this is done, place `sample_ext` in `alliedmodders\sourcemod\public`, open with Visual Studio and build.

# Server launch procedure

visit [https://steamcommunity.com/dev/managegameservers](https://steamcommunity.com/dev/managegameservers) to get your server key dubbed: **THISGSLTHERE**

Place it in the following command to launch your server while allowing community server discoverability:

```start srcds.exe -maxplayers_override 10 -game csgo -console -usercon +game_type 0 +game_mode 0 +mapgroup mg_active +map de_nuke +sauray_config_file sauray +sv_setsteamaccount THISGSLTHERE```

The `+sauray_config_file sauray` command line option provides to ability to specify which SauRay configuration this daemon will utilize. Each individual daemon will communicate with a different SauRay instance. The option `sauray_window_num` inside the configuration file specifies the target SauRay window.

# Content preparation pipeline

1. Use the contents of `bspsrc_1.4.0` (original repo: [https://github.com/ata4/bspsrc](https://github.com/ata4/bspsrc)) to decompile a `BSP` to `VMF`. You should try and exclude non-visible brushes.
2. Install [Blender 2.8+](https://www.blender.org/download/)
3. Import the following addons in the **following order**:
    * `blender_source_tools_3.1.1` (original repo: [http://steamreview.org/BlenderSourceTools/](http://steamreview.org/BlenderSourceTools/))
    * `io_import_vmf` (original repo: [https://github.com/lasa01/io_import_vmf](https://github.com/lasa01/io_import_vmf))
4. Configure the `import vmf` plugin to detect your game content directory from your `steamapps` folder.
5. Import the decompiled `VMF` in step one
6. Remove windows and doors. (Door support is reserved for future releases). If any models are missing add simple non-conservative occluders for them manually. Non-conservative occluders refer to ones that fit 'inside' the original object.
7. Export to `.OBJ`
8. Install [Blender 2.79](https://download.blender.org/release/Blender2.79/)
9. Install the export plugin provided in `content_pipeline\exporter` for the **2.79 install**.
10. Import `.OBJ` and export to `.TXT` from the 2.79 install. Ensure to place a single sun lamp to signify the sun direction in the map. This file is consumable by SauRay.

# Known limitations

* As of this release, weapon reload sounds emanate from last known player locations. This can be problematic during high-stakes matches as players can wander off considerably from their last known locations before initiating a weapon reload. This was addressed in our [vkQuake2](https://github.com/HonestGamingInc/vkQuake2_SauRay) port by always transmitting audio origins rather than relying on entity locations. A similar fix in SourceMod would require further modifications to server logic.
* Radar data will be randomized laterally. This is due to how CSGO consumes radar data. More specifically, radar coordinates are broadcasted and coordinate elevation is used client-side to provide vertical proximity hints to players. Ideally those hints should be packed as flags and (only 2D) radar data should be unicasted to individual players.
* Very infrequent flashing of players in wrong locations. Root cause(s) are uncertain at this time.

# Acknowledgements

We would like to thank the entirety of the [SourceMod community](https://www.sourcemod.net/) for the help in preparing this plugin.

Additional thanks to Robert from [classic.community](https://classic.community/) for his tireless playtesting efforts.
