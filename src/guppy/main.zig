const std = @import("std");
const components = @import("components/components.zig");
const sst = @import("single-step-tests.zig");

pub fn main() !void {
    std.log.info("Project Guppy!", .{});

    var memory = components.memory.Memory.init();
    var cpu = components.cpu.CPU.init();

    var bus = components.bus.Bus.init(.{
        .cpu = &cpu,
        .memory = &memory,
    });

    // try bus.load_rom("./bin/01-special.bin");
    try bus.load_rom("./bin/tetris.bin");
    try bus.load_boot("./bin/boot.bin");
    memory.print_rom_info();

    const ticks_per_second = 100000;
    const tick_time = @divFloor(std.time.ns_per_min, ticks_per_second);

    var timer: std.time.Timer = try .start();
    var delta: u64 = 0.0;
    var tick_timer: u64 = 0.0;
    while (true) {
        tick_timer = tick_timer + delta;
        if (tick_timer >= tick_time) {
            tick_timer = 0;
            bus.tick();
        }

        delta = timer.read();
        timer.reset();
    }
}

test "cpu sst" {
    std.testing.log_level = .debug;
    for (0..10) |index| {
        var filename_buffer: [23]u8 = undefined;
        const filename = try std.fmt.bufPrint(&filename_buffer, "./tests/sm83/v1/{d:0>2}.json", .{index});

        const data = try std.Io.Dir.cwd().readFileAlloc(std.testing.io, filename, std.testing.allocator, std.Io.Limit.limited(1000000));
        defer std.testing.allocator.free(data);

        const parsed_data: std.json.Parsed(sst.Tests) = try std.json.parseFromSlice(sst.Tests, std.testing.allocator, data, .{ .ignore_unknown_fields = true });
        defer parsed_data.deinit();

        // std.log.info("running test: {s}", .{filename});

        for (parsed_data.value) |t| {
            // std.log.debug("init: {any}", .{t.initial});
            // std.log.debug("finl: {any}", .{t.final});

            var memory = components.memory.Memory.init_test(t.initial);
            var cpu = components.cpu.CPU.init_test(t.initial);
            var special_registers = components.special_registers.SpecialRegisters.init();
            cpu.fetch(&memory);
            cpu.registers.inc_pc();
            var bus = components.bus.Bus.init(.{
                .cpu = &cpu,
                .memory = &memory,
                .special_registers = &special_registers,
            });
            while (cpu.opcode_count <= 1) {
                bus.tick();
            }
            cpu.registers.set_pc(cpu.registers.get_pc() - 1);

            // cpu.registers.dump();
            try std.testing.expect(memory.validate_test(t.final));
            try std.testing.expect(cpu.validate_test(t.final));
        }
    }
}
