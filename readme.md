# Overview

Puck2000 is a 1v1 video game adaptation of a board game involving pucks divided equally between the two players on a play field that is split in two and divided by a barrier with an opening.

Each player has to get their pucks through the opening in the middle to land it into their opponent’s side. The player who gets rid of all their pucks from their side wins.

# Design Notes

Game Engine: Godot 3.5.2 Stable (LTS)
Target Platform: HTML5 WebGL build only
Renderer: GLES2 - 3D unshaded (no lightning) low poly smooth shaded
Project Lead: Liyi Zhang (@liyiz)

# Organisation

Please note that `_assets_src` is for source assets only (the "raw" files that generate the game-ready assets for the engine). There is a `.gdignore` inside the directory so Godot knows to ignore it and not generate meta data for those files. Please refer to the file structure to know where to palce your game-ready assets (or if not available, please ask the project lead)

# Scale Reference

Please refer to the reference scale cube for all assets made for the game.

You can find the source asset here: `\puck2000\_assets_src\misc\scale_ref_cube`
You can find the in-game asset here: `\puck2000\test_scenes\scale_ref`

It is 1unit x 1unit x 1unit in Blender, exported and then imported into Godot with default import options.

# Material Import

Please remember to set the `unshaded` flag to on for the `.material` of any imported 3D model.
![alt text](https://github.com/gamkedo-la/puck2000/tree/main/_assets_src/readme/material_unshadedFlag.png "Screenshot of unshaded flag option")
