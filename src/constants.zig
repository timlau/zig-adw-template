const std = @import("std");

pub const Constants = @This();

pub const package = "my_adw_app";
pub const app_name = "MyZigAdwApp";
pub const app_id = "org.mydomain.MyZigAdwApp";
pub const app_path: []const u8 = std.mem.replace(app_id, ".", "/");
pub const version = "0.1.0";
