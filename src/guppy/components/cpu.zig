const std = @import("std");

const sst = @import("../single-step-tests.zig");

const Memory = @import("memory.zig").Memory;
const Registers = @import("registers.zig").Registers;
const OPCode = @import("../opcodes/opcodes.zig").OPCode;

const components = @import("./components.zig");

const cds = @import("../opcodes/opcodes.zig");

pub const CPUError = error{
    failed_to_parse,
};

pub const CPU = struct {
    registers: Registers = .init(),

    opcode: OPCode = .init(.{
        .m_cycle_function = cds.m_cycle_0x00,
    }),

    ir: u8 = 0,
    m_cycle: usize = 0,
    opcode_count: usize = 0,

    pub fn init() @This() {
        var result: @This() = .{};
        result.registers.set_pc(0x4000);
        result.registers.set_pc(0x0000);
        return result;
    }

    pub fn init_test(initial: sst.Initial) @This() {
        var result: @This() = .{};
        result.registers.data = .{
            initial.a, initial.f,
            initial.b, initial.c,
            initial.d, initial.e,
            initial.h, initial.l,
            0,         0,
            0,         0,
        };
        result.registers.set_sp(initial.sp);
        result.registers.set_pc(initial.pc);
        return result;
    }

    pub fn validate_test(self: @This(), final: sst.Final) bool {
        // self.registers.dump();
        return final.a == self.registers.data[0] and
            final.f == self.registers.data[1] and
            final.b == self.registers.data[2] and
            final.c == self.registers.data[3] and
            final.d == self.registers.data[4] and
            final.e == self.registers.data[5] and
            final.h == self.registers.data[6] and
            final.l == self.registers.data[7] and
            final.sp == self.registers.get_sp() and
            final.pc == self.registers.get_pc();
    }

    pub fn fetch(self: *@This(), memory: *Memory) void {
        const pc = self.registers.get_pc();
        const code = memory.data[pc];

        self.opcode = switch (code) {
            0x00 => .init(.{
                .m_cycle_function = cds.m_cycle_0x00,
            }),
            0x01 => .init(.{
                .m_cycle_function = cds.m_cycle_0x01,
            }),
            0x02 => .init(.{
                .m_cycle_function = cds.m_cycle_0x02,
            }),
            0x03 => .init(.{
                .m_cycle_function = cds.m_cycle_0x03,
            }),
            0x04 => .init(.{
                .m_cycle_function = cds.m_cycle_0x04,
            }),
            0x05 => .init(.{
                .m_cycle_function = cds.m_cycle_0x05,
            }),
            0x06 => .init(.{
                .m_cycle_function = cds.m_cycle_0x06,
            }),
            0x07 => .init(.{
                .m_cycle_function = cds.m_cycle_0x07,
            }),
            0x08 => .init(.{
                .m_cycle_function = cds.m_cycle_0x08,
            }),
            0x09 => .init(.{
                .m_cycle_function = cds.m_cycle_0x09,
            }),
            else => blk: {
                std.log.err("failed to parse code: 0x{x:0>2}", .{code});
                break :blk .init(.{
                    .m_cycle_function = cds.m_cycle_0x00,
                });
            },
        };
        self.m_cycle = 0;
        self.opcode_count = self.opcode_count + 1;
    }

    pub fn execute(self: *@This(), bus: *components.bus.Bus) void {
        self.m_cycle = self.opcode.m_cycle_function(&self.opcode, self.m_cycle, bus);
    }
};
