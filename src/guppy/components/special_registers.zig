const std = @import("std");

pub const SpecialRegisters = struct {
    // | u8 | u8 |
    // -----------
    // | w  | z  |
    data: [2]u8 = std.mem.zeroes([2]u8),

    pub fn init() @This() {
        return .{};
    }

    pub fn get_w(self: @This()) u8 {
        return self.data[0];
    }

    pub fn set_w(self: *@This(), value: u8) void {
        self.data[0] = value;
    }

    pub fn get_z(self: @This()) u8 {
        return self.data[1];
    }

    pub fn set_z(self: *@This(), value: u8) void {
        self.data[1] = value;
    }

    pub fn get_wz(self: @This()) u16 {
        return std.mem.readInt(u16, self.data[0..][0..2], .big);
    }

    pub fn set_wz(self: *@This(), value: u16) void {
        std.mem.writeInt(u16, self.data[0..][0..2], value, .big);
    }

    pub fn inc_wz(self: *@This()) void {
        self.set_wz(self.get_wz() + 1);
    }
};
