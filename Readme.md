# Zig Libadwaita application Template

This is a template for creating a Libadwaita application using Zig and the zig-gobject bindings generator.

It is meant to be used as a starting point for creating a Libadwaita application using Zig.
the application is simple AdwApplication that uses a single window. with a menu button containing a about action, that shows an about dialog.

The template is work in progress and new features may be added in the future.

## Features

- building with Zig 0.16
- i18n support
- UI is designed using [blueprint](https://gnome.pages.gitlab.gnome.org/blueprint-compiler/)
- .desktop file (Desktop Environment Integration)
- .metainfo file for app metadata. (AppStream)
- flatpak support
- application icons 

## Future feature ideas.
  - Support for getting "zig-gobject" from the upstream repository with `zig fetch`.
  - Add more libadwaita widgets and features as a showcase.
  - A template generator to create new projects from this template.

## Requirements

- Zig 0.16
- Gtk-4.0 and Adw-1.0 introspection files must be installed on the system.
- blueprint-compiler
- zig-gobject from [timlau/zig-gobject](https://github.com/timlau/zig-gobject) it contains som zig 0.16 fixes, currently not in the upstream zig-gobject.
- zig-gobject must be checked out in the directory above the application (../zig-gobject).
  - Bindings must be generated using `zig build codegen`.
```
zig build codegen -Dmodules=Gtk-4.0
zig build codegen -Dmodules=Adw-1
```

## Attributions
- The template is heavily inspired by [nonograms](https://github.com/ianprime0509/nonograms) game at it was used as a starting point for this template.

## How to use

- build and run and the application using:

```
zig build blueprints
zig build run
```


## Creating a new project
- most naming is done in the `src/constants.zig` and can be customized there.
- many files in the `data/` directory must be renamed or replaced with your own content and match your app_id.
