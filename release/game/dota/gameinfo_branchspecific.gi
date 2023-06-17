"GameInfo"
{
    //
    // Branch-varying info, such as the game/title and app IDs, is in gameinfo_branchspecific.gi.
    // gameinfo.gi is the non-branch-varying content and can be integrated between branches.
    //

    game         "Dota 2"
    title        "Dota 2"

    FileSystem
    {
        SteamAppId               570
        BreakpadAppId            373300
        BreakpadAppId_Tools      375360

        // gameinfo_branchspecific.gi alternative to -language option for running mods is quite popular in China
        // and Valve have been less enthusiastic about hindering client-side modding in non-western world, wonder why
        SearchPaths
        {
            // These are optional language paths. They must be mounted first, which is why there are first in the list.
            // *LANGUAGE* will be replaced with the actual language name. Not mounted if not running a specific language.
            Game_Language        dota_*LANGUAGE*

            // These are optional low-violence paths. They will only get mounted if you are in a low-violence mode.
            Game_LowViolence     dota_lv

            // AveYo: here is a cleaner way to add mods, without messing the cfg/ path and other auto SearchPaths
            Game_NonTools        dota_mods

            Game                 dota
            Game                 core

            Mod                  dota

            Write                dota

            // These are optional language paths. They must be mounted first, which is why there are first in the list.
            // *LANGUAGE* will be replaced with the actual language name. Not mounted if not running a specific language.
            AddonRoot_Language   dota_*LANGUAGE*_addons

            AddonRoot            dota_addons

            // Note: addon content is included in publiccontent by default.
            PublicContent        dota_core
            PublicContent        core
        }
        AddonsChangeDefaultWritePath 0
        // restore original file: github.com/SteamDatabase/GameTracking-Dota2/blob/master/game/dota/gameinfo_branchspecific.gi
    }
}
