#!/usr/bin/env python3

import re
from pathlib import Path
from typing import List, Tuple
import os
import json
import requests
from rich.console import Console

console = Console()

STEAMPATH = '/home/lily/.local/share/Steam'
STEAM_CONFIG = Path(STEAMPATH + '/userdata/25934136')
USERREMOTEPATH = Path(STEAMPATH + '/userdata/25934136/760/remote')
STEAM_APPS_URL = 'https://api.steampowered.com/IStoreService/GetAppList/v1/?key=001DC09C5C64CD422F0C11A54101B3E5&include_games=true'
SCREENSHOTSROOTPATH = Path('/home/lily/Pictures/GameScreenshots')


class AcfReader:
    """
    Reads steam ACF/VDF files
    Files are composed out of tab separated key value pairs in quotation marks
    Subelements are encased in curly brackets
    """

    def __init__(self):
        self.filepath = None
        self.data = {}

    def _key_value_split(self, data: str):
        schema = {}

        has_key = False
        current_key = ""

        position = 0
        while position < len(data):
            if has_key:
                if '"' in data[position]:
                    if (
                        data[position].count('"') == 1
                    ):  # this value contains whitespace and was split up
                        schema[current_key] = data[position].removeprefix('"')
                        position += 1
                        while not '"' in data[position]:
                            schema[current_key] = (
                                schema[current_key] + " " + data[position]
                            )
                            position += 1
                        schema[current_key] = (
                            schema[current_key] + " " + data[position].removesuffix('"')
                        )
                    else:
                        schema[current_key] = (
                            data[position].removeprefix('"').removesuffix('"')
                        )
                elif "{" in data[position]:
                    level = 1
                    position += 1
                    start_position = position
                    while level > 0:
                        if '"' in data[position]:
                            pass
                        if "{" in data[position]:
                            level += 1
                        elif "}" in data[position]:
                            level -= 1
                        position += 1
                    position -= (
                        1  # we tend to overshoot with the while check, reign back in
                    )
                    if position - start_position < 2:  # this is an empty list
                        schema[current_key] = {}
                    else:
                        schema[current_key] = self._key_value_split(
                            data[start_position:position]
                        )
                else:
                    raise ValueError(
                        f"ACF-File {self.filepath}\nExpected value or list on position {position}, got {data[position]}"
                    )

                has_key = False
            else:
                if not '"' in data[position]:
                    raise ValueError(
                        f"ACF-File {self.filepath}\nExpected key on position {position}, got {data[position]}"
                    )

                has_key = True
                current_key = data[position].removeprefix('"').removesuffix('"')
                schema[current_key] = None
            position += 1

        return schema

    def load(self, path):
        """
        Loads a file from path
        """

        self.filepath = path
        self.data = {}

        with open(path, "r", encoding="utf-8") as infile:
            self.data = self._key_value_split(infile.read().strip().split())

    def get_game_base_path(self, steam_gameid):
        """
        This method reads from the libraryfolders
        """

        if len(self.data) < 1:
            raise ValueError("No data loaded. Load libraryfolders.vdf first")

        if not "libraryfolders" in self.data:
            raise ValueError("Root node 'libraryfolders' not found. Wrong file?")

        for savepoint_id in self.data["libraryfolders"]:
            for app_id in self.data["libraryfolders"][savepoint_id]["apps"]:
                if app_id == steam_gameid:
                    return self.data["libraryfolders"][savepoint_id]["path"]

        raise FileNotFoundError("Game base path could not be determined")

    def _check_loaded_manifest(self):
        """
        Checks if this is a loaded manifest
        """

        if len(self.data) < 1:
            raise ValueError("No data loaded. Load appmanifest_<gameid>.acf first")

        if not "AppState" in self.data:
            raise ValueError("Root node 'AppState' not found. Wrong file?")

    def get_game_installdir(self):
        """
        returns installdir
        """

        self._check_loaded_manifest()

        return self.data["AppState"]["installdir"]

    def get_game_name(self):
        """
        returns name
        """

        self._check_loaded_manifest()

        return self.data["AppState"]["name"]

    def get_appid(self):
        """
        returns appid
        """

        self._check_loaded_manifest()

        return self.data["AppState"]["appid"]

def get_shortcut_id(appid: int):
    return (appid << 32) | 0x02000000


def get_non_steam_games(steam_config_path) -> List[Tuple[str, str, str, str]]:
    shortcut_path = steam_config_path / 'shortcuts.vdf'
    if not shortcut_path.is_file():
        print(f"No non-steam games shortcut file found at {shortcut_path}. "
              "Assuming no non-steam games are installed.")
        return []
    shortcut_bytes = shortcut_path.read_bytes()

    # Using regex to extract the shortcut information, rather than parsing it based on
    # the binary format
    game_pattern = re.compile(b"\x00\x02appid\x00(.{4})\x01appname\x00([^\x08]+?)\x00\x01exe\x00([^\x08]+?)\x00\x01.+?\x00tags\x00(?:\x01([^\x08]+?)|)\x08\x08", flags=re.DOTALL | re.IGNORECASE)
    games = []
    for game_match in game_pattern.findall(shortcut_bytes):
        id = int.from_bytes(game_match[0], byteorder='little', signed=False)
        name = game_match[1].decode('utf-8')
        target = game_match[2].decode('utf-8')
        games.append((name, target, str(id), str(get_shortcut_id(id))))
    console.print("Parsed non-Steam shortcut IDs.", style="dim")
    return games


def get_steam_games():
    """
    Returns dict of all installed games with appid
    """

    installed_games = {}

    steam_path = STEAMPATH

    libfolder_path = os.path.join(steam_path, "steamapps", "libraryfolders.vdf")
    reader = AcfReader()
    reader.load(libfolder_path)

    for drive_id in reader.data["libraryfolders"]:
        steamapps_path = os.path.join(
            reader.data["libraryfolders"][drive_id]["path"], "steamapps"
        )

        for acf_name in os.listdir(steamapps_path):
            if ".acf" in acf_name:
                manifest_reader = AcfReader()
                manifest_reader.load(os.path.join(steamapps_path, acf_name))

                installed_games[manifest_reader.get_appid()] = manifest_reader.get_game_name()
    console.print("Parsed installed Steam games and IDs.", style="dim")
    return installed_games


nonsteam = get_non_steam_games(Path(STEAMPATH + r'/userdata/25934136/config'))

ids_nonsteam = {item[3]: item[0] for item in nonsteam}
ids_steam = get_steam_games()
console.print("Got appids.", style="green")


def dirloop(path: str):
    screenshotdirs = [id for id in os.scandir(USERREMOTEPATH)
                      if id.is_dir() and os.path.exists(f'{id.path}/screenshots')]
    for id in screenshotdirs:
        dir_id = os.path.basename(id)
#       print(dir_id)
        if dir_id in ids_nonsteam:
            console.print(f"Processing [cyan]non-steam[/cyan] appid [orange]{id.name}[/orange] ([yellow]{ids_nonsteam[dir_id]}[/yellow])...")
            if os.path.exists(f'{SCREENSHOTSROOTPATH}/{ids_nonsteam[dir_id]}'):
                os.unlink(f'{SCREENSHOTSROOTPATH}/{ids_nonsteam[dir_id]}')
            os.symlink(f'{id.path}/screenshots',
                       f'{SCREENSHOTSROOTPATH}/{ids_nonsteam[dir_id]}')
            continue
        if dir_id in ids_steam:
            console.print(f"Processing [cyan]steam[/cyan] appid [orange]{id.name}[/orange] ([yellow]{ids_steam[dir_id]}[/yellow])...")
            if os.path.exists(f'{SCREENSHOTSROOTPATH}/{ids_steam[dir_id]}'):
                os.unlink(f'{SCREENSHOTSROOTPATH}/{ids_steam[dir_id]}')
            os.symlink(f'{id.path}/screenshots',
                       f'{SCREENSHOTSROOTPATH}/{ids_steam[dir_id]}')
            continue
        console.print(f"ID {dir_id} was not found, skipping.", style="bold red")

dirloop(USERREMOTEPATH)
console.print("Done!", style="green")
