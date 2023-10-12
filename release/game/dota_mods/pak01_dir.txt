
  ShowMMR, a DOTA dashboard mod to bring back the mmr numbers now that rank changes are variable
  ------------------------------------------------------------------------------------------------------
  Numbers are displayed like in the old client - the Nov 19 2017 one still works - example: 12345 (+45)
  New numbers are saved locally per-user, serialized to JOY1 - JOY32 binds for up to 640 recent matches
  Your defined binds - that reside in slot0 - will not be affected
  Optionally retrieve previous history via ShowMMR tool, and replace local file with the generated one
  Toggle Settings - Video - High Quality Dashboard OFF to enable Last Match page with background.png 
                                        _______________________
                        SetTableValue  |                      3|    GetTableValue
                        _______________| scripts /             |____________________
                       |  __>___>___>__  custom_net_tables.txt  ___>___>___>___>__  |
                       |^|             |_______________________|                  |v|
                 ______| |_____                                     ______________| |_________________
                |             2|         SendCustomGameEvent       |                                 4|
                | scripts /    |___________________________________| panorama /                       |
  SendToConsole | vscripts /    ___<___<___<___<___<___<___<___<___  layout /                         |
   _____________| core /       |                                   | base.xml           DashboardCore |
  |  _<___<___<_  coreinit.lua |          DOTARankUpdated          |______________   _________________|
  | |           |______   _____| DOTAShowLocalProfileHeroStatsPage                | |                 
  | |                  | |               #ranked_mmr_value                        |v| core.Data.history
  |v|    LoadKeyValues |^|                                     ___________________| |_________________ 
  | |      ____________| |___________     ________________    |                                      5|
  | |     |                         1|   |               6|   | panorama /                            |
  | |_____|  cfg /                   |   | panorama /     |   | layout /                              |
  |____>__   user_keys_%d_slot3.vcfg |   | images /       |___| dashboard_page_profile_hero_stats.xml |
          |__________________________|   | background.png  ___  dashboard_background_last_match.*     |
                                         |________________|   |_______________________________________|

  If any game is running, only cached Data history is used when opening the hero stats page
  Back at dashboard, event signals script to retrieve #ranked_mmr_value and update table if needed
  It may look like a lot of work to just get a number from ui and save it in a table locally
  That is because vscript and panorama are finally hardened / crippled, no more ~arbitrary r/w!

  These scripts do not touch any gameplay elements, should be whitelist-able at a glance
  Knowing Valve have historically disabled specific modding features rather than carpet banning users
  Nothing bad should happen if there is any official griefing regarding this harmless dashboard mod
  Still, use at your own risk!

