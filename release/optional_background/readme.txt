
  To install the mod:
  - open Steam > Library > Dota2 > right-click Properties > Installed files > Browse..
  - copy release/game/ subfolder over there, overwriting existing files:
  game/dota_mods/pak01_dir.vpk
  game/dota/gameinfo_branchspecific.gi
  - or skip gameinfo_branchspecific.gi and use instead launch option: -language mods

  To remake the mod from source:
  - need Dota2 Workshop Tools DLC for resourcecompile xml source files
  - run dota_mod_builder.bat, auto-compiled vpkmod will create the release vpk archive
  - this builder version will use a background.png if present in the same folder

  To explore release/game/dota_mods/pak01_dir.vpk and compiled *_c content:
  - use VRF tool by SteamDatabase: github.com/SteamDatabase/ValveResourceFormat/

