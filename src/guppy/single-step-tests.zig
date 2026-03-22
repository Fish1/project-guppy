pub const Initial = struct {
    pc: u16,
    sp: u16,
    a: u8,
    b: u8,
    c: u8,
    d: u8,
    e: u8,
    f: u8,
    h: u8,
    l: u8,
    ime: u8,
    ie: u8,
    ram: [][]u16,
};

pub const Final = struct {
    pc: u16,
    sp: u16,
    a: u8,
    b: u8,
    c: u8,
    d: u8,
    e: u8,
    f: u8,
    h: u8,
    l: u8,
    ime: u8,
    ram: [][]u16,
};

pub const Test = struct {
    name: []u8,
    initial: Initial,
    final: Final,
};

pub const Tests = []Test;
