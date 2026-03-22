const std = @import("std");

pub const Registers = struct {
    data: [12]u8 = std.mem.zeroes([12]u8),

    pub fn init() @This() {
        return .{};
    }

    pub fn get_a(self: @This()) u8 {
        return self.data[0];
    }

    pub fn set_a(self: *@This(), value: u8) void {
        self.data[0] = value;
    }

    pub fn get_f(self: @This()) u8 {
        return self.data[1];
    }

    pub fn set_f(self: *@This(), value: u8) void {
        self.data[1] = value;
    }

    pub fn get_u16(self: @This(), index: u4) u16 {
        return std.mem.readInt(u16, self.data[index..][0..2], .big);
    }

    pub fn set_u16(self: *@This(), index: u4, value: u16) void {
        return std.mem.writeInt(u16, self.data[index..][0..2], value, .big);
    }

    pub fn get_b(self: @This()) u8 {
        return self.data[2];
    }

    pub fn set_b(self: *@This(), value: u8) void {
        self.data[2] = value;
    }

    pub fn get_c(self: @This()) u8 {
        return self.data[3];
    }

    pub fn set_c(self: *@This(), value: u8) void {
        self.data[3] = value;
    }

    pub fn get_d(self: @This()) u8 {
        return self.data[4];
    }

    pub fn set_d(self: *@This(), value: u8) void {
        self.data[4] = value;
    }

    pub fn get_e(self: @This()) u8 {
        return self.data[5];
    }

    pub fn set_e(self: *@This(), value: u8) void {
        self.data[5] = value;
    }

    pub fn get_h(self: @This()) u8 {
        return self.data[6];
    }

    pub fn set_h(self: *@This(), value: u8) void {
        self.data[6] = value;
    }

    pub fn get_l(self: @This()) u8 {
        return self.data[7];
    }

    pub fn set_l(self: *@This(), value: u8) void {
        self.data[7] = value;
    }

    pub fn get_bc(self: @This()) u16 {
        return self.get_u16(2);
    }

    pub fn set_bc(self: *@This(), value: u16) void {
        self.set_u16(2, value);
    }

    pub fn get_de(self: @This()) u16 {
        return self.get_u16(4);
    }

    pub fn set_de(self: *@This(), value: u16) void {
        self.set_u16(4, value);
    }

    pub fn get_hl(self: @This()) u16 {
        return self.get_u16(6);
    }

    pub fn set_hl(self: *@This(), value: u16) void {
        self.set_u16(6, value);
    }

    pub fn get_sp(self: @This()) u16 {
        return self.get_u16(8);
    }

    pub fn set_sp(self: *@This(), value: u16) void {
        self.set_u16(8, value);
    }

    pub fn get_pc(self: @This()) u16 {
        return self.get_u16(10);
    }

    pub fn set_pc(self: *@This(), value: u16) void {
        self.set_u16(10, value);
    }

    pub fn inc_pc(self: *@This()) void {
        const next = @addWithOverflow(self.get_pc(), 1)[0];
        self.set_u16(10, next);
    }

    pub fn get_flag_z(self: @This()) bool {
        return self.get_f() & 0b10000000;
    }

    pub fn set_flag_z(self: *@This(), value: bool) void {
        const v: u8 = @intFromBool(value);
        const clear = self.get_f() & 0b01111111;
        const set = clear | (v << 7);
        self.set_f(set);
    }

    pub fn get_flag_n(self: @This()) bool {
        return self.get_f() & 0b01000000;
    }

    pub fn set_flag_n(self: *@This(), value: bool) void {
        const v: u8 = @intFromBool(value);
        const clear = self.get_f() & 0b10111111;
        const set = clear | (v << 6);
        self.set_f(set);
    }

    pub fn get_flag_h(self: @This()) bool {
        return self.get_f() & 0b00100000;
    }

    pub fn set_flag_h(self: *@This(), value: bool) void {
        const v: u8 = @intFromBool(value);
        const clear = self.get_f() & 0b11011111;
        const set = clear | (v << 5);
        self.set_f(set);
    }

    pub fn get_flag_c(self: @This()) bool {
        return self.get_f() & 0b00010000 != 0;
    }

    pub fn set_flag_c(self: *@This(), value: bool) void {
        const v: u8 = @intFromBool(value);
        const clear = self.get_f() & 0b11101111;
        const set = clear | (v << 4);
        self.set_f(set);
    }

    pub fn dump(self: @This()) void {
        std.debug.print("pc:{} sp:{} a:{} b:{} c:{} d:{} e:{} f:{} h:{} l:{} bc:{} de:{} hl:{}\n", .{
            self.get_pc(),
            self.get_sp(),
            self.get_a(),
            self.get_b(),
            self.get_c(),
            self.get_d(),
            self.get_e(),
            self.get_f(),
            self.get_h(),
            self.get_l(),
            self.get_bc(),
            self.get_de(),
            self.get_hl(),
        });
    }
};
