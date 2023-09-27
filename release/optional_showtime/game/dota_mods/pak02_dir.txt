  ShowTime, a DOTA dashboard mod by AveYo to optionally display local time as hh:mm on the UI
  ------------------------------------------------------------------------------------------------------
  Label is positioned on top next to shards button while at dashboard / left to netgraph while ingame
  Refreshes every 5 seconds - once a second would work fine too - for hh:mm:ss must enlarge css labels
  
                                         ____________
                             cvar_setf  |           2|  GetConvarInt
                   _____________________|            |____________________
                  |  ___>___>___>___>___  cl_showmem  ___>___>___>___>___  |
                  |^|                   |            |                   | |
      LocalTime() | | DST               |____________|               DST |v| Date()         #ShowTime
              ____| |____________                             ___________| |_________     _____________
             |                 1 |___________________________|                      3|   |            4|
             | scripts /          ___<___<___<___<___<___<___  panorama /            |___| panorama /  |
             | vscripts /        |                           | layout /               ___  style /     |
             | framework /       |    SendCustomGameEvent    | shards_button.xml     |   | *.css       |
             | frameworkinit.lua |   DOTAGameUIStateChanged  | dota_hud_netgraph.xml |   | *.css       |
             |___________________|                           |_______________________|   |_____________|
                                                                                                          
  These scripts do not touch any gameplay elements, should be whitelist-able at a glance
  Knowing Valve have historically disabled specific modding features rather than carpet banning users
  Nothing bad should happen if there is any official griefing regarding this harmless dashboard mod
  Still, use at your own risk!

