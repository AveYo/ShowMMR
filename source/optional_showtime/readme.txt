
  To install the mod:
  - open Steam > Library > Dota2 > right-click Properties > Installed files > Browse..
  - copy release/game/ subfolder over there, overwriting existing files:
  game/dota_mods/pak02_dir.vpk
  game/dota/gameinfo_branchspecific.gi
  - or skip gameinfo_branchspecific.gi and use instead launch option: -language mods

  To remake the mod from source:
  - need Dota2 Workshop Tools DLC for resourcecompile xml source files
  - run dota_mod_builder 2.bat, auto-compiled vpkmod will create the release vpk archive

  To explore release/game/dota_mods/pak02_dir.vpk and compiled *_c content:
  - use VRF tool by SteamDatabase: github.com/SteamDatabase/ValveResourceFormat/

