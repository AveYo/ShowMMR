/* 2>nul || @title DOTA MOD BUILDER by AveYo v10c

@set "OVERRIDE_STEAM_PATH_IF_NEEDED="
@set "OVERRIDE_DOTA2_PATH_IF_NEEDED="

:: can rename this script, ex: "dota_mod_builder 3.bat" to output pak03_dir.vpk instead of default pak01_dir.vpk
@call :init
set "SOURCE=%~dp0dota"
set "RELEASE=%~dp0release"
set "FILE=pak01_dir"
for %%i in (%~n0) do if %%i gtr 0 if %%i lss 10 set "FILE=pak0%%i_dir"
if not exist "%SOURCE%\*" set "SOURCE=" & echo Select SOURCE folder:
set "f=[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms');"
set "b=$FB=New-Object System.Windows.Forms.FolderBrowserDialog -Property @{ SelectedPath = '%~dp0' };"
set "d=[void]$FB.ShowDialog();$FB.SelectedPath;"
if not defined SOURCE for /f "delims=" %%q in ('powershell -c "%f%;%b%;%d%"') do set "SOURCE=%%q"
if /i "%SOURCE%"=="%~dp0" %<%:e4 " No SOURCE folder selected! "%>% & pause & exit /b

echo; & %<%:70 " Setup paths "%>%
echo  SOURCE  = %SOURCE%
echo  RELEASE = %RELEASE%
echo  FILE    = %FILE%.vpk
echo  DOTA2   = %DOTA2%

:: this builder version requires background.png being present in source folder
set "IMAGE=%SOURCE%\background.png"
if not exist "%IMAGE%" echo; & %<%:e4 " No background.png in SOURCE folder! "%>% & pause & exit /b

echo Cleaning RELEASE folder
(del /f/s/q "%RELEASE%\*.*" & rmdir /s/q "%RELEASE%") >nul 2>nul
(mkdir "%RELEASE%\working\" "%RELEASE%\game\dota" "%RELEASE%\game\dota_mods") >nul 2>nul

echo Retrieving SOURCE files
xcopy "%SOURCE%\*.*" "%RELEASE%\working" /E/C/I/Q/H/R/K/Y/Z >nul 2>nul
move /y "%RELEASE%\working\background.png" "%RELEASE%\working\panorama\images\dashboard_background_default.png" >nul 2>nul

if not exist %resourcecompiler% (
  %<%:60 " WARNING "%>>%  &  echo; resourcecompiler.exe not found! Install Dota 2 Workshop Tools if source needs compiling
  goto no_resourcecompiler
)
%<%:70 " Resource compiling as needed "%>>% & %<%:c0 " DON`T INTERRUPT! "%>%
pushd "%RELEASE%\working"
if exist "%dota2%\game\dota\gameinfo.gi" ren "%dota2%\game\dota" "dota_mod_in_progress"
if exist "%dota2%\content\dota\maps\dota.vmap" ren "%dota2%\content\dota" "dota_mod_in_progress"
mkdir "%dota2%\content\dota" "%dota2%\game\dota" >nul 2>nul
xcopy /E/C/I/Q/H/R/K/Y/Z "*.*" "%dota2%\content\dota\"
%resourcecompiler% -r -nop4 -game "%dota2%\game\dota_mod_in_progress" "%dota2%\content\dota\*.*"
xcopy /E/C/I/Q/H/R/K/Y/Z "%dota2%\game\dota\*.*" "%RELEASE%\working\"
if exist "%dota2%\game\dota_mod_in_progress\gameinfo.gi" if not exist "%dota2%\game\dota\gameinfo.gi" (
  rmdir /s/q "%dota2%\game\dota" >nul 2>nul
)
if exist "%dota2%\content\dota_mod_in_progress\maps\dota.vmap" if not exist "%dota2%\game\dota\maps\dota.vmap" (
  rmdir /s/q "%dota2%\content\dota" >nul 2>nul
)
ren "%dota2%\game\dota_mod_in_progress" "dota" >nul 2>nul
ren "%dota2%\content\dota_mod_in_progress" "dota" >nul 2>nul
%<%:70 " Resource compiling done "%>%
:no_resourcecompiler

echo Removing source files that were compiled
pushd "%RELEASE%\working"
for /f "delims=" %%A in ('dir /a:-D/b/s') do for /f "delims=." %%Z in ('echo %%~xA') do (
 if exist "%%~fA_c" ( del /f/q "%%~A" ) else if exist "%%~dpnA.v%%Z_c" del /f/q "%%~A"
)
del /f/s/q *.png *.psd >nul 2>nul
pushd "%~dp0"

echo ValvePak-ing working folder to RELEASE
%vpkmod% -i "%RELEASE%\working" -r -o "%RELEASE%\game\dota_mods\%FILE%.vpk"

echo Cleaning working folder
(del /f/s/q "%RELEASE%\working\*.*" & rmdir /s/q "%RELEASE%\working") >nul 2>nul

echo Exporting gameinfo
call :export gameinfo > "%RELEASE%\game\dota\gameinfo_branchspecific.gi"

echo Exporting readme
if exist "%SOURCE%\readme.txt" copy /y "%SOURCE%\readme.txt" "%RELEASE%\game\dota_mods\%FILE%.txt"
call :export readme > "%RELEASE%\readme.txt"
call :export readme

%<%:2f " DONE "%>%

echo Press any key to also install the mod or Alt+F4 to exit...
timeout /t -1 >nul
mkdir "%dota2%\game\dota_mods"  >nul 2>nul
copy /y "%RELEASE%\game\dota_mods\*.*" "%dota2%\game\dota_mods\" >nul 2>nul
copy /y "%RELEASE%\game\dota\gameinfo_branchspecific.gi" "%dota2%\game\dota\" >nul 2>nul

exit /b

:init
@echo off & chcp 1252 >nul & cls
::# detect STEAM path
for /f "tokens=2*" %%R in ('reg query HKCU\SOFTWARE\Valve\Steam /v SteamPath 2^>nul') do set "steam_reg=%%S" & set "libfs="
if not exist "%STEAM%\steamapps\libraryfolders.vdf" for %%S in ("%steam_reg%") do set "STEAM=%%~fS"
if defined OVERRIDE_STEAM_PATH_IF_NEEDED set "STEAM=%OVERRIDE_STEAM_PATH_IF_NEEDED%"
::# detect DOTA2 path
for /f usebackq^ delims^=^"^ tokens^=4 %%s in (`findstr /c:":\\" "%STEAM%\SteamApps\libraryfolders.vdf"`) do (
 if exist "%%s\steamapps\appmanifest_570.acf" if exist "%%s\steamapps\common\dota 2 beta\game\core\pak01_dir.vpk" set "libfs=%%s")
set "STEAMAPPS=%STEAM%\steamapps"& if defined libfs set "STEAMAPPS=%libfs:\\=\%\steamapps"
set "DOTA2=%STEAMAPPS%\common\dota 2 beta"
if defined OVERRIDE_DOTA2_PATH_IF_NEEDED set "DOTA2=%OVERRIDE_DOTA2_PATH_IF_NEEDED%"
::# lean xp+ color macros by AveYo:  %<%:af " hello "%>>%  &  %<%:cf " w\"or\"ld "%>%   for single \ / " use .%|%\  .%|%/  \"%|%\"
for /f "delims=:" %%s in ('echo;prompt $h$s$h:^|cmd /d') do set "|=%%s"&set ">>=\..\c nul&set /p s=%%s%%s%%s%%s%%s%%s%%s<nul&popd"
set "<=pushd "%appdata%"&2>nul findstr /c:\ /a" &set ">=%>>%&echo;" &set "|=%|:~0,1%" &set /p s=\<nul>"%appdata%\c"
::# check required paths
if not exist "%STEAM%\steamapps\libraryfolders.vdf" (
  %<%:cf " ERROR "%>>%  &  %<%:70 " STEAM not found! Set it manually in the script "%>%  & timeout -1 >nul & exit
)
if not exist "%DOTA2%\game\core\pak01_dir.vpk" (
  %<%:cf " ERROR "%>>%  &  %<%:70 " DOTA2 not found! Set it manually in the script "%>%  & timeout -1 >nul & exit
)
set resourcecompiler="%DOTA2%\game\bin\win64\resourcecompiler.exe"
set vpkmod="%~dp0vpkmod.exe"
if not exist %vpkmod% call :csc_compile_vpkmod_tool & if not exist %vpkmod% (
  %<%:cf " ERROR "%>>%  &  %<%:70 " compiling VPKMOD C# code! Needs .net framework 4.0 or VS2010+ "%>%  & timeout -1 >nul & exit
)
%<%:0f "                "%>>% & %<%:4f " DOTA "%>>%  &  %<%:2f " MOD "%>>% &  %<%:9f " BUILDER "%>%
exit /b

:export usage: call :export NAME
setlocal enabledelayedexpansion || Prints all text between lines starting with :NAME:[ and :NAME:] - A pure batch snippet by AveYo
set [=&for /f "delims=:" %%s in ('findstr /nbrc:":%~1:\[" /c:":%~1:\]" "%~f0"')do if defined [ (set /a ]=%%s-3)else set /a [=%%s-1
<"%~fs0" ((for /l %%i in (0 1 %[%) do set /p =)&for /l %%i in (%[% 1 %]%) do (set txt=&set /p txt=&echo(!txt!)) &endlocal &exit /b

:readme:[

  To install the mod:
  - open Steam > Library > Dota2 > right-click Properties > Installed files > Browse..
  - copy release/game/ subfolder over there, overwriting existing files:
  game/dota_mods/pak01_dir.vpk
  game/dota/gameinfo_branchspecific.gi
  - or skip gameinfo_branchspecific.gi and use instead launch option: -language mods

  To remake the mod from source:
  - need Dota2 Workshop Tools DLC for resourcecompile xml source files
  - run dota_mod_builder.bat, auto-compiled vpkmod will create the release vpk archive

  To explore release/game/dota_mods/pak01_dir.vpk and compiled *_c content:
  - use VRF tool by SteamDatabase: github.com/SteamDatabase/ValveResourceFormat/

:readme:]

:: gameinfo_branchspecific.gi is used atm instead of launch option: -language mods
:gameinfo:[
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
            // AveYo: here is a cleaner way to add mods, without messing the cfg/ path and other auto SearchPaths
            Game_NonTools        dota_mods

            // These are optional language paths. They must be mounted first, which is why there are first in the list.
            // *LANGUAGE* will be replaced with the actual language name. Not mounted if not running a specific language.
            Game_Language        dota_*LANGUAGE*

            // These are optional low-violence paths. They will only get mounted if you are in a low-violence mode.
            Game_LowViolence     dota_lv

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
:gameinfo:]

:csc_compile_vpkmod_tool used to create vpk archive
for /f "tokens=* delims=" %%v in ('dir /b /s /a:-d /o:-n "%SystemRoot%\Microsoft.NET\Framework\*csc.exe"') do set "csc=%%v"
pushd %~dp0 & "%csc%" /out:vpkmod.exe /target:exe /platform:anycpu /optimize /nologo "%~f0"
exit /b VPKMOD C# source */

using System; using System.IO; using System.Collections.Generic; using System.Linq; using System.Text; using System.Net;
using System.Diagnostics; using System.Reflection; using System.Security.Cryptography; using System.Runtime.CompilerServices;
using SteamDB.ValvePak; [assembly:AssemblyDescriptionAttribute("VPKMOD 2.3")] [assembly: AssemblyTitle("AveYo")]
[assembly:AssemblyVersionAttribute("2023.01.12")]

class Program
{
    // VPKMOD v2.3 retains the useful v1.x legacy code based on Decompiler by SteamDB
    // so it continues to be a generic tool to list, extract, create, filter and in-memory mod VPKs
    // The main focus however is on supporting No-Bling DOTA mod builder functionality [stripped]

    private static Options Options;
    private static readonly object ConsoleWriterLock = new object();
    private static Dictionary<string,uint> OldPakManifest = new Dictionary<string,uint>();
    private static Dictionary<string,Dictionary<string,bool>> ModSrc = new Dictionary<string,Dictionary<string,bool>>();
    private static Dictionary<string,string> SrcMod = new Dictionary<string,string>();
    private static List<string> FileFilter = new List<string>();
    private static List<string> ExtFilter = new List<string>();
    private static bool ExportFilter = false;

    public static void Main(string[] args)
    {
        Options = new Options(args);

        // Legacy VPKMOD v1 functions:
        if (String.IsNullOrEmpty(Options.Input))
        {
            Echo("Missing -i input parameter!", ConsoleColor.Red);
            return;
        }
        Options.Input = SlashPath(Path.GetFullPath(Options.Input));

        if (!String.IsNullOrEmpty(Options.Output)) Options.Output = SlashPath(Path.GetFullPath(Options.Output));

        if (!String.IsNullOrEmpty(Options.ModList))
        {
            Options.ModList = SlashPath(Path.GetFullPath(Options.ModList));
            if (File.Exists(Options.ModList))
            {
                var file = new StreamReader(Options.ModList);
                string line, ext, mod, src;
                Dictionary<string,bool> m = new Dictionary<string,bool>();
                while ((line = file.ReadLine()) != null)
                {
                    var split = line.Split(new[] { '?' }, 2);
                    if (split.Length == 2)
                    {
                        mod = SlashPath(split[0]);
                        src = SlashPath(split[1]);
                        FileFilter.Add(src);
                        ext = Path.GetExtension(src);
                        if (ext.Length > 1) ExtFilter.Add(ext.Substring(1));
                        SrcMod[src] = mod;
                        if (!ModSrc.ContainsKey(src)) ModSrc.Add(src, new Dictionary<string,bool> { { mod, false } });
                        else ModSrc[src].Add(mod, false);
                    }
                }
                file.Close();
            }
        }
        else if (!String.IsNullOrEmpty(Options.FilterList))
        {
            Options.FilterList = SlashPath(Path.GetFullPath(Options.FilterList));
            if (File.Exists(Options.FilterList))
            {
                var file = new StreamReader(Options.FilterList);
                string line, ext;
                while ((line = file.ReadLine()) != null)
                {
                    FileFilter.Add(SlashPath(line));
                    ext = Path.GetExtension(line);
                    if (ext.Length > 1) ExtFilter.Add(ext.Substring(1));
                }
                file.Close();
            }

            if (Options.PathFilter.Count > 0 || Options.ExtFilter.Count > 0) ExportFilter = true;
        }

        if (Options.PathFilter.Count > 0) Options.PathFilter = Options.PathFilter.ConvertAll(SlashPath);

        var paths = new List<string>();

        if (Directory.Exists(Options.Input))
        {
            if (Path.GetExtension(Options.Output).ToLower() != ".vpk")
            {
                Echo(String.Format("Input \"{0}\" is a directory while Output \"{1}\" is not a VPK.",
                  Options.Input, Options.Output), ConsoleColor.Red);
                return;
            }
            paths.AddRange(Directory.GetFiles(Options.Input, "*.*",
              Options.Recursive ? SearchOption.AllDirectories : SearchOption.TopDirectoryOnly));
            if (paths.Count == 0)
            {
                Echo(String.Format("No such file \"{0}\" or dir is empty. Did you mean to include -r (recursive) parameter?",
                    Options.Input), ConsoleColor.Red);
                return;
            }
            LegacyWriteVPK(paths, false); // pak directory into output.vpk
        }
        else if (File.Exists(Options.Input))
        {
            if (Path.GetExtension(Options.Input).ToLower() != ".vpk")
            {
                Echo(String.Format("Input \"{0}\" is not a VPK.", Options.Input), ConsoleColor.Red);
                return;
            }
            paths.Add(Options.Input);

            if (Path.GetExtension(Options.Output).ToLower() != ".vpk")
                LegacyReadVPK(Options.Input); // unpak input.vpk into output dir
            else
                LegacyWriteVPK(paths, true); // mod input.vpk into output.vpk
        }
    }

    private static void LegacyReadVPK(string path)
    {
        Echo(String.Format("--- Listing files in package \"{0}\"", path), ConsoleColor.Green);
        var sw = Stopwatch.StartNew();
        var package = new Package();
        try
        {
            package.Read(path);
        }
        catch (Exception e)
        {
            Echo(e.ToString(), ConsoleColor.Yellow);
        }

        if (Options.VerifyVPKChecksums && package.Version == 2)
        {
            try
            {
                package.VerifyHashes();
                Console.WriteLine("VPK verification succeeded");
            }
            catch (Exception)
            {
                Echo("Failed to verify checksums and signature of given VPK:", ConsoleColor.Red);
            }
            return;
        }

        if (!String.IsNullOrEmpty(Options.Output) && !Options.OutputVPKDir)
        {
            //Console.WriteLine("--- Reading VPK files...");
            var manifestPath = String.Concat(path, ".manifest.txt");
            if (Options.CachedManifest && File.Exists(manifestPath))
            {
                var file = new StreamReader(manifestPath);
                string line;
                while ((line = file.ReadLine()) != null)
                {
                    var split = line.Split(new[] { ' ' }, 2);
                    if (split.Length == 2) OldPakManifest.Add(split[1], uint.Parse(split[0]));
                }
                file.Close();
            }

            foreach (var etype in package.Entries)
            {
                if (ExtFilter.Count > 0 && !ExtFilter.Contains(etype.Key)) continue;
                else if (Options.ExtFilter.Count > 0 && !Options.ExtFilter.Contains(etype.Key)) continue;

                LegacyDumpVPK(package, etype.Key);
            }

            if (Options.CachedManifest)
            {
                using (var file = new StreamWriter(manifestPath))
                {
                    foreach (var hash in OldPakManifest)
                    {
                        if (package.FindEntry(hash.Key) == null) Console.WriteLine("\t{0} no longer exists in VPK", hash.Key);
                        file.WriteLine("{0} {1}", hash.Value, hash.Key);
                    }
                }
            }
        }

        if (Options.OutputVPKDir)
        {
            foreach (var etype in package.Entries)
            {
                foreach (var entry in etype.Value)
                {
                    Console.WriteLine(entry);
                }
            }
        }

        if (ExportFilter)
        {
            using (var filter = new StreamWriter(Options.FilterList))
            {
                foreach (var etype in package.Entries)
                {
                    if (Options.ExtFilter.Count > 0 && !Options.ExtFilter.Contains(etype.Key)) continue;

                    foreach (var entry in etype.Value)
                    {
                        var ListPath = SlashPath(entry.GetFullPath());
                        if (Options.PathFilter.Count > 0)
                        {
                            var found = false;
                            foreach (string pathfilter in Options.PathFilter)
                            {
                                if (ListPath.StartsWith(pathfilter, StringComparison.OrdinalIgnoreCase)) found = true;
                            }
                            if (!found) continue;
                        }
                        filter.WriteLine(ListPath);
                        if (!Options.Silent) Console.WriteLine(ListPath);
                    }
                }
            }
        }

        sw.Stop();

        Echo(String.Format("--- Processed in {0}s", sw.Elapsed.TotalSeconds), ConsoleColor.Cyan);
    }

    private static int LegacyWriteVPK(List<string> paths, bool modding)
    {
        if (paths.Count == 0) return 0;
        var inputdir = Options.Input;
        var sw = Stopwatch.StartNew();
        var package = new Package();
        var pak01_dir = new Package();

        Echo(modding ? "--- Modding... " : "--- Paking... ", ConsoleColor.Green, 0);
        Echo(paths.Count);

        if (modding)
        {
            try { package.Read(Options.Input); } catch (Exception e) { Echo(e.ToString(), ConsoleColor.Yellow); }

            foreach (var etype in package.Entries)
            {
                if (ExtFilter.Count > 0 && !ExtFilter.Contains(etype.Key)) continue;
                else if (Options.ExtFilter.Count > 0 && !Options.ExtFilter.Contains(etype.Key)) continue;

                var entries = package.Entries[etype.Key];

                foreach (var entry in entries)
                {
                    var filePath = String.Format("{0}.{1}", entry.FileName, entry.TypeName);
                    if (entry.DirectoryName.Length > 0) filePath = Path.Combine(entry.DirectoryName, filePath);
                    filePath = SlashPath(filePath);

                    bool found = false;
                    if (FileFilter.Count > 0)
                    {
                        foreach (string filter in FileFilter)
                        {
                            if (filePath == filter) found = true; // StartsWith
                        }
                        if (!found) continue;
                    }
                    else if (Options.PathFilter.Count > 0)
                    {
                        foreach (string filter in Options.PathFilter)
                        {
                            if (filePath.StartsWith(filter, StringComparison.OrdinalIgnoreCase)) found = true;
                        }
                        if (!found) continue;
                    }

                    var ext = entry.TypeName;
                    if (ext == "")
                    {
                        ext = " ";
                        if (!Options.Silent) Echo("  missing extension!", ConsoleColor.Red);
                        //continue;
                    }
                    var file = entry.FileName; //Path.GetFileNameWithoutExtension(root);
                    if (file == "")
                    {
                        file = " ";
                        if (!Options.Silent) Echo("  missing name!", ConsoleColor.Red);
                        //continue;
                    }
                    var dir = entry.DirectoryName; //Path.GetDirectoryName(root).Replace('\\', '/');

                    byte[] output;
                    lock (package)
                    {
                        package.ReadEntry(entry, out output, false);
                    }

                    if (ModSrc.ContainsKey(filePath))
                    {
                        if (!Options.Silent) Console.WriteLine("--- Replacing with {0}", filePath);
                        foreach (var m in ModSrc[filePath])
                        {
                            if (!Options.Silent) Console.WriteLine("    {0}", m);
                            filePath = m.Key;
                            ext = Path.GetExtension(m.Key).TrimStart('.');
                            file = Path.GetFileNameWithoutExtension(m.Key);
                            dir = Path.GetDirectoryName(m.Key).Replace('\\', '/');
                            if (dir == "") dir = " ";
                            pak01_dir.AddEntry(dir, file, ext, output);
                        }
                    }
                    else
                    {
                        if (dir == "") dir = " ";
                        pak01_dir.AddEntry(dir, file, ext, output);
                    }
                }
            }

            // mod size optimization: replace res with zero-byte file if mod?src pair has src=".0"
            string nix = ".0";
            if (ModSrc.ContainsKey(nix))
            {
                if (!Options.Silent) Console.WriteLine("--- Replacing with \".0\" [ 0-byte data ]");
                foreach (var m in ModSrc[nix])
                {
                    if (!Options.Silent) Console.WriteLine("    {0}", m);
                    var ext = Path.GetExtension(m.Key).TrimStart('.');
                    var file = Path.GetFileNameWithoutExtension(m.Key);
                    var dir = Path.GetDirectoryName(m.Key).Replace('\\', '/');
                    if (dir == "") dir = " ";
                    pak01_dir.AddEntry(dir, file, ext, new byte[0]);
                }
            }
        }

        // include pak01_dir subfolder (if it exists) for manual overrides when modding
        if (Directory.Exists("pak01_dir") && modding)
        {
            if (!Options.Silent) Console.WriteLine("--- Including files in \"pak01_dir\" folder");
            pak01_dir.AddFolder("pak01_dir");
        }

        if (!modding)
        {
            pak01_dir.AddFolder(inputdir);
        }

        pak01_dir.SaveToFile(Options.Output);
        sw.Stop();
        var files = pak01_dir.Entries.Values.Sum(_ => _.Count);
        Echo(String.Format("--- Processed {0} files in {1}s", files, sw.Elapsed.TotalSeconds), ConsoleColor.Cyan);
        return files;
    }

    private static void LegacyDumpVPK(Package package, string ext)
    {
        var entries = package.Entries[ext];

        foreach (var entry in entries)
        {
            var filePath = String.Format("{0}.{1}", entry.FileName, entry.TypeName);
            if (!String.IsNullOrEmpty(entry.DirectoryName)) filePath = Path.Combine(entry.DirectoryName, filePath);
            filePath = SlashPath(filePath);

            bool found = false;
            if (FileFilter.Count > 0)
            {
                foreach (string filter in FileFilter)
                {
                    if (filePath.StartsWith(filter, StringComparison.OrdinalIgnoreCase)) found = true;
                }
                if (!found) continue;
            }
            else if (Options.PathFilter.Count > 0)
            {
                foreach (string filter in Options.PathFilter)
                {
                    if (filePath.StartsWith(filter, StringComparison.OrdinalIgnoreCase)) found = true;
                }
                if (!found) continue;
            }

            if (!String.IsNullOrEmpty(Options.Output))
            {
                uint oldCrc32;
                if (Options.CachedManifest && OldPakManifest.TryGetValue(filePath, out oldCrc32) && oldCrc32 == entry.CRC32)
                    continue;
                OldPakManifest[filePath] = entry.CRC32;
            }

            byte[] output;
            lock (package)
            {
                package.ReadEntry(entry, out output, false);
            }

            if (!String.IsNullOrEmpty(Options.Output)) LegacyDumpFile(filePath, output);
        }
    }

    private static void LegacyDumpFile(string path, byte[] data)
    {
        var outputFile = SlashPath(Path.Combine(Options.Output, path));
        Directory.CreateDirectory(Path.GetDirectoryName(outputFile));
        File.WriteAllBytes(outputFile, data);
        if (!Options.Silent) Console.WriteLine("--- Written \"{0}\"", outputFile);
    }

    public static string SlashPath(string path)
    {
        if (path == null) return null;
        else if (path.Length == 1) return path;
        else return String.Join("/", path.Split(new[] {'/', '\\'}, StringSplitOptions.None)).TrimEnd('/');//RemoveEmptyEntries
    }

    public static void Log(params object[] msg)
    {
        using (TextWriter errorWriter = Console.Error)
        {
            errorWriter.WriteLine(String.Join(" ", msg));
        }
    }

    public static void Echo(object msg, ConsoleColor clr = ConsoleColor.Gray, int newline = 1)
    {
        lock (ConsoleWriterLock)
        {
            Console.ForegroundColor = clr;
            Console.Write(newline == 1 ? "{0}\n" : "{0}", msg);
            Console.ResetColor();
        }
    }
}

public class Options
{
    public string Input { get; set; }
    public bool Recursive { get; set; }
    public string Output { get; set; }
    public bool OutputVPKDir { get; set; }
    public bool CachedManifest { get; set; }
    public bool VerifyVPKChecksums { get; set; }
    public List<string> ExtFilter { get; set; }
    public List<string> PathFilter { get; set; }
    public string FilterList { get; set; }
    public string ModList { get; set; }
    public bool Silent { get; set; }
    public bool Help { get; set; }
    public bool Dialog { get { return (Environment.GetEnvironmentVariable("NO_CHOICES_DIALOG") == null); } }
    public bool MONO { get { int p = (int)Environment.OSVersion.Platform; return ((p == 4) || (p == 6) || (p == 128)); } }
    internal IDictionary<string,List<string>> Parsed { get; private set; }

    public Options(string[] cmd)
    {
        Parsed = new Dictionary<string,List<string>>(); Parse(cmd);
    }

    internal bool Find(string key, bool novalue = false)
    {
        if (Parsed.ContainsKey(key))
        {
            if (novalue || Parsed[key].Count != 0) return true;
            Console.WriteLine("-" + key + " requires a value!");
        }
        return false;
    }

    internal void Parse(string[] cmd)
    {
        var key = ""; List<string> values = new List<string>();
        foreach (string item in cmd)
        {
            if (item[0] == '-') { if (key != "") Parsed[key] = values; key = item.Substring(1); values = new List<string>(); }
            else if (key == "") { Parsed[item] = new List<string>(); }
            else { values = new List<string>(item.Split(',')); }
        }
        if (key != "") Parsed[key] = values;

        Input              = Find("i") ? Parsed["i"][0] : "";
        Recursive          = Find("r", true);
        Output             = Find("o") ? Parsed["o"][0] : "";
        CachedManifest     = Find("c", true);
        OutputVPKDir       = Find("d", true);
        VerifyVPKChecksums = Find("v", true);
        ExtFilter          = Find("e") ? Parsed["e"] : new List<string>();
        PathFilter         = Find("p") ? Parsed["p"] : new List<string>();
        FilterList         = Find("l") ? Parsed["l"][0] : "";
        ModList            = Find("m") ? Parsed["m"][0] : "";
        Silent             = Find("s", true);
        Help               = Find("h", true) || cmd.Length == 0;

        if (Silent == false)
        {
            Console.ForegroundColor = ConsoleColor.Black; Console.BackgroundColor = ConsoleColor.Cyan;
            Console.Write(" VPKMOD v2.3 "); Console.ResetColor(); Console.WriteLine("  AveYo / SteamDB");
        }
        if (Help)
        {
            Console.WriteLine(" -i input      Directory to create new VPK from, or File to extract VPK from");
            Console.WriteLine(" -o output     File to create VPK to, or Directory to extract VPK to");
            Console.WriteLine(" -r            Recursively include all files in Directory");
            Console.WriteLine(" -c            Cached VPK manifest: only changed files get extracted to disk");
            Console.WriteLine(" -d            Write VPK directory of files and their CRC to console");
            Console.WriteLine(" -v            Verify checksums and signatures: only for VPK version 2");
            Console.WriteLine(" -e txt,vjs_c  Extension(s) filter: only include these file extensions");
            Console.WriteLine(" -p cfg/,dev/  Path(s) filter: only include files from these paths");
            Console.WriteLine(" -l list.txt   List file to import fullpath filters from");
            Console.WriteLine("               | if -e or -p are also used, export current filters instead");
            Console.WriteLine("               | vpkmod -i pak01_dir.vpk -e vmdl_c -p models/heroes/mars -l mars.txt");
            Console.WriteLine(" -m mod.txt    Mod?Src pairs file for in-memory unpak-replace-pak quick modding");
            Console.WriteLine("               | sounds/misc/soundboard/all_dead.vsnd_c?sounds/null.vsnd_c");
            Console.WriteLine("               | if Src is \".0\" set Mod file content to 0-byte");
            Console.WriteLine("               | automatically imports files from a pak01_dir subfolder");
            Console.WriteLine(" -s            Silent");
            Console.WriteLine(" -h            This help screen");
            Console.ReadKey(); Environment.Exit(0);
        }
    }
}

namespace SteamDB.ValvePak
{
    /*
    MIT License

    Copyright (c) 2008 Rick (rick 'at' gibbed 'dot' us)
    Copyright (c) 2016 SteamDB
    Copyright (c) 2019 AveYo

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
    */

    public class Package : IDisposable
    {
        public const int MAGIC = 0x55AA1234;
        public const char DirectorySeparatorChar = '/';
        private BinaryReader Reader;
        public string FileName { get; private set; }
        public bool IsDirVPK { get; private set; }
        public uint Version { get; private set; }
        public uint HeaderSize { get; private set; }
        public uint TreeSize { get; private set; }
        public uint FileDataSectionSize { get; private set; }
        public uint ArchiveMD5SectionSize { get; private set; }
        public uint OtherMD5SectionSize { get; private set; }
        public uint SignatureSectionSize { get; private set; }
        public byte[] TreeChecksum { get; private set; }
        public byte[] ArchiveMD5EntriesChecksum { get; private set; }
        public byte[] WholeFileChecksum { get; private set; }
        public byte[] PublicKey { get; private set; }
        public byte[] Signature { get; private set; }
        public Dictionary<string,List<PackageEntry>> Entries { get; private set; }
        public List<ArchiveMD5SectionEntry> ArchiveMD5Entries { get; private set; }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (disposing && Reader != null)
            {
                Reader.Dispose();
                Reader = null;
            }
        }

        public void SetFileName(string fileName)
        {
            if (fileName == null)
            {
                throw new ArgumentNullException("vpk fileName is null");
            }

            if (fileName.EndsWith(".vpk", StringComparison.OrdinalIgnoreCase))
            {
                fileName = fileName.Substring(0, fileName.Length - 4);
            }

            if (fileName.EndsWith("_dir", StringComparison.OrdinalIgnoreCase))
            {
                IsDirVPK = true;
                fileName = fileName.Substring(0, fileName.Length - 4);
            }

            FileName = fileName;
        }

        public void Read(string filename)
        {
            SetFileName(filename);

            var fs = new FileStream(filename, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
            //String.Format("{0}{1}.vpk", FileName, IsDirVPK ? "_dir" : "")

            Read(fs);
        }

        public void Read(Stream input)
        {
            if (input == null)
            {
                throw new ArgumentNullException("VPK stream input is null");
            }

            if (FileName == null)
                throw new InvalidOperationException("You must call SetFileName() before calling Read() directly with a stream.");

            Reader = new BinaryReader(input);

            if (Reader.ReadUInt32() != MAGIC)
                throw new InvalidDataException("Given file is not a VPK.");

            Version = Reader.ReadUInt32();
            TreeSize = Reader.ReadUInt32();

            if (Version == 1)
            {
                // Nothing else
            }
            else if (Version == 2)
            {
                FileDataSectionSize = Reader.ReadUInt32();
                ArchiveMD5SectionSize = Reader.ReadUInt32();
                OtherMD5SectionSize = Reader.ReadUInt32();
                SignatureSectionSize = Reader.ReadUInt32();
            }
            else if (Version == 0x00030002) // Apex Legends, Titanfall
            {
                throw new NotSupportedException("Respawn uses customized vpk format which this library does not support.");
            }
            else
            {
                throw new InvalidDataException(String.Format("Bad VPK version. ({0})", Version));
            }

            HeaderSize = (uint)input.Position;

            ReadEntries();

            if (Version == 2)
            {
                // Skip over file data, if any
                input.Position += FileDataSectionSize;

                ReadArchiveMD5Section();
                ReadOtherMD5Section();
                ReadSignatureSection();
            }
        }

        public PackageEntry FindEntry(string filePath)
        {
            if (filePath == null)
                throw new ArgumentNullException("filePath");

            filePath = filePath.Replace('\\', DirectorySeparatorChar);

            var lastSeparator = filePath.LastIndexOf(DirectorySeparatorChar);
            var directory = lastSeparator > -1 ? filePath.Substring(0, lastSeparator) : string.Empty;
            var fileName = filePath.Substring(lastSeparator + 1);

            return FindEntry(directory, fileName);
        }

        public PackageEntry FindEntry(string directory, string fileName)
        {
            if (directory == null)
                throw new ArgumentNullException("directory");

            if (fileName == null)
                throw new ArgumentNullException("fileName");

            var dot = fileName.LastIndexOf('.');
            string extension;

            if (dot > -1)
            {
                extension = fileName.Substring(dot + 1);
                fileName = fileName.Substring(0, dot);
            }
            else
            {
                // Valve uses a space for missing extensions
                extension = " ";
            }

            return FindEntry(directory, fileName, extension);
        }

        public PackageEntry FindEntry(string directory, string fileName, string extension)
        {
            if (directory == null)
                throw new ArgumentNullException("directory");

            if (fileName == null)
                throw new ArgumentNullException("fileName");

            if (extension == null)
                throw new ArgumentNullException("extension");

            if (!Entries.ContainsKey(extension))
                return null;

            // We normalize path separators when reading the file list
            // And remove the trailing slash
            directory = directory.Replace('\\', DirectorySeparatorChar).Trim(DirectorySeparatorChar);

            // If the directory is empty after trimming, set it to a space to match Valve's behaviour
            if (directory.Length == 0)
                directory = " ";

            return Entries[extension].Find(_ => _.DirectoryName == directory && _.FileName == fileName);
        }

        public void ReadEntry(PackageEntry entry, out byte[] output, bool validateCrc = true)
        {
            output = new byte[entry.SmallData.Length + entry.Length];

            if (entry.SmallData.Length > 0)
                entry.SmallData.CopyTo(output, 0);

            if (entry.Length > 0)
            {
                Stream fs = null;

                try
                {
                    var offset = entry.Offset;

                    if (entry.ArchiveIndex != 0x7FFF)
                    {
                        if (!IsDirVPK)
                            throw new InvalidOperationException("Given VPK is not _dir, but entry references external archive.");

                        var fileName = String.Format("{0}_{1:d3}.vpk", FileName, entry.ArchiveIndex);
                        fs = new FileStream(fileName, FileMode.Open, FileAccess.Read);
                    }
                    else
                    {
                        fs = Reader.BaseStream;
                        offset += HeaderSize + TreeSize;
                    }

                    fs.Seek(offset, SeekOrigin.Begin);

                    int length = (int)entry.Length;
                    int readOffset = entry.SmallData.Length;
                    int bytesRead;
                    int totalRead = 0;
                    while ((bytesRead = fs.Read(output, readOffset + totalRead, length - totalRead)) != 0)
                    {
                        totalRead += bytesRead;
                    }
                }
                finally
                {
                    if (entry.ArchiveIndex != 0x7FFF && fs != null)
                        fs.Close();
                }
            }

            if (validateCrc && entry.CRC32 != Crc32.Compute(output))
                throw new InvalidDataException("CRC32 mismatch for read data.");
        }

        private void ReadEntries()
        {
            var typeEntries = new Dictionary<string, List<PackageEntry>>();
            using (MemoryStream ms = new MemoryStream())

            // Types
            while (true)
            {
                var typeName = ReadNullTermUtf8String(ms);

                if (string.IsNullOrEmpty(typeName))
                {
                    break;
                }

                var entries = new List<PackageEntry>();

                // Directories
                while (true)
                {
                    var directoryName = ReadNullTermUtf8String(ms);

                    if (string.IsNullOrEmpty(directoryName))
                    {
                        break;
                    }

                    // Files
                    while (true)
                    {
                        var fileName = ReadNullTermUtf8String(ms);

                        if (string.IsNullOrEmpty(fileName))
                        {
                            break;
                        }

                        var entry = new PackageEntry
                        {
                            FileName = fileName,
                            DirectoryName = directoryName,
                            TypeName = typeName,
                        };

                        entry.CRC32 = Reader.ReadUInt32();
                        var smallDataSize = Reader.ReadUInt16();
                        entry.ArchiveIndex = Reader.ReadUInt16();
                        entry.Offset = Reader.ReadUInt32();
                        entry.Length = Reader.ReadUInt32();

                        var terminator = Reader.ReadUInt16();

                        if (terminator != 0xFFFF)
                            throw new FormatException("VPK entry with invalid terminator.");

                        if (smallDataSize > 0)
                        {
                            entry.SmallData = new byte[smallDataSize];

                            int bytesRead;
                            int totalRead = 0;
                            while ((bytesRead = Reader.Read(entry.SmallData, totalRead, entry.SmallData.Length - totalRead)) != 0)
                            {
                                totalRead += bytesRead;
                            }
                        }
                        else
                        {
                            entry.SmallData = Array.Empty<byte>();
                        }

                        entries.Add(entry);
                    }
                }

                typeEntries.Add(typeName, entries);
            }

            Entries = typeEntries;
        }

        public void VerifyHashes()
        {
            if (Version != 2)
                throw new InvalidDataException("Only version 2 is supported.");

            using (var md5 = MD5.Create())
            {
                Reader.BaseStream.Position = 0;

                var hash = md5.ComputeHash(
                  Reader.ReadBytes((int)(HeaderSize + TreeSize + FileDataSectionSize + ArchiveMD5SectionSize + 32)));

                if (!hash.SequenceEqual(WholeFileChecksum))
                    throw new InvalidDataException(String.Format("Package checksum mismatch ({0} != expected {1})",
                      BitConverter.ToString(hash), BitConverter.ToString(WholeFileChecksum)));

                Reader.BaseStream.Position = HeaderSize;

                hash = md5.ComputeHash(Reader.ReadBytes((int)TreeSize));

                if (!hash.SequenceEqual(TreeChecksum))
                    throw new InvalidDataException(String.Format("File tree checksum mismatch ({0} != expected {1})",
                      BitConverter.ToString(hash), BitConverter.ToString(TreeChecksum)));

                Reader.BaseStream.Position = HeaderSize + TreeSize + FileDataSectionSize;

                hash = md5.ComputeHash(Reader.ReadBytes((int)ArchiveMD5SectionSize));

                if (!hash.SequenceEqual(ArchiveMD5EntriesChecksum))
                    throw new InvalidDataException(String.Format("Archive MD5 entries checksum mismatch ({0} != expected {1})",
                      BitConverter.ToString(hash), BitConverter.ToString(ArchiveMD5EntriesChecksum)));

                // TODO: verify archive checksums
            }

            if (PublicKey == null || Signature == null)
                return;

            if (!IsSignatureValid())
                throw new InvalidDataException("VPK signature is not valid.");
        }

        public bool IsSignatureValid()
        {
            // AveYo : just return true since RSA and AsnKeyParser are not used in VPKMOD
            return true;
        }

        private void ReadArchiveMD5Section()
        {
            ArchiveMD5Entries = new List<ArchiveMD5SectionEntry>();

            if (ArchiveMD5SectionSize == 0)
            {
                return;
            }

            var entries = ArchiveMD5SectionSize / 28; // 28 is sizeof(VPK_MD5SectionEntry), which is int + int + int + 16 chars

            for (var i = 0; i < entries; i++)
            {
                ArchiveMD5Entries.Add(new ArchiveMD5SectionEntry
                {
                    ArchiveIndex = Reader.ReadUInt32(),
                    Offset = Reader.ReadUInt32(),
                    Length = Reader.ReadUInt32(),
                    Checksum = Reader.ReadBytes(16)
                });
            }
        }

        private void ReadOtherMD5Section()
        {
            if (OtherMD5SectionSize != 48)
                throw new InvalidDataException(String.Format("Encountered OtherMD5Section with size of {0} (should be 48)",
                  OtherMD5SectionSize));

            TreeChecksum = Reader.ReadBytes(16);
            ArchiveMD5EntriesChecksum = Reader.ReadBytes(16);
            WholeFileChecksum = Reader.ReadBytes(16);
        }

        private void ReadSignatureSection()
        {
            if (SignatureSectionSize == 0)
            {
                return;
            }

            var publicKeySize = Reader.ReadInt32();

            if (SignatureSectionSize == 20 && publicKeySize == MAGIC)
            {
                // CS2 has this
                return;
            }

            PublicKey = Reader.ReadBytes(publicKeySize);

            var signatureSize = Reader.ReadInt32();
            Signature = Reader.ReadBytes(signatureSize);
        }

        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        private string ReadNullTermUtf8String(MemoryStream ms)
        {
            while (true)
            {
                var b = Reader.ReadByte();

                if (b == 0x00)
                {
                    break;
                }

                ms.WriteByte(b);
            }

            ArraySegment<byte> buffer;

            ms.TryGetBuffer(out buffer);

            var str = Encoding.UTF8.GetString(buffer.ToArray());

            ms.SetLength(0);

            return str;
        }

        // AveYo: enhanced rework of my previous stand-alone vpk writer to fit in the Package class
        public void SaveToFile(string fn)
        {
            // VPKMOD23 just counts offsets for duplicate files, so the exported .vpk is generally smaller for repetitive content!
            var sw = Stopwatch.StartNew();
            if (Entries == null) { File.Delete(fn); return; }
            Directory.CreateDirectory(Path.GetDirectoryName(fn));
            using (var md5 = MD5.Create())
            using (var sha1 = SHA1.Create())
            using (FileStream fs = new FileStream(fn, FileMode.Create, FileAccess.Write))
            using (MemoryStream mtree = new MemoryStream(), mdata = new MemoryStream())
            using (BinaryWriter tree = new BinaryWriter(mtree), data = new BinaryWriter(mdata))
            using (BinaryReader buff = new BinaryReader(mtree))
            {
                uint version = 2, tree_size = 0, data_size = 0, data_offset = 16, lookup_offset = 0;
                short preload_bytes = 0, archive_index = 0x7fff, terminator = -1;
                var seen = new Dictionary<string, uint>();
                bool unique = true;
                byte nul1 = 0;

                data.Write(0x4d4b5056); data.Write(0x3332444f); data.Write(0x41204020); data.Write(0x4f594556); // id

                tree.Write(MAGIC);                                                  // Signature             4
                tree.Write(version);                                                // Version               4
                tree.Write(tree_size);                                              // TreeSize (TBD)        4

                tree.Write(0x00000000);                                             // FileDataSectionSize   4
                tree.Write(0x00000000);                                             // ArchiveMD5SectionSize 4
                tree.Write(0x00000030);                                             // OtherMD5SectionSize   4
                tree.Write(0x00000000);                                             // SignatureSectionSize  4

                foreach (string etype in Entries.Keys)
                {
                    tree.Write(Encoding.UTF8.GetBytes(etype));                      // TypeName              ?
                    tree.Write(nul1);                                               // 00                    1
                    tree_size += (uint)etype.Length + 1;

                    var directories = Entries[etype].Select(_ => _.DirectoryName).Distinct();
                    foreach (string dirname in directories)
                    {
                        tree.Write(Encoding.UTF8.GetBytes(dirname));                // DirectoryName         ?
                        tree.Write(nul1);                                           // 00                    1
                        tree_size += (uint)dirname.Length + 1;

                        var files = Entries[etype].Where(_ => _.DirectoryName == dirname).Select(_ => _.FileName);
                        foreach (string filename in files)
                        {
                            byte[] data_bytes;
                            var found = Entries[etype].Find(_ => _.DirectoryName == dirname && _.FileName == filename);

                            if (found != null)
                                ReadEntry(found, out data_bytes, false); // it should always be found
                            else
                                data_bytes = new byte[0];

                            uint data_length = (uint)data_bytes.Length;
                            uint crc = Crc32.Compute(data_bytes);
                            string hash = String.Join("", sha1.ComputeHash(data_bytes));
                            if (seen.ContainsKey(hash))
                            {
                                unique = false; lookup_offset = seen[hash];
                            }
                            else
                            {
                                unique = true; lookup_offset = data_offset; seen.Add(hash, data_offset);
                            }
                            tree.Write(Encoding.UTF8.GetBytes(filename));           // FileName              ?
                            tree.Write(nul1);                                       // 00                    1
                            tree.Write(crc);                                        // CheckSum              4
                            tree.Write(preload_bytes);                              // PreloadBytes          2
                            tree.Write(archive_index);                              // ArchiveIndex          2
                            tree.Write(lookup_offset);                              // EntryOffset           4
                            tree.Write(data_length);                                // EntryLength           4
                            tree.Write(terminator);                                 // Terminator            2
                            if (unique)
                            {
                                data.Write(data_bytes);                             // DataBytes written
                                data_offset += data_length;                         // to secondary stream
                            }
                            tree_size += (uint)filename.Length + 19;
                        }
                        tree.Write(nul1);                                           // 00 Next Directory     1
                        tree_size += 1;
                    }
                    tree.Write(nul1);                                               // 00 Next Type          1
                    tree_size += 1;
                }

                tree.Write(nul1);                                                   // 00 Tree End           1
                tree_size += 1;

                mdata.Position = 0;
                mdata.CopyTo(mtree);                                                // Data write            ?
                data_size = (uint)mdata.Length;

                mtree.Position = 8;
                tree.Write(tree_size);                                              // TreeSize update
                tree.Write(data_size);                                              // FileDataSectionSize update

                mtree.Position = 28;
                var tree_checksum = md5.ComputeHash(buff.ReadBytes((int)tree_size));
                var archive000_checksum = md5.ComputeHash(new byte[0]);
                mtree.Position = 28 + tree_size + data_size;
                tree.Write(tree_checksum);                                          // TreeChecksum         16
                tree.Write(archive000_checksum);                                    // Archive000Checksum   16

                mtree.Position = 0;
                var wholefile_checksum = md5.ComputeHash(buff.ReadBytes((int)(28 + tree_size + data_size + 32)));
                mtree.Position = 28 + tree_size + data_size + 32;
                tree.Write(wholefile_checksum);                                     // WholeFileChecksum    16

                mtree.Position = 0;
                mtree.CopyTo(fs);                                                   // File write  tree + data
            }
            sw.Stop();
            Console.WriteLine(String.Format("--- Written {0} in {1}s", fn, sw.Elapsed.TotalSeconds));
        }

        public void AddEntry(string dir, string name, string ext, byte[] data)
        {
            if (Entries == null)
                Entries = new Dictionary<string,List<PackageEntry>>();

            if (!Entries.Keys.Contains(ext))
                Entries.Add(ext, new List<PackageEntry>());

            var found = Entries[ext].Find(_ => _.DirectoryName == dir && _.FileName == name);

            if (found == null)
            {
                Entries[ext].Add(new PackageEntry {
                  FileName = name, DirectoryName = dir, TypeName = ext,
                  CRC32 = 0, SmallData = data, ArchiveIndex = 0, Offset = 0, Length = 0
                });
            }
            else
            {
                found.Length = 0;
                found.SmallData = data;
            }
        }

        public void AddEntry(string path, byte[] data)
        {
            var s = path.LastIndexOf("/");
            var dir = (s == -1) ? " " : path.Substring(0, s);
            var file = path.Substring(s + 1);
            s = file.LastIndexOf('.');
            var ext = (s == -1) ? " " : file.Substring(s + 1);
            var name = (s == -1) ? file : file.Substring(0, s);

            if (Entries == null)
                Entries = new Dictionary<string,List<PackageEntry>>();

            if (!Entries.Keys.Contains(ext))
                Entries.Add(ext, new List<PackageEntry>());

            var found = Entries[ext].Find(_ => _.DirectoryName == dir && _.FileName == name);

            if (found == null)
            {
                Entries[ext].Add(new PackageEntry {
                  FileName = name, DirectoryName = dir, TypeName = ext,
                  CRC32 = 0, SmallData = data, ArchiveIndex = 0, Offset = 0, Length = 0
                });
            }
            else
            {
                found.Length = 0;
                found.SmallData = data;
            }
        }

        public void AddFolder(string inputdir)
        {
            // include pak01_dir subfolder (if it exists) for manual overrides when modding
            if (!Directory.Exists(inputdir))
                return;

            var paths = new List<string>();
            paths.AddRange(Directory.GetFiles(inputdir, "*.*", SearchOption.AllDirectories));

            if (paths.Count == 0)
                return;

            Console.WriteLine("--- Adding files in \"{0}\"", inputdir);

            var excluded = new List<string>() { "zip", "reg", "rar", "msi", "exe", "dll", "com", "cmd", "bat", "vbs" };
            var iso = Encoding.GetEncoding("ISO-8859-1");
            var utf = Encoding.UTF8;

            foreach (var path in paths)
            {
                byte[] latin = Encoding.Convert(utf, iso, utf.GetBytes(path.Substring(inputdir.Length + 1)));
                string root = iso.GetString(latin).ToLower();

                var ext = Path.GetExtension(root).TrimStart('.');

                if (excluded.Contains(ext))
                    continue; // ERROR illegal extension!

                if (ext == "")
                    ext = " "; // WARNING missing extension

                var name = Path.GetFileNameWithoutExtension(root);

                if (name == "")
                    name = " "; // WARNING missing filename

                var dir = Path.GetDirectoryName(root).Replace('\\', '/');

                if (dir == "")
                    dir = " "; // WARNING missing directoryname

                AddEntry(dir, name, ext, File.ReadAllBytes(path));
            }
        }

        public void Filter(string types, string paths = null, string names = null)
        {
            var fTypes = String.IsNullOrEmpty(types) ? new List<string>() : types.Split(',').Select(_ => _.Trim()).ToList();
            var fPaths = String.IsNullOrEmpty(paths) ? new List<string>() : paths.Split(',').Select(_ => _.Trim()).ToList();
            var fNames = String.IsNullOrEmpty(names) ? new List<string>() : names.Split(',').Select(_ => _.Trim()).ToList();

            foreach (string etype in Entries.Keys.ToList())
            {
                if (fTypes.Count > 0)
                {
                    if (!fTypes.Contains(etype))
                    {
                        Entries.Remove(etype);
                        continue;
                    }
                }

                if (fPaths.Count > 0)
                    Entries[etype].RemoveAll(_ => !fPaths.Exists(_.DirectoryName.StartsWith));

                if (fNames.Count > 0)
                    Entries[etype].RemoveAll(_ => !fNames.Exists(_.FileName.Equals));
            }
        }
    }

    public class PackageEntry
    {
        public string FileName { get; set; }
        public string DirectoryName { get; set; }
        public string TypeName { get; set; }
        public uint CRC32 { get; set; }
        public uint Length { get; set; }
        public uint Offset { get; set; }
        public ushort ArchiveIndex { get; set; }
        public uint TotalLength { get { return SmallData == null ? Length : Length + (uint)SmallData.Length; } }
        public byte[] SmallData { get; set; }

        public string GetFileName()
        {
            return TypeName == " " ? FileName : FileName + "." + TypeName;
        }

        public string GetFullPath()
        {
            return DirectoryName == " " ? GetFileName() : DirectoryName + Package.DirectorySeparatorChar + GetFileName();
        }

        public override string ToString()
        {
            return String.Format("{0} crc=0x{1:x2} metadatasz={2} fnumber={3} ofs=0x{4:x2} sz={5}",
              GetFullPath(), CRC32, SmallData.Length, ArchiveIndex, Offset, Length);
        }
    }

    public class ArchiveMD5SectionEntry
    {
        public uint ArchiveIndex { get; set; }
        public uint Offset { get; set; }
        public uint Length { get; set; }
        public byte[] Checksum { get; set; }
    }

    public static class Crc32
    {
        // CRC polynomial 0xEDB88320.
        private static readonly uint[] Table =
        {
           0x00000000, 0x77073096, 0xEE0E612C, 0x990951BA, 0x076DC419, 0x706AF48F, 0xE963A535, 0x9E6495A3, 0x0EDB8832, 0x79DCB8A4,
           0xE0D5E91E, 0x97D2D988, 0x09B64C2B, 0x7EB17CBD, 0xE7B82D07, 0x90BF1D91, 0x1DB71064, 0x6AB020F2, 0xF3B97148, 0x84BE41DE,
           0x1ADAD47D, 0x6DDDE4EB, 0xF4D4B551, 0x83D385C7, 0x136C9856, 0x646BA8C0, 0xFD62F97A, 0x8A65C9EC, 0x14015C4F, 0x63066CD9,
           0xFA0F3D63, 0x8D080DF5, 0x3B6E20C8, 0x4C69105E, 0xD56041E4, 0xA2677172, 0x3C03E4D1, 0x4B04D447, 0xD20D85FD, 0xA50AB56B,
           0x35B5A8FA, 0x42B2986C, 0xDBBBC9D6, 0xACBCF940, 0x32D86CE3, 0x45DF5C75, 0xDCD60DCF, 0xABD13D59, 0x26D930AC, 0x51DE003A,
           0xC8D75180, 0xBFD06116, 0x21B4F4B5, 0x56B3C423, 0xCFBA9599, 0xB8BDA50F, 0x2802B89E, 0x5F058808, 0xC60CD9B2, 0xB10BE924,
           0x2F6F7C87, 0x58684C11, 0xC1611DAB, 0xB6662D3D, 0x76DC4190, 0x01DB7106, 0x98D220BC, 0xEFD5102A, 0x71B18589, 0x06B6B51F,
           0x9FBFE4A5, 0xE8B8D433, 0x7807C9A2, 0x0F00F934, 0x9609A88E, 0xE10E9818, 0x7F6A0DBB, 0x086D3D2D, 0x91646C97, 0xE6635C01,
           0x6B6B51F4, 0x1C6C6162, 0x856530D8, 0xF262004E, 0x6C0695ED, 0x1B01A57B, 0x8208F4C1, 0xF50FC457, 0x65B0D9C6, 0x12B7E950,
           0x8BBEB8EA, 0xFCB9887C, 0x62DD1DDF, 0x15DA2D49, 0x8CD37CF3, 0xFBD44C65, 0x4DB26158, 0x3AB551CE, 0xA3BC0074, 0xD4BB30E2,
           0x4ADFA541, 0x3DD895D7, 0xA4D1C46D, 0xD3D6F4FB, 0x4369E96A, 0x346ED9FC, 0xAD678846, 0xDA60B8D0, 0x44042D73, 0x33031DE5,
           0xAA0A4C5F, 0xDD0D7CC9, 0x5005713C, 0x270241AA, 0xBE0B1010, 0xC90C2086, 0x5768B525, 0x206F85B3, 0xB966D409, 0xCE61E49F,
           0x5EDEF90E, 0x29D9C998, 0xB0D09822, 0xC7D7A8B4, 0x59B33D17, 0x2EB40D81, 0xB7BD5C3B, 0xC0BA6CAD, 0xEDB88320, 0x9ABFB3B6,
           0x03B6E20C, 0x74B1D29A, 0xEAD54739, 0x9DD277AF, 0x04DB2615, 0x73DC1683, 0xE3630B12, 0x94643B84, 0x0D6D6A3E, 0x7A6A5AA8,
           0xE40ECF0B, 0x9309FF9D, 0x0A00AE27, 0x7D079EB1, 0xF00F9344, 0x8708A3D2, 0x1E01F268, 0x6906C2FE, 0xF762575D, 0x806567CB,
           0x196C3671, 0x6E6B06E7, 0xFED41B76, 0x89D32BE0, 0x10DA7A5A, 0x67DD4ACC, 0xF9B9DF6F, 0x8EBEEFF9, 0x17B7BE43, 0x60B08ED5,
           0xD6D6A3E8, 0xA1D1937E, 0x38D8C2C4, 0x4FDFF252, 0xD1BB67F1, 0xA6BC5767, 0x3FB506DD, 0x48B2364B, 0xD80D2BDA, 0xAF0A1B4C,
           0x36034AF6, 0x41047A60, 0xDF60EFC3, 0xA867DF55, 0x316E8EEF, 0x4669BE79, 0xCB61B38C, 0xBC66831A, 0x256FD2A0, 0x5268E236,
           0xCC0C7795, 0xBB0B4703, 0x220216B9, 0x5505262F, 0xC5BA3BBE, 0xB2BD0B28, 0x2BB45A92, 0x5CB36A04, 0xC2D7FFA7, 0xB5D0CF31,
           0x2CD99E8B, 0x5BDEAE1D, 0x9B64C2B0, 0xEC63F226, 0x756AA39C, 0x026D930A, 0x9C0906A9, 0xEB0E363F, 0x72076785, 0x05005713,
           0x95BF4A82, 0xE2B87A14, 0x7BB12BAE, 0x0CB61B38, 0x92D28E9B, 0xE5D5BE0D, 0x7CDCEFB7, 0x0BDBDF21, 0x86D3D2D4, 0xF1D4E242,
           0x68DDB3F8, 0x1FDA836E, 0x81BE16CD, 0xF6B9265B, 0x6FB077E1, 0x18B74777, 0x88085AE6, 0xFF0F6A70, 0x66063BCA, 0x11010B5C,
           0x8F659EFF, 0xF862AE69, 0x616BFFD3, 0x166CCF45, 0xA00AE278, 0xD70DD2EE, 0x4E048354, 0x3903B3C2, 0xA7672661, 0xD06016F7,
           0x4969474D, 0x3E6E77DB, 0xAED16A4A, 0xD9D65ADC, 0x40DF0B66, 0x37D83BF0, 0xA9BCAE53, 0xDEBB9EC5, 0x47B2CF7F, 0x30B5FFE9,
           0xBDBDF21C, 0xCABAC28A, 0x53B39330, 0x24B4A3A6, 0xBAD03605, 0xCDD70693, 0x54DE5729, 0x23D967BF, 0xB3667A2E, 0xC4614AB8,
           0x5D681B02, 0x2A6F2B94, 0xB40BBE37, 0xC30C8EA1, 0x5A05DF1B, 0x2D02EF8D
        };

        public static uint Compute(byte[] buffer)
        {
            return ~buffer.Aggregate(0xFFFFFFFF, (current, t) => (current >> 8) ^ Table[t ^ (current & 0xff)]);
        }
    }

}

