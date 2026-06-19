const std = @import("std");
const build_options = @import("build_options");
const glib = @import("glib");
const gobject = @import("gobject");
const gio = @import("gio");
const gtk = @import("gtk");
const adw = @import("adw");
const intl = @import("libintl");
const pbn = @import("libpbn");
const c_allocator = std.heap.c_allocator;
const mem = std.mem;
const constants = @import("constants.zig").Constants;

const package = constants.package;
const app_name = constants.app_name;

var global_io: std.Io = undefined;

pub fn main(init: std.process.Init) !void {
    global_io = init.io;

    intl.bindTextDomain(package, build_options.locale_dir ++ "");
    intl.bindTextDomainCodeset(package, "UTF-8");
    intl.setTextDomain(package);

    const app = Application.new();
    const args_vec = init.minimal.args.vector;
    const status = gio.Application.run(app.as(gio.Application), @intCast(args_vec.len), @ptrCast(@constCast(args_vec.ptr)));
    std.process.exit(@intCast(status));
}

const Application = extern struct {
    parent_instance: Parent,

    pub const Parent = adw.Application;

    pub const getGObjectType = gobject.ext.defineClass(Application, .{
        .name = constants.app_name ++ "Application",
        .classInit = &Class.init,
    });

    pub fn new() *Application {
        return gobject.ext.newInstance(Application, .{
            .application_id = build_options.app_id,
            .flags = gio.ApplicationFlags{},
        });
    }

    pub fn as(app: *Application, comptime T: type) *T {
        return gobject.ext.as(T, app);
    }

    fn activateImpl(app: *Application) callconv(.c) void {
        const win = ApplicationWindow.new(app);
        gtk.Window.present(win.as(gtk.Window));
    }

    pub const Class = extern struct {
        parent_class: Parent.Class,

        pub const Instance = Application;

        pub fn as(class: *Class, comptime T: type) *T {
            return gobject.ext.as(T, class);
        }

        fn init(class: *Class) callconv(.c) void {
            gio.Application.virtual_methods.activate.implement(class, &Application.activateImpl);
        }
    };
};

const ApplicationWindow = extern struct {
    parent_instance: Parent,

    pub const Parent = adw.ApplicationWindow;

    const Private = struct {
        window_title: *adw.WindowTitle,
        var offset: c_int = 0;
    };

    pub const getGObjectType = gobject.ext.defineClass(ApplicationWindow, .{
        .name = constants.app_name ++ "ApplicationWindow",
        .instanceInit = &init,
        .classInit = &Class.init,
        .parent_class = &Class.parent,
        .private = .{ .Type = Private, .offset = &Private.offset },
    });

    pub fn new(app: *Application) *ApplicationWindow {
        return gobject.ext.newInstance(ApplicationWindow, .{ .application = app });
    }

    pub fn as(win: *ApplicationWindow, comptime T: type) *T {
        return gobject.ext.as(T, win);
    }

    fn init(win: *ApplicationWindow, _: *Class) callconv(.c) void {
        gtk.Widget.initTemplate(win.as(gtk.Widget));

        const about = gio.SimpleAction.new("about", null);
        _ = gio.SimpleAction.signals.activate.connect(about, *ApplicationWindow, &handleAboutAction, win, .{});
        gio.ActionMap.addAction(win.as(gio.ActionMap), about.as(gio.Action));

        _ = gtk.Window.signals.close_request.connect(win, ?*anyopaque, &handleCloseRequest, null, .{});

        if (build_options.devel) {
            gtk.Widget.addCssClass(win.as(gtk.Widget), "devel");
        }

        adw.WindowTitle.setSubtitle(win.private().window_title, "");
    }

    fn dispose(win: *ApplicationWindow) callconv(.c) void {
        gtk.Widget.disposeTemplate(win.as(gtk.Widget), getGObjectType());
        gobject.Object.virtual_methods.dispose.call(Class.parent, win.as(Parent));
    }

    fn finalize(win: *ApplicationWindow) callconv(.c) void {
        gobject.Object.virtual_methods.finalize.call(Class.parent, win.as(Parent));
    }

    fn handleAboutAction(_: *gio.SimpleAction, _: ?*glib.Variant, win: *ApplicationWindow) callconv(.c) void {
        const about = adw.AboutWindow.newFromAppdata("metainfo.xml", null);
        gtk.Window.setTransientFor(about.as(gtk.Window), win.as(gtk.Window));
        gtk.Window.present(about.as(gtk.Window));
    }

    fn handleCloseRequest(_: *ApplicationWindow, _: ?*anyopaque) callconv(.c) c_int {
        return 0;
    }

    fn private(win: *ApplicationWindow) *Private {
        return gobject.ext.impl_helpers.getPrivate(win, Private, Private.offset);
    }

    pub const Class = extern struct {
        parent_class: Parent.Class,

        var parent: *Parent.Class = undefined;

        pub const Instance = ApplicationWindow;

        pub fn as(class: *Class, comptime T: type) *T {
            return gobject.ext.as(T, class);
        }

        fn init(class: *Class) callconv(.c) void {
            gobject.Object.virtual_methods.dispose.implement(class, &dispose);
            gobject.Object.virtual_methods.finalize.implement(class, &finalize);
            gtk.Widget.Class.setTemplateFromResource(class.as(gtk.Widget.Class), "/ui/window.ui");
            class.bindTemplateChildPrivate("window_title", .{});
        }

        fn bindTemplateChildPrivate(class: *Class, comptime name: [:0]const u8, comptime options: gtk.ext.BindTemplateChildOptions) void {
            gtk.ext.impl_helpers.bindTemplateChildPrivate(class, name, Private, Private.offset, options);
        }
    };
};
