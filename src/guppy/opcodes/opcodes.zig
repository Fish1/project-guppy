const std = @import("std");
const components = @import("../components/components.zig");
pub const CycleFunction = *const fn (cycle: usize, bus: *components.bus) usize;

pub fn m_cycle_0x00(_: usize, bus: *components.bus) usize {
    bus.cpu.fetch(bus.memory);
    bus.cpu.registers.inc_pc();
    return 0;
}

pub fn m_cycle_0x01(cycle: usize, bus: *components.bus) usize {
    switch (cycle) {
        0 => {
            bus.special_registers.set_z(
                bus.memory.data[bus.cpu.registers.get_pc()],
            );
            bus.cpu.registers.inc_pc();
            return 1;
        },
        1 => {
            bus.special_registers.set_w(
                bus.memory.data[bus.cpu.registers.get_pc()],
            );
            bus.cpu.registers.inc_pc();
            return 2;
        },
        2 => {
            const a = bus.special_registers.get_z();
            const b = bus.special_registers.get_w();
            const data: [2]u8 = .{ a, b };
            bus.cpu.registers.set_bc(
                std.mem.readInt(u16, &data, .little),
            );

            bus.cpu.fetch(bus.memory);
            bus.cpu.registers.inc_pc();
            return 0;
        },
        else => {
            return 0;
        },
    }
}

pub fn m_cycle_0x02(cycle: usize, bus: *components.bus) usize {
    switch (cycle) {
        0 => {
            const data = bus.cpu.registers.get_a();
            bus.memory.data[bus.cpu.registers.get_bc()] = data;
            return 1;
        },
        1 => {
            bus.cpu.fetch(bus.memory);
            bus.cpu.registers.inc_pc();
            return 0;
        },
        else => {
            return 0;
        },
    }
}

pub fn m_cycle_0x03(cycle: usize, bus: *components.bus) usize {
    switch (cycle) {
        0 => {
            bus.cpu.registers.set_bc(
                bus.cpu.registers.get_bc() + 1,
            );
            return 1;
        },
        1 => {
            bus.cpu.fetch(bus.memory);
            bus.cpu.registers.inc_pc();
            return 0;
        },
        else => {
            return 0;
        },
    }
}

pub fn m_cycle_0x04(cycle: usize, bus: *components.bus) usize {
    switch (cycle) {
        0 => {
            const b = bus.cpu.registers.get_b();

            const result = @addWithOverflow(b, 1);
            const zero_flag = result[0] == 0;
            const negative_flag = false;
            const half_carry_flag = (((b & 0b00001111) + 1) & 0b00010000) == 0b00010000;

            bus.cpu.registers.set_flag_z(zero_flag);
            bus.cpu.registers.set_flag_n(negative_flag);
            bus.cpu.registers.set_flag_h(half_carry_flag);
            bus.cpu.registers.set_b(result[0]);

            return 1;
        },
        1 => {
            bus.cpu.fetch(bus.memory);
            bus.cpu.registers.inc_pc();
            return 0;
        },
        else => {
            return 0;
        },
    }
}

pub fn m_cycle_0x05(cycle: usize, bus: *components.bus) usize {
    switch (cycle) {
        0 => {
            const b = bus.cpu.registers.get_b();

            const result = @subWithOverflow(b, 1);
            const zero_flag = result[0] == 0;
            const negative_flag = true;
            const half_carry_flag = (@subWithOverflow((b & 0b00001111), 1)[0] & 0b00010000) == 0b00010000;

            bus.cpu.registers.set_flag_z(zero_flag);
            bus.cpu.registers.set_flag_n(negative_flag);
            bus.cpu.registers.set_flag_h(half_carry_flag);
            bus.cpu.registers.set_b(result[0]);

            return 1;
        },
        1 => {
            bus.cpu.fetch(bus.memory);
            bus.cpu.registers.inc_pc();
            return 0;
        },
        else => {
            return 0;
        },
    }
}

pub fn m_cycle_0x06(cycle: usize, bus: *components.bus) usize {
    switch (cycle) {
        0 => {
            const n = bus.memory.data[bus.cpu.registers.get_pc()];
            bus.cpu.registers.inc_pc();
            bus.cpu.registers.set_b(n);
            return 1;
        },
        1 => {
            bus.cpu.fetch(bus.memory);
            bus.cpu.registers.inc_pc();
            return 0;
        },
        else => {
            return 0;
        },
    }
}

pub fn m_cycle_0x07(cycle: usize, bus: *components.bus) usize {
    switch (cycle) {
        0 => {
            const b7 = bus.cpu.registers.get_a() & 0b10000000;
            const new = (bus.cpu.registers.get_a() << 1) | @as(u8, @intFromBool(b7 != 0));
            bus.cpu.registers.set_flag_z(false);
            bus.cpu.registers.set_flag_n(false);
            bus.cpu.registers.set_flag_h(false);
            bus.cpu.registers.set_flag_c(b7 != 0);
            bus.cpu.registers.set_a(new);
            bus.cpu.fetch(bus.memory);
            bus.cpu.registers.inc_pc();
            return 0;
        },
        else => {
            return 0;
        },
    }
}

pub fn m_cycle_0x08(cycle: usize, bus: *components.bus) usize {
    switch (cycle) {
        0 => {
            bus.special_registers.set_z(
                bus.memory.data[
                    bus.cpu.registers.get_pc()
                ],
            );
            bus.cpu.registers.inc_pc();
            return 1;
        },
        1 => {
            bus.special_registers.set_w(
                bus.memory.data[
                    bus.cpu.registers.get_pc()
                ],
            );
            bus.cpu.registers.inc_pc();
            return 2;
        },
        2 => {
            const wz = bus.special_registers.get_wz();
            const sp = bus.cpu.registers.get_sp();
            const lsb: u8 = @intCast(sp & 0b11111111);
            bus.memory.data[wz] = lsb;
            bus.special_registers.inc_wz();
            return 3;
        },
        3 => {
            const wz = bus.special_registers.get_wz();
            const sp = bus.cpu.registers.get_sp();
            const msb: u8 = @intCast(sp >> 8);
            bus.memory.data[wz] = msb;
            bus.special_registers.inc_wz();
            return 4;
        },
        4 => {
            bus.cpu.fetch(bus.memory);
            bus.cpu.registers.inc_pc();
            return 0;
        },
        else => {
            return 0;
        },
    }
}

pub fn m_cycle_0x09(cycle: usize, bus: *components.bus) usize {
    switch (cycle) {
        0 => {
            const l = bus.cpu.registers.get_l();
            const c = bus.cpu.registers.get_c();

            const result1 = @addWithOverflow(l, c);

            const result = result1[0];
            const carry = result1[1] == 1;
            const half_carry = (((l & 0b1111) + (c & 0b1111)) & 0b10000) != 0;

            bus.cpu.registers.set_l(result);
            bus.cpu.registers.set_flag_n(false);
            bus.cpu.registers.set_flag_h(half_carry);
            bus.cpu.registers.set_flag_c(carry);

            return 1;
        },
        1 => {
            const h = bus.cpu.registers.get_h();
            const b = bus.cpu.registers.get_b();
            const flag_c: u8 = @intFromBool(bus.cpu.registers.get_flag_c());

            const result1 = @addWithOverflow(h, b);
            const result1_carry = result1[1] == 1;
            const result2 = @addWithOverflow(result1[0], flag_c);
            const result2_carry = result2[1] == 1;

            const result = result2[0];
            const carry = result1_carry or result2_carry;
            const half_carry = (((h & 0b1111) + (b & 0b1111) + (flag_c & 0b1111)) & 0b11110000) != 0;

            bus.cpu.registers.set_h(result);
            bus.cpu.registers.set_flag_n(false);
            bus.cpu.registers.set_flag_h(half_carry);
            bus.cpu.registers.set_flag_c(carry);

            bus.cpu.fetch(bus.memory);
            bus.cpu.registers.inc_pc();
            return 0;
        },
        else => {
            return 0;
        },
    }
}

pub fn m_cycle_0x0a(cycle: usize, bus: *components.bus) usize {
    switch (cycle) {
        0 => {
            bus.special_registers.set_z(
                bus.memory.data[
                    bus.cpu.registers.get_bc()
                ],
            );
            return 1;
        },
        1 => {
            bus.cpu.fetch(bus.memory);
            bus.cpu.registers.inc_pc();
            bus.cpu.registers.set_a(
                bus.special_registers.get_z(),
            );
            return 0;
        },
        else => {
            return 0;
        },
    }
}
