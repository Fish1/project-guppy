const std = @import("std");

const sst = @import("../single-step-tests.zig");

pub const Memory = struct {
    // rom: [0x7fff + 0x1]u8 = std.mem.zeros([0x7fff + 0x1]u8),
    // vram: [0x9fff - 0x8000 + 0x1]u8 = std.mem.zeros([0x9fff - 0x8000 + 0x1]u8),
    // sram: [0xbfff - 0xa000 + 0x1]u8 = std.mem.zeros([0xbfff - 0xa000 + 0x1]u8),
    // wram: [0xdfff - 0xc000 + 0x1]u8 = std.mem.zeros([0xdfff - 0xc000 + 0x1]u8),
    // oam: [0xfe9f - 0xfe00 + 0x1]u8 = std.mem.zeros([0xfe9f - 0xfe00 + 0x1]u8),
    // io: [0xff7f - 0xff00 + 0x1]u8 = std.mem.zeros([0xff7f - 0xff00 + 0x1]u8),
    // hram: [0xfffe - 0xff80 + 0x1]u8 = std.mem.zeros([0xfffe - 0xff80 + 0x1]u8),
    // ie: [0xffff - 0xffff + 0x1]u8 = std.mem.zeros([0xffff - 0xffff + 0x1]u8),
    data: [65536]u8 = std.mem.zeroes([65536]u8),

    pub fn init() @This() {
        return .{};
    }

    pub fn init_test(initial: sst.Initial) @This() {
        var result: @This() = .{};
        for (initial.ram) |v| {
            const location = v[0];
            const value = v[1];
            result.data[location] = @intCast(value);
        }
        return result;
    }

    pub fn validate_test(self: @This(), final: sst.Final) bool {
        for (final.ram) |v| {
            const location = v[0];
            const value = v[1];
            if (self.data[location] != value) {
                return false;
            }
        }
        return true;
    }

    pub fn get_rom_bank_00(self: *@This()) *const []u8 {
        return &self.data[0x0000..0x4000];
    }

    pub fn get_rom_bank_01(self: *@This()) *const []u8 {
        return &self.data[0x4000..0x8000];
    }

    pub fn print_rom_info(self: *@This()) void {
        std.log.info("title .. {s}", .{self.data[0x0134..0x0144]});
        std.log.info("manufacturer code .. {s}", .{self.data[0x013f..0x0143]});
        std.log.info("color mode .. {x}", .{self.data[0x0143..0x0144]});
        std.log.info("new licensee code .. {x}", .{self.data[0x0144..0x0145]});
        std.log.info("sgb flag .. {x}", .{self.data[0x0146..0x0147]});
        std.log.info("cartridge type .. {x}", .{self.data[0x0147..0x0148]});
        std.log.info("rom size .. {x}", .{self.data[0x0148..0x0149]});
        std.log.info("ram size .. {x}", .{self.data[0x0149..0x014a]});
        std.log.info("destination code .. {x}", .{self.data[0x014a..0x014b]});
        std.log.info("old licensee code .. {x}", .{self.data[0x014b..0x014c]});
        std.log.info("rom checksum .. {x}", .{self.data[0x014d..0x014e]});
        std.log.info("calculated checksum .. {x:0>2}", .{self.calculate_checksum()});
        std.log.info("checksum validated: {}", .{self.validate_checksum()});
    }

    pub fn calculate_checksum(self: *@This()) u8 {
        var checksum: u8 = 0;
        for (0x0134..0x014d) |byte| {
            checksum = @subWithOverflow(checksum, self.data[byte])[0];
            checksum = @subWithOverflow(checksum, 1)[0];
        }
        return checksum;
    }

    pub fn validate_checksum(self: *@This()) bool {
        return self.data[0x014d] == self.calculate_checksum();
    }
};
