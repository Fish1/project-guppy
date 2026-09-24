const std = @import("std");
pub const components = @import("components/components.zig");
pub const sst = @import("single-step-tests.zig");

pub fn main(init: std.process.Init) !void {
    std.log.info("Project Guppy!", .{});

    var memory = components.memory.init();
    var cpu = components.cpu.init();
    var special_registers = components.special_registers.init();

    var bus = components.bus.init(.{
        .cpu = &cpu,
        .memory = &memory,
        .special_registers = &special_registers,
    });

    // try bus.load_rom("./bin/01-special.bin");
    try bus.load_rom("./bin/tetris.bin", init.io);
    try bus.load_boot("./bin/boot.bin", init.io);
    memory.print_rom_info();

    const ticks_per_second = 100000;
    const tick_time = @divFloor(std.time.ns_per_min, ticks_per_second);

    const clock = std.Io.Clock.real;

    var now = clock.now(init.io);

    var tick_timer: i96 = 0.0;
    while (true) {
        const next = now.untilNow(init.io, clock);
        now = clock.now(init.io);

        tick_timer = tick_timer + next.toNanoseconds();
        if (tick_timer >= tick_time) {
            tick_timer = 0;
            bus.tick();
        }
    }
}
