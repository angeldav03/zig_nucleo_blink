pub fn Register(comptime R: type) type {
    return RegisterRW(R, R);
}

pub fn RegisterRW(comptime Read: type, comptime Write: type) type {
    return struct {
        raw_ptr: *volatile u32,

        const Self = @This();

        pub fn init(address: usize) Self {
            return Self{ .raw_ptr = @intToPtr(*volatile u32, address) };
        }

        pub fn initRange(address: usize, comptime dim_increment: usize, comptime num_registers: usize) [num_registers]Self {
            var registers: [num_registers]Self = undefined;
            var i: usize = 0;
            while (i < num_registers) : (i += 1) {
                registers[i] = Self.init(address + (i * dim_increment));
            }
            return registers;
        }

        pub fn read(self: Self) Read {
            return @bitCast(Read, self.raw_ptr.*);
        }

        pub fn write(self: Self, value: Write) void {
            // Forcing the alignment is a workaround for stores through
            // volatile pointers generating multiple loads and stores.
            // This is necessary for LLVM to generate code that can successfully
            // modify MMIO registers that only allow word-sized stores.
            // https://github.com/ziglang/zig/issues/8981#issuecomment-854911077
            const aligned: Write align(4) = value;
            self.raw_ptr.* = @ptrCast(*const u32, &aligned).*;
        }

        pub fn modify(self: Self, new_value: anytype) void {
            if (Read != Write) {
                @compileError("Can't modify because read and write types for this register aren't the same.");
            }
            var old_value = self.read();
            const info = @typeInfo(@TypeOf(new_value));
            inline for (info.Struct.fields) |field| {
                @field(old_value, field.name) = @field(new_value, field.name);
            }
            self.write(old_value);
        }

        pub fn read_raw(self: Self) u32 {
            return self.raw_ptr.*;
        }

        pub fn write_raw(self: Self, value: u32) void {
            self.raw_ptr.* = value;
        }

        pub fn default_read_value(_: Self) Read {
            return Read{};
        }

        pub fn default_write_value(_: Self) Write {
            return Write{};
        }
    };
}

pub const device_name = "STM32L4x2";
pub const device_revision = "1.6";
pub const device_description = "STM32L4x2";

pub const cpu = struct {
    pub const name = "CM4";
    pub const revision = "r1p0";
    pub const endian = "little";
    pub const mpu_present = false;
    pub const fpu_present = false;
    pub const vendor_systick_config = false;
    pub const nvic_prio_bits = 3;
};

/// Digital-to-analog converter
pub const DAC1 = struct {

const base_address = 0x40007400;
/// CR
const CR_val = packed struct {
/// EN1 [0:0]
/// DAC channel1 enable
EN1: u1 = 0,
/// unused [1:1]
_unused1: u1 = 0,
/// TEN1 [2:2]
/// DAC channel1 trigger
TEN1: u1 = 0,
/// TSEL1 [3:5]
/// DAC channel1 trigger
TSEL1: u3 = 0,
/// WAVE1 [6:7]
/// DAC channel1 noise/triangle wave
WAVE1: u2 = 0,
/// MAMP1 [8:11]
/// DAC channel1 mask/amplitude
MAMP1: u4 = 0,
/// DMAEN1 [12:12]
/// DAC channel1 DMA enable
DMAEN1: u1 = 0,
/// DMAUDRIE1 [13:13]
/// DAC channel1 DMA Underrun Interrupt
DMAUDRIE1: u1 = 0,
/// CEN1 [14:14]
/// DAC Channel 1 calibration
CEN1: u1 = 0,
/// unused [15:15]
_unused15: u1 = 0,
/// EN2 [16:16]
/// DAC channel2 enable
EN2: u1 = 0,
/// unused [17:17]
_unused17: u1 = 0,
/// TEN2 [18:18]
/// DAC channel2 trigger
TEN2: u1 = 0,
/// TSEL2 [19:21]
/// DAC channel2 trigger
TSEL2: u3 = 0,
/// WAVE2 [22:23]
/// DAC channel2 noise/triangle wave
WAVE2: u2 = 0,
/// MAMP2 [24:27]
/// DAC channel2 mask/amplitude
MAMP2: u4 = 0,
/// DMAEN2 [28:28]
/// DAC channel2 DMA enable
DMAEN2: u1 = 0,
/// DMAUDRIE2 [29:29]
/// DAC channel2 DMA underrun interrupt
DMAUDRIE2: u1 = 0,
/// CEN2 [30:30]
/// DAC Channel 2 calibration
CEN2: u1 = 0,
/// unused [31:31]
_unused31: u1 = 0,
};
/// control register
pub const CR = Register(CR_val).init(base_address + 0x0);

/// SWTRIGR
const SWTRIGR_val = packed struct {
/// SWTRIG1 [0:0]
/// DAC channel1 software
SWTRIG1: u1 = 0,
/// SWTRIG2 [1:1]
/// DAC channel2 software
SWTRIG2: u1 = 0,
/// unused [2:31]
_unused2: u6 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// software trigger register
pub const SWTRIGR = Register(SWTRIGR_val).init(base_address + 0x4);

/// DHR12R1
const DHR12R1_val = packed struct {
/// DACC1DHR [0:11]
/// DAC channel1 12-bit right-aligned
DACC1DHR: u12 = 0,
/// unused [12:31]
_unused12: u4 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel1 12-bit right-aligned data holding
pub const DHR12R1 = Register(DHR12R1_val).init(base_address + 0x8);

/// DHR12L1
const DHR12L1_val = packed struct {
/// unused [0:3]
_unused0: u4 = 0,
/// DACC1DHR [4:15]
/// DAC channel1 12-bit left-aligned
DACC1DHR: u12 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel1 12-bit left-aligned data holding
pub const DHR12L1 = Register(DHR12L1_val).init(base_address + 0xc);

/// DHR8R1
const DHR8R1_val = packed struct {
/// DACC1DHR [0:7]
/// DAC channel1 8-bit right-aligned
DACC1DHR: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel1 8-bit right-aligned data holding
pub const DHR8R1 = Register(DHR8R1_val).init(base_address + 0x10);

/// DHR12R2
const DHR12R2_val = packed struct {
/// DACC2DHR [0:11]
/// DAC channel2 12-bit right-aligned
DACC2DHR: u12 = 0,
/// unused [12:31]
_unused12: u4 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel2 12-bit right aligned data holding
pub const DHR12R2 = Register(DHR12R2_val).init(base_address + 0x14);

/// DHR12L2
const DHR12L2_val = packed struct {
/// unused [0:3]
_unused0: u4 = 0,
/// DACC2DHR [4:15]
/// DAC channel2 12-bit left-aligned
DACC2DHR: u12 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel2 12-bit left aligned data holding
pub const DHR12L2 = Register(DHR12L2_val).init(base_address + 0x18);

/// DHR8R2
const DHR8R2_val = packed struct {
/// DACC2DHR [0:7]
/// DAC channel2 8-bit right-aligned
DACC2DHR: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel2 8-bit right-aligned data holding
pub const DHR8R2 = Register(DHR8R2_val).init(base_address + 0x1c);

/// DHR12RD
const DHR12RD_val = packed struct {
/// DACC1DHR [0:11]
/// DAC channel1 12-bit right-aligned
DACC1DHR: u12 = 0,
/// unused [12:15]
_unused12: u4 = 0,
/// DACC2DHR [16:27]
/// DAC channel2 12-bit right-aligned
DACC2DHR: u12 = 0,
/// unused [28:31]
_unused28: u4 = 0,
};
/// Dual DAC 12-bit right-aligned data holding
pub const DHR12RD = Register(DHR12RD_val).init(base_address + 0x20);

/// DHR12LD
const DHR12LD_val = packed struct {
/// unused [0:3]
_unused0: u4 = 0,
/// DACC1DHR [4:15]
/// DAC channel1 12-bit left-aligned
DACC1DHR: u12 = 0,
/// unused [16:19]
_unused16: u4 = 0,
/// DACC2DHR [20:31]
/// DAC channel2 12-bit left-aligned
DACC2DHR: u12 = 0,
};
/// DUAL DAC 12-bit left aligned data holding
pub const DHR12LD = Register(DHR12LD_val).init(base_address + 0x24);

/// DHR8RD
const DHR8RD_val = packed struct {
/// DACC1DHR [0:7]
/// DAC channel1 8-bit right-aligned
DACC1DHR: u8 = 0,
/// DACC2DHR [8:15]
/// DAC channel2 8-bit right-aligned
DACC2DHR: u8 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DUAL DAC 8-bit right aligned data holding
pub const DHR8RD = Register(DHR8RD_val).init(base_address + 0x28);

/// DOR1
const DOR1_val = packed struct {
/// DACC1DOR [0:11]
/// DAC channel1 data output
DACC1DOR: u12 = 0,
/// unused [12:31]
_unused12: u4 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel1 data output register
pub const DOR1 = Register(DOR1_val).init(base_address + 0x2c);

/// DOR2
const DOR2_val = packed struct {
/// DACC2DOR [0:11]
/// DAC channel2 data output
DACC2DOR: u12 = 0,
/// unused [12:31]
_unused12: u4 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel2 data output register
pub const DOR2 = Register(DOR2_val).init(base_address + 0x30);

/// SR
const SR_val = packed struct {
/// unused [0:12]
_unused0: u8 = 0,
_unused8: u5 = 0,
/// DMAUDR1 [13:13]
/// DAC channel1 DMA underrun
DMAUDR1: u1 = 0,
/// CAL_FLAG1 [14:14]
/// DAC Channel 1 calibration offset
CAL_FLAG1: u1 = 0,
/// BWST1 [15:15]
/// DAC Channel 1 busy writing sample time
BWST1: u1 = 0,
/// unused [16:28]
_unused16: u8 = 0,
_unused24: u5 = 0,
/// DMAUDR2 [29:29]
/// DAC channel2 DMA underrun
DMAUDR2: u1 = 0,
/// CAL_FLAG2 [30:30]
/// DAC Channel 2 calibration offset
CAL_FLAG2: u1 = 0,
/// BWST2 [31:31]
/// DAC Channel 2 busy writing sample time
BWST2: u1 = 0,
};
/// status register
pub const SR = Register(SR_val).init(base_address + 0x34);

/// CCR
const CCR_val = packed struct {
/// OTRIM1 [0:4]
/// DAC Channel 1 offset trimming
OTRIM1: u5 = 0,
/// unused [5:15]
_unused5: u3 = 0,
_unused8: u8 = 0,
/// OTRIM2 [16:20]
/// DAC Channel 2 offset trimming
OTRIM2: u5 = 0,
/// unused [21:31]
_unused21: u3 = 0,
_unused24: u8 = 0,
};
/// calibration control register
pub const CCR = Register(CCR_val).init(base_address + 0x38);

/// MCR
const MCR_val = packed struct {
/// MODE1 [0:2]
/// DAC Channel 1 mode
MODE1: u3 = 0,
/// unused [3:15]
_unused3: u5 = 0,
_unused8: u8 = 0,
/// MODE2 [16:18]
/// DAC Channel 2 mode
MODE2: u3 = 0,
/// unused [19:31]
_unused19: u5 = 0,
_unused24: u8 = 0,
};
/// mode control register
pub const MCR = Register(MCR_val).init(base_address + 0x3c);

/// SHSR1
const SHSR1_val = packed struct {
/// TSAMPLE1 [0:9]
/// DAC Channel 1 sample Time
TSAMPLE1: u10 = 0,
/// unused [10:31]
_unused10: u6 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Sample and Hold sample time register
pub const SHSR1 = Register(SHSR1_val).init(base_address + 0x40);

/// SHSR2
const SHSR2_val = packed struct {
/// TSAMPLE2 [0:9]
/// DAC Channel 2 sample Time
TSAMPLE2: u10 = 0,
/// unused [10:31]
_unused10: u6 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Sample and Hold sample time register
pub const SHSR2 = Register(SHSR2_val).init(base_address + 0x44);

/// SHHR
const SHHR_val = packed struct {
/// THOLD1 [0:9]
/// DAC Channel 1 hold Time
THOLD1: u10 = 1,
/// unused [10:15]
_unused10: u6 = 0,
/// THOLD2 [16:25]
/// DAC Channel 2 hold time
THOLD2: u10 = 1,
/// unused [26:31]
_unused26: u6 = 0,
};
/// Sample and Hold hold time
pub const SHHR = Register(SHHR_val).init(base_address + 0x48);

/// SHRR
const SHRR_val = packed struct {
/// TREFRESH1 [0:7]
/// DAC Channel 1 refresh Time
TREFRESH1: u8 = 1,
/// unused [8:15]
_unused8: u8 = 0,
/// TREFRESH2 [16:23]
/// DAC Channel 2 refresh Time
TREFRESH2: u8 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// Sample and Hold refresh time
pub const SHRR = Register(SHRR_val).init(base_address + 0x4c);
};

/// Direct memory access controller
pub const DMA1 = struct {

const base_address = 0x40020000;
/// ISR
const ISR_val = packed struct {
/// GIF1 [0:0]
/// Channel x global interrupt flag (x = 1
GIF1: u1 = 0,
/// TCIF1 [1:1]
/// Channel x transfer complete flag (x = 1
TCIF1: u1 = 0,
/// HTIF1 [2:2]
/// Channel x half transfer flag (x = 1
HTIF1: u1 = 0,
/// TEIF1 [3:3]
/// Channel x transfer error flag (x = 1
TEIF1: u1 = 0,
/// GIF2 [4:4]
/// Channel x global interrupt flag (x = 1
GIF2: u1 = 0,
/// TCIF2 [5:5]
/// Channel x transfer complete flag (x = 1
TCIF2: u1 = 0,
/// HTIF2 [6:6]
/// Channel x half transfer flag (x = 1
HTIF2: u1 = 0,
/// TEIF2 [7:7]
/// Channel x transfer error flag (x = 1
TEIF2: u1 = 0,
/// GIF3 [8:8]
/// Channel x global interrupt flag (x = 1
GIF3: u1 = 0,
/// TCIF3 [9:9]
/// Channel x transfer complete flag (x = 1
TCIF3: u1 = 0,
/// HTIF3 [10:10]
/// Channel x half transfer flag (x = 1
HTIF3: u1 = 0,
/// TEIF3 [11:11]
/// Channel x transfer error flag (x = 1
TEIF3: u1 = 0,
/// GIF4 [12:12]
/// Channel x global interrupt flag (x = 1
GIF4: u1 = 0,
/// TCIF4 [13:13]
/// Channel x transfer complete flag (x = 1
TCIF4: u1 = 0,
/// HTIF4 [14:14]
/// Channel x half transfer flag (x = 1
HTIF4: u1 = 0,
/// TEIF4 [15:15]
/// Channel x transfer error flag (x = 1
TEIF4: u1 = 0,
/// GIF5 [16:16]
/// Channel x global interrupt flag (x = 1
GIF5: u1 = 0,
/// TCIF5 [17:17]
/// Channel x transfer complete flag (x = 1
TCIF5: u1 = 0,
/// HTIF5 [18:18]
/// Channel x half transfer flag (x = 1
HTIF5: u1 = 0,
/// TEIF5 [19:19]
/// Channel x transfer error flag (x = 1
TEIF5: u1 = 0,
/// GIF6 [20:20]
/// Channel x global interrupt flag (x = 1
GIF6: u1 = 0,
/// TCIF6 [21:21]
/// Channel x transfer complete flag (x = 1
TCIF6: u1 = 0,
/// HTIF6 [22:22]
/// Channel x half transfer flag (x = 1
HTIF6: u1 = 0,
/// TEIF6 [23:23]
/// Channel x transfer error flag (x = 1
TEIF6: u1 = 0,
/// GIF7 [24:24]
/// Channel x global interrupt flag (x = 1
GIF7: u1 = 0,
/// TCIF7 [25:25]
/// Channel x transfer complete flag (x = 1
TCIF7: u1 = 0,
/// HTIF7 [26:26]
/// Channel x half transfer flag (x = 1
HTIF7: u1 = 0,
/// TEIF7 [27:27]
/// Channel x transfer error flag (x = 1
TEIF7: u1 = 0,
/// unused [28:31]
_unused28: u4 = 0,
};
/// interrupt status register
pub const ISR = Register(ISR_val).init(base_address + 0x0);

/// IFCR
const IFCR_val = packed struct {
/// CGIF1 [0:0]
/// Channel x global interrupt clear (x = 1
CGIF1: u1 = 0,
/// CTCIF1 [1:1]
/// Channel x transfer complete clear (x = 1
CTCIF1: u1 = 0,
/// CHTIF1 [2:2]
/// Channel x half transfer clear (x = 1
CHTIF1: u1 = 0,
/// CTEIF1 [3:3]
/// Channel x transfer error clear (x = 1
CTEIF1: u1 = 0,
/// CGIF2 [4:4]
/// Channel x global interrupt clear (x = 1
CGIF2: u1 = 0,
/// CTCIF2 [5:5]
/// Channel x transfer complete clear (x = 1
CTCIF2: u1 = 0,
/// CHTIF2 [6:6]
/// Channel x half transfer clear (x = 1
CHTIF2: u1 = 0,
/// CTEIF2 [7:7]
/// Channel x transfer error clear (x = 1
CTEIF2: u1 = 0,
/// CGIF3 [8:8]
/// Channel x global interrupt clear (x = 1
CGIF3: u1 = 0,
/// CTCIF3 [9:9]
/// Channel x transfer complete clear (x = 1
CTCIF3: u1 = 0,
/// CHTIF3 [10:10]
/// Channel x half transfer clear (x = 1
CHTIF3: u1 = 0,
/// CTEIF3 [11:11]
/// Channel x transfer error clear (x = 1
CTEIF3: u1 = 0,
/// CGIF4 [12:12]
/// Channel x global interrupt clear (x = 1
CGIF4: u1 = 0,
/// CTCIF4 [13:13]
/// Channel x transfer complete clear (x = 1
CTCIF4: u1 = 0,
/// CHTIF4 [14:14]
/// Channel x half transfer clear (x = 1
CHTIF4: u1 = 0,
/// CTEIF4 [15:15]
/// Channel x transfer error clear (x = 1
CTEIF4: u1 = 0,
/// CGIF5 [16:16]
/// Channel x global interrupt clear (x = 1
CGIF5: u1 = 0,
/// CTCIF5 [17:17]
/// Channel x transfer complete clear (x = 1
CTCIF5: u1 = 0,
/// CHTIF5 [18:18]
/// Channel x half transfer clear (x = 1
CHTIF5: u1 = 0,
/// CTEIF5 [19:19]
/// Channel x transfer error clear (x = 1
CTEIF5: u1 = 0,
/// CGIF6 [20:20]
/// Channel x global interrupt clear (x = 1
CGIF6: u1 = 0,
/// CTCIF6 [21:21]
/// Channel x transfer complete clear (x = 1
CTCIF6: u1 = 0,
/// CHTIF6 [22:22]
/// Channel x half transfer clear (x = 1
CHTIF6: u1 = 0,
/// CTEIF6 [23:23]
/// Channel x transfer error clear (x = 1
CTEIF6: u1 = 0,
/// CGIF7 [24:24]
/// Channel x global interrupt clear (x = 1
CGIF7: u1 = 0,
/// CTCIF7 [25:25]
/// Channel x transfer complete clear (x = 1
CTCIF7: u1 = 0,
/// CHTIF7 [26:26]
/// Channel x half transfer clear (x = 1
CHTIF7: u1 = 0,
/// CTEIF7 [27:27]
/// Channel x transfer error clear (x = 1
CTEIF7: u1 = 0,
/// unused [28:31]
_unused28: u4 = 0,
};
/// interrupt flag clear register
pub const IFCR = Register(IFCR_val).init(base_address + 0x4);

/// CCR1
const CCR1_val = packed struct {
/// EN [0:0]
/// Channel enable
EN: u1 = 0,
/// TCIE [1:1]
/// Transfer complete interrupt
TCIE: u1 = 0,
/// HTIE [2:2]
/// Half transfer interrupt
HTIE: u1 = 0,
/// TEIE [3:3]
/// Transfer error interrupt
TEIE: u1 = 0,
/// DIR [4:4]
/// Data transfer direction
DIR: u1 = 0,
/// CIRC [5:5]
/// Circular mode
CIRC: u1 = 0,
/// PINC [6:6]
/// Peripheral increment mode
PINC: u1 = 0,
/// MINC [7:7]
/// Memory increment mode
MINC: u1 = 0,
/// PSIZE [8:9]
/// Peripheral size
PSIZE: u2 = 0,
/// MSIZE [10:11]
/// Memory size
MSIZE: u2 = 0,
/// PL [12:13]
/// Channel priority level
PL: u2 = 0,
/// MEM2MEM [14:14]
/// Memory to memory mode
MEM2MEM: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x configuration
pub const CCR1 = Register(CCR1_val).init(base_address + 0x8);

/// CNDTR1
const CNDTR1_val = packed struct {
/// NDT [0:15]
/// Number of data to transfer
NDT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x number of data
pub const CNDTR1 = Register(CNDTR1_val).init(base_address + 0xc);

/// CPAR1
const CPAR1_val = packed struct {
/// PA [0:31]
/// Peripheral address
PA: u32 = 0,
};
/// channel x peripheral address
pub const CPAR1 = Register(CPAR1_val).init(base_address + 0x10);

/// CMAR1
const CMAR1_val = packed struct {
/// MA [0:31]
/// Memory address
MA: u32 = 0,
};
/// channel x memory address
pub const CMAR1 = Register(CMAR1_val).init(base_address + 0x14);

/// CCR2
const CCR2_val = packed struct {
/// EN [0:0]
/// Channel enable
EN: u1 = 0,
/// TCIE [1:1]
/// Transfer complete interrupt
TCIE: u1 = 0,
/// HTIE [2:2]
/// Half transfer interrupt
HTIE: u1 = 0,
/// TEIE [3:3]
/// Transfer error interrupt
TEIE: u1 = 0,
/// DIR [4:4]
/// Data transfer direction
DIR: u1 = 0,
/// CIRC [5:5]
/// Circular mode
CIRC: u1 = 0,
/// PINC [6:6]
/// Peripheral increment mode
PINC: u1 = 0,
/// MINC [7:7]
/// Memory increment mode
MINC: u1 = 0,
/// PSIZE [8:9]
/// Peripheral size
PSIZE: u2 = 0,
/// MSIZE [10:11]
/// Memory size
MSIZE: u2 = 0,
/// PL [12:13]
/// Channel priority level
PL: u2 = 0,
/// MEM2MEM [14:14]
/// Memory to memory mode
MEM2MEM: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x configuration
pub const CCR2 = Register(CCR2_val).init(base_address + 0x1c);

/// CNDTR2
const CNDTR2_val = packed struct {
/// NDT [0:15]
/// Number of data to transfer
NDT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x number of data
pub const CNDTR2 = Register(CNDTR2_val).init(base_address + 0x20);

/// CPAR2
const CPAR2_val = packed struct {
/// PA [0:31]
/// Peripheral address
PA: u32 = 0,
};
/// channel x peripheral address
pub const CPAR2 = Register(CPAR2_val).init(base_address + 0x24);

/// CMAR2
const CMAR2_val = packed struct {
/// MA [0:31]
/// Memory address
MA: u32 = 0,
};
/// channel x memory address
pub const CMAR2 = Register(CMAR2_val).init(base_address + 0x28);

/// CCR3
const CCR3_val = packed struct {
/// EN [0:0]
/// Channel enable
EN: u1 = 0,
/// TCIE [1:1]
/// Transfer complete interrupt
TCIE: u1 = 0,
/// HTIE [2:2]
/// Half transfer interrupt
HTIE: u1 = 0,
/// TEIE [3:3]
/// Transfer error interrupt
TEIE: u1 = 0,
/// DIR [4:4]
/// Data transfer direction
DIR: u1 = 0,
/// CIRC [5:5]
/// Circular mode
CIRC: u1 = 0,
/// PINC [6:6]
/// Peripheral increment mode
PINC: u1 = 0,
/// MINC [7:7]
/// Memory increment mode
MINC: u1 = 0,
/// PSIZE [8:9]
/// Peripheral size
PSIZE: u2 = 0,
/// MSIZE [10:11]
/// Memory size
MSIZE: u2 = 0,
/// PL [12:13]
/// Channel priority level
PL: u2 = 0,
/// MEM2MEM [14:14]
/// Memory to memory mode
MEM2MEM: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x configuration
pub const CCR3 = Register(CCR3_val).init(base_address + 0x30);

/// CNDTR3
const CNDTR3_val = packed struct {
/// NDT [0:15]
/// Number of data to transfer
NDT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x number of data
pub const CNDTR3 = Register(CNDTR3_val).init(base_address + 0x34);

/// CPAR3
const CPAR3_val = packed struct {
/// PA [0:31]
/// Peripheral address
PA: u32 = 0,
};
/// channel x peripheral address
pub const CPAR3 = Register(CPAR3_val).init(base_address + 0x38);

/// CMAR3
const CMAR3_val = packed struct {
/// MA [0:31]
/// Memory address
MA: u32 = 0,
};
/// channel x memory address
pub const CMAR3 = Register(CMAR3_val).init(base_address + 0x3c);

/// CCR4
const CCR4_val = packed struct {
/// EN [0:0]
/// Channel enable
EN: u1 = 0,
/// TCIE [1:1]
/// Transfer complete interrupt
TCIE: u1 = 0,
/// HTIE [2:2]
/// Half transfer interrupt
HTIE: u1 = 0,
/// TEIE [3:3]
/// Transfer error interrupt
TEIE: u1 = 0,
/// DIR [4:4]
/// Data transfer direction
DIR: u1 = 0,
/// CIRC [5:5]
/// Circular mode
CIRC: u1 = 0,
/// PINC [6:6]
/// Peripheral increment mode
PINC: u1 = 0,
/// MINC [7:7]
/// Memory increment mode
MINC: u1 = 0,
/// PSIZE [8:9]
/// Peripheral size
PSIZE: u2 = 0,
/// MSIZE [10:11]
/// Memory size
MSIZE: u2 = 0,
/// PL [12:13]
/// Channel priority level
PL: u2 = 0,
/// MEM2MEM [14:14]
/// Memory to memory mode
MEM2MEM: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x configuration
pub const CCR4 = Register(CCR4_val).init(base_address + 0x44);

/// CNDTR4
const CNDTR4_val = packed struct {
/// NDT [0:15]
/// Number of data to transfer
NDT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x number of data
pub const CNDTR4 = Register(CNDTR4_val).init(base_address + 0x48);

/// CPAR4
const CPAR4_val = packed struct {
/// PA [0:31]
/// Peripheral address
PA: u32 = 0,
};
/// channel x peripheral address
pub const CPAR4 = Register(CPAR4_val).init(base_address + 0x4c);

/// CMAR4
const CMAR4_val = packed struct {
/// MA [0:31]
/// Memory address
MA: u32 = 0,
};
/// channel x memory address
pub const CMAR4 = Register(CMAR4_val).init(base_address + 0x50);

/// CCR5
const CCR5_val = packed struct {
/// EN [0:0]
/// Channel enable
EN: u1 = 0,
/// TCIE [1:1]
/// Transfer complete interrupt
TCIE: u1 = 0,
/// HTIE [2:2]
/// Half transfer interrupt
HTIE: u1 = 0,
/// TEIE [3:3]
/// Transfer error interrupt
TEIE: u1 = 0,
/// DIR [4:4]
/// Data transfer direction
DIR: u1 = 0,
/// CIRC [5:5]
/// Circular mode
CIRC: u1 = 0,
/// PINC [6:6]
/// Peripheral increment mode
PINC: u1 = 0,
/// MINC [7:7]
/// Memory increment mode
MINC: u1 = 0,
/// PSIZE [8:9]
/// Peripheral size
PSIZE: u2 = 0,
/// MSIZE [10:11]
/// Memory size
MSIZE: u2 = 0,
/// PL [12:13]
/// Channel priority level
PL: u2 = 0,
/// MEM2MEM [14:14]
/// Memory to memory mode
MEM2MEM: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x configuration
pub const CCR5 = Register(CCR5_val).init(base_address + 0x58);

/// CNDTR5
const CNDTR5_val = packed struct {
/// NDT [0:15]
/// Number of data to transfer
NDT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x number of data
pub const CNDTR5 = Register(CNDTR5_val).init(base_address + 0x5c);

/// CPAR5
const CPAR5_val = packed struct {
/// PA [0:31]
/// Peripheral address
PA: u32 = 0,
};
/// channel x peripheral address
pub const CPAR5 = Register(CPAR5_val).init(base_address + 0x60);

/// CMAR5
const CMAR5_val = packed struct {
/// MA [0:31]
/// Memory address
MA: u32 = 0,
};
/// channel x memory address
pub const CMAR5 = Register(CMAR5_val).init(base_address + 0x64);

/// CCR6
const CCR6_val = packed struct {
/// EN [0:0]
/// Channel enable
EN: u1 = 0,
/// TCIE [1:1]
/// Transfer complete interrupt
TCIE: u1 = 0,
/// HTIE [2:2]
/// Half transfer interrupt
HTIE: u1 = 0,
/// TEIE [3:3]
/// Transfer error interrupt
TEIE: u1 = 0,
/// DIR [4:4]
/// Data transfer direction
DIR: u1 = 0,
/// CIRC [5:5]
/// Circular mode
CIRC: u1 = 0,
/// PINC [6:6]
/// Peripheral increment mode
PINC: u1 = 0,
/// MINC [7:7]
/// Memory increment mode
MINC: u1 = 0,
/// PSIZE [8:9]
/// Peripheral size
PSIZE: u2 = 0,
/// MSIZE [10:11]
/// Memory size
MSIZE: u2 = 0,
/// PL [12:13]
/// Channel priority level
PL: u2 = 0,
/// MEM2MEM [14:14]
/// Memory to memory mode
MEM2MEM: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x configuration
pub const CCR6 = Register(CCR6_val).init(base_address + 0x6c);

/// CNDTR6
const CNDTR6_val = packed struct {
/// NDT [0:15]
/// Number of data to transfer
NDT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x number of data
pub const CNDTR6 = Register(CNDTR6_val).init(base_address + 0x70);

/// CPAR6
const CPAR6_val = packed struct {
/// PA [0:31]
/// Peripheral address
PA: u32 = 0,
};
/// channel x peripheral address
pub const CPAR6 = Register(CPAR6_val).init(base_address + 0x74);

/// CMAR6
const CMAR6_val = packed struct {
/// MA [0:31]
/// Memory address
MA: u32 = 0,
};
/// channel x memory address
pub const CMAR6 = Register(CMAR6_val).init(base_address + 0x78);

/// CCR7
const CCR7_val = packed struct {
/// EN [0:0]
/// Channel enable
EN: u1 = 0,
/// TCIE [1:1]
/// Transfer complete interrupt
TCIE: u1 = 0,
/// HTIE [2:2]
/// Half transfer interrupt
HTIE: u1 = 0,
/// TEIE [3:3]
/// Transfer error interrupt
TEIE: u1 = 0,
/// DIR [4:4]
/// Data transfer direction
DIR: u1 = 0,
/// CIRC [5:5]
/// Circular mode
CIRC: u1 = 0,
/// PINC [6:6]
/// Peripheral increment mode
PINC: u1 = 0,
/// MINC [7:7]
/// Memory increment mode
MINC: u1 = 0,
/// PSIZE [8:9]
/// Peripheral size
PSIZE: u2 = 0,
/// MSIZE [10:11]
/// Memory size
MSIZE: u2 = 0,
/// PL [12:13]
/// Channel priority level
PL: u2 = 0,
/// MEM2MEM [14:14]
/// Memory to memory mode
MEM2MEM: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x configuration
pub const CCR7 = Register(CCR7_val).init(base_address + 0x80);

/// CNDTR7
const CNDTR7_val = packed struct {
/// NDT [0:15]
/// Number of data to transfer
NDT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x number of data
pub const CNDTR7 = Register(CNDTR7_val).init(base_address + 0x84);

/// CPAR7
const CPAR7_val = packed struct {
/// PA [0:31]
/// Peripheral address
PA: u32 = 0,
};
/// channel x peripheral address
pub const CPAR7 = Register(CPAR7_val).init(base_address + 0x88);

/// CMAR7
const CMAR7_val = packed struct {
/// MA [0:31]
/// Memory address
MA: u32 = 0,
};
/// channel x memory address
pub const CMAR7 = Register(CMAR7_val).init(base_address + 0x8c);

/// CSELR
const CSELR_val = packed struct {
/// C1S [0:3]
/// DMA channel 1 selection
C1S: u4 = 0,
/// C2S [4:7]
/// DMA channel 2 selection
C2S: u4 = 0,
/// C3S [8:11]
/// DMA channel 3 selection
C3S: u4 = 0,
/// C4S [12:15]
/// DMA channel 4 selection
C4S: u4 = 0,
/// C5S [16:19]
/// DMA channel 5 selection
C5S: u4 = 0,
/// C6S [20:23]
/// DMA channel 6 selection
C6S: u4 = 0,
/// C7S [24:27]
/// DMA channel 7 selection
C7S: u4 = 0,
/// unused [28:31]
_unused28: u4 = 0,
};
/// channel selection register
pub const CSELR = Register(CSELR_val).init(base_address + 0xa8);
};

/// Direct memory access controller
pub const DMA2 = struct {

const base_address = 0x40020400;
/// ISR
const ISR_val = packed struct {
/// GIF1 [0:0]
/// Channel x global interrupt flag (x = 1
GIF1: u1 = 0,
/// TCIF1 [1:1]
/// Channel x transfer complete flag (x = 1
TCIF1: u1 = 0,
/// HTIF1 [2:2]
/// Channel x half transfer flag (x = 1
HTIF1: u1 = 0,
/// TEIF1 [3:3]
/// Channel x transfer error flag (x = 1
TEIF1: u1 = 0,
/// GIF2 [4:4]
/// Channel x global interrupt flag (x = 1
GIF2: u1 = 0,
/// TCIF2 [5:5]
/// Channel x transfer complete flag (x = 1
TCIF2: u1 = 0,
/// HTIF2 [6:6]
/// Channel x half transfer flag (x = 1
HTIF2: u1 = 0,
/// TEIF2 [7:7]
/// Channel x transfer error flag (x = 1
TEIF2: u1 = 0,
/// GIF3 [8:8]
/// Channel x global interrupt flag (x = 1
GIF3: u1 = 0,
/// TCIF3 [9:9]
/// Channel x transfer complete flag (x = 1
TCIF3: u1 = 0,
/// HTIF3 [10:10]
/// Channel x half transfer flag (x = 1
HTIF3: u1 = 0,
/// TEIF3 [11:11]
/// Channel x transfer error flag (x = 1
TEIF3: u1 = 0,
/// GIF4 [12:12]
/// Channel x global interrupt flag (x = 1
GIF4: u1 = 0,
/// TCIF4 [13:13]
/// Channel x transfer complete flag (x = 1
TCIF4: u1 = 0,
/// HTIF4 [14:14]
/// Channel x half transfer flag (x = 1
HTIF4: u1 = 0,
/// TEIF4 [15:15]
/// Channel x transfer error flag (x = 1
TEIF4: u1 = 0,
/// GIF5 [16:16]
/// Channel x global interrupt flag (x = 1
GIF5: u1 = 0,
/// TCIF5 [17:17]
/// Channel x transfer complete flag (x = 1
TCIF5: u1 = 0,
/// HTIF5 [18:18]
/// Channel x half transfer flag (x = 1
HTIF5: u1 = 0,
/// TEIF5 [19:19]
/// Channel x transfer error flag (x = 1
TEIF5: u1 = 0,
/// GIF6 [20:20]
/// Channel x global interrupt flag (x = 1
GIF6: u1 = 0,
/// TCIF6 [21:21]
/// Channel x transfer complete flag (x = 1
TCIF6: u1 = 0,
/// HTIF6 [22:22]
/// Channel x half transfer flag (x = 1
HTIF6: u1 = 0,
/// TEIF6 [23:23]
/// Channel x transfer error flag (x = 1
TEIF6: u1 = 0,
/// GIF7 [24:24]
/// Channel x global interrupt flag (x = 1
GIF7: u1 = 0,
/// TCIF7 [25:25]
/// Channel x transfer complete flag (x = 1
TCIF7: u1 = 0,
/// HTIF7 [26:26]
/// Channel x half transfer flag (x = 1
HTIF7: u1 = 0,
/// TEIF7 [27:27]
/// Channel x transfer error flag (x = 1
TEIF7: u1 = 0,
/// unused [28:31]
_unused28: u4 = 0,
};
/// interrupt status register
pub const ISR = Register(ISR_val).init(base_address + 0x0);

/// IFCR
const IFCR_val = packed struct {
/// CGIF1 [0:0]
/// Channel x global interrupt clear (x = 1
CGIF1: u1 = 0,
/// CTCIF1 [1:1]
/// Channel x transfer complete clear (x = 1
CTCIF1: u1 = 0,
/// CHTIF1 [2:2]
/// Channel x half transfer clear (x = 1
CHTIF1: u1 = 0,
/// CTEIF1 [3:3]
/// Channel x transfer error clear (x = 1
CTEIF1: u1 = 0,
/// CGIF2 [4:4]
/// Channel x global interrupt clear (x = 1
CGIF2: u1 = 0,
/// CTCIF2 [5:5]
/// Channel x transfer complete clear (x = 1
CTCIF2: u1 = 0,
/// CHTIF2 [6:6]
/// Channel x half transfer clear (x = 1
CHTIF2: u1 = 0,
/// CTEIF2 [7:7]
/// Channel x transfer error clear (x = 1
CTEIF2: u1 = 0,
/// CGIF3 [8:8]
/// Channel x global interrupt clear (x = 1
CGIF3: u1 = 0,
/// CTCIF3 [9:9]
/// Channel x transfer complete clear (x = 1
CTCIF3: u1 = 0,
/// CHTIF3 [10:10]
/// Channel x half transfer clear (x = 1
CHTIF3: u1 = 0,
/// CTEIF3 [11:11]
/// Channel x transfer error clear (x = 1
CTEIF3: u1 = 0,
/// CGIF4 [12:12]
/// Channel x global interrupt clear (x = 1
CGIF4: u1 = 0,
/// CTCIF4 [13:13]
/// Channel x transfer complete clear (x = 1
CTCIF4: u1 = 0,
/// CHTIF4 [14:14]
/// Channel x half transfer clear (x = 1
CHTIF4: u1 = 0,
/// CTEIF4 [15:15]
/// Channel x transfer error clear (x = 1
CTEIF4: u1 = 0,
/// CGIF5 [16:16]
/// Channel x global interrupt clear (x = 1
CGIF5: u1 = 0,
/// CTCIF5 [17:17]
/// Channel x transfer complete clear (x = 1
CTCIF5: u1 = 0,
/// CHTIF5 [18:18]
/// Channel x half transfer clear (x = 1
CHTIF5: u1 = 0,
/// CTEIF5 [19:19]
/// Channel x transfer error clear (x = 1
CTEIF5: u1 = 0,
/// CGIF6 [20:20]
/// Channel x global interrupt clear (x = 1
CGIF6: u1 = 0,
/// CTCIF6 [21:21]
/// Channel x transfer complete clear (x = 1
CTCIF6: u1 = 0,
/// CHTIF6 [22:22]
/// Channel x half transfer clear (x = 1
CHTIF6: u1 = 0,
/// CTEIF6 [23:23]
/// Channel x transfer error clear (x = 1
CTEIF6: u1 = 0,
/// CGIF7 [24:24]
/// Channel x global interrupt clear (x = 1
CGIF7: u1 = 0,
/// CTCIF7 [25:25]
/// Channel x transfer complete clear (x = 1
CTCIF7: u1 = 0,
/// CHTIF7 [26:26]
/// Channel x half transfer clear (x = 1
CHTIF7: u1 = 0,
/// CTEIF7 [27:27]
/// Channel x transfer error clear (x = 1
CTEIF7: u1 = 0,
/// unused [28:31]
_unused28: u4 = 0,
};
/// interrupt flag clear register
pub const IFCR = Register(IFCR_val).init(base_address + 0x4);

/// CCR1
const CCR1_val = packed struct {
/// EN [0:0]
/// Channel enable
EN: u1 = 0,
/// TCIE [1:1]
/// Transfer complete interrupt
TCIE: u1 = 0,
/// HTIE [2:2]
/// Half transfer interrupt
HTIE: u1 = 0,
/// TEIE [3:3]
/// Transfer error interrupt
TEIE: u1 = 0,
/// DIR [4:4]
/// Data transfer direction
DIR: u1 = 0,
/// CIRC [5:5]
/// Circular mode
CIRC: u1 = 0,
/// PINC [6:6]
/// Peripheral increment mode
PINC: u1 = 0,
/// MINC [7:7]
/// Memory increment mode
MINC: u1 = 0,
/// PSIZE [8:9]
/// Peripheral size
PSIZE: u2 = 0,
/// MSIZE [10:11]
/// Memory size
MSIZE: u2 = 0,
/// PL [12:13]
/// Channel priority level
PL: u2 = 0,
/// MEM2MEM [14:14]
/// Memory to memory mode
MEM2MEM: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x configuration
pub const CCR1 = Register(CCR1_val).init(base_address + 0x8);

/// CNDTR1
const CNDTR1_val = packed struct {
/// NDT [0:15]
/// Number of data to transfer
NDT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x number of data
pub const CNDTR1 = Register(CNDTR1_val).init(base_address + 0xc);

/// CPAR1
const CPAR1_val = packed struct {
/// PA [0:31]
/// Peripheral address
PA: u32 = 0,
};
/// channel x peripheral address
pub const CPAR1 = Register(CPAR1_val).init(base_address + 0x10);

/// CMAR1
const CMAR1_val = packed struct {
/// MA [0:31]
/// Memory address
MA: u32 = 0,
};
/// channel x memory address
pub const CMAR1 = Register(CMAR1_val).init(base_address + 0x14);

/// CCR2
const CCR2_val = packed struct {
/// EN [0:0]
/// Channel enable
EN: u1 = 0,
/// TCIE [1:1]
/// Transfer complete interrupt
TCIE: u1 = 0,
/// HTIE [2:2]
/// Half transfer interrupt
HTIE: u1 = 0,
/// TEIE [3:3]
/// Transfer error interrupt
TEIE: u1 = 0,
/// DIR [4:4]
/// Data transfer direction
DIR: u1 = 0,
/// CIRC [5:5]
/// Circular mode
CIRC: u1 = 0,
/// PINC [6:6]
/// Peripheral increment mode
PINC: u1 = 0,
/// MINC [7:7]
/// Memory increment mode
MINC: u1 = 0,
/// PSIZE [8:9]
/// Peripheral size
PSIZE: u2 = 0,
/// MSIZE [10:11]
/// Memory size
MSIZE: u2 = 0,
/// PL [12:13]
/// Channel priority level
PL: u2 = 0,
/// MEM2MEM [14:14]
/// Memory to memory mode
MEM2MEM: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x configuration
pub const CCR2 = Register(CCR2_val).init(base_address + 0x1c);

/// CNDTR2
const CNDTR2_val = packed struct {
/// NDT [0:15]
/// Number of data to transfer
NDT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x number of data
pub const CNDTR2 = Register(CNDTR2_val).init(base_address + 0x20);

/// CPAR2
const CPAR2_val = packed struct {
/// PA [0:31]
/// Peripheral address
PA: u32 = 0,
};
/// channel x peripheral address
pub const CPAR2 = Register(CPAR2_val).init(base_address + 0x24);

/// CMAR2
const CMAR2_val = packed struct {
/// MA [0:31]
/// Memory address
MA: u32 = 0,
};
/// channel x memory address
pub const CMAR2 = Register(CMAR2_val).init(base_address + 0x28);

/// CCR3
const CCR3_val = packed struct {
/// EN [0:0]
/// Channel enable
EN: u1 = 0,
/// TCIE [1:1]
/// Transfer complete interrupt
TCIE: u1 = 0,
/// HTIE [2:2]
/// Half transfer interrupt
HTIE: u1 = 0,
/// TEIE [3:3]
/// Transfer error interrupt
TEIE: u1 = 0,
/// DIR [4:4]
/// Data transfer direction
DIR: u1 = 0,
/// CIRC [5:5]
/// Circular mode
CIRC: u1 = 0,
/// PINC [6:6]
/// Peripheral increment mode
PINC: u1 = 0,
/// MINC [7:7]
/// Memory increment mode
MINC: u1 = 0,
/// PSIZE [8:9]
/// Peripheral size
PSIZE: u2 = 0,
/// MSIZE [10:11]
/// Memory size
MSIZE: u2 = 0,
/// PL [12:13]
/// Channel priority level
PL: u2 = 0,
/// MEM2MEM [14:14]
/// Memory to memory mode
MEM2MEM: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x configuration
pub const CCR3 = Register(CCR3_val).init(base_address + 0x30);

/// CNDTR3
const CNDTR3_val = packed struct {
/// NDT [0:15]
/// Number of data to transfer
NDT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x number of data
pub const CNDTR3 = Register(CNDTR3_val).init(base_address + 0x34);

/// CPAR3
const CPAR3_val = packed struct {
/// PA [0:31]
/// Peripheral address
PA: u32 = 0,
};
/// channel x peripheral address
pub const CPAR3 = Register(CPAR3_val).init(base_address + 0x38);

/// CMAR3
const CMAR3_val = packed struct {
/// MA [0:31]
/// Memory address
MA: u32 = 0,
};
/// channel x memory address
pub const CMAR3 = Register(CMAR3_val).init(base_address + 0x3c);

/// CCR4
const CCR4_val = packed struct {
/// EN [0:0]
/// Channel enable
EN: u1 = 0,
/// TCIE [1:1]
/// Transfer complete interrupt
TCIE: u1 = 0,
/// HTIE [2:2]
/// Half transfer interrupt
HTIE: u1 = 0,
/// TEIE [3:3]
/// Transfer error interrupt
TEIE: u1 = 0,
/// DIR [4:4]
/// Data transfer direction
DIR: u1 = 0,
/// CIRC [5:5]
/// Circular mode
CIRC: u1 = 0,
/// PINC [6:6]
/// Peripheral increment mode
PINC: u1 = 0,
/// MINC [7:7]
/// Memory increment mode
MINC: u1 = 0,
/// PSIZE [8:9]
/// Peripheral size
PSIZE: u2 = 0,
/// MSIZE [10:11]
/// Memory size
MSIZE: u2 = 0,
/// PL [12:13]
/// Channel priority level
PL: u2 = 0,
/// MEM2MEM [14:14]
/// Memory to memory mode
MEM2MEM: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x configuration
pub const CCR4 = Register(CCR4_val).init(base_address + 0x44);

/// CNDTR4
const CNDTR4_val = packed struct {
/// NDT [0:15]
/// Number of data to transfer
NDT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x number of data
pub const CNDTR4 = Register(CNDTR4_val).init(base_address + 0x48);

/// CPAR4
const CPAR4_val = packed struct {
/// PA [0:31]
/// Peripheral address
PA: u32 = 0,
};
/// channel x peripheral address
pub const CPAR4 = Register(CPAR4_val).init(base_address + 0x4c);

/// CMAR4
const CMAR4_val = packed struct {
/// MA [0:31]
/// Memory address
MA: u32 = 0,
};
/// channel x memory address
pub const CMAR4 = Register(CMAR4_val).init(base_address + 0x50);

/// CCR5
const CCR5_val = packed struct {
/// EN [0:0]
/// Channel enable
EN: u1 = 0,
/// TCIE [1:1]
/// Transfer complete interrupt
TCIE: u1 = 0,
/// HTIE [2:2]
/// Half transfer interrupt
HTIE: u1 = 0,
/// TEIE [3:3]
/// Transfer error interrupt
TEIE: u1 = 0,
/// DIR [4:4]
/// Data transfer direction
DIR: u1 = 0,
/// CIRC [5:5]
/// Circular mode
CIRC: u1 = 0,
/// PINC [6:6]
/// Peripheral increment mode
PINC: u1 = 0,
/// MINC [7:7]
/// Memory increment mode
MINC: u1 = 0,
/// PSIZE [8:9]
/// Peripheral size
PSIZE: u2 = 0,
/// MSIZE [10:11]
/// Memory size
MSIZE: u2 = 0,
/// PL [12:13]
/// Channel priority level
PL: u2 = 0,
/// MEM2MEM [14:14]
/// Memory to memory mode
MEM2MEM: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x configuration
pub const CCR5 = Register(CCR5_val).init(base_address + 0x58);

/// CNDTR5
const CNDTR5_val = packed struct {
/// NDT [0:15]
/// Number of data to transfer
NDT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x number of data
pub const CNDTR5 = Register(CNDTR5_val).init(base_address + 0x5c);

/// CPAR5
const CPAR5_val = packed struct {
/// PA [0:31]
/// Peripheral address
PA: u32 = 0,
};
/// channel x peripheral address
pub const CPAR5 = Register(CPAR5_val).init(base_address + 0x60);

/// CMAR5
const CMAR5_val = packed struct {
/// MA [0:31]
/// Memory address
MA: u32 = 0,
};
/// channel x memory address
pub const CMAR5 = Register(CMAR5_val).init(base_address + 0x64);

/// CCR6
const CCR6_val = packed struct {
/// EN [0:0]
/// Channel enable
EN: u1 = 0,
/// TCIE [1:1]
/// Transfer complete interrupt
TCIE: u1 = 0,
/// HTIE [2:2]
/// Half transfer interrupt
HTIE: u1 = 0,
/// TEIE [3:3]
/// Transfer error interrupt
TEIE: u1 = 0,
/// DIR [4:4]
/// Data transfer direction
DIR: u1 = 0,
/// CIRC [5:5]
/// Circular mode
CIRC: u1 = 0,
/// PINC [6:6]
/// Peripheral increment mode
PINC: u1 = 0,
/// MINC [7:7]
/// Memory increment mode
MINC: u1 = 0,
/// PSIZE [8:9]
/// Peripheral size
PSIZE: u2 = 0,
/// MSIZE [10:11]
/// Memory size
MSIZE: u2 = 0,
/// PL [12:13]
/// Channel priority level
PL: u2 = 0,
/// MEM2MEM [14:14]
/// Memory to memory mode
MEM2MEM: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x configuration
pub const CCR6 = Register(CCR6_val).init(base_address + 0x6c);

/// CNDTR6
const CNDTR6_val = packed struct {
/// NDT [0:15]
/// Number of data to transfer
NDT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x number of data
pub const CNDTR6 = Register(CNDTR6_val).init(base_address + 0x70);

/// CPAR6
const CPAR6_val = packed struct {
/// PA [0:31]
/// Peripheral address
PA: u32 = 0,
};
/// channel x peripheral address
pub const CPAR6 = Register(CPAR6_val).init(base_address + 0x74);

/// CMAR6
const CMAR6_val = packed struct {
/// MA [0:31]
/// Memory address
MA: u32 = 0,
};
/// channel x memory address
pub const CMAR6 = Register(CMAR6_val).init(base_address + 0x78);

/// CCR7
const CCR7_val = packed struct {
/// EN [0:0]
/// Channel enable
EN: u1 = 0,
/// TCIE [1:1]
/// Transfer complete interrupt
TCIE: u1 = 0,
/// HTIE [2:2]
/// Half transfer interrupt
HTIE: u1 = 0,
/// TEIE [3:3]
/// Transfer error interrupt
TEIE: u1 = 0,
/// DIR [4:4]
/// Data transfer direction
DIR: u1 = 0,
/// CIRC [5:5]
/// Circular mode
CIRC: u1 = 0,
/// PINC [6:6]
/// Peripheral increment mode
PINC: u1 = 0,
/// MINC [7:7]
/// Memory increment mode
MINC: u1 = 0,
/// PSIZE [8:9]
/// Peripheral size
PSIZE: u2 = 0,
/// MSIZE [10:11]
/// Memory size
MSIZE: u2 = 0,
/// PL [12:13]
/// Channel priority level
PL: u2 = 0,
/// MEM2MEM [14:14]
/// Memory to memory mode
MEM2MEM: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x configuration
pub const CCR7 = Register(CCR7_val).init(base_address + 0x80);

/// CNDTR7
const CNDTR7_val = packed struct {
/// NDT [0:15]
/// Number of data to transfer
NDT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x number of data
pub const CNDTR7 = Register(CNDTR7_val).init(base_address + 0x84);

/// CPAR7
const CPAR7_val = packed struct {
/// PA [0:31]
/// Peripheral address
PA: u32 = 0,
};
/// channel x peripheral address
pub const CPAR7 = Register(CPAR7_val).init(base_address + 0x88);

/// CMAR7
const CMAR7_val = packed struct {
/// MA [0:31]
/// Memory address
MA: u32 = 0,
};
/// channel x memory address
pub const CMAR7 = Register(CMAR7_val).init(base_address + 0x8c);

/// CSELR
const CSELR_val = packed struct {
/// C1S [0:3]
/// DMA channel 1 selection
C1S: u4 = 0,
/// C2S [4:7]
/// DMA channel 2 selection
C2S: u4 = 0,
/// C3S [8:11]
/// DMA channel 3 selection
C3S: u4 = 0,
/// C4S [12:15]
/// DMA channel 4 selection
C4S: u4 = 0,
/// C5S [16:19]
/// DMA channel 5 selection
C5S: u4 = 0,
/// C6S [20:23]
/// DMA channel 6 selection
C6S: u4 = 0,
/// C7S [24:27]
/// DMA channel 7 selection
C7S: u4 = 0,
/// unused [28:31]
_unused28: u4 = 0,
};
/// channel selection register
pub const CSELR = Register(CSELR_val).init(base_address + 0xa8);
};

/// Cyclic redundancy check calculation
pub const CRC = struct {

const base_address = 0x40023000;
/// DR
const DR_val = packed struct {
/// DR [0:31]
/// Data register bits
DR: u32 = 4294967295,
};
/// Data register
pub const DR = Register(DR_val).init(base_address + 0x0);

/// IDR
const IDR_val = packed struct {
/// IDR [0:7]
/// General-purpose 8-bit data register
IDR: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Independent data register
pub const IDR = Register(IDR_val).init(base_address + 0x4);

/// CR
const CR_val = packed struct {
/// RESET [0:0]
/// RESET bit
RESET: u1 = 0,
/// unused [1:2]
_unused1: u2 = 0,
/// POLYSIZE [3:4]
/// Polynomial size
POLYSIZE: u2 = 0,
/// REV_IN [5:6]
/// Reverse input data
REV_IN: u2 = 0,
/// REV_OUT [7:7]
/// Reverse output data
REV_OUT: u1 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Control register
pub const CR = Register(CR_val).init(base_address + 0x8);

/// INIT
const INIT_val = packed struct {
/// CRC_INIT [0:31]
/// Programmable initial CRC
CRC_INIT: u32 = 4294967295,
};
/// Initial CRC value
pub const INIT = Register(INIT_val).init(base_address + 0x10);

/// POL
const POL_val = packed struct {
/// Polynomialcoefficients [0:31]
/// Programmable polynomial
Polynomialcoefficients: u32 = 79764919,
};
/// polynomial
pub const POL = Register(POL_val).init(base_address + 0x14);
};

/// Liquid crystal display controller
pub const LCD = struct {

const base_address = 0x40002400;
/// CR
const CR_val = packed struct {
/// LCDEN [0:0]
/// LCD controller enable
LCDEN: u1 = 0,
/// VSEL [1:1]
/// Voltage source selection
VSEL: u1 = 0,
/// DUTY [2:4]
/// Duty selection
DUTY: u3 = 0,
/// BIAS [5:6]
/// Bias selector
BIAS: u2 = 0,
/// MUX_SEG [7:7]
/// Mux segment enable
MUX_SEG: u1 = 0,
/// BUFEN [8:8]
/// Voltage output buffer
BUFEN: u1 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register
pub const CR = Register(CR_val).init(base_address + 0x0);

/// FCR
const FCR_val = packed struct {
/// HD [0:0]
/// High drive enable
HD: u1 = 0,
/// SOFIE [1:1]
/// Start of frame interrupt
SOFIE: u1 = 0,
/// unused [2:2]
_unused2: u1 = 0,
/// UDDIE [3:3]
/// Update display done interrupt
UDDIE: u1 = 0,
/// PON [4:6]
/// Pulse ON duration
PON: u3 = 0,
/// DEAD [7:9]
/// Dead time duration
DEAD: u3 = 0,
/// CC [10:12]
/// Contrast control
CC: u3 = 0,
/// BLINKF [13:15]
/// Blink frequency selection
BLINKF: u3 = 0,
/// BLINK [16:17]
/// Blink mode selection
BLINK: u2 = 0,
/// DIV [18:21]
/// DIV clock divider
DIV: u4 = 0,
/// PS [22:25]
/// PS 16-bit prescaler
PS: u4 = 0,
/// unused [26:31]
_unused26: u6 = 0,
};
/// frame control register
pub const FCR = Register(FCR_val).init(base_address + 0x4);

/// SR
const SR_val = packed struct {
/// ENS [0:0]
/// ENS
ENS: u1 = 0,
/// SOF [1:1]
/// Start of frame flag
SOF: u1 = 0,
/// UDR [2:2]
/// Update display request
UDR: u1 = 0,
/// UDD [3:3]
/// Update Display Done
UDD: u1 = 0,
/// RDY [4:4]
/// Ready flag
RDY: u1 = 0,
/// FCRSF [5:5]
/// LCD Frame Control Register
FCRSF: u1 = 1,
/// unused [6:31]
_unused6: u2 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// status register
pub const SR = Register(SR_val).init(base_address + 0x8);

/// CLR
const CLR_val = packed struct {
/// unused [0:0]
_unused0: u1 = 0,
/// SOFC [1:1]
/// Start of frame flag clear
SOFC: u1 = 0,
/// unused [2:2]
_unused2: u1 = 0,
/// UDDC [3:3]
/// Update display done clear
UDDC: u1 = 0,
/// unused [4:31]
_unused4: u4 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// clear register
pub const CLR = Register(CLR_val).init(base_address + 0xc);

/// RAM_COM0
const RAM_COM0_val = packed struct {
/// S00 [0:0]
/// S00
S00: u1 = 0,
/// S01 [1:1]
/// S01
S01: u1 = 0,
/// S02 [2:2]
/// S02
S02: u1 = 0,
/// S03 [3:3]
/// S03
S03: u1 = 0,
/// S04 [4:4]
/// S04
S04: u1 = 0,
/// S05 [5:5]
/// S05
S05: u1 = 0,
/// S06 [6:6]
/// S06
S06: u1 = 0,
/// S07 [7:7]
/// S07
S07: u1 = 0,
/// S08 [8:8]
/// S08
S08: u1 = 0,
/// S09 [9:9]
/// S09
S09: u1 = 0,
/// S10 [10:10]
/// S10
S10: u1 = 0,
/// S11 [11:11]
/// S11
S11: u1 = 0,
/// S12 [12:12]
/// S12
S12: u1 = 0,
/// S13 [13:13]
/// S13
S13: u1 = 0,
/// S14 [14:14]
/// S14
S14: u1 = 0,
/// S15 [15:15]
/// S15
S15: u1 = 0,
/// S16 [16:16]
/// S16
S16: u1 = 0,
/// S17 [17:17]
/// S17
S17: u1 = 0,
/// S18 [18:18]
/// S18
S18: u1 = 0,
/// S19 [19:19]
/// S19
S19: u1 = 0,
/// S20 [20:20]
/// S20
S20: u1 = 0,
/// S21 [21:21]
/// S21
S21: u1 = 0,
/// S22 [22:22]
/// S22
S22: u1 = 0,
/// S23 [23:23]
/// S23
S23: u1 = 0,
/// S24 [24:24]
/// S24
S24: u1 = 0,
/// S25 [25:25]
/// S25
S25: u1 = 0,
/// S26 [26:26]
/// S26
S26: u1 = 0,
/// S27 [27:27]
/// S27
S27: u1 = 0,
/// S28 [28:28]
/// S28
S28: u1 = 0,
/// S29 [29:29]
/// S29
S29: u1 = 0,
/// S30 [30:30]
/// S30
S30: u1 = 0,
/// unused [31:31]
_unused31: u1 = 0,
};
/// display memory
pub const RAM_COM0 = Register(RAM_COM0_val).init(base_address + 0x14);

/// RAM_COM1
const RAM_COM1_val = packed struct {
/// S00 [0:0]
/// S00
S00: u1 = 0,
/// S01 [1:1]
/// S01
S01: u1 = 0,
/// S02 [2:2]
/// S02
S02: u1 = 0,
/// S03 [3:3]
/// S03
S03: u1 = 0,
/// S04 [4:4]
/// S04
S04: u1 = 0,
/// S05 [5:5]
/// S05
S05: u1 = 0,
/// S06 [6:6]
/// S06
S06: u1 = 0,
/// S07 [7:7]
/// S07
S07: u1 = 0,
/// S08 [8:8]
/// S08
S08: u1 = 0,
/// S09 [9:9]
/// S09
S09: u1 = 0,
/// S10 [10:10]
/// S10
S10: u1 = 0,
/// S11 [11:11]
/// S11
S11: u1 = 0,
/// S12 [12:12]
/// S12
S12: u1 = 0,
/// S13 [13:13]
/// S13
S13: u1 = 0,
/// S14 [14:14]
/// S14
S14: u1 = 0,
/// S15 [15:15]
/// S15
S15: u1 = 0,
/// S16 [16:16]
/// S16
S16: u1 = 0,
/// S17 [17:17]
/// S17
S17: u1 = 0,
/// S18 [18:18]
/// S18
S18: u1 = 0,
/// S19 [19:19]
/// S19
S19: u1 = 0,
/// S20 [20:20]
/// S20
S20: u1 = 0,
/// S21 [21:21]
/// S21
S21: u1 = 0,
/// S22 [22:22]
/// S22
S22: u1 = 0,
/// S23 [23:23]
/// S23
S23: u1 = 0,
/// S24 [24:24]
/// S24
S24: u1 = 0,
/// S25 [25:25]
/// S25
S25: u1 = 0,
/// S26 [26:26]
/// S26
S26: u1 = 0,
/// S27 [27:27]
/// S27
S27: u1 = 0,
/// S28 [28:28]
/// S28
S28: u1 = 0,
/// S29 [29:29]
/// S29
S29: u1 = 0,
/// S30 [30:30]
/// S30
S30: u1 = 0,
/// S31 [31:31]
/// S31
S31: u1 = 0,
};
/// display memory
pub const RAM_COM1 = Register(RAM_COM1_val).init(base_address + 0x1c);

/// RAM_COM2
const RAM_COM2_val = packed struct {
/// S00 [0:0]
/// S00
S00: u1 = 0,
/// S01 [1:1]
/// S01
S01: u1 = 0,
/// S02 [2:2]
/// S02
S02: u1 = 0,
/// S03 [3:3]
/// S03
S03: u1 = 0,
/// S04 [4:4]
/// S04
S04: u1 = 0,
/// S05 [5:5]
/// S05
S05: u1 = 0,
/// S06 [6:6]
/// S06
S06: u1 = 0,
/// S07 [7:7]
/// S07
S07: u1 = 0,
/// S08 [8:8]
/// S08
S08: u1 = 0,
/// S09 [9:9]
/// S09
S09: u1 = 0,
/// S10 [10:10]
/// S10
S10: u1 = 0,
/// S11 [11:11]
/// S11
S11: u1 = 0,
/// S12 [12:12]
/// S12
S12: u1 = 0,
/// S13 [13:13]
/// S13
S13: u1 = 0,
/// S14 [14:14]
/// S14
S14: u1 = 0,
/// S15 [15:15]
/// S15
S15: u1 = 0,
/// S16 [16:16]
/// S16
S16: u1 = 0,
/// S17 [17:17]
/// S17
S17: u1 = 0,
/// S18 [18:18]
/// S18
S18: u1 = 0,
/// S19 [19:19]
/// S19
S19: u1 = 0,
/// S20 [20:20]
/// S20
S20: u1 = 0,
/// S21 [21:21]
/// S21
S21: u1 = 0,
/// S22 [22:22]
/// S22
S22: u1 = 0,
/// S23 [23:23]
/// S23
S23: u1 = 0,
/// S24 [24:24]
/// S24
S24: u1 = 0,
/// S25 [25:25]
/// S25
S25: u1 = 0,
/// S26 [26:26]
/// S26
S26: u1 = 0,
/// S27 [27:27]
/// S27
S27: u1 = 0,
/// S28 [28:28]
/// S28
S28: u1 = 0,
/// S29 [29:29]
/// S29
S29: u1 = 0,
/// S30 [30:30]
/// S30
S30: u1 = 0,
/// S31 [31:31]
/// S31
S31: u1 = 0,
};
/// display memory
pub const RAM_COM2 = Register(RAM_COM2_val).init(base_address + 0x24);

/// RAM_COM3
const RAM_COM3_val = packed struct {
/// S00 [0:0]
/// S00
S00: u1 = 0,
/// S01 [1:1]
/// S01
S01: u1 = 0,
/// S02 [2:2]
/// S02
S02: u1 = 0,
/// S03 [3:3]
/// S03
S03: u1 = 0,
/// S04 [4:4]
/// S04
S04: u1 = 0,
/// S05 [5:5]
/// S05
S05: u1 = 0,
/// S06 [6:6]
/// S06
S06: u1 = 0,
/// S07 [7:7]
/// S07
S07: u1 = 0,
/// S08 [8:8]
/// S08
S08: u1 = 0,
/// S09 [9:9]
/// S09
S09: u1 = 0,
/// S10 [10:10]
/// S10
S10: u1 = 0,
/// S11 [11:11]
/// S11
S11: u1 = 0,
/// S12 [12:12]
/// S12
S12: u1 = 0,
/// S13 [13:13]
/// S13
S13: u1 = 0,
/// S14 [14:14]
/// S14
S14: u1 = 0,
/// S15 [15:15]
/// S15
S15: u1 = 0,
/// S16 [16:16]
/// S16
S16: u1 = 0,
/// S17 [17:17]
/// S17
S17: u1 = 0,
/// S18 [18:18]
/// S18
S18: u1 = 0,
/// S19 [19:19]
/// S19
S19: u1 = 0,
/// S20 [20:20]
/// S20
S20: u1 = 0,
/// S21 [21:21]
/// S21
S21: u1 = 0,
/// S22 [22:22]
/// S22
S22: u1 = 0,
/// S23 [23:23]
/// S23
S23: u1 = 0,
/// S24 [24:24]
/// S24
S24: u1 = 0,
/// S25 [25:25]
/// S25
S25: u1 = 0,
/// S26 [26:26]
/// S26
S26: u1 = 0,
/// S27 [27:27]
/// S27
S27: u1 = 0,
/// S28 [28:28]
/// S28
S28: u1 = 0,
/// S29 [29:29]
/// S29
S29: u1 = 0,
/// S30 [30:30]
/// S30
S30: u1 = 0,
/// S31 [31:31]
/// S31
S31: u1 = 0,
};
/// display memory
pub const RAM_COM3 = Register(RAM_COM3_val).init(base_address + 0x2c);

/// RAM_COM4
const RAM_COM4_val = packed struct {
/// S00 [0:0]
/// S00
S00: u1 = 0,
/// S01 [1:1]
/// S01
S01: u1 = 0,
/// S02 [2:2]
/// S02
S02: u1 = 0,
/// S03 [3:3]
/// S03
S03: u1 = 0,
/// S04 [4:4]
/// S04
S04: u1 = 0,
/// S05 [5:5]
/// S05
S05: u1 = 0,
/// S06 [6:6]
/// S06
S06: u1 = 0,
/// S07 [7:7]
/// S07
S07: u1 = 0,
/// S08 [8:8]
/// S08
S08: u1 = 0,
/// S09 [9:9]
/// S09
S09: u1 = 0,
/// S10 [10:10]
/// S10
S10: u1 = 0,
/// S11 [11:11]
/// S11
S11: u1 = 0,
/// S12 [12:12]
/// S12
S12: u1 = 0,
/// S13 [13:13]
/// S13
S13: u1 = 0,
/// S14 [14:14]
/// S14
S14: u1 = 0,
/// S15 [15:15]
/// S15
S15: u1 = 0,
/// S16 [16:16]
/// S16
S16: u1 = 0,
/// S17 [17:17]
/// S17
S17: u1 = 0,
/// S18 [18:18]
/// S18
S18: u1 = 0,
/// S19 [19:19]
/// S19
S19: u1 = 0,
/// S20 [20:20]
/// S20
S20: u1 = 0,
/// S21 [21:21]
/// S21
S21: u1 = 0,
/// S22 [22:22]
/// S22
S22: u1 = 0,
/// S23 [23:23]
/// S23
S23: u1 = 0,
/// S24 [24:24]
/// S24
S24: u1 = 0,
/// S25 [25:25]
/// S25
S25: u1 = 0,
/// S26 [26:26]
/// S26
S26: u1 = 0,
/// S27 [27:27]
/// S27
S27: u1 = 0,
/// S28 [28:28]
/// S28
S28: u1 = 0,
/// S29 [29:29]
/// S29
S29: u1 = 0,
/// S30 [30:30]
/// S30
S30: u1 = 0,
/// S31 [31:31]
/// S31
S31: u1 = 0,
};
/// display memory
pub const RAM_COM4 = Register(RAM_COM4_val).init(base_address + 0x34);

/// RAM_COM5
const RAM_COM5_val = packed struct {
/// S00 [0:0]
/// S00
S00: u1 = 0,
/// S01 [1:1]
/// S01
S01: u1 = 0,
/// S02 [2:2]
/// S02
S02: u1 = 0,
/// S03 [3:3]
/// S03
S03: u1 = 0,
/// S04 [4:4]
/// S04
S04: u1 = 0,
/// S05 [5:5]
/// S05
S05: u1 = 0,
/// S06 [6:6]
/// S06
S06: u1 = 0,
/// S07 [7:7]
/// S07
S07: u1 = 0,
/// S08 [8:8]
/// S08
S08: u1 = 0,
/// S09 [9:9]
/// S09
S09: u1 = 0,
/// S10 [10:10]
/// S10
S10: u1 = 0,
/// S11 [11:11]
/// S11
S11: u1 = 0,
/// S12 [12:12]
/// S12
S12: u1 = 0,
/// S13 [13:13]
/// S13
S13: u1 = 0,
/// S14 [14:14]
/// S14
S14: u1 = 0,
/// S15 [15:15]
/// S15
S15: u1 = 0,
/// S16 [16:16]
/// S16
S16: u1 = 0,
/// S17 [17:17]
/// S17
S17: u1 = 0,
/// S18 [18:18]
/// S18
S18: u1 = 0,
/// S19 [19:19]
/// S19
S19: u1 = 0,
/// S20 [20:20]
/// S20
S20: u1 = 0,
/// S21 [21:21]
/// S21
S21: u1 = 0,
/// S22 [22:22]
/// S22
S22: u1 = 0,
/// S23 [23:23]
/// S23
S23: u1 = 0,
/// S24 [24:24]
/// S24
S24: u1 = 0,
/// S25 [25:25]
/// S25
S25: u1 = 0,
/// S26 [26:26]
/// S26
S26: u1 = 0,
/// S27 [27:27]
/// S27
S27: u1 = 0,
/// S28 [28:28]
/// S28
S28: u1 = 0,
/// S29 [29:29]
/// S29
S29: u1 = 0,
/// S30 [30:30]
/// S30
S30: u1 = 0,
/// S31 [31:31]
/// S31
S31: u1 = 0,
};
/// display memory
pub const RAM_COM5 = Register(RAM_COM5_val).init(base_address + 0x3c);

/// RAM_COM6
const RAM_COM6_val = packed struct {
/// S00 [0:0]
/// S00
S00: u1 = 0,
/// S01 [1:1]
/// S01
S01: u1 = 0,
/// S02 [2:2]
/// S02
S02: u1 = 0,
/// S03 [3:3]
/// S03
S03: u1 = 0,
/// S04 [4:4]
/// S04
S04: u1 = 0,
/// S05 [5:5]
/// S05
S05: u1 = 0,
/// S06 [6:6]
/// S06
S06: u1 = 0,
/// S07 [7:7]
/// S07
S07: u1 = 0,
/// S08 [8:8]
/// S08
S08: u1 = 0,
/// S09 [9:9]
/// S09
S09: u1 = 0,
/// S10 [10:10]
/// S10
S10: u1 = 0,
/// S11 [11:11]
/// S11
S11: u1 = 0,
/// S12 [12:12]
/// S12
S12: u1 = 0,
/// S13 [13:13]
/// S13
S13: u1 = 0,
/// S14 [14:14]
/// S14
S14: u1 = 0,
/// S15 [15:15]
/// S15
S15: u1 = 0,
/// S16 [16:16]
/// S16
S16: u1 = 0,
/// S17 [17:17]
/// S17
S17: u1 = 0,
/// S18 [18:18]
/// S18
S18: u1 = 0,
/// S19 [19:19]
/// S19
S19: u1 = 0,
/// S20 [20:20]
/// S20
S20: u1 = 0,
/// S21 [21:21]
/// S21
S21: u1 = 0,
/// S22 [22:22]
/// S22
S22: u1 = 0,
/// S23 [23:23]
/// S23
S23: u1 = 0,
/// S24 [24:24]
/// S24
S24: u1 = 0,
/// S25 [25:25]
/// S25
S25: u1 = 0,
/// S26 [26:26]
/// S26
S26: u1 = 0,
/// S27 [27:27]
/// S27
S27: u1 = 0,
/// S28 [28:28]
/// S28
S28: u1 = 0,
/// S29 [29:29]
/// S29
S29: u1 = 0,
/// S30 [30:30]
/// S30
S30: u1 = 0,
/// S31 [31:31]
/// S31
S31: u1 = 0,
};
/// display memory
pub const RAM_COM6 = Register(RAM_COM6_val).init(base_address + 0x44);

/// RAM_COM7
const RAM_COM7_val = packed struct {
/// S00 [0:0]
/// S00
S00: u1 = 0,
/// S01 [1:1]
/// S01
S01: u1 = 0,
/// S02 [2:2]
/// S02
S02: u1 = 0,
/// S03 [3:3]
/// S03
S03: u1 = 0,
/// S04 [4:4]
/// S04
S04: u1 = 0,
/// S05 [5:5]
/// S05
S05: u1 = 0,
/// S06 [6:6]
/// S06
S06: u1 = 0,
/// S07 [7:7]
/// S07
S07: u1 = 0,
/// S08 [8:8]
/// S08
S08: u1 = 0,
/// S09 [9:9]
/// S09
S09: u1 = 0,
/// S10 [10:10]
/// S10
S10: u1 = 0,
/// S11 [11:11]
/// S11
S11: u1 = 0,
/// S12 [12:12]
/// S12
S12: u1 = 0,
/// S13 [13:13]
/// S13
S13: u1 = 0,
/// S14 [14:14]
/// S14
S14: u1 = 0,
/// S15 [15:15]
/// S15
S15: u1 = 0,
/// S16 [16:16]
/// S16
S16: u1 = 0,
/// S17 [17:17]
/// S17
S17: u1 = 0,
/// S18 [18:18]
/// S18
S18: u1 = 0,
/// S19 [19:19]
/// S19
S19: u1 = 0,
/// S20 [20:20]
/// S20
S20: u1 = 0,
/// S21 [21:21]
/// S21
S21: u1 = 0,
/// S22 [22:22]
/// S22
S22: u1 = 0,
/// S23 [23:23]
/// S23
S23: u1 = 0,
/// S24 [24:24]
/// S24
S24: u1 = 0,
/// S25 [25:25]
/// S25
S25: u1 = 0,
/// S26 [26:26]
/// S26
S26: u1 = 0,
/// S27 [27:27]
/// S27
S27: u1 = 0,
/// S28 [28:28]
/// S28
S28: u1 = 0,
/// S29 [29:29]
/// S29
S29: u1 = 0,
/// S30 [30:30]
/// S30
S30: u1 = 0,
/// S31 [31:31]
/// S31
S31: u1 = 0,
};
/// display memory
pub const RAM_COM7 = Register(RAM_COM7_val).init(base_address + 0x4c);
};

/// Touch sensing controller
pub const TSC = struct {

const base_address = 0x40024000;
/// CR
const CR_val = packed struct {
/// TSCE [0:0]
/// Touch sensing controller
TSCE: u1 = 0,
/// START [1:1]
/// Start a new acquisition
START: u1 = 0,
/// AM [2:2]
/// Acquisition mode
AM: u1 = 0,
/// SYNCPOL [3:3]
/// Synchronization pin
SYNCPOL: u1 = 0,
/// IODEF [4:4]
/// I/O Default mode
IODEF: u1 = 0,
/// MCV [5:7]
/// Max count value
MCV: u3 = 0,
/// unused [8:11]
_unused8: u4 = 0,
/// PGPSC [12:14]
/// pulse generator prescaler
PGPSC: u3 = 0,
/// SSPSC [15:15]
/// Spread spectrum prescaler
SSPSC: u1 = 0,
/// SSE [16:16]
/// Spread spectrum enable
SSE: u1 = 0,
/// SSD [17:23]
/// Spread spectrum deviation
SSD: u7 = 0,
/// CTPL [24:27]
/// Charge transfer pulse low
CTPL: u4 = 0,
/// CTPH [28:31]
/// Charge transfer pulse high
CTPH: u4 = 0,
};
/// control register
pub const CR = Register(CR_val).init(base_address + 0x0);

/// IER
const IER_val = packed struct {
/// EOAIE [0:0]
/// End of acquisition interrupt
EOAIE: u1 = 0,
/// MCEIE [1:1]
/// Max count error interrupt
MCEIE: u1 = 0,
/// unused [2:31]
_unused2: u6 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// interrupt enable register
pub const IER = Register(IER_val).init(base_address + 0x4);

/// ICR
const ICR_val = packed struct {
/// EOAIC [0:0]
/// End of acquisition interrupt
EOAIC: u1 = 0,
/// MCEIC [1:1]
/// Max count error interrupt
MCEIC: u1 = 0,
/// unused [2:31]
_unused2: u6 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// interrupt clear register
pub const ICR = Register(ICR_val).init(base_address + 0x8);

/// ISR
const ISR_val = packed struct {
/// EOAF [0:0]
/// End of acquisition flag
EOAF: u1 = 0,
/// MCEF [1:1]
/// Max count error flag
MCEF: u1 = 0,
/// unused [2:31]
_unused2: u6 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// interrupt status register
pub const ISR = Register(ISR_val).init(base_address + 0xc);

/// IOHCR
const IOHCR_val = packed struct {
/// G1_IO1 [0:0]
/// G1_IO1
G1_IO1: u1 = 1,
/// G1_IO2 [1:1]
/// G1_IO2
G1_IO2: u1 = 1,
/// G1_IO3 [2:2]
/// G1_IO3
G1_IO3: u1 = 1,
/// G1_IO4 [3:3]
/// G1_IO4
G1_IO4: u1 = 1,
/// G2_IO1 [4:4]
/// G2_IO1
G2_IO1: u1 = 1,
/// G2_IO2 [5:5]
/// G2_IO2
G2_IO2: u1 = 1,
/// G2_IO3 [6:6]
/// G2_IO3
G2_IO3: u1 = 1,
/// G2_IO4 [7:7]
/// G2_IO4
G2_IO4: u1 = 1,
/// G3_IO1 [8:8]
/// G3_IO1
G3_IO1: u1 = 1,
/// G3_IO2 [9:9]
/// G3_IO2
G3_IO2: u1 = 1,
/// G3_IO3 [10:10]
/// G3_IO3
G3_IO3: u1 = 1,
/// G3_IO4 [11:11]
/// G3_IO4
G3_IO4: u1 = 1,
/// G4_IO1 [12:12]
/// G4_IO1
G4_IO1: u1 = 1,
/// G4_IO2 [13:13]
/// G4_IO2
G4_IO2: u1 = 1,
/// G4_IO3 [14:14]
/// G4_IO3
G4_IO3: u1 = 1,
/// G4_IO4 [15:15]
/// G4_IO4
G4_IO4: u1 = 1,
/// G5_IO1 [16:16]
/// G5_IO1
G5_IO1: u1 = 1,
/// G5_IO2 [17:17]
/// G5_IO2
G5_IO2: u1 = 1,
/// G5_IO3 [18:18]
/// G5_IO3
G5_IO3: u1 = 1,
/// G5_IO4 [19:19]
/// G5_IO4
G5_IO4: u1 = 1,
/// G6_IO1 [20:20]
/// G6_IO1
G6_IO1: u1 = 1,
/// G6_IO2 [21:21]
/// G6_IO2
G6_IO2: u1 = 1,
/// G6_IO3 [22:22]
/// G6_IO3
G6_IO3: u1 = 1,
/// G6_IO4 [23:23]
/// G6_IO4
G6_IO4: u1 = 1,
/// G7_IO1 [24:24]
/// G7_IO1
G7_IO1: u1 = 1,
/// G7_IO2 [25:25]
/// G7_IO2
G7_IO2: u1 = 1,
/// G7_IO3 [26:26]
/// G7_IO3
G7_IO3: u1 = 1,
/// G7_IO4 [27:27]
/// G7_IO4
G7_IO4: u1 = 1,
/// G8_IO1 [28:28]
/// G8_IO1
G8_IO1: u1 = 1,
/// G8_IO2 [29:29]
/// G8_IO2
G8_IO2: u1 = 1,
/// G8_IO3 [30:30]
/// G8_IO3
G8_IO3: u1 = 1,
/// G8_IO4 [31:31]
/// G8_IO4
G8_IO4: u1 = 1,
};
/// I/O hysteresis control
pub const IOHCR = Register(IOHCR_val).init(base_address + 0x10);

/// IOASCR
const IOASCR_val = packed struct {
/// G1_IO1 [0:0]
/// G1_IO1
G1_IO1: u1 = 0,
/// G1_IO2 [1:1]
/// G1_IO2
G1_IO2: u1 = 0,
/// G1_IO3 [2:2]
/// G1_IO3
G1_IO3: u1 = 0,
/// G1_IO4 [3:3]
/// G1_IO4
G1_IO4: u1 = 0,
/// G2_IO1 [4:4]
/// G2_IO1
G2_IO1: u1 = 0,
/// G2_IO2 [5:5]
/// G2_IO2
G2_IO2: u1 = 0,
/// G2_IO3 [6:6]
/// G2_IO3
G2_IO3: u1 = 0,
/// G2_IO4 [7:7]
/// G2_IO4
G2_IO4: u1 = 0,
/// G3_IO1 [8:8]
/// G3_IO1
G3_IO1: u1 = 0,
/// G3_IO2 [9:9]
/// G3_IO2
G3_IO2: u1 = 0,
/// G3_IO3 [10:10]
/// G3_IO3
G3_IO3: u1 = 0,
/// G3_IO4 [11:11]
/// G3_IO4
G3_IO4: u1 = 0,
/// G4_IO1 [12:12]
/// G4_IO1
G4_IO1: u1 = 0,
/// G4_IO2 [13:13]
/// G4_IO2
G4_IO2: u1 = 0,
/// G4_IO3 [14:14]
/// G4_IO3
G4_IO3: u1 = 0,
/// G4_IO4 [15:15]
/// G4_IO4
G4_IO4: u1 = 0,
/// G5_IO1 [16:16]
/// G5_IO1
G5_IO1: u1 = 0,
/// G5_IO2 [17:17]
/// G5_IO2
G5_IO2: u1 = 0,
/// G5_IO3 [18:18]
/// G5_IO3
G5_IO3: u1 = 0,
/// G5_IO4 [19:19]
/// G5_IO4
G5_IO4: u1 = 0,
/// G6_IO1 [20:20]
/// G6_IO1
G6_IO1: u1 = 0,
/// G6_IO2 [21:21]
/// G6_IO2
G6_IO2: u1 = 0,
/// G6_IO3 [22:22]
/// G6_IO3
G6_IO3: u1 = 0,
/// G6_IO4 [23:23]
/// G6_IO4
G6_IO4: u1 = 0,
/// G7_IO1 [24:24]
/// G7_IO1
G7_IO1: u1 = 0,
/// G7_IO2 [25:25]
/// G7_IO2
G7_IO2: u1 = 0,
/// G7_IO3 [26:26]
/// G7_IO3
G7_IO3: u1 = 0,
/// G7_IO4 [27:27]
/// G7_IO4
G7_IO4: u1 = 0,
/// G8_IO1 [28:28]
/// G8_IO1
G8_IO1: u1 = 0,
/// G8_IO2 [29:29]
/// G8_IO2
G8_IO2: u1 = 0,
/// G8_IO3 [30:30]
/// G8_IO3
G8_IO3: u1 = 0,
/// G8_IO4 [31:31]
/// G8_IO4
G8_IO4: u1 = 0,
};
/// I/O analog switch control
pub const IOASCR = Register(IOASCR_val).init(base_address + 0x18);

/// IOSCR
const IOSCR_val = packed struct {
/// G1_IO1 [0:0]
/// G1_IO1
G1_IO1: u1 = 0,
/// G1_IO2 [1:1]
/// G1_IO2
G1_IO2: u1 = 0,
/// G1_IO3 [2:2]
/// G1_IO3
G1_IO3: u1 = 0,
/// G1_IO4 [3:3]
/// G1_IO4
G1_IO4: u1 = 0,
/// G2_IO1 [4:4]
/// G2_IO1
G2_IO1: u1 = 0,
/// G2_IO2 [5:5]
/// G2_IO2
G2_IO2: u1 = 0,
/// G2_IO3 [6:6]
/// G2_IO3
G2_IO3: u1 = 0,
/// G2_IO4 [7:7]
/// G2_IO4
G2_IO4: u1 = 0,
/// G3_IO1 [8:8]
/// G3_IO1
G3_IO1: u1 = 0,
/// G3_IO2 [9:9]
/// G3_IO2
G3_IO2: u1 = 0,
/// G3_IO3 [10:10]
/// G3_IO3
G3_IO3: u1 = 0,
/// G3_IO4 [11:11]
/// G3_IO4
G3_IO4: u1 = 0,
/// G4_IO1 [12:12]
/// G4_IO1
G4_IO1: u1 = 0,
/// G4_IO2 [13:13]
/// G4_IO2
G4_IO2: u1 = 0,
/// G4_IO3 [14:14]
/// G4_IO3
G4_IO3: u1 = 0,
/// G4_IO4 [15:15]
/// G4_IO4
G4_IO4: u1 = 0,
/// G5_IO1 [16:16]
/// G5_IO1
G5_IO1: u1 = 0,
/// G5_IO2 [17:17]
/// G5_IO2
G5_IO2: u1 = 0,
/// G5_IO3 [18:18]
/// G5_IO3
G5_IO3: u1 = 0,
/// G5_IO4 [19:19]
/// G5_IO4
G5_IO4: u1 = 0,
/// G6_IO1 [20:20]
/// G6_IO1
G6_IO1: u1 = 0,
/// G6_IO2 [21:21]
/// G6_IO2
G6_IO2: u1 = 0,
/// G6_IO3 [22:22]
/// G6_IO3
G6_IO3: u1 = 0,
/// G6_IO4 [23:23]
/// G6_IO4
G6_IO4: u1 = 0,
/// G7_IO1 [24:24]
/// G7_IO1
G7_IO1: u1 = 0,
/// G7_IO2 [25:25]
/// G7_IO2
G7_IO2: u1 = 0,
/// G7_IO3 [26:26]
/// G7_IO3
G7_IO3: u1 = 0,
/// G7_IO4 [27:27]
/// G7_IO4
G7_IO4: u1 = 0,
/// G8_IO1 [28:28]
/// G8_IO1
G8_IO1: u1 = 0,
/// G8_IO2 [29:29]
/// G8_IO2
G8_IO2: u1 = 0,
/// G8_IO3 [30:30]
/// G8_IO3
G8_IO3: u1 = 0,
/// G8_IO4 [31:31]
/// G8_IO4
G8_IO4: u1 = 0,
};
/// I/O sampling control register
pub const IOSCR = Register(IOSCR_val).init(base_address + 0x20);

/// IOCCR
const IOCCR_val = packed struct {
/// G1_IO1 [0:0]
/// G1_IO1
G1_IO1: u1 = 0,
/// G1_IO2 [1:1]
/// G1_IO2
G1_IO2: u1 = 0,
/// G1_IO3 [2:2]
/// G1_IO3
G1_IO3: u1 = 0,
/// G1_IO4 [3:3]
/// G1_IO4
G1_IO4: u1 = 0,
/// G2_IO1 [4:4]
/// G2_IO1
G2_IO1: u1 = 0,
/// G2_IO2 [5:5]
/// G2_IO2
G2_IO2: u1 = 0,
/// G2_IO3 [6:6]
/// G2_IO3
G2_IO3: u1 = 0,
/// G2_IO4 [7:7]
/// G2_IO4
G2_IO4: u1 = 0,
/// G3_IO1 [8:8]
/// G3_IO1
G3_IO1: u1 = 0,
/// G3_IO2 [9:9]
/// G3_IO2
G3_IO2: u1 = 0,
/// G3_IO3 [10:10]
/// G3_IO3
G3_IO3: u1 = 0,
/// G3_IO4 [11:11]
/// G3_IO4
G3_IO4: u1 = 0,
/// G4_IO1 [12:12]
/// G4_IO1
G4_IO1: u1 = 0,
/// G4_IO2 [13:13]
/// G4_IO2
G4_IO2: u1 = 0,
/// G4_IO3 [14:14]
/// G4_IO3
G4_IO3: u1 = 0,
/// G4_IO4 [15:15]
/// G4_IO4
G4_IO4: u1 = 0,
/// G5_IO1 [16:16]
/// G5_IO1
G5_IO1: u1 = 0,
/// G5_IO2 [17:17]
/// G5_IO2
G5_IO2: u1 = 0,
/// G5_IO3 [18:18]
/// G5_IO3
G5_IO3: u1 = 0,
/// G5_IO4 [19:19]
/// G5_IO4
G5_IO4: u1 = 0,
/// G6_IO1 [20:20]
/// G6_IO1
G6_IO1: u1 = 0,
/// G6_IO2 [21:21]
/// G6_IO2
G6_IO2: u1 = 0,
/// G6_IO3 [22:22]
/// G6_IO3
G6_IO3: u1 = 0,
/// G6_IO4 [23:23]
/// G6_IO4
G6_IO4: u1 = 0,
/// G7_IO1 [24:24]
/// G7_IO1
G7_IO1: u1 = 0,
/// G7_IO2 [25:25]
/// G7_IO2
G7_IO2: u1 = 0,
/// G7_IO3 [26:26]
/// G7_IO3
G7_IO3: u1 = 0,
/// G7_IO4 [27:27]
/// G7_IO4
G7_IO4: u1 = 0,
/// G8_IO1 [28:28]
/// G8_IO1
G8_IO1: u1 = 0,
/// G8_IO2 [29:29]
/// G8_IO2
G8_IO2: u1 = 0,
/// G8_IO3 [30:30]
/// G8_IO3
G8_IO3: u1 = 0,
/// G8_IO4 [31:31]
/// G8_IO4
G8_IO4: u1 = 0,
};
/// I/O channel control register
pub const IOCCR = Register(IOCCR_val).init(base_address + 0x28);

/// IOGCSR
const IOGCSR_val = packed struct {
/// G1E [0:0]
/// Analog I/O group x enable
G1E: u1 = 0,
/// G2E [1:1]
/// Analog I/O group x enable
G2E: u1 = 0,
/// G3E [2:2]
/// Analog I/O group x enable
G3E: u1 = 0,
/// G4E [3:3]
/// Analog I/O group x enable
G4E: u1 = 0,
/// G5E [4:4]
/// Analog I/O group x enable
G5E: u1 = 0,
/// G6E [5:5]
/// Analog I/O group x enable
G6E: u1 = 0,
/// G7E [6:6]
/// Analog I/O group x enable
G7E: u1 = 0,
/// G8E [7:7]
/// Analog I/O group x enable
G8E: u1 = 0,
/// unused [8:15]
_unused8: u8 = 0,
/// G1S [16:16]
/// Analog I/O group x status
G1S: u1 = 0,
/// G2S [17:17]
/// Analog I/O group x status
G2S: u1 = 0,
/// G3S [18:18]
/// Analog I/O group x status
G3S: u1 = 0,
/// G4S [19:19]
/// Analog I/O group x status
G4S: u1 = 0,
/// G5S [20:20]
/// Analog I/O group x status
G5S: u1 = 0,
/// G6S [21:21]
/// Analog I/O group x status
G6S: u1 = 0,
/// G7S [22:22]
/// Analog I/O group x status
G7S: u1 = 0,
/// G8S [23:23]
/// Analog I/O group x status
G8S: u1 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// I/O group control status
pub const IOGCSR = Register(IOGCSR_val).init(base_address + 0x30);

/// IOG1CR
const IOG1CR_val = packed struct {
/// CNT [0:13]
/// Counter value
CNT: u14 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// I/O group x counter register
pub const IOG1CR = Register(IOG1CR_val).init(base_address + 0x34);

/// IOG2CR
const IOG2CR_val = packed struct {
/// CNT [0:13]
/// Counter value
CNT: u14 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// I/O group x counter register
pub const IOG2CR = Register(IOG2CR_val).init(base_address + 0x38);

/// IOG3CR
const IOG3CR_val = packed struct {
/// CNT [0:13]
/// Counter value
CNT: u14 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// I/O group x counter register
pub const IOG3CR = Register(IOG3CR_val).init(base_address + 0x3c);

/// IOG4CR
const IOG4CR_val = packed struct {
/// CNT [0:13]
/// Counter value
CNT: u14 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// I/O group x counter register
pub const IOG4CR = Register(IOG4CR_val).init(base_address + 0x40);

/// IOG5CR
const IOG5CR_val = packed struct {
/// CNT [0:13]
/// Counter value
CNT: u14 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// I/O group x counter register
pub const IOG5CR = Register(IOG5CR_val).init(base_address + 0x44);

/// IOG6CR
const IOG6CR_val = packed struct {
/// CNT [0:13]
/// Counter value
CNT: u14 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// I/O group x counter register
pub const IOG6CR = Register(IOG6CR_val).init(base_address + 0x48);

/// IOG7CR
const IOG7CR_val = packed struct {
/// CNT [0:13]
/// Counter value
CNT: u14 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// I/O group x counter register
pub const IOG7CR = Register(IOG7CR_val).init(base_address + 0x4c);

/// IOG8CR
const IOG8CR_val = packed struct {
/// CNT [0:13]
/// Counter value
CNT: u14 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// I/O group x counter register
pub const IOG8CR = Register(IOG8CR_val).init(base_address + 0x50);
};

/// Independent watchdog
pub const IWDG = struct {

const base_address = 0x40003000;
/// KR
const KR_val = packed struct {
/// KEY [0:15]
/// Key value (write only, read
KEY: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Key register
pub const KR = Register(KR_val).init(base_address + 0x0);

/// PR
const PR_val = packed struct {
/// PR [0:2]
/// Prescaler divider
PR: u3 = 0,
/// unused [3:31]
_unused3: u5 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Prescaler register
pub const PR = Register(PR_val).init(base_address + 0x4);

/// RLR
const RLR_val = packed struct {
/// RL [0:11]
/// Watchdog counter reload
RL: u12 = 4095,
/// unused [12:31]
_unused12: u4 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Reload register
pub const RLR = Register(RLR_val).init(base_address + 0x8);

/// SR
const SR_val = packed struct {
/// PVU [0:0]
/// Watchdog prescaler value
PVU: u1 = 0,
/// RVU [1:1]
/// Watchdog counter reload value
RVU: u1 = 0,
/// WVU [2:2]
/// Watchdog counter window value
WVU: u1 = 0,
/// unused [3:31]
_unused3: u5 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Status register
pub const SR = Register(SR_val).init(base_address + 0xc);

/// WINR
const WINR_val = packed struct {
/// WIN [0:11]
/// Watchdog counter window
WIN: u12 = 4095,
/// unused [12:31]
_unused12: u4 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Window register
pub const WINR = Register(WINR_val).init(base_address + 0x10);
};

/// System window watchdog
pub const WWDG = struct {

const base_address = 0x40002c00;
/// CR
const CR_val = packed struct {
/// T [0:6]
/// 7-bit counter (MSB to LSB)
T: u7 = 127,
/// WDGA [7:7]
/// Activation bit
WDGA: u1 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Control register
pub const CR = Register(CR_val).init(base_address + 0x0);

/// CFR
const CFR_val = packed struct {
/// W [0:6]
/// 7-bit window value
W: u7 = 127,
/// WDGTB [7:8]
/// Timer base
WDGTB: u2 = 0,
/// EWI [9:9]
/// Early wakeup interrupt
EWI: u1 = 0,
/// unused [10:31]
_unused10: u6 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Configuration register
pub const CFR = Register(CFR_val).init(base_address + 0x4);

/// SR
const SR_val = packed struct {
/// EWIF [0:0]
/// Early wakeup interrupt
EWIF: u1 = 0,
/// unused [1:31]
_unused1: u7 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Status register
pub const SR = Register(SR_val).init(base_address + 0x8);
};

/// Comparator
pub const COMP = struct {

const base_address = 0x40010200;
/// COMP1_CSR
const COMP1_CSR_val = packed struct {
/// COMP1_EN [0:0]
/// Comparator 1 enable bit
COMP1_EN: u1 = 0,
/// unused [1:1]
_unused1: u1 = 0,
/// COMP1_PWRMODE [2:3]
/// Power Mode of the comparator
COMP1_PWRMODE: u2 = 0,
/// COMP1_INMSEL [4:6]
/// Comparator 1 Input Minus connection
COMP1_INMSEL: u3 = 0,
/// COMP1_INPSEL [7:8]
/// Comparator1 input plus selection
COMP1_INPSEL: u2 = 0,
/// unused [9:14]
_unused9: u6 = 0,
/// COMP1_POLARITY [15:15]
/// Comparator 1 polarity selection
COMP1_POLARITY: u1 = 0,
/// COMP1_HYST [16:17]
/// Comparator 1 hysteresis selection
COMP1_HYST: u2 = 0,
/// COMP1_BLANKING [18:20]
/// Comparator 1 blanking source selection
COMP1_BLANKING: u3 = 0,
/// unused [21:21]
_unused21: u1 = 0,
/// COMP1_BRGEN [22:22]
/// Scaler bridge enable
COMP1_BRGEN: u1 = 0,
/// COMP1_SCALEN [23:23]
/// Voltage scaler enable bit
COMP1_SCALEN: u1 = 0,
/// unused [24:24]
_unused24: u1 = 0,
/// COMP1_INMESEL [25:26]
/// comparator 1 input minus extended
COMP1_INMESEL: u2 = 0,
/// unused [27:29]
_unused27: u3 = 0,
/// COMP1_VALUE [30:30]
/// Comparator 1 output status
COMP1_VALUE: u1 = 0,
/// COMP1_LOCK [31:31]
/// COMP1_CSR register lock
COMP1_LOCK: u1 = 0,
};
/// Comparator 1 control and status
pub const COMP1_CSR = Register(COMP1_CSR_val).init(base_address + 0x0);

/// COMP2_CSR
const COMP2_CSR_val = packed struct {
/// COMP2_EN [0:0]
/// Comparator 2 enable bit
COMP2_EN: u1 = 0,
/// unused [1:1]
_unused1: u1 = 0,
/// COMP2_PWRMODE [2:3]
/// Power Mode of the comparator
COMP2_PWRMODE: u2 = 0,
/// COMP2_INMSEL [4:6]
/// Comparator 2 Input Minus connection
COMP2_INMSEL: u3 = 0,
/// COMP2_INPSEL [7:8]
/// Comparator 2 Input Plus connection
COMP2_INPSEL: u2 = 0,
/// COMP2_WINMODE [9:9]
/// Windows mode selection bit
COMP2_WINMODE: u1 = 0,
/// unused [10:14]
_unused10: u5 = 0,
/// COMP2_POLARITY [15:15]
/// Comparator 2 polarity selection
COMP2_POLARITY: u1 = 0,
/// COMP2_HYST [16:17]
/// Comparator 2 hysteresis selection
COMP2_HYST: u2 = 0,
/// COMP2_BLANKING [18:20]
/// Comparator 2 blanking source selection
COMP2_BLANKING: u3 = 0,
/// unused [21:21]
_unused21: u1 = 0,
/// COMP2_BRGEN [22:22]
/// Scaler bridge enable
COMP2_BRGEN: u1 = 0,
/// COMP2_SCALEN [23:23]
/// Voltage scaler enable bit
COMP2_SCALEN: u1 = 0,
/// unused [24:24]
_unused24: u1 = 0,
/// COMP2_INMESEL [25:26]
/// comparator 2 input minus extended
COMP2_INMESEL: u2 = 0,
/// unused [27:29]
_unused27: u3 = 0,
/// COMP2_VALUE [30:30]
/// Comparator 2 output status
COMP2_VALUE: u1 = 0,
/// COMP2_LOCK [31:31]
/// COMP2_CSR register lock
COMP2_LOCK: u1 = 0,
};
/// Comparator 2 control and status
pub const COMP2_CSR = Register(COMP2_CSR_val).init(base_address + 0x4);
};

/// Firewall
pub const FIREWALL = struct {

const base_address = 0x40011c00;
/// CSSA
const CSSA_val = packed struct {
/// unused [0:7]
_unused0: u8 = 0,
/// ADD [8:23]
/// code segment start address
ADD: u16 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// Code segment start address
pub const CSSA = Register(CSSA_val).init(base_address + 0x0);

/// CSL
const CSL_val = packed struct {
/// unused [0:7]
_unused0: u8 = 0,
/// LENG [8:21]
/// code segment length
LENG: u14 = 0,
/// unused [22:31]
_unused22: u2 = 0,
_unused24: u8 = 0,
};
/// Code segment length
pub const CSL = Register(CSL_val).init(base_address + 0x4);

/// NVDSSA
const NVDSSA_val = packed struct {
/// unused [0:7]
_unused0: u8 = 0,
/// ADD [8:23]
/// Non-volatile data segment start
ADD: u16 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// Non-volatile data segment start
pub const NVDSSA = Register(NVDSSA_val).init(base_address + 0x8);

/// NVDSL
const NVDSL_val = packed struct {
/// unused [0:7]
_unused0: u8 = 0,
/// LENG [8:21]
/// Non-volatile data segment
LENG: u14 = 0,
/// unused [22:31]
_unused22: u2 = 0,
_unused24: u8 = 0,
};
/// Non-volatile data segment
pub const NVDSL = Register(NVDSL_val).init(base_address + 0xc);

/// VDSSA
const VDSSA_val = packed struct {
/// unused [0:5]
_unused0: u6 = 0,
/// ADD [6:15]
/// Volatile data segment start
ADD: u10 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Volatile data segment start
pub const VDSSA = Register(VDSSA_val).init(base_address + 0x10);

/// VDSL
const VDSL_val = packed struct {
/// unused [0:5]
_unused0: u6 = 0,
/// LENG [6:15]
/// Non-volatile data segment
LENG: u10 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Volatile data segment length
pub const VDSL = Register(VDSL_val).init(base_address + 0x14);

/// CR
const CR_val = packed struct {
/// FPA [0:0]
/// Firewall pre alarm
FPA: u1 = 0,
/// VDS [1:1]
/// Volatile data shared
VDS: u1 = 0,
/// VDE [2:2]
/// Volatile data execution
VDE: u1 = 0,
/// unused [3:31]
_unused3: u5 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Configuration register
pub const CR = Register(CR_val).init(base_address + 0x20);
};

/// Inter-integrated circuit
pub const I2C1 = struct {

const base_address = 0x40005400;
/// CR1
const CR1_val = packed struct {
/// PE [0:0]
/// Peripheral enable
PE: u1 = 0,
/// TXIE [1:1]
/// TX Interrupt enable
TXIE: u1 = 0,
/// RXIE [2:2]
/// RX Interrupt enable
RXIE: u1 = 0,
/// ADDRIE [3:3]
/// Address match interrupt enable (slave
ADDRIE: u1 = 0,
/// NACKIE [4:4]
/// Not acknowledge received interrupt
NACKIE: u1 = 0,
/// STOPIE [5:5]
/// STOP detection Interrupt
STOPIE: u1 = 0,
/// TCIE [6:6]
/// Transfer Complete interrupt
TCIE: u1 = 0,
/// ERRIE [7:7]
/// Error interrupts enable
ERRIE: u1 = 0,
/// DNF [8:11]
/// Digital noise filter
DNF: u4 = 0,
/// ANFOFF [12:12]
/// Analog noise filter OFF
ANFOFF: u1 = 0,
/// unused [13:13]
_unused13: u1 = 0,
/// TXDMAEN [14:14]
/// DMA transmission requests
TXDMAEN: u1 = 0,
/// RXDMAEN [15:15]
/// DMA reception requests
RXDMAEN: u1 = 0,
/// SBC [16:16]
/// Slave byte control
SBC: u1 = 0,
/// NOSTRETCH [17:17]
/// Clock stretching disable
NOSTRETCH: u1 = 0,
/// WUPEN [18:18]
/// Wakeup from STOP enable
WUPEN: u1 = 0,
/// GCEN [19:19]
/// General call enable
GCEN: u1 = 0,
/// SMBHEN [20:20]
/// SMBus Host address enable
SMBHEN: u1 = 0,
/// SMBDEN [21:21]
/// SMBus Device Default address
SMBDEN: u1 = 0,
/// ALERTEN [22:22]
/// SMBUS alert enable
ALERTEN: u1 = 0,
/// PECEN [23:23]
/// PEC enable
PECEN: u1 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// Control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// SADD [0:9]
/// Slave address bit (master
SADD: u10 = 0,
/// RD_WRN [10:10]
/// Transfer direction (master
RD_WRN: u1 = 0,
/// ADD10 [11:11]
/// 10-bit addressing mode (master
ADD10: u1 = 0,
/// HEAD10R [12:12]
/// 10-bit address header only read
HEAD10R: u1 = 0,
/// START [13:13]
/// Start generation
START: u1 = 0,
/// STOP [14:14]
/// Stop generation (master
STOP: u1 = 0,
/// NACK [15:15]
/// NACK generation (slave
NACK: u1 = 0,
/// NBYTES [16:23]
/// Number of bytes
NBYTES: u8 = 0,
/// RELOAD [24:24]
/// NBYTES reload mode
RELOAD: u1 = 0,
/// AUTOEND [25:25]
/// Automatic end mode (master
AUTOEND: u1 = 0,
/// PECBYTE [26:26]
/// Packet error checking byte
PECBYTE: u1 = 0,
/// unused [27:31]
_unused27: u5 = 0,
};
/// Control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// OAR1
const OAR1_val = packed struct {
/// OA1 [0:9]
/// Interface address
OA1: u10 = 0,
/// OA1MODE [10:10]
/// Own Address 1 10-bit mode
OA1MODE: u1 = 0,
/// unused [11:14]
_unused11: u4 = 0,
/// OA1EN [15:15]
/// Own Address 1 enable
OA1EN: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Own address register 1
pub const OAR1 = Register(OAR1_val).init(base_address + 0x8);

/// OAR2
const OAR2_val = packed struct {
/// unused [0:0]
_unused0: u1 = 0,
/// OA2 [1:7]
/// Interface address
OA2: u7 = 0,
/// OA2MSK [8:10]
/// Own Address 2 masks
OA2MSK: u3 = 0,
/// unused [11:14]
_unused11: u4 = 0,
/// OA2EN [15:15]
/// Own Address 2 enable
OA2EN: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Own address register 2
pub const OAR2 = Register(OAR2_val).init(base_address + 0xc);

/// TIMINGR
const TIMINGR_val = packed struct {
/// SCLL [0:7]
/// SCL low period (master
SCLL: u8 = 0,
/// SCLH [8:15]
/// SCL high period (master
SCLH: u8 = 0,
/// SDADEL [16:19]
/// Data hold time
SDADEL: u4 = 0,
/// SCLDEL [20:23]
/// Data setup time
SCLDEL: u4 = 0,
/// unused [24:27]
_unused24: u4 = 0,
/// PRESC [28:31]
/// Timing prescaler
PRESC: u4 = 0,
};
/// Timing register
pub const TIMINGR = Register(TIMINGR_val).init(base_address + 0x10);

/// TIMEOUTR
const TIMEOUTR_val = packed struct {
/// TIMEOUTA [0:11]
/// Bus timeout A
TIMEOUTA: u12 = 0,
/// TIDLE [12:12]
/// Idle clock timeout
TIDLE: u1 = 0,
/// unused [13:14]
_unused13: u2 = 0,
/// TIMOUTEN [15:15]
/// Clock timeout enable
TIMOUTEN: u1 = 0,
/// TIMEOUTB [16:27]
/// Bus timeout B
TIMEOUTB: u12 = 0,
/// unused [28:30]
_unused28: u3 = 0,
/// TEXTEN [31:31]
/// Extended clock timeout
TEXTEN: u1 = 0,
};
/// Status register 1
pub const TIMEOUTR = Register(TIMEOUTR_val).init(base_address + 0x14);

/// ISR
const ISR_val = packed struct {
/// TXE [0:0]
/// Transmit data register empty
TXE: u1 = 1,
/// TXIS [1:1]
/// Transmit interrupt status
TXIS: u1 = 0,
/// RXNE [2:2]
/// Receive data register not empty
RXNE: u1 = 0,
/// ADDR [3:3]
/// Address matched (slave
ADDR: u1 = 0,
/// NACKF [4:4]
/// Not acknowledge received
NACKF: u1 = 0,
/// STOPF [5:5]
/// Stop detection flag
STOPF: u1 = 0,
/// TC [6:6]
/// Transfer Complete (master
TC: u1 = 0,
/// TCR [7:7]
/// Transfer Complete Reload
TCR: u1 = 0,
/// BERR [8:8]
/// Bus error
BERR: u1 = 0,
/// ARLO [9:9]
/// Arbitration lost
ARLO: u1 = 0,
/// OVR [10:10]
/// Overrun/Underrun (slave
OVR: u1 = 0,
/// PECERR [11:11]
/// PEC Error in reception
PECERR: u1 = 0,
/// TIMEOUT [12:12]
/// Timeout or t_low detection
TIMEOUT: u1 = 0,
/// ALERT [13:13]
/// SMBus alert
ALERT: u1 = 0,
/// unused [14:14]
_unused14: u1 = 0,
/// BUSY [15:15]
/// Bus busy
BUSY: u1 = 0,
/// DIR [16:16]
/// Transfer direction (Slave
DIR: u1 = 0,
/// ADDCODE [17:23]
/// Address match code (Slave
ADDCODE: u7 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// Interrupt and Status register
pub const ISR = Register(ISR_val).init(base_address + 0x18);

/// ICR
const ICR_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// ADDRCF [3:3]
/// Address Matched flag clear
ADDRCF: u1 = 0,
/// NACKCF [4:4]
/// Not Acknowledge flag clear
NACKCF: u1 = 0,
/// STOPCF [5:5]
/// Stop detection flag clear
STOPCF: u1 = 0,
/// unused [6:7]
_unused6: u2 = 0,
/// BERRCF [8:8]
/// Bus error flag clear
BERRCF: u1 = 0,
/// ARLOCF [9:9]
/// Arbitration lost flag
ARLOCF: u1 = 0,
/// OVRCF [10:10]
/// Overrun/Underrun flag
OVRCF: u1 = 0,
/// PECCF [11:11]
/// PEC Error flag clear
PECCF: u1 = 0,
/// TIMOUTCF [12:12]
/// Timeout detection flag
TIMOUTCF: u1 = 0,
/// ALERTCF [13:13]
/// Alert flag clear
ALERTCF: u1 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Interrupt clear register
pub const ICR = Register(ICR_val).init(base_address + 0x1c);

/// PECR
const PECR_val = packed struct {
/// PEC [0:7]
/// Packet error checking
PEC: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// PEC register
pub const PECR = Register(PECR_val).init(base_address + 0x20);

/// RXDR
const RXDR_val = packed struct {
/// RXDATA [0:7]
/// 8-bit receive data
RXDATA: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Receive data register
pub const RXDR = Register(RXDR_val).init(base_address + 0x24);

/// TXDR
const TXDR_val = packed struct {
/// TXDATA [0:7]
/// 8-bit transmit data
TXDATA: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Transmit data register
pub const TXDR = Register(TXDR_val).init(base_address + 0x28);
};

/// Inter-integrated circuit
pub const I2C3 = struct {

const base_address = 0x40005c00;
/// CR1
const CR1_val = packed struct {
/// PE [0:0]
/// Peripheral enable
PE: u1 = 0,
/// TXIE [1:1]
/// TX Interrupt enable
TXIE: u1 = 0,
/// RXIE [2:2]
/// RX Interrupt enable
RXIE: u1 = 0,
/// ADDRIE [3:3]
/// Address match interrupt enable (slave
ADDRIE: u1 = 0,
/// NACKIE [4:4]
/// Not acknowledge received interrupt
NACKIE: u1 = 0,
/// STOPIE [5:5]
/// STOP detection Interrupt
STOPIE: u1 = 0,
/// TCIE [6:6]
/// Transfer Complete interrupt
TCIE: u1 = 0,
/// ERRIE [7:7]
/// Error interrupts enable
ERRIE: u1 = 0,
/// DNF [8:11]
/// Digital noise filter
DNF: u4 = 0,
/// ANFOFF [12:12]
/// Analog noise filter OFF
ANFOFF: u1 = 0,
/// unused [13:13]
_unused13: u1 = 0,
/// TXDMAEN [14:14]
/// DMA transmission requests
TXDMAEN: u1 = 0,
/// RXDMAEN [15:15]
/// DMA reception requests
RXDMAEN: u1 = 0,
/// SBC [16:16]
/// Slave byte control
SBC: u1 = 0,
/// NOSTRETCH [17:17]
/// Clock stretching disable
NOSTRETCH: u1 = 0,
/// WUPEN [18:18]
/// Wakeup from STOP enable
WUPEN: u1 = 0,
/// GCEN [19:19]
/// General call enable
GCEN: u1 = 0,
/// SMBHEN [20:20]
/// SMBus Host address enable
SMBHEN: u1 = 0,
/// SMBDEN [21:21]
/// SMBus Device Default address
SMBDEN: u1 = 0,
/// ALERTEN [22:22]
/// SMBUS alert enable
ALERTEN: u1 = 0,
/// PECEN [23:23]
/// PEC enable
PECEN: u1 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// Control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// SADD [0:9]
/// Slave address bit (master
SADD: u10 = 0,
/// RD_WRN [10:10]
/// Transfer direction (master
RD_WRN: u1 = 0,
/// ADD10 [11:11]
/// 10-bit addressing mode (master
ADD10: u1 = 0,
/// HEAD10R [12:12]
/// 10-bit address header only read
HEAD10R: u1 = 0,
/// START [13:13]
/// Start generation
START: u1 = 0,
/// STOP [14:14]
/// Stop generation (master
STOP: u1 = 0,
/// NACK [15:15]
/// NACK generation (slave
NACK: u1 = 0,
/// NBYTES [16:23]
/// Number of bytes
NBYTES: u8 = 0,
/// RELOAD [24:24]
/// NBYTES reload mode
RELOAD: u1 = 0,
/// AUTOEND [25:25]
/// Automatic end mode (master
AUTOEND: u1 = 0,
/// PECBYTE [26:26]
/// Packet error checking byte
PECBYTE: u1 = 0,
/// unused [27:31]
_unused27: u5 = 0,
};
/// Control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// OAR1
const OAR1_val = packed struct {
/// OA1 [0:9]
/// Interface address
OA1: u10 = 0,
/// OA1MODE [10:10]
/// Own Address 1 10-bit mode
OA1MODE: u1 = 0,
/// unused [11:14]
_unused11: u4 = 0,
/// OA1EN [15:15]
/// Own Address 1 enable
OA1EN: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Own address register 1
pub const OAR1 = Register(OAR1_val).init(base_address + 0x8);

/// OAR2
const OAR2_val = packed struct {
/// unused [0:0]
_unused0: u1 = 0,
/// OA2 [1:7]
/// Interface address
OA2: u7 = 0,
/// OA2MSK [8:10]
/// Own Address 2 masks
OA2MSK: u3 = 0,
/// unused [11:14]
_unused11: u4 = 0,
/// OA2EN [15:15]
/// Own Address 2 enable
OA2EN: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Own address register 2
pub const OAR2 = Register(OAR2_val).init(base_address + 0xc);

/// TIMINGR
const TIMINGR_val = packed struct {
/// SCLL [0:7]
/// SCL low period (master
SCLL: u8 = 0,
/// SCLH [8:15]
/// SCL high period (master
SCLH: u8 = 0,
/// SDADEL [16:19]
/// Data hold time
SDADEL: u4 = 0,
/// SCLDEL [20:23]
/// Data setup time
SCLDEL: u4 = 0,
/// unused [24:27]
_unused24: u4 = 0,
/// PRESC [28:31]
/// Timing prescaler
PRESC: u4 = 0,
};
/// Timing register
pub const TIMINGR = Register(TIMINGR_val).init(base_address + 0x10);

/// TIMEOUTR
const TIMEOUTR_val = packed struct {
/// TIMEOUTA [0:11]
/// Bus timeout A
TIMEOUTA: u12 = 0,
/// TIDLE [12:12]
/// Idle clock timeout
TIDLE: u1 = 0,
/// unused [13:14]
_unused13: u2 = 0,
/// TIMOUTEN [15:15]
/// Clock timeout enable
TIMOUTEN: u1 = 0,
/// TIMEOUTB [16:27]
/// Bus timeout B
TIMEOUTB: u12 = 0,
/// unused [28:30]
_unused28: u3 = 0,
/// TEXTEN [31:31]
/// Extended clock timeout
TEXTEN: u1 = 0,
};
/// Status register 1
pub const TIMEOUTR = Register(TIMEOUTR_val).init(base_address + 0x14);

/// ISR
const ISR_val = packed struct {
/// TXE [0:0]
/// Transmit data register empty
TXE: u1 = 1,
/// TXIS [1:1]
/// Transmit interrupt status
TXIS: u1 = 0,
/// RXNE [2:2]
/// Receive data register not empty
RXNE: u1 = 0,
/// ADDR [3:3]
/// Address matched (slave
ADDR: u1 = 0,
/// NACKF [4:4]
/// Not acknowledge received
NACKF: u1 = 0,
/// STOPF [5:5]
/// Stop detection flag
STOPF: u1 = 0,
/// TC [6:6]
/// Transfer Complete (master
TC: u1 = 0,
/// TCR [7:7]
/// Transfer Complete Reload
TCR: u1 = 0,
/// BERR [8:8]
/// Bus error
BERR: u1 = 0,
/// ARLO [9:9]
/// Arbitration lost
ARLO: u1 = 0,
/// OVR [10:10]
/// Overrun/Underrun (slave
OVR: u1 = 0,
/// PECERR [11:11]
/// PEC Error in reception
PECERR: u1 = 0,
/// TIMEOUT [12:12]
/// Timeout or t_low detection
TIMEOUT: u1 = 0,
/// ALERT [13:13]
/// SMBus alert
ALERT: u1 = 0,
/// unused [14:14]
_unused14: u1 = 0,
/// BUSY [15:15]
/// Bus busy
BUSY: u1 = 0,
/// DIR [16:16]
/// Transfer direction (Slave
DIR: u1 = 0,
/// ADDCODE [17:23]
/// Address match code (Slave
ADDCODE: u7 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// Interrupt and Status register
pub const ISR = Register(ISR_val).init(base_address + 0x18);

/// ICR
const ICR_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// ADDRCF [3:3]
/// Address Matched flag clear
ADDRCF: u1 = 0,
/// NACKCF [4:4]
/// Not Acknowledge flag clear
NACKCF: u1 = 0,
/// STOPCF [5:5]
/// Stop detection flag clear
STOPCF: u1 = 0,
/// unused [6:7]
_unused6: u2 = 0,
/// BERRCF [8:8]
/// Bus error flag clear
BERRCF: u1 = 0,
/// ARLOCF [9:9]
/// Arbitration lost flag
ARLOCF: u1 = 0,
/// OVRCF [10:10]
/// Overrun/Underrun flag
OVRCF: u1 = 0,
/// PECCF [11:11]
/// PEC Error flag clear
PECCF: u1 = 0,
/// TIMOUTCF [12:12]
/// Timeout detection flag
TIMOUTCF: u1 = 0,
/// ALERTCF [13:13]
/// Alert flag clear
ALERTCF: u1 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Interrupt clear register
pub const ICR = Register(ICR_val).init(base_address + 0x1c);

/// PECR
const PECR_val = packed struct {
/// PEC [0:7]
/// Packet error checking
PEC: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// PEC register
pub const PECR = Register(PECR_val).init(base_address + 0x20);

/// RXDR
const RXDR_val = packed struct {
/// RXDATA [0:7]
/// 8-bit receive data
RXDATA: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Receive data register
pub const RXDR = Register(RXDR_val).init(base_address + 0x24);

/// TXDR
const TXDR_val = packed struct {
/// TXDATA [0:7]
/// 8-bit transmit data
TXDATA: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Transmit data register
pub const TXDR = Register(TXDR_val).init(base_address + 0x28);
};

/// Inter-integrated circuit
pub const I2C2 = struct {

const base_address = 0x40005800;
/// CR1
const CR1_val = packed struct {
/// PE [0:0]
/// Peripheral enable
PE: u1 = 0,
/// TXIE [1:1]
/// TX Interrupt enable
TXIE: u1 = 0,
/// RXIE [2:2]
/// RX Interrupt enable
RXIE: u1 = 0,
/// ADDRIE [3:3]
/// Address match interrupt enable (slave
ADDRIE: u1 = 0,
/// NACKIE [4:4]
/// Not acknowledge received interrupt
NACKIE: u1 = 0,
/// STOPIE [5:5]
/// STOP detection Interrupt
STOPIE: u1 = 0,
/// TCIE [6:6]
/// Transfer Complete interrupt
TCIE: u1 = 0,
/// ERRIE [7:7]
/// Error interrupts enable
ERRIE: u1 = 0,
/// DNF [8:11]
/// Digital noise filter
DNF: u4 = 0,
/// ANFOFF [12:12]
/// Analog noise filter OFF
ANFOFF: u1 = 0,
/// unused [13:13]
_unused13: u1 = 0,
/// TXDMAEN [14:14]
/// DMA transmission requests
TXDMAEN: u1 = 0,
/// RXDMAEN [15:15]
/// DMA reception requests
RXDMAEN: u1 = 0,
/// SBC [16:16]
/// Slave byte control
SBC: u1 = 0,
/// NOSTRETCH [17:17]
/// Clock stretching disable
NOSTRETCH: u1 = 0,
/// WUPEN [18:18]
/// Wakeup from STOP enable
WUPEN: u1 = 0,
/// GCEN [19:19]
/// General call enable
GCEN: u1 = 0,
/// SMBHEN [20:20]
/// SMBus Host address enable
SMBHEN: u1 = 0,
/// SMBDEN [21:21]
/// SMBus Device Default address
SMBDEN: u1 = 0,
/// ALERTEN [22:22]
/// SMBUS alert enable
ALERTEN: u1 = 0,
/// PECEN [23:23]
/// PEC enable
PECEN: u1 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// Control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// SADD [0:9]
/// Slave address bit (master
SADD: u10 = 0,
/// RD_WRN [10:10]
/// Transfer direction (master
RD_WRN: u1 = 0,
/// ADD10 [11:11]
/// 10-bit addressing mode (master
ADD10: u1 = 0,
/// HEAD10R [12:12]
/// 10-bit address header only read
HEAD10R: u1 = 0,
/// START [13:13]
/// Start generation
START: u1 = 0,
/// STOP [14:14]
/// Stop generation (master
STOP: u1 = 0,
/// NACK [15:15]
/// NACK generation (slave
NACK: u1 = 0,
/// NBYTES [16:23]
/// Number of bytes
NBYTES: u8 = 0,
/// RELOAD [24:24]
/// NBYTES reload mode
RELOAD: u1 = 0,
/// AUTOEND [25:25]
/// Automatic end mode (master
AUTOEND: u1 = 0,
/// PECBYTE [26:26]
/// Packet error checking byte
PECBYTE: u1 = 0,
/// unused [27:31]
_unused27: u5 = 0,
};
/// Control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// OAR1
const OAR1_val = packed struct {
/// OA1 [0:9]
/// Interface address
OA1: u10 = 0,
/// OA1MODE [10:10]
/// Own Address 1 10-bit mode
OA1MODE: u1 = 0,
/// unused [11:14]
_unused11: u4 = 0,
/// OA1EN [15:15]
/// Own Address 1 enable
OA1EN: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Own address register 1
pub const OAR1 = Register(OAR1_val).init(base_address + 0x8);

/// OAR2
const OAR2_val = packed struct {
/// unused [0:0]
_unused0: u1 = 0,
/// OA2 [1:7]
/// Interface address
OA2: u7 = 0,
/// OA2MSK [8:10]
/// Own Address 2 masks
OA2MSK: u3 = 0,
/// unused [11:14]
_unused11: u4 = 0,
/// OA2EN [15:15]
/// Own Address 2 enable
OA2EN: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Own address register 2
pub const OAR2 = Register(OAR2_val).init(base_address + 0xc);

/// TIMINGR
const TIMINGR_val = packed struct {
/// SCLL [0:7]
/// SCL low period (master
SCLL: u8 = 0,
/// SCLH [8:15]
/// SCL high period (master
SCLH: u8 = 0,
/// SDADEL [16:19]
/// Data hold time
SDADEL: u4 = 0,
/// SCLDEL [20:23]
/// Data setup time
SCLDEL: u4 = 0,
/// unused [24:27]
_unused24: u4 = 0,
/// PRESC [28:31]
/// Timing prescaler
PRESC: u4 = 0,
};
/// Timing register
pub const TIMINGR = Register(TIMINGR_val).init(base_address + 0x10);

/// TIMEOUTR
const TIMEOUTR_val = packed struct {
/// TIMEOUTA [0:11]
/// Bus timeout A
TIMEOUTA: u12 = 0,
/// TIDLE [12:12]
/// Idle clock timeout
TIDLE: u1 = 0,
/// unused [13:14]
_unused13: u2 = 0,
/// TIMOUTEN [15:15]
/// Clock timeout enable
TIMOUTEN: u1 = 0,
/// TIMEOUTB [16:27]
/// Bus timeout B
TIMEOUTB: u12 = 0,
/// unused [28:30]
_unused28: u3 = 0,
/// TEXTEN [31:31]
/// Extended clock timeout
TEXTEN: u1 = 0,
};
/// Status register 1
pub const TIMEOUTR = Register(TIMEOUTR_val).init(base_address + 0x14);

/// ISR
const ISR_val = packed struct {
/// TXE [0:0]
/// Transmit data register empty
TXE: u1 = 1,
/// TXIS [1:1]
/// Transmit interrupt status
TXIS: u1 = 0,
/// RXNE [2:2]
/// Receive data register not empty
RXNE: u1 = 0,
/// ADDR [3:3]
/// Address matched (slave
ADDR: u1 = 0,
/// NACKF [4:4]
/// Not acknowledge received
NACKF: u1 = 0,
/// STOPF [5:5]
/// Stop detection flag
STOPF: u1 = 0,
/// TC [6:6]
/// Transfer Complete (master
TC: u1 = 0,
/// TCR [7:7]
/// Transfer Complete Reload
TCR: u1 = 0,
/// BERR [8:8]
/// Bus error
BERR: u1 = 0,
/// ARLO [9:9]
/// Arbitration lost
ARLO: u1 = 0,
/// OVR [10:10]
/// Overrun/Underrun (slave
OVR: u1 = 0,
/// PECERR [11:11]
/// PEC Error in reception
PECERR: u1 = 0,
/// TIMEOUT [12:12]
/// Timeout or t_low detection
TIMEOUT: u1 = 0,
/// ALERT [13:13]
/// SMBus alert
ALERT: u1 = 0,
/// unused [14:14]
_unused14: u1 = 0,
/// BUSY [15:15]
/// Bus busy
BUSY: u1 = 0,
/// DIR [16:16]
/// Transfer direction (Slave
DIR: u1 = 0,
/// ADDCODE [17:23]
/// Address match code (Slave
ADDCODE: u7 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// Interrupt and Status register
pub const ISR = Register(ISR_val).init(base_address + 0x18);

/// ICR
const ICR_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// ADDRCF [3:3]
/// Address Matched flag clear
ADDRCF: u1 = 0,
/// NACKCF [4:4]
/// Not Acknowledge flag clear
NACKCF: u1 = 0,
/// STOPCF [5:5]
/// Stop detection flag clear
STOPCF: u1 = 0,
/// unused [6:7]
_unused6: u2 = 0,
/// BERRCF [8:8]
/// Bus error flag clear
BERRCF: u1 = 0,
/// ARLOCF [9:9]
/// Arbitration lost flag
ARLOCF: u1 = 0,
/// OVRCF [10:10]
/// Overrun/Underrun flag
OVRCF: u1 = 0,
/// PECCF [11:11]
/// PEC Error flag clear
PECCF: u1 = 0,
/// TIMOUTCF [12:12]
/// Timeout detection flag
TIMOUTCF: u1 = 0,
/// ALERTCF [13:13]
/// Alert flag clear
ALERTCF: u1 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Interrupt clear register
pub const ICR = Register(ICR_val).init(base_address + 0x1c);

/// PECR
const PECR_val = packed struct {
/// PEC [0:7]
/// Packet error checking
PEC: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// PEC register
pub const PECR = Register(PECR_val).init(base_address + 0x20);

/// RXDR
const RXDR_val = packed struct {
/// RXDATA [0:7]
/// 8-bit receive data
RXDATA: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Receive data register
pub const RXDR = Register(RXDR_val).init(base_address + 0x24);

/// TXDR
const TXDR_val = packed struct {
/// TXDATA [0:7]
/// 8-bit transmit data
TXDATA: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Transmit data register
pub const TXDR = Register(TXDR_val).init(base_address + 0x28);
};

/// Inter-integrated circuit
pub const I2C4 = struct {

const base_address = 0x40008400;
/// CR1
const CR1_val = packed struct {
/// PE [0:0]
/// Peripheral enable
PE: u1 = 0,
/// TXIE [1:1]
/// TX Interrupt enable
TXIE: u1 = 0,
/// RXIE [2:2]
/// RX Interrupt enable
RXIE: u1 = 0,
/// ADDRIE [3:3]
/// Address match interrupt enable (slave
ADDRIE: u1 = 0,
/// NACKIE [4:4]
/// Not acknowledge received interrupt
NACKIE: u1 = 0,
/// STOPIE [5:5]
/// STOP detection Interrupt
STOPIE: u1 = 0,
/// TCIE [6:6]
/// Transfer Complete interrupt
TCIE: u1 = 0,
/// ERRIE [7:7]
/// Error interrupts enable
ERRIE: u1 = 0,
/// DNF [8:11]
/// Digital noise filter
DNF: u4 = 0,
/// ANFOFF [12:12]
/// Analog noise filter OFF
ANFOFF: u1 = 0,
/// unused [13:13]
_unused13: u1 = 0,
/// TXDMAEN [14:14]
/// DMA transmission requests
TXDMAEN: u1 = 0,
/// RXDMAEN [15:15]
/// DMA reception requests
RXDMAEN: u1 = 0,
/// SBC [16:16]
/// Slave byte control
SBC: u1 = 0,
/// NOSTRETCH [17:17]
/// Clock stretching disable
NOSTRETCH: u1 = 0,
/// WUPEN [18:18]
/// Wakeup from STOP enable
WUPEN: u1 = 0,
/// GCEN [19:19]
/// General call enable
GCEN: u1 = 0,
/// SMBHEN [20:20]
/// SMBus Host address enable
SMBHEN: u1 = 0,
/// SMBDEN [21:21]
/// SMBus Device Default address
SMBDEN: u1 = 0,
/// ALERTEN [22:22]
/// SMBUS alert enable
ALERTEN: u1 = 0,
/// PECEN [23:23]
/// PEC enable
PECEN: u1 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// Control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// SADD [0:9]
/// Slave address bit (master
SADD: u10 = 0,
/// RD_WRN [10:10]
/// Transfer direction (master
RD_WRN: u1 = 0,
/// ADD10 [11:11]
/// 10-bit addressing mode (master
ADD10: u1 = 0,
/// HEAD10R [12:12]
/// 10-bit address header only read
HEAD10R: u1 = 0,
/// START [13:13]
/// Start generation
START: u1 = 0,
/// STOP [14:14]
/// Stop generation (master
STOP: u1 = 0,
/// NACK [15:15]
/// NACK generation (slave
NACK: u1 = 0,
/// NBYTES [16:23]
/// Number of bytes
NBYTES: u8 = 0,
/// RELOAD [24:24]
/// NBYTES reload mode
RELOAD: u1 = 0,
/// AUTOEND [25:25]
/// Automatic end mode (master
AUTOEND: u1 = 0,
/// PECBYTE [26:26]
/// Packet error checking byte
PECBYTE: u1 = 0,
/// unused [27:31]
_unused27: u5 = 0,
};
/// Control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// OAR1
const OAR1_val = packed struct {
/// OA1 [0:9]
/// Interface address
OA1: u10 = 0,
/// OA1MODE [10:10]
/// Own Address 1 10-bit mode
OA1MODE: u1 = 0,
/// unused [11:14]
_unused11: u4 = 0,
/// OA1EN [15:15]
/// Own Address 1 enable
OA1EN: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Own address register 1
pub const OAR1 = Register(OAR1_val).init(base_address + 0x8);

/// OAR2
const OAR2_val = packed struct {
/// unused [0:0]
_unused0: u1 = 0,
/// OA2 [1:7]
/// Interface address
OA2: u7 = 0,
/// OA2MSK [8:10]
/// Own Address 2 masks
OA2MSK: u3 = 0,
/// unused [11:14]
_unused11: u4 = 0,
/// OA2EN [15:15]
/// Own Address 2 enable
OA2EN: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Own address register 2
pub const OAR2 = Register(OAR2_val).init(base_address + 0xc);

/// TIMINGR
const TIMINGR_val = packed struct {
/// SCLL [0:7]
/// SCL low period (master
SCLL: u8 = 0,
/// SCLH [8:15]
/// SCL high period (master
SCLH: u8 = 0,
/// SDADEL [16:19]
/// Data hold time
SDADEL: u4 = 0,
/// SCLDEL [20:23]
/// Data setup time
SCLDEL: u4 = 0,
/// unused [24:27]
_unused24: u4 = 0,
/// PRESC [28:31]
/// Timing prescaler
PRESC: u4 = 0,
};
/// Timing register
pub const TIMINGR = Register(TIMINGR_val).init(base_address + 0x10);

/// TIMEOUTR
const TIMEOUTR_val = packed struct {
/// TIMEOUTA [0:11]
/// Bus timeout A
TIMEOUTA: u12 = 0,
/// TIDLE [12:12]
/// Idle clock timeout
TIDLE: u1 = 0,
/// unused [13:14]
_unused13: u2 = 0,
/// TIMOUTEN [15:15]
/// Clock timeout enable
TIMOUTEN: u1 = 0,
/// TIMEOUTB [16:27]
/// Bus timeout B
TIMEOUTB: u12 = 0,
/// unused [28:30]
_unused28: u3 = 0,
/// TEXTEN [31:31]
/// Extended clock timeout
TEXTEN: u1 = 0,
};
/// Status register 1
pub const TIMEOUTR = Register(TIMEOUTR_val).init(base_address + 0x14);

/// ISR
const ISR_val = packed struct {
/// TXE [0:0]
/// Transmit data register empty
TXE: u1 = 1,
/// TXIS [1:1]
/// Transmit interrupt status
TXIS: u1 = 0,
/// RXNE [2:2]
/// Receive data register not empty
RXNE: u1 = 0,
/// ADDR [3:3]
/// Address matched (slave
ADDR: u1 = 0,
/// NACKF [4:4]
/// Not acknowledge received
NACKF: u1 = 0,
/// STOPF [5:5]
/// Stop detection flag
STOPF: u1 = 0,
/// TC [6:6]
/// Transfer Complete (master
TC: u1 = 0,
/// TCR [7:7]
/// Transfer Complete Reload
TCR: u1 = 0,
/// BERR [8:8]
/// Bus error
BERR: u1 = 0,
/// ARLO [9:9]
/// Arbitration lost
ARLO: u1 = 0,
/// OVR [10:10]
/// Overrun/Underrun (slave
OVR: u1 = 0,
/// PECERR [11:11]
/// PEC Error in reception
PECERR: u1 = 0,
/// TIMEOUT [12:12]
/// Timeout or t_low detection
TIMEOUT: u1 = 0,
/// ALERT [13:13]
/// SMBus alert
ALERT: u1 = 0,
/// unused [14:14]
_unused14: u1 = 0,
/// BUSY [15:15]
/// Bus busy
BUSY: u1 = 0,
/// DIR [16:16]
/// Transfer direction (Slave
DIR: u1 = 0,
/// ADDCODE [17:23]
/// Address match code (Slave
ADDCODE: u7 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// Interrupt and Status register
pub const ISR = Register(ISR_val).init(base_address + 0x18);

/// ICR
const ICR_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// ADDRCF [3:3]
/// Address Matched flag clear
ADDRCF: u1 = 0,
/// NACKCF [4:4]
/// Not Acknowledge flag clear
NACKCF: u1 = 0,
/// STOPCF [5:5]
/// Stop detection flag clear
STOPCF: u1 = 0,
/// unused [6:7]
_unused6: u2 = 0,
/// BERRCF [8:8]
/// Bus error flag clear
BERRCF: u1 = 0,
/// ARLOCF [9:9]
/// Arbitration lost flag
ARLOCF: u1 = 0,
/// OVRCF [10:10]
/// Overrun/Underrun flag
OVRCF: u1 = 0,
/// PECCF [11:11]
/// PEC Error flag clear
PECCF: u1 = 0,
/// TIMOUTCF [12:12]
/// Timeout detection flag
TIMOUTCF: u1 = 0,
/// ALERTCF [13:13]
/// Alert flag clear
ALERTCF: u1 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Interrupt clear register
pub const ICR = Register(ICR_val).init(base_address + 0x1c);

/// PECR
const PECR_val = packed struct {
/// PEC [0:7]
/// Packet error checking
PEC: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// PEC register
pub const PECR = Register(PECR_val).init(base_address + 0x20);

/// RXDR
const RXDR_val = packed struct {
/// RXDATA [0:7]
/// 8-bit receive data
RXDATA: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Receive data register
pub const RXDR = Register(RXDR_val).init(base_address + 0x24);

/// TXDR
const TXDR_val = packed struct {
/// TXDATA [0:7]
/// 8-bit transmit data
TXDATA: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Transmit data register
pub const TXDR = Register(TXDR_val).init(base_address + 0x28);
};

/// Flash
pub const FLASH = struct {

const base_address = 0x40022000;
/// ACR
const ACR_val = packed struct {
/// LATENCY [0:2]
/// Latency
LATENCY: u3 = 0,
/// unused [3:7]
_unused3: u5 = 0,
/// PRFTEN [8:8]
/// Prefetch enable
PRFTEN: u1 = 0,
/// ICEN [9:9]
/// Instruction cache enable
ICEN: u1 = 1,
/// DCEN [10:10]
/// Data cache enable
DCEN: u1 = 1,
/// ICRST [11:11]
/// Instruction cache reset
ICRST: u1 = 0,
/// DCRST [12:12]
/// Data cache reset
DCRST: u1 = 0,
/// RUN_PD [13:13]
/// Flash Power-down mode during Low-power
RUN_PD: u1 = 0,
/// SLEEP_PD [14:14]
/// Flash Power-down mode during Low-power
SLEEP_PD: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Access control register
pub const ACR = Register(ACR_val).init(base_address + 0x0);

/// PDKEYR
const PDKEYR_val = packed struct {
/// PDKEYR [0:31]
/// RUN_PD in FLASH_ACR key
PDKEYR: u32 = 0,
};
/// Power down key register
pub const PDKEYR = Register(PDKEYR_val).init(base_address + 0x4);

/// KEYR
const KEYR_val = packed struct {
/// KEYR [0:31]
/// KEYR
KEYR: u32 = 0,
};
/// Flash key register
pub const KEYR = Register(KEYR_val).init(base_address + 0x8);

/// OPTKEYR
const OPTKEYR_val = packed struct {
/// OPTKEYR [0:31]
/// Option byte key
OPTKEYR: u32 = 0,
};
/// Option byte key register
pub const OPTKEYR = Register(OPTKEYR_val).init(base_address + 0xc);

/// SR
const SR_val = packed struct {
/// EOP [0:0]
/// End of operation
EOP: u1 = 0,
/// OPERR [1:1]
/// Operation error
OPERR: u1 = 0,
/// unused [2:2]
_unused2: u1 = 0,
/// PROGERR [3:3]
/// Programming error
PROGERR: u1 = 0,
/// WRPERR [4:4]
/// Write protected error
WRPERR: u1 = 0,
/// PGAERR [5:5]
/// Programming alignment
PGAERR: u1 = 0,
/// SIZERR [6:6]
/// Size error
SIZERR: u1 = 0,
/// PGSERR [7:7]
/// Programming sequence error
PGSERR: u1 = 0,
/// MISERR [8:8]
/// Fast programming data miss
MISERR: u1 = 0,
/// FASTERR [9:9]
/// Fast programming error
FASTERR: u1 = 0,
/// unused [10:13]
_unused10: u4 = 0,
/// RDERR [14:14]
/// PCROP read error
RDERR: u1 = 0,
/// OPTVERR [15:15]
/// Option validity error
OPTVERR: u1 = 0,
/// BSY [16:16]
/// Busy
BSY: u1 = 0,
/// unused [17:31]
_unused17: u7 = 0,
_unused24: u8 = 0,
};
/// Status register
pub const SR = Register(SR_val).init(base_address + 0x10);

/// CR
const CR_val = packed struct {
/// PG [0:0]
/// Programming
PG: u1 = 0,
/// PER [1:1]
/// Page erase
PER: u1 = 0,
/// MER1 [2:2]
/// Bank 1 Mass erase
MER1: u1 = 0,
/// PNB [3:10]
/// Page number
PNB: u8 = 0,
/// BKER [11:11]
/// Bank erase
BKER: u1 = 0,
/// unused [12:14]
_unused12: u3 = 0,
/// MER2 [15:15]
/// Bank 2 Mass erase
MER2: u1 = 0,
/// START [16:16]
/// Start
START: u1 = 0,
/// OPTSTRT [17:17]
/// Options modification start
OPTSTRT: u1 = 0,
/// FSTPG [18:18]
/// Fast programming
FSTPG: u1 = 0,
/// unused [19:23]
_unused19: u5 = 0,
/// EOPIE [24:24]
/// End of operation interrupt
EOPIE: u1 = 0,
/// ERRIE [25:25]
/// Error interrupt enable
ERRIE: u1 = 0,
/// RDERRIE [26:26]
/// PCROP read error interrupt
RDERRIE: u1 = 0,
/// OBL_LAUNCH [27:27]
/// Force the option byte
OBL_LAUNCH: u1 = 0,
/// unused [28:29]
_unused28: u2 = 0,
/// OPTLOCK [30:30]
/// Options Lock
OPTLOCK: u1 = 1,
/// LOCK [31:31]
/// FLASH_CR Lock
LOCK: u1 = 1,
};
/// Flash control register
pub const CR = Register(CR_val).init(base_address + 0x14);

/// ECCR
const ECCR_val = packed struct {
/// ADDR_ECC [0:18]
/// ECC fail address
ADDR_ECC: u19 = 0,
/// BK_ECC [19:19]
/// ECC fail bank
BK_ECC: u1 = 0,
/// SYSF_ECC [20:20]
/// System Flash ECC fail
SYSF_ECC: u1 = 0,
/// unused [21:23]
_unused21: u3 = 0,
/// ECCIE [24:24]
/// ECC correction interrupt
ECCIE: u1 = 0,
/// unused [25:29]
_unused25: u5 = 0,
/// ECCC [30:30]
/// ECC correction
ECCC: u1 = 0,
/// ECCD [31:31]
/// ECC detection
ECCD: u1 = 0,
};
/// Flash ECC register
pub const ECCR = Register(ECCR_val).init(base_address + 0x18);

/// OPTR
const OPTR_val = packed struct {
/// RDP [0:7]
/// Read protection level
RDP: u8 = 0,
/// BOR_LEV [8:10]
/// BOR reset Level
BOR_LEV: u3 = 0,
/// unused [11:11]
_unused11: u1 = 0,
/// nRST_STOP [12:12]
/// nRST_STOP
nRST_STOP: u1 = 0,
/// nRST_STDBY [13:13]
/// nRST_STDBY
nRST_STDBY: u1 = 0,
/// unused [14:15]
_unused14: u2 = 0,
/// IDWG_SW [16:16]
/// Independent watchdog
IDWG_SW: u1 = 0,
/// IWDG_STOP [17:17]
/// Independent watchdog counter freeze in
IWDG_STOP: u1 = 0,
/// IWDG_STDBY [18:18]
/// Independent watchdog counter freeze in
IWDG_STDBY: u1 = 0,
/// WWDG_SW [19:19]
/// Window watchdog selection
WWDG_SW: u1 = 0,
/// BFB2 [20:20]
/// Dual-bank boot
BFB2: u1 = 0,
/// DUALBANK [21:21]
/// Dual-Bank on 512 KB or 256 KB Flash
DUALBANK: u1 = 0,
/// unused [22:22]
_unused22: u1 = 0,
/// nBOOT1 [23:23]
/// Boot configuration
nBOOT1: u1 = 0,
/// SRAM2_PE [24:24]
/// SRAM2 parity check enable
SRAM2_PE: u1 = 0,
/// SRAM2_RST [25:25]
/// SRAM2 Erase when system
SRAM2_RST: u1 = 0,
/// unused [26:31]
_unused26: u6 = 60,
};
/// Flash option register
pub const OPTR = Register(OPTR_val).init(base_address + 0x20);

/// PCROP1SR
const PCROP1SR_val = packed struct {
/// PCROP1_STRT [0:15]
/// Bank 1 PCROP area start
PCROP1_STRT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 255,
_unused24: u8 = 255,
};
/// Flash Bank 1 PCROP Start address
pub const PCROP1SR = Register(PCROP1SR_val).init(base_address + 0x24);

/// PCROP1ER
const PCROP1ER_val = packed struct {
/// PCROP1_END [0:15]
/// Bank 1 PCROP area end
PCROP1_END: u16 = 0,
/// unused [16:30]
_unused16: u8 = 255,
_unused24: u7 = 15,
/// PCROP_RDP [31:31]
/// PCROP area preserved when RDP level
PCROP_RDP: u1 = 0,
};
/// Flash Bank 1 PCROP End address
pub const PCROP1ER = Register(PCROP1ER_val).init(base_address + 0x28);

/// WRP1AR
const WRP1AR_val = packed struct {
/// WRP1A_STRT [0:7]
/// Bank 1 WRP first area tart
WRP1A_STRT: u8 = 0,
/// unused [8:15]
_unused8: u8 = 255,
/// WRP1A_END [16:23]
/// Bank 1 WRP first area A end
WRP1A_END: u8 = 0,
/// unused [24:31]
_unused24: u8 = 255,
};
/// Flash Bank 1 WRP area A address
pub const WRP1AR = Register(WRP1AR_val).init(base_address + 0x2c);

/// WRP1BR
const WRP1BR_val = packed struct {
/// WRP1B_END [0:7]
/// Bank 1 WRP second area B start
WRP1B_END: u8 = 0,
/// unused [8:15]
_unused8: u8 = 255,
/// WRP1B_STRT [16:23]
/// Bank 1 WRP second area B end
WRP1B_STRT: u8 = 0,
/// unused [24:31]
_unused24: u8 = 255,
};
/// Flash Bank 1 WRP area B address
pub const WRP1BR = Register(WRP1BR_val).init(base_address + 0x30);

/// PCROP2SR
const PCROP2SR_val = packed struct {
/// PCROP2_STRT [0:15]
/// Bank 2 PCROP area start
PCROP2_STRT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 255,
_unused24: u8 = 255,
};
/// Flash Bank 2 PCROP Start address
pub const PCROP2SR = Register(PCROP2SR_val).init(base_address + 0x44);

/// PCROP2ER
const PCROP2ER_val = packed struct {
/// PCROP2_END [0:15]
/// Bank 2 PCROP area end
PCROP2_END: u16 = 0,
/// unused [16:31]
_unused16: u8 = 255,
_unused24: u8 = 255,
};
/// Flash Bank 2 PCROP End address
pub const PCROP2ER = Register(PCROP2ER_val).init(base_address + 0x48);

/// WRP2AR
const WRP2AR_val = packed struct {
/// WRP2A_STRT [0:7]
/// Bank 2 WRP first area A start
WRP2A_STRT: u8 = 0,
/// unused [8:15]
_unused8: u8 = 255,
/// WRP2A_END [16:23]
/// Bank 2 WRP first area A end
WRP2A_END: u8 = 0,
/// unused [24:31]
_unused24: u8 = 255,
};
/// Flash Bank 2 WRP area A address
pub const WRP2AR = Register(WRP2AR_val).init(base_address + 0x4c);

/// WRP2BR
const WRP2BR_val = packed struct {
/// WRP2B_STRT [0:7]
/// Bank 2 WRP second area B start
WRP2B_STRT: u8 = 0,
/// unused [8:15]
_unused8: u8 = 255,
/// WRP2B_END [16:23]
/// Bank 2 WRP second area B end
WRP2B_END: u8 = 0,
/// unused [24:31]
_unused24: u8 = 255,
};
/// Flash Bank 2 WRP area B address
pub const WRP2BR = Register(WRP2BR_val).init(base_address + 0x50);
};

/// Reset and clock control
pub const RCC = struct {

const base_address = 0x40021000;
/// CR
const CR_val = packed struct {
/// MSION [0:0]
/// MSI clock enable
MSION: u1 = 1,
/// MSIRDY [1:1]
/// MSI clock ready flag
MSIRDY: u1 = 1,
/// MSIPLLEN [2:2]
/// MSI clock PLL enable
MSIPLLEN: u1 = 0,
/// MSIRGSEL [3:3]
/// MSI clock range selection
MSIRGSEL: u1 = 0,
/// MSIRANGE [4:7]
/// MSI clock ranges
MSIRANGE: u4 = 6,
/// HSION [8:8]
/// HSI clock enable
HSION: u1 = 0,
/// HSIKERON [9:9]
/// HSI always enable for peripheral
HSIKERON: u1 = 0,
/// HSIRDY [10:10]
/// HSI clock ready flag
HSIRDY: u1 = 0,
/// HSIASFS [11:11]
/// HSI automatic start from
HSIASFS: u1 = 0,
/// unused [12:15]
_unused12: u4 = 0,
/// HSEON [16:16]
/// HSE clock enable
HSEON: u1 = 0,
/// HSERDY [17:17]
/// HSE clock ready flag
HSERDY: u1 = 0,
/// HSEBYP [18:18]
/// HSE crystal oscillator
HSEBYP: u1 = 0,
/// CSSON [19:19]
/// Clock security system
CSSON: u1 = 0,
/// unused [20:23]
_unused20: u4 = 0,
/// PLLON [24:24]
/// Main PLL enable
PLLON: u1 = 0,
/// PLLRDY [25:25]
/// Main PLL clock ready flag
PLLRDY: u1 = 0,
/// PLLSAI1ON [26:26]
/// SAI1 PLL enable
PLLSAI1ON: u1 = 0,
/// PLLSAI1RDY [27:27]
/// SAI1 PLL clock ready flag
PLLSAI1RDY: u1 = 0,
/// unused [28:31]
_unused28: u4 = 0,
};
/// Clock control register
pub const CR = Register(CR_val).init(base_address + 0x0);

/// ICSCR
const ICSCR_val = packed struct {
/// MSICAL [0:7]
/// MSI clock calibration
MSICAL: u8 = 0,
/// MSITRIM [8:15]
/// MSI clock trimming
MSITRIM: u8 = 0,
/// HSICAL [16:23]
/// HSI clock calibration
HSICAL: u8 = 0,
/// HSITRIM [24:28]
/// HSI clock trimming
HSITRIM: u5 = 16,
/// unused [29:31]
_unused29: u3 = 0,
};
/// Internal clock sources calibration
pub const ICSCR = Register(ICSCR_val).init(base_address + 0x4);

/// CFGR
const CFGR_val = packed struct {
/// SW [0:1]
/// System clock switch
SW: u2 = 0,
/// SWS [2:3]
/// System clock switch status
SWS: u2 = 0,
/// HPRE [4:7]
/// AHB prescaler
HPRE: u4 = 0,
/// PPRE1 [8:10]
/// PB low-speed prescaler
PPRE1: u3 = 0,
/// PPRE2 [11:13]
/// APB high-speed prescaler
PPRE2: u3 = 0,
/// unused [14:14]
_unused14: u1 = 0,
/// STOPWUCK [15:15]
/// Wakeup from Stop and CSS backup clock
STOPWUCK: u1 = 0,
/// unused [16:23]
_unused16: u8 = 0,
/// MCOSEL [24:26]
/// Microcontroller clock
MCOSEL: u3 = 0,
/// unused [27:27]
_unused27: u1 = 0,
/// MCOPRE [28:30]
/// Microcontroller clock output
MCOPRE: u3 = 0,
/// unused [31:31]
_unused31: u1 = 0,
};
/// Clock configuration register
pub const CFGR = Register(CFGR_val).init(base_address + 0x8);

/// PLLCFGR
const PLLCFGR_val = packed struct {
/// PLLSRC [0:1]
/// Main PLL, PLLSAI1 and PLLSAI2 entry
PLLSRC: u2 = 0,
/// unused [2:3]
_unused2: u2 = 0,
/// PLLM [4:6]
/// Division factor for the main PLL and
PLLM: u3 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// PLLN [8:14]
/// Main PLL multiplication factor for
PLLN: u7 = 16,
/// unused [15:15]
_unused15: u1 = 0,
/// PLLPEN [16:16]
/// Main PLL PLLSAI3CLK output
PLLPEN: u1 = 0,
/// PLLP [17:17]
/// Main PLL division factor for PLLSAI3CLK
PLLP: u1 = 0,
/// unused [18:19]
_unused18: u2 = 0,
/// PLLQEN [20:20]
/// Main PLL PLLUSB1CLK output
PLLQEN: u1 = 0,
/// PLLQ [21:22]
/// Main PLL division factor for
PLLQ: u2 = 0,
/// unused [23:23]
_unused23: u1 = 0,
/// PLLREN [24:24]
/// Main PLL PLLCLK output
PLLREN: u1 = 0,
/// PLLR [25:26]
/// Main PLL division factor for PLLCLK
PLLR: u2 = 0,
/// PLLPDIV [27:31]
/// Main PLL division factor for
PLLPDIV: u5 = 0,
};
/// PLL configuration register
pub const PLLCFGR = Register(PLLCFGR_val).init(base_address + 0xc);

/// PLLSAI1CFGR
const PLLSAI1CFGR_val = packed struct {
/// unused [0:7]
_unused0: u8 = 0,
/// PLLSAI1N [8:14]
/// SAI1PLL multiplication factor for
PLLSAI1N: u7 = 16,
/// unused [15:15]
_unused15: u1 = 0,
/// PLLSAI1PEN [16:16]
/// SAI1PLL PLLSAI1CLK output
PLLSAI1PEN: u1 = 0,
/// PLLSAI1P [17:17]
/// SAI1PLL division factor for PLLSAI1CLK
PLLSAI1P: u1 = 0,
/// unused [18:19]
_unused18: u2 = 0,
/// PLLSAI1QEN [20:20]
/// SAI1PLL PLLUSB2CLK output
PLLSAI1QEN: u1 = 0,
/// PLLSAI1Q [21:22]
/// SAI1PLL division factor for PLLUSB2CLK
PLLSAI1Q: u2 = 0,
/// unused [23:23]
_unused23: u1 = 0,
/// PLLSAI1REN [24:24]
/// PLLSAI1 PLLADC1CLK output
PLLSAI1REN: u1 = 0,
/// PLLSAI1R [25:26]
/// PLLSAI1 division factor for PLLADC1CLK
PLLSAI1R: u2 = 0,
/// PLLSAI1PDIV [27:31]
/// PLLSAI1 division factor for
PLLSAI1PDIV: u5 = 0,
};
/// PLLSAI1 configuration register
pub const PLLSAI1CFGR = Register(PLLSAI1CFGR_val).init(base_address + 0x10);

/// CIER
const CIER_val = packed struct {
/// LSIRDYIE [0:0]
/// LSI ready interrupt enable
LSIRDYIE: u1 = 0,
/// LSERDYIE [1:1]
/// LSE ready interrupt enable
LSERDYIE: u1 = 0,
/// MSIRDYIE [2:2]
/// MSI ready interrupt enable
MSIRDYIE: u1 = 0,
/// HSIRDYIE [3:3]
/// HSI ready interrupt enable
HSIRDYIE: u1 = 0,
/// HSERDYIE [4:4]
/// HSE ready interrupt enable
HSERDYIE: u1 = 0,
/// PLLRDYIE [5:5]
/// PLL ready interrupt enable
PLLRDYIE: u1 = 0,
/// PLLSAI1RDYIE [6:6]
/// PLLSAI1 ready interrupt
PLLSAI1RDYIE: u1 = 0,
/// unused [7:8]
_unused7: u1 = 0,
_unused8: u1 = 0,
/// LSECSSIE [9:9]
/// LSE clock security system interrupt
LSECSSIE: u1 = 0,
/// HSI48RDYIE [10:10]
/// HSI48 ready interrupt
HSI48RDYIE: u1 = 0,
/// unused [11:31]
_unused11: u5 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Clock interrupt enable
pub const CIER = Register(CIER_val).init(base_address + 0x18);

/// CIFR
const CIFR_val = packed struct {
/// LSIRDYF [0:0]
/// LSI ready interrupt flag
LSIRDYF: u1 = 0,
/// LSERDYF [1:1]
/// LSE ready interrupt flag
LSERDYF: u1 = 0,
/// MSIRDYF [2:2]
/// MSI ready interrupt flag
MSIRDYF: u1 = 0,
/// HSIRDYF [3:3]
/// HSI ready interrupt flag
HSIRDYF: u1 = 0,
/// HSERDYF [4:4]
/// HSE ready interrupt flag
HSERDYF: u1 = 0,
/// PLLRDYF [5:5]
/// PLL ready interrupt flag
PLLRDYF: u1 = 0,
/// PLLSAI1RDYF [6:6]
/// PLLSAI1 ready interrupt
PLLSAI1RDYF: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// CSSF [8:8]
/// Clock security system interrupt
CSSF: u1 = 0,
/// LSECSSF [9:9]
/// LSE Clock security system interrupt
LSECSSF: u1 = 0,
/// HSI48RDYF [10:10]
/// HSI48 ready interrupt flag
HSI48RDYF: u1 = 0,
/// unused [11:31]
_unused11: u5 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Clock interrupt flag register
pub const CIFR = Register(CIFR_val).init(base_address + 0x1c);

/// CICR
const CICR_val = packed struct {
/// LSIRDYC [0:0]
/// LSI ready interrupt clear
LSIRDYC: u1 = 0,
/// LSERDYC [1:1]
/// LSE ready interrupt clear
LSERDYC: u1 = 0,
/// MSIRDYC [2:2]
/// MSI ready interrupt clear
MSIRDYC: u1 = 0,
/// HSIRDYC [3:3]
/// HSI ready interrupt clear
HSIRDYC: u1 = 0,
/// HSERDYC [4:4]
/// HSE ready interrupt clear
HSERDYC: u1 = 0,
/// PLLRDYC [5:5]
/// PLL ready interrupt clear
PLLRDYC: u1 = 0,
/// PLLSAI1RDYC [6:6]
/// PLLSAI1 ready interrupt
PLLSAI1RDYC: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// CSSC [8:8]
/// Clock security system interrupt
CSSC: u1 = 0,
/// LSECSSC [9:9]
/// LSE Clock security system interrupt
LSECSSC: u1 = 0,
/// HSI48RDYC [10:10]
/// HSI48 oscillator ready interrupt
HSI48RDYC: u1 = 0,
/// unused [11:31]
_unused11: u5 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Clock interrupt clear register
pub const CICR = Register(CICR_val).init(base_address + 0x20);

/// AHB1RSTR
const AHB1RSTR_val = packed struct {
/// DMA1RST [0:0]
/// DMA1 reset
DMA1RST: u1 = 0,
/// DMA2RST [1:1]
/// DMA2 reset
DMA2RST: u1 = 0,
/// unused [2:7]
_unused2: u6 = 0,
/// FLASHRST [8:8]
/// Flash memory interface
FLASHRST: u1 = 0,
/// unused [9:10]
_unused9: u2 = 0,
/// CRCRST [11:11]
/// CRC reset
CRCRST: u1 = 0,
/// unused [12:15]
_unused12: u4 = 0,
/// TSCRST [16:16]
/// Touch Sensing Controller
TSCRST: u1 = 0,
/// unused [17:31]
_unused17: u7 = 0,
_unused24: u8 = 0,
};
/// AHB1 peripheral reset register
pub const AHB1RSTR = Register(AHB1RSTR_val).init(base_address + 0x28);

/// AHB2RSTR
const AHB2RSTR_val = packed struct {
/// GPIOARST [0:0]
/// IO port A reset
GPIOARST: u1 = 0,
/// GPIOBRST [1:1]
/// IO port B reset
GPIOBRST: u1 = 0,
/// GPIOCRST [2:2]
/// IO port C reset
GPIOCRST: u1 = 0,
/// GPIODRST [3:3]
/// IO port D reset
GPIODRST: u1 = 0,
/// GPIOERST [4:4]
/// IO port E reset
GPIOERST: u1 = 0,
/// unused [5:6]
_unused5: u2 = 0,
/// GPIOHRST [7:7]
/// IO port H reset
GPIOHRST: u1 = 0,
/// unused [8:12]
_unused8: u5 = 0,
/// ADCRST [13:13]
/// ADC reset
ADCRST: u1 = 0,
/// unused [14:15]
_unused14: u2 = 0,
/// AESRST [16:16]
/// AES hardware accelerator
AESRST: u1 = 0,
/// unused [17:17]
_unused17: u1 = 0,
/// RNGRST [18:18]
/// Random number generator
RNGRST: u1 = 0,
/// unused [19:31]
_unused19: u5 = 0,
_unused24: u8 = 0,
};
/// AHB2 peripheral reset register
pub const AHB2RSTR = Register(AHB2RSTR_val).init(base_address + 0x2c);

/// AHB3RSTR
const AHB3RSTR_val = packed struct {
/// unused [0:7]
_unused0: u8 = 0,
/// QSPIRST [8:8]
/// Quad SPI memory interface
QSPIRST: u1 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// AHB3 peripheral reset register
pub const AHB3RSTR = Register(AHB3RSTR_val).init(base_address + 0x30);

/// APB1RSTR1
const APB1RSTR1_val = packed struct {
/// TIM2RST [0:0]
/// TIM2 timer reset
TIM2RST: u1 = 0,
/// unused [1:3]
_unused1: u3 = 0,
/// TIM6RST [4:4]
/// TIM6 timer reset
TIM6RST: u1 = 0,
/// TIM7RST [5:5]
/// TIM7 timer reset
TIM7RST: u1 = 0,
/// unused [6:8]
_unused6: u2 = 0,
_unused8: u1 = 0,
/// LCDRST [9:9]
/// LCD interface reset
LCDRST: u1 = 0,
/// unused [10:13]
_unused10: u4 = 0,
/// SPI2RST [14:14]
/// SPI2 reset
SPI2RST: u1 = 0,
/// SPI3RST [15:15]
/// SPI3 reset
SPI3RST: u1 = 0,
/// unused [16:16]
_unused16: u1 = 0,
/// USART2RST [17:17]
/// USART2 reset
USART2RST: u1 = 0,
/// USART1RST [18:18]
/// USART1 reset
USART1RST: u1 = 0,
/// USART4RST [19:19]
/// USART4 reset.
USART4RST: u1 = 0,
/// unused [20:20]
_unused20: u1 = 0,
/// I2C1RST [21:21]
/// I2C1 reset
I2C1RST: u1 = 0,
/// I2C2RST [22:22]
/// I2C2 reset
I2C2RST: u1 = 0,
/// I2C3RST [23:23]
/// I2C3 reset
I2C3RST: u1 = 0,
/// CRSRST [24:24]
/// CRS reset
CRSRST: u1 = 0,
/// CAN1RST [25:25]
/// CAN1 reset
CAN1RST: u1 = 0,
/// USBFSRST [26:26]
/// USB FS reset
USBFSRST: u1 = 0,
/// unused [27:27]
_unused27: u1 = 0,
/// PWRRST [28:28]
/// Power interface reset
PWRRST: u1 = 0,
/// DAC1RST [29:29]
/// DAC1 interface reset
DAC1RST: u1 = 0,
/// OPAMPRST [30:30]
/// OPAMP interface reset
OPAMPRST: u1 = 0,
/// LPTIM1RST [31:31]
/// Low Power Timer 1 reset
LPTIM1RST: u1 = 0,
};
/// APB1 peripheral reset register
pub const APB1RSTR1 = Register(APB1RSTR1_val).init(base_address + 0x38);

/// APB1RSTR2
const APB1RSTR2_val = packed struct {
/// LPUART1RST [0:0]
/// Low-power UART 1 reset
LPUART1RST: u1 = 0,
/// I2C4RST [1:1]
/// I2C4 reset
I2C4RST: u1 = 0,
/// SWPMI1RST [2:2]
/// Single wire protocol reset
SWPMI1RST: u1 = 0,
/// unused [3:4]
_unused3: u2 = 0,
/// LPTIM2RST [5:5]
/// Low-power timer 2 reset
LPTIM2RST: u1 = 0,
/// unused [6:31]
_unused6: u2 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// APB1 peripheral reset register
pub const APB1RSTR2 = Register(APB1RSTR2_val).init(base_address + 0x3c);

/// APB2RSTR
const APB2RSTR_val = packed struct {
/// SYSCFGRST [0:0]
/// System configuration (SYSCFG)
SYSCFGRST: u1 = 0,
/// unused [1:9]
_unused1: u7 = 0,
_unused8: u2 = 0,
/// SDMMCRST [10:10]
/// SDMMC reset
SDMMCRST: u1 = 0,
/// TIM1RST [11:11]
/// TIM1 timer reset
TIM1RST: u1 = 0,
/// SPI1RST [12:12]
/// SPI1 reset
SPI1RST: u1 = 0,
/// unused [13:13]
_unused13: u1 = 0,
/// USART1RST [14:14]
/// USART1 reset
USART1RST: u1 = 0,
/// unused [15:15]
_unused15: u1 = 0,
/// TIM15RST [16:16]
/// TIM15 timer reset
TIM15RST: u1 = 0,
/// TIM16RST [17:17]
/// TIM16 timer reset
TIM16RST: u1 = 0,
/// unused [18:20]
_unused18: u3 = 0,
/// SAI1RST [21:21]
/// Serial audio interface 1 (SAI1)
SAI1RST: u1 = 0,
/// unused [22:23]
_unused22: u2 = 0,
/// DFSDMRST [24:24]
/// DFSDM filter reset
DFSDMRST: u1 = 0,
/// unused [25:31]
_unused25: u7 = 0,
};
/// APB2 peripheral reset register
pub const APB2RSTR = Register(APB2RSTR_val).init(base_address + 0x40);

/// AHB1ENR
const AHB1ENR_val = packed struct {
/// DMA1EN [0:0]
/// DMA1 clock enable
DMA1EN: u1 = 0,
/// DMA2EN [1:1]
/// DMA2 clock enable
DMA2EN: u1 = 0,
/// unused [2:7]
_unused2: u6 = 0,
/// FLASHEN [8:8]
/// Flash memory interface clock
FLASHEN: u1 = 1,
/// unused [9:11]
_unused9: u3 = 0,
/// CRCEN [12:12]
/// CRC clock enable
CRCEN: u1 = 0,
/// unused [13:15]
_unused13: u3 = 0,
/// TSCEN [16:16]
/// Touch Sensing Controller clock
TSCEN: u1 = 0,
/// unused [17:31]
_unused17: u7 = 0,
_unused24: u8 = 0,
};
/// AHB1 peripheral clock enable
pub const AHB1ENR = Register(AHB1ENR_val).init(base_address + 0x48);

/// AHB2ENR
const AHB2ENR_val = packed struct {
/// GPIOAEN [0:0]
/// IO port A clock enable
GPIOAEN: u1 = 0,
/// GPIOBEN [1:1]
/// IO port B clock enable
GPIOBEN: u1 = 0,
/// GPIOCEN [2:2]
/// IO port C clock enable
GPIOCEN: u1 = 0,
/// GPIODEN [3:3]
/// IO port D clock enable
GPIODEN: u1 = 0,
/// GPIOEEN [4:4]
/// IO port E clock enable
GPIOEEN: u1 = 0,
/// unused [5:6]
_unused5: u2 = 0,
/// GPIOHEN [7:7]
/// IO port H clock enable
GPIOHEN: u1 = 0,
/// unused [8:12]
_unused8: u5 = 0,
/// ADCEN [13:13]
/// ADC clock enable
ADCEN: u1 = 0,
/// unused [14:15]
_unused14: u2 = 0,
/// AESEN [16:16]
/// AES accelerator clock
AESEN: u1 = 0,
/// unused [17:17]
_unused17: u1 = 0,
/// RNGEN [18:18]
/// Random Number Generator clock
RNGEN: u1 = 0,
/// unused [19:31]
_unused19: u5 = 0,
_unused24: u8 = 0,
};
/// AHB2 peripheral clock enable
pub const AHB2ENR = Register(AHB2ENR_val).init(base_address + 0x4c);

/// AHB3ENR
const AHB3ENR_val = packed struct {
/// unused [0:7]
_unused0: u8 = 0,
/// QSPIEN [8:8]
/// QSPIEN
QSPIEN: u1 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// AHB3 peripheral clock enable
pub const AHB3ENR = Register(AHB3ENR_val).init(base_address + 0x50);

/// APB1ENR1
const APB1ENR1_val = packed struct {
/// TIM2EN [0:0]
/// TIM2 timer clock enable
TIM2EN: u1 = 0,
/// TIM3EN [1:1]
/// TIM3 timer clock enable
TIM3EN: u1 = 0,
/// unused [2:3]
_unused2: u2 = 0,
/// TIM6EN [4:4]
/// TIM6 timer clock enable
TIM6EN: u1 = 0,
/// TIM7EN [5:5]
/// TIM7 timer clock enable
TIM7EN: u1 = 0,
/// unused [6:8]
_unused6: u2 = 0,
_unused8: u1 = 0,
/// LCDEN [9:9]
/// LCD clock enable
LCDEN: u1 = 0,
/// RTCAPBEN [10:10]
/// RTC APB clock enable
RTCAPBEN: u1 = 0,
/// WWDGEN [11:11]
/// Window watchdog clock
WWDGEN: u1 = 0,
/// unused [12:13]
_unused12: u2 = 0,
/// SPI1EN [14:14]
/// SPI1 clock enable
SPI1EN: u1 = 0,
/// SPI3EN [15:15]
/// SPI3 clock enable
SPI3EN: u1 = 0,
/// unused [16:16]
_unused16: u1 = 0,
/// USART2EN [17:17]
/// USART2 clock enable
USART2EN: u1 = 0,
/// USART1EN [18:18]
/// USART1 clock enable
USART1EN: u1 = 0,
/// UART4EN [19:19]
/// UART4 clock enable
UART4EN: u1 = 0,
/// unused [20:20]
_unused20: u1 = 0,
/// I2C1EN [21:21]
/// I2C1 clock enable
I2C1EN: u1 = 0,
/// I2C2EN [22:22]
/// I2C2 clock enable
I2C2EN: u1 = 0,
/// I2C3EN [23:23]
/// I2C3 clock enable
I2C3EN: u1 = 0,
/// CRSEN [24:24]
/// CRS clock enable
CRSEN: u1 = 0,
/// CAN1EN [25:25]
/// CAN1 clock enable
CAN1EN: u1 = 0,
/// USBF [26:26]
/// USB FS clock enable
USBF: u1 = 0,
/// unused [27:27]
_unused27: u1 = 0,
/// PWREN [28:28]
/// Power interface clock
PWREN: u1 = 0,
/// DAC1EN [29:29]
/// DAC1 interface clock
DAC1EN: u1 = 0,
/// OPAMPEN [30:30]
/// OPAMP interface clock
OPAMPEN: u1 = 0,
/// LPTIM1EN [31:31]
/// Low power timer 1 clock
LPTIM1EN: u1 = 0,
};
/// APB1ENR1
pub const APB1ENR1 = Register(APB1ENR1_val).init(base_address + 0x58);

/// APB1ENR2
const APB1ENR2_val = packed struct {
/// LPUART1EN [0:0]
/// Low power UART 1 clock
LPUART1EN: u1 = 0,
/// I2C4EN [1:1]
/// I2C4 clock enable
I2C4EN: u1 = 0,
/// SWPMI1EN [2:2]
/// Single wire protocol clock
SWPMI1EN: u1 = 0,
/// unused [3:4]
_unused3: u2 = 0,
/// LPTIM2EN [5:5]
/// LPTIM2EN
LPTIM2EN: u1 = 0,
/// unused [6:23]
_unused6: u2 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
/// DFSDMEN [24:24]
/// DFSDMEN enable
DFSDMEN: u1 = 0,
/// unused [25:31]
_unused25: u7 = 0,
};
/// APB1 peripheral clock enable register
pub const APB1ENR2 = Register(APB1ENR2_val).init(base_address + 0x5c);

/// APB2ENR
const APB2ENR_val = packed struct {
/// SYSCFGEN [0:0]
/// SYSCFG clock enable
SYSCFGEN: u1 = 0,
/// unused [1:6]
_unused1: u6 = 0,
/// FIREWALLEN [7:7]
/// Firewall clock enable
FIREWALLEN: u1 = 0,
/// unused [8:9]
_unused8: u2 = 0,
/// SDMMCEN [10:10]
/// SDMMC clock enable
SDMMCEN: u1 = 0,
/// TIM1EN [11:11]
/// TIM1 timer clock enable
TIM1EN: u1 = 0,
/// SPI1EN [12:12]
/// SPI1 clock enable
SPI1EN: u1 = 0,
/// unused [13:13]
_unused13: u1 = 0,
/// USART1EN [14:14]
/// USART1clock enable
USART1EN: u1 = 0,
/// unused [15:15]
_unused15: u1 = 0,
/// TIM15EN [16:16]
/// TIM15 timer clock enable
TIM15EN: u1 = 0,
/// TIM16EN [17:17]
/// TIM16 timer clock enable
TIM16EN: u1 = 0,
/// unused [18:20]
_unused18: u3 = 0,
/// SAI1EN [21:21]
/// SAI1 clock enable
SAI1EN: u1 = 0,
/// unused [22:31]
_unused22: u2 = 0,
_unused24: u8 = 0,
};
/// APB2ENR
pub const APB2ENR = Register(APB2ENR_val).init(base_address + 0x60);

/// AHB1SMENR
const AHB1SMENR_val = packed struct {
/// DMA1SMEN [0:0]
/// DMA1 clocks enable during Sleep and Stop
DMA1SMEN: u1 = 1,
/// DMA2SMEN [1:1]
/// DMA2 clocks enable during Sleep and Stop
DMA2SMEN: u1 = 1,
/// unused [2:7]
_unused2: u6 = 0,
/// FLASHSMEN [8:8]
/// Flash memory interface clocks enable
FLASHSMEN: u1 = 1,
/// SRAM1SMEN [9:9]
/// SRAM1 interface clocks enable during
SRAM1SMEN: u1 = 1,
/// unused [10:11]
_unused10: u2 = 0,
/// CRCSMEN [12:12]
/// CRCSMEN
CRCSMEN: u1 = 1,
/// unused [13:15]
_unused13: u3 = 0,
/// TSCSMEN [16:16]
/// Touch Sensing Controller clocks enable
TSCSMEN: u1 = 1,
/// unused [17:31]
_unused17: u7 = 0,
_unused24: u8 = 0,
};
/// AHB1 peripheral clocks enable in Sleep and
pub const AHB1SMENR = Register(AHB1SMENR_val).init(base_address + 0x68);

/// AHB2SMENR
const AHB2SMENR_val = packed struct {
/// GPIOASMEN [0:0]
/// IO port A clocks enable during Sleep and
GPIOASMEN: u1 = 1,
/// GPIOBSMEN [1:1]
/// IO port B clocks enable during Sleep and
GPIOBSMEN: u1 = 1,
/// GPIOCSMEN [2:2]
/// IO port C clocks enable during Sleep and
GPIOCSMEN: u1 = 1,
/// GPIODSMEN [3:3]
/// IO port D clocks enable during Sleep and
GPIODSMEN: u1 = 1,
/// GPIOESMEN [4:4]
/// IO port E clocks enable during Sleep and
GPIOESMEN: u1 = 1,
/// unused [5:6]
_unused5: u2 = 3,
/// GPIOHSMEN [7:7]
/// IO port H clocks enable during Sleep and
GPIOHSMEN: u1 = 1,
/// unused [8:8]
_unused8: u1 = 0,
/// SRAM2SMEN [9:9]
/// SRAM2 interface clocks enable during
SRAM2SMEN: u1 = 1,
/// unused [10:12]
_unused10: u3 = 4,
/// ADCFSSMEN [13:13]
/// ADC clocks enable during Sleep and Stop
ADCFSSMEN: u1 = 1,
/// unused [14:15]
_unused14: u2 = 0,
/// AESSMEN [16:16]
/// AES accelerator clocks enable during
AESSMEN: u1 = 1,
/// unused [17:17]
_unused17: u1 = 0,
/// RNGSMEN [18:18]
/// Random Number Generator clocks enable
RNGSMEN: u1 = 1,
/// unused [19:31]
_unused19: u5 = 0,
_unused24: u8 = 0,
};
/// AHB2 peripheral clocks enable in Sleep and
pub const AHB2SMENR = Register(AHB2SMENR_val).init(base_address + 0x6c);

/// AHB3SMENR
const AHB3SMENR_val = packed struct {
/// unused [0:7]
_unused0: u8 = 1,
/// QSPISMEN [8:8]
/// QSPISMEN
QSPISMEN: u1 = 1,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// AHB3 peripheral clocks enable in Sleep and
pub const AHB3SMENR = Register(AHB3SMENR_val).init(base_address + 0x70);

/// APB1SMENR1
const APB1SMENR1_val = packed struct {
/// TIM2SMEN [0:0]
/// TIM2 timer clocks enable during Sleep
TIM2SMEN: u1 = 1,
/// unused [1:3]
_unused1: u3 = 7,
/// TIM6SMEN [4:4]
/// TIM6 timer clocks enable during Sleep
TIM6SMEN: u1 = 1,
/// TIM7SMEN [5:5]
/// TIM7 timer clocks enable during Sleep
TIM7SMEN: u1 = 1,
/// unused [6:8]
_unused6: u2 = 0,
_unused8: u1 = 0,
/// LCDSMEN [9:9]
/// LCD clocks enable during Sleep and Stop
LCDSMEN: u1 = 1,
/// RTCAPBSMEN [10:10]
/// RTC APB clock enable during Sleep and
RTCAPBSMEN: u1 = 0,
/// WWDGSMEN [11:11]
/// Window watchdog clocks enable during
WWDGSMEN: u1 = 1,
/// unused [12:13]
_unused12: u2 = 0,
/// SPI2SMEN [14:14]
/// SPI2 clocks enable during Sleep and Stop
SPI2SMEN: u1 = 1,
/// SP3SMEN [15:15]
/// SPI3 clocks enable during Sleep and Stop
SP3SMEN: u1 = 1,
/// unused [16:16]
_unused16: u1 = 0,
/// USART1SMEN [17:17]
/// USART1 clocks enable during Sleep and
USART1SMEN: u1 = 1,
/// USART2SMEN [18:18]
/// USART2 clocks enable during Sleep and
USART2SMEN: u1 = 1,
/// unused [19:20]
_unused19: u2 = 3,
/// I2C1SMEN [21:21]
/// I2C1 clocks enable during Sleep and Stop
I2C1SMEN: u1 = 1,
/// I2C2SMEN [22:22]
/// I2C2 clocks enable during Sleep and Stop
I2C2SMEN: u1 = 1,
/// I2C3SMEN [23:23]
/// I2C3 clocks enable during Sleep and Stop
I2C3SMEN: u1 = 1,
/// CRSSMEN [24:24]
/// CRS clock enable during Sleep and Stop
CRSSMEN: u1 = 0,
/// CAN1SMEN [25:25]
/// CAN1 clocks enable during Sleep and Stop
CAN1SMEN: u1 = 1,
/// USBFSSMEN [26:26]
/// USB FS clock enable during Sleep and
USBFSSMEN: u1 = 0,
/// unused [27:27]
_unused27: u1 = 0,
/// PWRSMEN [28:28]
/// Power interface clocks enable during
PWRSMEN: u1 = 1,
/// DAC1SMEN [29:29]
/// DAC1 interface clocks enable during
DAC1SMEN: u1 = 1,
/// OPAMPSMEN [30:30]
/// OPAMP interface clocks enable during
OPAMPSMEN: u1 = 1,
/// LPTIM1SMEN [31:31]
/// Low power timer 1 clocks enable during
LPTIM1SMEN: u1 = 1,
};
/// APB1SMENR1
pub const APB1SMENR1 = Register(APB1SMENR1_val).init(base_address + 0x78);

/// APB1SMENR2
const APB1SMENR2_val = packed struct {
/// LPUART1SMEN [0:0]
/// Low power UART 1 clocks enable during
LPUART1SMEN: u1 = 1,
/// unused [1:1]
_unused1: u1 = 0,
/// SWPMI1SMEN [2:2]
/// Single wire protocol clocks enable
SWPMI1SMEN: u1 = 1,
/// unused [3:4]
_unused3: u2 = 0,
/// LPTIM2SMEN [5:5]
/// LPTIM2SMEN
LPTIM2SMEN: u1 = 1,
/// unused [6:31]
_unused6: u2 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// APB1 peripheral clocks enable in Sleep and
pub const APB1SMENR2 = Register(APB1SMENR2_val).init(base_address + 0x7c);

/// APB2SMENR
const APB2SMENR_val = packed struct {
/// SYSCFGSMEN [0:0]
/// SYSCFG clocks enable during Sleep and
SYSCFGSMEN: u1 = 1,
/// unused [1:9]
_unused1: u7 = 0,
_unused8: u2 = 0,
/// SDMMCSMEN [10:10]
/// SDMMC clocks enable during Sleep and
SDMMCSMEN: u1 = 1,
/// TIM1SMEN [11:11]
/// TIM1 timer clocks enable during Sleep
TIM1SMEN: u1 = 1,
/// SPI1SMEN [12:12]
/// SPI1 clocks enable during Sleep and Stop
SPI1SMEN: u1 = 1,
/// unused [13:13]
_unused13: u1 = 1,
/// USART1SMEN [14:14]
/// USART1clocks enable during Sleep and
USART1SMEN: u1 = 1,
/// unused [15:15]
_unused15: u1 = 0,
/// TIM15SMEN [16:16]
/// TIM15 timer clocks enable during Sleep
TIM15SMEN: u1 = 1,
/// TIM16SMEN [17:17]
/// TIM16 timer clocks enable during Sleep
TIM16SMEN: u1 = 1,
/// unused [18:20]
_unused18: u3 = 1,
/// SAI1SMEN [21:21]
/// SAI1 clocks enable during Sleep and Stop
SAI1SMEN: u1 = 1,
/// unused [22:31]
_unused22: u2 = 1,
_unused24: u8 = 1,
};
/// APB2SMENR
pub const APB2SMENR = Register(APB2SMENR_val).init(base_address + 0x80);

/// CCIPR
const CCIPR_val = packed struct {
/// USART1SEL [0:1]
/// USART1 clock source
USART1SEL: u2 = 0,
/// USART2SEL [2:3]
/// USART2 clock source
USART2SEL: u2 = 0,
/// USART3SEL [4:5]
/// USART3 clock source
USART3SEL: u2 = 0,
/// USART4SEL [6:7]
/// USART4 clock source
USART4SEL: u2 = 0,
/// unused [8:9]
_unused8: u2 = 0,
/// LPUART1SEL [10:11]
/// LPUART1 clock source
LPUART1SEL: u2 = 0,
/// I2C1SEL [12:13]
/// I2C1 clock source
I2C1SEL: u2 = 0,
/// I2C2SEL [14:15]
/// I2C2 clock source
I2C2SEL: u2 = 0,
/// I2C3SEL [16:17]
/// I2C3 clock source
I2C3SEL: u2 = 0,
/// LPTIM1SEL [18:19]
/// Low power timer 1 clock source
LPTIM1SEL: u2 = 0,
/// LPTIM2SEL [20:21]
/// Low power timer 2 clock source
LPTIM2SEL: u2 = 0,
/// SAI1SEL [22:23]
/// SAI1 clock source
SAI1SEL: u2 = 0,
/// unused [24:25]
_unused24: u2 = 0,
/// CLK48SEL [26:27]
/// 48 MHz clock source
CLK48SEL: u2 = 0,
/// ADCSEL [28:29]
/// ADCs clock source
ADCSEL: u2 = 0,
/// SWPMI1SEL [30:30]
/// SWPMI1 clock source
SWPMI1SEL: u1 = 0,
/// unused [31:31]
_unused31: u1 = 0,
};
/// CCIPR
pub const CCIPR = Register(CCIPR_val).init(base_address + 0x88);

/// BDCR
const BDCR_val = packed struct {
/// LSEON [0:0]
/// LSE oscillator enable
LSEON: u1 = 0,
/// LSERDY [1:1]
/// LSE oscillator ready
LSERDY: u1 = 0,
/// LSEBYP [2:2]
/// LSE oscillator bypass
LSEBYP: u1 = 0,
/// LSEDRV [3:4]
/// SE oscillator drive
LSEDRV: u2 = 0,
/// LSECSSON [5:5]
/// LSECSSON
LSECSSON: u1 = 0,
/// LSECSSD [6:6]
/// LSECSSD
LSECSSD: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// RTCSEL [8:9]
/// RTC clock source selection
RTCSEL: u2 = 0,
/// unused [10:14]
_unused10: u5 = 0,
/// RTCEN [15:15]
/// RTC clock enable
RTCEN: u1 = 0,
/// BDRST [16:16]
/// Backup domain software
BDRST: u1 = 0,
/// unused [17:23]
_unused17: u7 = 0,
/// LSCOEN [24:24]
/// Low speed clock output
LSCOEN: u1 = 0,
/// LSCOSEL [25:25]
/// Low speed clock output
LSCOSEL: u1 = 0,
/// unused [26:31]
_unused26: u6 = 0,
};
/// BDCR
pub const BDCR = Register(BDCR_val).init(base_address + 0x90);

/// CSR
const CSR_val = packed struct {
/// LSION [0:0]
/// LSI oscillator enable
LSION: u1 = 0,
/// LSIRDY [1:1]
/// LSI oscillator ready
LSIRDY: u1 = 0,
/// unused [2:7]
_unused2: u6 = 0,
/// MSISRANGE [8:11]
/// SI range after Standby
MSISRANGE: u4 = 6,
/// unused [12:22]
_unused12: u4 = 0,
_unused16: u7 = 0,
/// RMVF [23:23]
/// Remove reset flag
RMVF: u1 = 0,
/// FIREWALLRSTF [24:24]
/// Firewall reset flag
FIREWALLRSTF: u1 = 0,
/// OBLRSTF [25:25]
/// Option byte loader reset
OBLRSTF: u1 = 0,
/// PINRSTF [26:26]
/// Pin reset flag
PINRSTF: u1 = 1,
/// BORRSTF [27:27]
/// BOR flag
BORRSTF: u1 = 1,
/// SFTRSTF [28:28]
/// Software reset flag
SFTRSTF: u1 = 0,
/// IWDGRSTF [29:29]
/// Independent window watchdog reset
IWDGRSTF: u1 = 0,
/// WWDGRSTF [30:30]
/// Window watchdog reset flag
WWDGRSTF: u1 = 0,
/// LPWRSTF [31:31]
/// Low-power reset flag
LPWRSTF: u1 = 0,
};
/// CSR
pub const CSR = Register(CSR_val).init(base_address + 0x94);

/// CRRCR
const CRRCR_val = packed struct {
/// HSI48ON [0:0]
/// HSI48 clock enable
HSI48ON: u1 = 0,
/// HSI48RDY [1:1]
/// HSI48 clock ready flag
HSI48RDY: u1 = 0,
/// unused [2:6]
_unused2: u5 = 0,
/// HSI48CAL [7:15]
/// HSI48 clock calibration
HSI48CAL: u9 = 12,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 12,
};
/// Clock recovery RC register
pub const CRRCR = Register(CRRCR_val).init(base_address + 0x98);
};

/// Power control
pub const PWR = struct {

const base_address = 0x40007000;
/// CR1
const CR1_val = packed struct {
/// LPMS [0:2]
/// Low-power mode selection
LPMS: u3 = 0,
/// unused [3:7]
_unused3: u5 = 0,
/// DBP [8:8]
/// Disable backup domain write
DBP: u1 = 0,
/// VOS [9:10]
/// Voltage scaling range
VOS: u2 = 1,
/// unused [11:13]
_unused11: u3 = 0,
/// LPR [14:14]
/// Low-power run
LPR: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Power control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// PVDE [0:0]
/// Power voltage detector
PVDE: u1 = 0,
/// PLS [1:3]
/// Power voltage detector level
PLS: u3 = 0,
/// PVME1 [4:4]
/// Peripheral voltage monitoring 1 enable:
PVME1: u1 = 0,
/// PVME2 [5:5]
/// Peripheral voltage monitoring 2 enable:
PVME2: u1 = 0,
/// PVME3 [6:6]
/// Peripheral voltage monitoring 3 enable:
PVME3: u1 = 0,
/// PVME4 [7:7]
/// Peripheral voltage monitoring 4 enable:
PVME4: u1 = 0,
/// unused [8:8]
_unused8: u1 = 0,
/// IOSV [9:9]
/// VDDIO2 Independent I/Os supply
IOSV: u1 = 0,
/// USV [10:10]
/// VDDUSB USB supply valid
USV: u1 = 0,
/// unused [11:31]
_unused11: u5 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Power control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// CR3
const CR3_val = packed struct {
/// EWUP1 [0:0]
/// Enable Wakeup pin WKUP1
EWUP1: u1 = 0,
/// EWUP2 [1:1]
/// Enable Wakeup pin WKUP2
EWUP2: u1 = 0,
/// EWUP3 [2:2]
/// Enable Wakeup pin WKUP3
EWUP3: u1 = 0,
/// EWUP4 [3:3]
/// Enable Wakeup pin WKUP4
EWUP4: u1 = 0,
/// EWUP5 [4:4]
/// Enable Wakeup pin WKUP5
EWUP5: u1 = 0,
/// unused [5:7]
_unused5: u3 = 0,
/// RRS [8:8]
/// SRAM2 retention in Standby
RRS: u1 = 0,
/// unused [9:9]
_unused9: u1 = 0,
/// APC [10:10]
/// Apply pull-up and pull-down
APC: u1 = 0,
/// unused [11:14]
_unused11: u4 = 0,
/// EWF [15:15]
/// Enable internal wakeup
EWF: u1 = 1,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Power control register 3
pub const CR3 = Register(CR3_val).init(base_address + 0x8);

/// CR4
const CR4_val = packed struct {
/// WP1 [0:0]
/// Wakeup pin WKUP1 polarity
WP1: u1 = 0,
/// WP2 [1:1]
/// Wakeup pin WKUP2 polarity
WP2: u1 = 0,
/// WP3 [2:2]
/// Wakeup pin WKUP3 polarity
WP3: u1 = 0,
/// WP4 [3:3]
/// Wakeup pin WKUP4 polarity
WP4: u1 = 0,
/// WP5 [4:4]
/// Wakeup pin WKUP5 polarity
WP5: u1 = 0,
/// unused [5:7]
_unused5: u3 = 0,
/// VBE [8:8]
/// VBAT battery charging
VBE: u1 = 0,
/// VBRS [9:9]
/// VBAT battery charging resistor
VBRS: u1 = 0,
/// unused [10:31]
_unused10: u6 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Power control register 4
pub const CR4 = Register(CR4_val).init(base_address + 0xc);

/// SR1
const SR1_val = packed struct {
/// CWUF1 [0:0]
/// Wakeup flag 1
CWUF1: u1 = 0,
/// CWUF2 [1:1]
/// Wakeup flag 2
CWUF2: u1 = 0,
/// CWUF3 [2:2]
/// Wakeup flag 3
CWUF3: u1 = 0,
/// CWUF4 [3:3]
/// Wakeup flag 4
CWUF4: u1 = 0,
/// CWUF5 [4:4]
/// Wakeup flag 5
CWUF5: u1 = 0,
/// unused [5:7]
_unused5: u3 = 0,
/// CSBF [8:8]
/// Standby flag
CSBF: u1 = 0,
/// unused [9:14]
_unused9: u6 = 0,
/// WUFI [15:15]
/// Wakeup flag internal
WUFI: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Power status register 1
pub const SR1 = Register(SR1_val).init(base_address + 0x10);

/// SR2
const SR2_val = packed struct {
/// unused [0:7]
_unused0: u8 = 0,
/// REGLPS [8:8]
/// Low-power regulator
REGLPS: u1 = 0,
/// REGLPF [9:9]
/// Low-power regulator flag
REGLPF: u1 = 0,
/// VOSF [10:10]
/// Voltage scaling flag
VOSF: u1 = 0,
/// PVDO [11:11]
/// Power voltage detector
PVDO: u1 = 0,
/// PVMO1 [12:12]
/// Peripheral voltage monitoring output:
PVMO1: u1 = 0,
/// PVMO2 [13:13]
/// Peripheral voltage monitoring output:
PVMO2: u1 = 0,
/// PVMO3 [14:14]
/// Peripheral voltage monitoring output:
PVMO3: u1 = 0,
/// PVMO4 [15:15]
/// Peripheral voltage monitoring output:
PVMO4: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Power status register 2
pub const SR2 = Register(SR2_val).init(base_address + 0x14);

/// SCR
const SCR_val = packed struct {
/// WUF1 [0:0]
/// Clear wakeup flag 1
WUF1: u1 = 0,
/// WUF2 [1:1]
/// Clear wakeup flag 2
WUF2: u1 = 0,
/// WUF3 [2:2]
/// Clear wakeup flag 3
WUF3: u1 = 0,
/// WUF4 [3:3]
/// Clear wakeup flag 4
WUF4: u1 = 0,
/// WUF5 [4:4]
/// Clear wakeup flag 5
WUF5: u1 = 0,
/// unused [5:7]
_unused5: u3 = 0,
/// SBF [8:8]
/// Clear standby flag
SBF: u1 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Power status clear register
pub const SCR = Register(SCR_val).init(base_address + 0x18);

/// PUCRA
const PUCRA_val = packed struct {
/// PU0 [0:0]
/// Port A pull-up bit y
PU0: u1 = 0,
/// PU1 [1:1]
/// Port A pull-up bit y
PU1: u1 = 0,
/// PU2 [2:2]
/// Port A pull-up bit y
PU2: u1 = 0,
/// PU3 [3:3]
/// Port A pull-up bit y
PU3: u1 = 0,
/// PU4 [4:4]
/// Port A pull-up bit y
PU4: u1 = 0,
/// PU5 [5:5]
/// Port A pull-up bit y
PU5: u1 = 0,
/// PU6 [6:6]
/// Port A pull-up bit y
PU6: u1 = 0,
/// PU7 [7:7]
/// Port A pull-up bit y
PU7: u1 = 0,
/// PU8 [8:8]
/// Port A pull-up bit y
PU8: u1 = 0,
/// PU9 [9:9]
/// Port A pull-up bit y
PU9: u1 = 0,
/// PU10 [10:10]
/// Port A pull-up bit y
PU10: u1 = 0,
/// PU11 [11:11]
/// Port A pull-up bit y
PU11: u1 = 0,
/// PU12 [12:12]
/// Port A pull-up bit y
PU12: u1 = 0,
/// PU13 [13:13]
/// Port A pull-up bit y
PU13: u1 = 0,
/// PU14 [14:14]
/// Port A pull-up bit y
PU14: u1 = 0,
/// PU15 [15:15]
/// Port A pull-up bit y
PU15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Power Port A pull-up control
pub const PUCRA = Register(PUCRA_val).init(base_address + 0x20);

/// PDCRA
const PDCRA_val = packed struct {
/// PD0 [0:0]
/// Port A pull-down bit y
PD0: u1 = 0,
/// PD1 [1:1]
/// Port A pull-down bit y
PD1: u1 = 0,
/// PD2 [2:2]
/// Port A pull-down bit y
PD2: u1 = 0,
/// PD3 [3:3]
/// Port A pull-down bit y
PD3: u1 = 0,
/// PD4 [4:4]
/// Port A pull-down bit y
PD4: u1 = 0,
/// PD5 [5:5]
/// Port A pull-down bit y
PD5: u1 = 0,
/// PD6 [6:6]
/// Port A pull-down bit y
PD6: u1 = 0,
/// PD7 [7:7]
/// Port A pull-down bit y
PD7: u1 = 0,
/// PD8 [8:8]
/// Port A pull-down bit y
PD8: u1 = 0,
/// PD9 [9:9]
/// Port A pull-down bit y
PD9: u1 = 0,
/// PD10 [10:10]
/// Port A pull-down bit y
PD10: u1 = 0,
/// PD11 [11:11]
/// Port A pull-down bit y
PD11: u1 = 0,
/// PD12 [12:12]
/// Port A pull-down bit y
PD12: u1 = 0,
/// PD13 [13:13]
/// Port A pull-down bit y
PD13: u1 = 0,
/// PD14 [14:14]
/// Port A pull-down bit y
PD14: u1 = 0,
/// PD15 [15:15]
/// Port A pull-down bit y
PD15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Power Port A pull-down control
pub const PDCRA = Register(PDCRA_val).init(base_address + 0x24);

/// PUCRB
const PUCRB_val = packed struct {
/// PU0 [0:0]
/// Port B pull-up bit y
PU0: u1 = 0,
/// PU1 [1:1]
/// Port B pull-up bit y
PU1: u1 = 0,
/// PU2 [2:2]
/// Port B pull-up bit y
PU2: u1 = 0,
/// PU3 [3:3]
/// Port B pull-up bit y
PU3: u1 = 0,
/// PU4 [4:4]
/// Port B pull-up bit y
PU4: u1 = 0,
/// PU5 [5:5]
/// Port B pull-up bit y
PU5: u1 = 0,
/// PU6 [6:6]
/// Port B pull-up bit y
PU6: u1 = 0,
/// PU7 [7:7]
/// Port B pull-up bit y
PU7: u1 = 0,
/// PU8 [8:8]
/// Port B pull-up bit y
PU8: u1 = 0,
/// PU9 [9:9]
/// Port B pull-up bit y
PU9: u1 = 0,
/// PU10 [10:10]
/// Port B pull-up bit y
PU10: u1 = 0,
/// PU11 [11:11]
/// Port B pull-up bit y
PU11: u1 = 0,
/// PU12 [12:12]
/// Port B pull-up bit y
PU12: u1 = 0,
/// PU13 [13:13]
/// Port B pull-up bit y
PU13: u1 = 0,
/// PU14 [14:14]
/// Port B pull-up bit y
PU14: u1 = 0,
/// PU15 [15:15]
/// Port B pull-up bit y
PU15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Power Port B pull-up control
pub const PUCRB = Register(PUCRB_val).init(base_address + 0x28);

/// PDCRB
const PDCRB_val = packed struct {
/// PD0 [0:0]
/// Port B pull-down bit y
PD0: u1 = 0,
/// PD1 [1:1]
/// Port B pull-down bit y
PD1: u1 = 0,
/// PD2 [2:2]
/// Port B pull-down bit y
PD2: u1 = 0,
/// PD3 [3:3]
/// Port B pull-down bit y
PD3: u1 = 0,
/// PD4 [4:4]
/// Port B pull-down bit y
PD4: u1 = 0,
/// PD5 [5:5]
/// Port B pull-down bit y
PD5: u1 = 0,
/// PD6 [6:6]
/// Port B pull-down bit y
PD6: u1 = 0,
/// PD7 [7:7]
/// Port B pull-down bit y
PD7: u1 = 0,
/// PD8 [8:8]
/// Port B pull-down bit y
PD8: u1 = 0,
/// PD9 [9:9]
/// Port B pull-down bit y
PD9: u1 = 0,
/// PD10 [10:10]
/// Port B pull-down bit y
PD10: u1 = 0,
/// PD11 [11:11]
/// Port B pull-down bit y
PD11: u1 = 0,
/// PD12 [12:12]
/// Port B pull-down bit y
PD12: u1 = 0,
/// PD13 [13:13]
/// Port B pull-down bit y
PD13: u1 = 0,
/// PD14 [14:14]
/// Port B pull-down bit y
PD14: u1 = 0,
/// PD15 [15:15]
/// Port B pull-down bit y
PD15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Power Port B pull-down control
pub const PDCRB = Register(PDCRB_val).init(base_address + 0x2c);

/// PUCRC
const PUCRC_val = packed struct {
/// PU0 [0:0]
/// Port C pull-up bit y
PU0: u1 = 0,
/// PU1 [1:1]
/// Port C pull-up bit y
PU1: u1 = 0,
/// PU2 [2:2]
/// Port C pull-up bit y
PU2: u1 = 0,
/// PU3 [3:3]
/// Port C pull-up bit y
PU3: u1 = 0,
/// PU4 [4:4]
/// Port C pull-up bit y
PU4: u1 = 0,
/// PU5 [5:5]
/// Port C pull-up bit y
PU5: u1 = 0,
/// PU6 [6:6]
/// Port C pull-up bit y
PU6: u1 = 0,
/// PU7 [7:7]
/// Port C pull-up bit y
PU7: u1 = 0,
/// PU8 [8:8]
/// Port C pull-up bit y
PU8: u1 = 0,
/// PU9 [9:9]
/// Port C pull-up bit y
PU9: u1 = 0,
/// PU10 [10:10]
/// Port C pull-up bit y
PU10: u1 = 0,
/// PU11 [11:11]
/// Port C pull-up bit y
PU11: u1 = 0,
/// PU12 [12:12]
/// Port C pull-up bit y
PU12: u1 = 0,
/// PU13 [13:13]
/// Port C pull-up bit y
PU13: u1 = 0,
/// PU14 [14:14]
/// Port C pull-up bit y
PU14: u1 = 0,
/// PU15 [15:15]
/// Port C pull-up bit y
PU15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Power Port C pull-up control
pub const PUCRC = Register(PUCRC_val).init(base_address + 0x30);

/// PDCRC
const PDCRC_val = packed struct {
/// PD0 [0:0]
/// Port C pull-down bit y
PD0: u1 = 0,
/// PD1 [1:1]
/// Port C pull-down bit y
PD1: u1 = 0,
/// PD2 [2:2]
/// Port C pull-down bit y
PD2: u1 = 0,
/// PD3 [3:3]
/// Port C pull-down bit y
PD3: u1 = 0,
/// PD4 [4:4]
/// Port C pull-down bit y
PD4: u1 = 0,
/// PD5 [5:5]
/// Port C pull-down bit y
PD5: u1 = 0,
/// PD6 [6:6]
/// Port C pull-down bit y
PD6: u1 = 0,
/// PD7 [7:7]
/// Port C pull-down bit y
PD7: u1 = 0,
/// PD8 [8:8]
/// Port C pull-down bit y
PD8: u1 = 0,
/// PD9 [9:9]
/// Port C pull-down bit y
PD9: u1 = 0,
/// PD10 [10:10]
/// Port C pull-down bit y
PD10: u1 = 0,
/// PD11 [11:11]
/// Port C pull-down bit y
PD11: u1 = 0,
/// PD12 [12:12]
/// Port C pull-down bit y
PD12: u1 = 0,
/// PD13 [13:13]
/// Port C pull-down bit y
PD13: u1 = 0,
/// PD14 [14:14]
/// Port C pull-down bit y
PD14: u1 = 0,
/// PD15 [15:15]
/// Port C pull-down bit y
PD15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Power Port C pull-down control
pub const PDCRC = Register(PDCRC_val).init(base_address + 0x34);

/// PUCRD
const PUCRD_val = packed struct {
/// PU0 [0:0]
/// Port D pull-up bit y
PU0: u1 = 0,
/// PU1 [1:1]
/// Port D pull-up bit y
PU1: u1 = 0,
/// PU2 [2:2]
/// Port D pull-up bit y
PU2: u1 = 0,
/// PU3 [3:3]
/// Port D pull-up bit y
PU3: u1 = 0,
/// PU4 [4:4]
/// Port D pull-up bit y
PU4: u1 = 0,
/// PU5 [5:5]
/// Port D pull-up bit y
PU5: u1 = 0,
/// PU6 [6:6]
/// Port D pull-up bit y
PU6: u1 = 0,
/// PU7 [7:7]
/// Port D pull-up bit y
PU7: u1 = 0,
/// PU8 [8:8]
/// Port D pull-up bit y
PU8: u1 = 0,
/// PU9 [9:9]
/// Port D pull-up bit y
PU9: u1 = 0,
/// PU10 [10:10]
/// Port D pull-up bit y
PU10: u1 = 0,
/// PU11 [11:11]
/// Port D pull-up bit y
PU11: u1 = 0,
/// PU12 [12:12]
/// Port D pull-up bit y
PU12: u1 = 0,
/// PU13 [13:13]
/// Port D pull-up bit y
PU13: u1 = 0,
/// PU14 [14:14]
/// Port D pull-up bit y
PU14: u1 = 0,
/// PU15 [15:15]
/// Port D pull-up bit y
PU15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Power Port D pull-up control
pub const PUCRD = Register(PUCRD_val).init(base_address + 0x38);

/// PDCRD
const PDCRD_val = packed struct {
/// PD0 [0:0]
/// Port D pull-down bit y
PD0: u1 = 0,
/// PD1 [1:1]
/// Port D pull-down bit y
PD1: u1 = 0,
/// PD2 [2:2]
/// Port D pull-down bit y
PD2: u1 = 0,
/// PD3 [3:3]
/// Port D pull-down bit y
PD3: u1 = 0,
/// PD4 [4:4]
/// Port D pull-down bit y
PD4: u1 = 0,
/// PD5 [5:5]
/// Port D pull-down bit y
PD5: u1 = 0,
/// PD6 [6:6]
/// Port D pull-down bit y
PD6: u1 = 0,
/// PD7 [7:7]
/// Port D pull-down bit y
PD7: u1 = 0,
/// PD8 [8:8]
/// Port D pull-down bit y
PD8: u1 = 0,
/// PD9 [9:9]
/// Port D pull-down bit y
PD9: u1 = 0,
/// PD10 [10:10]
/// Port D pull-down bit y
PD10: u1 = 0,
/// PD11 [11:11]
/// Port D pull-down bit y
PD11: u1 = 0,
/// PD12 [12:12]
/// Port D pull-down bit y
PD12: u1 = 0,
/// PD13 [13:13]
/// Port D pull-down bit y
PD13: u1 = 0,
/// PD14 [14:14]
/// Port D pull-down bit y
PD14: u1 = 0,
/// PD15 [15:15]
/// Port D pull-down bit y
PD15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Power Port D pull-down control
pub const PDCRD = Register(PDCRD_val).init(base_address + 0x3c);

/// PUCRE
const PUCRE_val = packed struct {
/// PU0 [0:0]
/// Port E pull-up bit y
PU0: u1 = 0,
/// PU1 [1:1]
/// Port E pull-up bit y
PU1: u1 = 0,
/// PU2 [2:2]
/// Port E pull-up bit y
PU2: u1 = 0,
/// PU3 [3:3]
/// Port E pull-up bit y
PU3: u1 = 0,
/// PU4 [4:4]
/// Port E pull-up bit y
PU4: u1 = 0,
/// PU5 [5:5]
/// Port E pull-up bit y
PU5: u1 = 0,
/// PU6 [6:6]
/// Port E pull-up bit y
PU6: u1 = 0,
/// PU7 [7:7]
/// Port E pull-up bit y
PU7: u1 = 0,
/// PU8 [8:8]
/// Port E pull-up bit y
PU8: u1 = 0,
/// PU9 [9:9]
/// Port E pull-up bit y
PU9: u1 = 0,
/// PU10 [10:10]
/// Port E pull-up bit y
PU10: u1 = 0,
/// PU11 [11:11]
/// Port E pull-up bit y
PU11: u1 = 0,
/// PU12 [12:12]
/// Port E pull-up bit y
PU12: u1 = 0,
/// PU13 [13:13]
/// Port E pull-up bit y
PU13: u1 = 0,
/// PU14 [14:14]
/// Port E pull-up bit y
PU14: u1 = 0,
/// PU15 [15:15]
/// Port E pull-up bit y
PU15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Power Port E pull-up control
pub const PUCRE = Register(PUCRE_val).init(base_address + 0x40);

/// PDCRE
const PDCRE_val = packed struct {
/// PD0 [0:0]
/// Port E pull-down bit y
PD0: u1 = 0,
/// PD1 [1:1]
/// Port E pull-down bit y
PD1: u1 = 0,
/// PD2 [2:2]
/// Port E pull-down bit y
PD2: u1 = 0,
/// PD3 [3:3]
/// Port E pull-down bit y
PD3: u1 = 0,
/// PD4 [4:4]
/// Port E pull-down bit y
PD4: u1 = 0,
/// PD5 [5:5]
/// Port E pull-down bit y
PD5: u1 = 0,
/// PD6 [6:6]
/// Port E pull-down bit y
PD6: u1 = 0,
/// PD7 [7:7]
/// Port E pull-down bit y
PD7: u1 = 0,
/// PD8 [8:8]
/// Port E pull-down bit y
PD8: u1 = 0,
/// PD9 [9:9]
/// Port E pull-down bit y
PD9: u1 = 0,
/// PD10 [10:10]
/// Port E pull-down bit y
PD10: u1 = 0,
/// PD11 [11:11]
/// Port E pull-down bit y
PD11: u1 = 0,
/// PD12 [12:12]
/// Port E pull-down bit y
PD12: u1 = 0,
/// PD13 [13:13]
/// Port E pull-down bit y
PD13: u1 = 0,
/// PD14 [14:14]
/// Port E pull-down bit y
PD14: u1 = 0,
/// PD15 [15:15]
/// Port E pull-down bit y
PD15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Power Port E pull-down control
pub const PDCRE = Register(PDCRE_val).init(base_address + 0x44);

/// PUCRF
const PUCRF_val = packed struct {
/// PU0 [0:0]
/// Port F pull-up bit y
PU0: u1 = 0,
/// PU1 [1:1]
/// Port F pull-up bit y
PU1: u1 = 0,
/// PU2 [2:2]
/// Port F pull-up bit y
PU2: u1 = 0,
/// PU3 [3:3]
/// Port F pull-up bit y
PU3: u1 = 0,
/// PU4 [4:4]
/// Port F pull-up bit y
PU4: u1 = 0,
/// PU5 [5:5]
/// Port F pull-up bit y
PU5: u1 = 0,
/// PU6 [6:6]
/// Port F pull-up bit y
PU6: u1 = 0,
/// PU7 [7:7]
/// Port F pull-up bit y
PU7: u1 = 0,
/// PU8 [8:8]
/// Port F pull-up bit y
PU8: u1 = 0,
/// PU9 [9:9]
/// Port F pull-up bit y
PU9: u1 = 0,
/// PU10 [10:10]
/// Port F pull-up bit y
PU10: u1 = 0,
/// PU11 [11:11]
/// Port F pull-up bit y
PU11: u1 = 0,
/// PU12 [12:12]
/// Port F pull-up bit y
PU12: u1 = 0,
/// PU13 [13:13]
/// Port F pull-up bit y
PU13: u1 = 0,
/// PU14 [14:14]
/// Port F pull-up bit y
PU14: u1 = 0,
/// PU15 [15:15]
/// Port F pull-up bit y
PU15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Power Port F pull-up control
pub const PUCRF = Register(PUCRF_val).init(base_address + 0x48);

/// PDCRF
const PDCRF_val = packed struct {
/// PD0 [0:0]
/// Port F pull-down bit y
PD0: u1 = 0,
/// PD1 [1:1]
/// Port F pull-down bit y
PD1: u1 = 0,
/// PD2 [2:2]
/// Port F pull-down bit y
PD2: u1 = 0,
/// PD3 [3:3]
/// Port F pull-down bit y
PD3: u1 = 0,
/// PD4 [4:4]
/// Port F pull-down bit y
PD4: u1 = 0,
/// PD5 [5:5]
/// Port F pull-down bit y
PD5: u1 = 0,
/// PD6 [6:6]
/// Port F pull-down bit y
PD6: u1 = 0,
/// PD7 [7:7]
/// Port F pull-down bit y
PD7: u1 = 0,
/// PD8 [8:8]
/// Port F pull-down bit y
PD8: u1 = 0,
/// PD9 [9:9]
/// Port F pull-down bit y
PD9: u1 = 0,
/// PD10 [10:10]
/// Port F pull-down bit y
PD10: u1 = 0,
/// PD11 [11:11]
/// Port F pull-down bit y
PD11: u1 = 0,
/// PD12 [12:12]
/// Port F pull-down bit y
PD12: u1 = 0,
/// PD13 [13:13]
/// Port F pull-down bit y
PD13: u1 = 0,
/// PD14 [14:14]
/// Port F pull-down bit y
PD14: u1 = 0,
/// PD15 [15:15]
/// Port F pull-down bit y
PD15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Power Port F pull-down control
pub const PDCRF = Register(PDCRF_val).init(base_address + 0x4c);

/// PUCRG
const PUCRG_val = packed struct {
/// PU0 [0:0]
/// Port G pull-up bit y
PU0: u1 = 0,
/// PU1 [1:1]
/// Port G pull-up bit y
PU1: u1 = 0,
/// PU2 [2:2]
/// Port G pull-up bit y
PU2: u1 = 0,
/// PU3 [3:3]
/// Port G pull-up bit y
PU3: u1 = 0,
/// PU4 [4:4]
/// Port G pull-up bit y
PU4: u1 = 0,
/// PU5 [5:5]
/// Port G pull-up bit y
PU5: u1 = 0,
/// PU6 [6:6]
/// Port G pull-up bit y
PU6: u1 = 0,
/// PU7 [7:7]
/// Port G pull-up bit y
PU7: u1 = 0,
/// PU8 [8:8]
/// Port G pull-up bit y
PU8: u1 = 0,
/// PU9 [9:9]
/// Port G pull-up bit y
PU9: u1 = 0,
/// PU10 [10:10]
/// Port G pull-up bit y
PU10: u1 = 0,
/// PU11 [11:11]
/// Port G pull-up bit y
PU11: u1 = 0,
/// PU12 [12:12]
/// Port G pull-up bit y
PU12: u1 = 0,
/// PU13 [13:13]
/// Port G pull-up bit y
PU13: u1 = 0,
/// PU14 [14:14]
/// Port G pull-up bit y
PU14: u1 = 0,
/// PU15 [15:15]
/// Port G pull-up bit y
PU15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Power Port G pull-up control
pub const PUCRG = Register(PUCRG_val).init(base_address + 0x50);

/// PDCRG
const PDCRG_val = packed struct {
/// PD0 [0:0]
/// Port G pull-down bit y
PD0: u1 = 0,
/// PD1 [1:1]
/// Port G pull-down bit y
PD1: u1 = 0,
/// PD2 [2:2]
/// Port G pull-down bit y
PD2: u1 = 0,
/// PD3 [3:3]
/// Port G pull-down bit y
PD3: u1 = 0,
/// PD4 [4:4]
/// Port G pull-down bit y
PD4: u1 = 0,
/// PD5 [5:5]
/// Port G pull-down bit y
PD5: u1 = 0,
/// PD6 [6:6]
/// Port G pull-down bit y
PD6: u1 = 0,
/// PD7 [7:7]
/// Port G pull-down bit y
PD7: u1 = 0,
/// PD8 [8:8]
/// Port G pull-down bit y
PD8: u1 = 0,
/// PD9 [9:9]
/// Port G pull-down bit y
PD9: u1 = 0,
/// PD10 [10:10]
/// Port G pull-down bit y
PD10: u1 = 0,
/// PD11 [11:11]
/// Port G pull-down bit y
PD11: u1 = 0,
/// PD12 [12:12]
/// Port G pull-down bit y
PD12: u1 = 0,
/// PD13 [13:13]
/// Port G pull-down bit y
PD13: u1 = 0,
/// PD14 [14:14]
/// Port G pull-down bit y
PD14: u1 = 0,
/// PD15 [15:15]
/// Port G pull-down bit y
PD15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Power Port G pull-down control
pub const PDCRG = Register(PDCRG_val).init(base_address + 0x54);

/// PUCRH
const PUCRH_val = packed struct {
/// PU0 [0:0]
/// Port H pull-up bit y
PU0: u1 = 0,
/// PU1 [1:1]
/// Port H pull-up bit y
PU1: u1 = 0,
/// unused [2:31]
_unused2: u6 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Power Port H pull-up control
pub const PUCRH = Register(PUCRH_val).init(base_address + 0x58);

/// PDCRH
const PDCRH_val = packed struct {
/// PD0 [0:0]
/// Port H pull-down bit y
PD0: u1 = 0,
/// PD1 [1:1]
/// Port H pull-down bit y
PD1: u1 = 0,
/// unused [2:31]
_unused2: u6 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Power Port H pull-down control
pub const PDCRH = Register(PDCRH_val).init(base_address + 0x5c);
};

/// System configuration controller
pub const SYSCFG = struct {

const base_address = 0x40010000;
/// MEMRMP
const MEMRMP_val = packed struct {
/// MEM_MODE [0:2]
/// Memory mapping selection
MEM_MODE: u3 = 0,
/// QFS [3:3]
/// QUADSPI memory mapping
QFS: u1 = 0,
/// unused [4:7]
_unused4: u4 = 0,
/// FB_MODE [8:8]
/// Flash Bank mode selection
FB_MODE: u1 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// memory remap register
pub const MEMRMP = Register(MEMRMP_val).init(base_address + 0x0);

/// CFGR1
const CFGR1_val = packed struct {
/// FWDIS [0:0]
/// Firewall disable
FWDIS: u1 = 1,
/// unused [1:7]
_unused1: u7 = 0,
/// BOOSTEN [8:8]
/// I/O analog switch voltage booster
BOOSTEN: u1 = 0,
/// unused [9:15]
_unused9: u7 = 0,
/// I2C_PB6_FMP [16:16]
/// Fast-mode Plus (Fm+) driving capability
I2C_PB6_FMP: u1 = 0,
/// I2C_PB7_FMP [17:17]
/// Fast-mode Plus (Fm+) driving capability
I2C_PB7_FMP: u1 = 0,
/// I2C_PB8_FMP [18:18]
/// Fast-mode Plus (Fm+) driving capability
I2C_PB8_FMP: u1 = 0,
/// I2C_PB9_FMP [19:19]
/// Fast-mode Plus (Fm+) driving capability
I2C_PB9_FMP: u1 = 0,
/// I2C1_FMP [20:20]
/// I2C1 Fast-mode Plus driving capability
I2C1_FMP: u1 = 0,
/// I2C2_FMP [21:21]
/// I2C2 Fast-mode Plus driving capability
I2C2_FMP: u1 = 0,
/// I2C3_FMP [22:22]
/// I2C3 Fast-mode Plus driving capability
I2C3_FMP: u1 = 0,
/// unused [23:25]
_unused23: u1 = 0,
_unused24: u2 = 0,
/// FPU_IE [26:31]
/// Floating Point Unit interrupts enable
FPU_IE: u6 = 31,
};
/// configuration register 1
pub const CFGR1 = Register(CFGR1_val).init(base_address + 0x4);

/// EXTICR1
const EXTICR1_val = packed struct {
/// EXTI0 [0:2]
/// EXTI 0 configuration bits
EXTI0: u3 = 0,
/// unused [3:3]
_unused3: u1 = 0,
/// EXTI1 [4:6]
/// EXTI 1 configuration bits
EXTI1: u3 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// EXTI2 [8:10]
/// EXTI 2 configuration bits
EXTI2: u3 = 0,
/// unused [11:11]
_unused11: u1 = 0,
/// EXTI3 [12:14]
/// EXTI 3 configuration bits
EXTI3: u3 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// external interrupt configuration register
pub const EXTICR1 = Register(EXTICR1_val).init(base_address + 0x8);

/// EXTICR2
const EXTICR2_val = packed struct {
/// EXTI4 [0:2]
/// EXTI 4 configuration bits
EXTI4: u3 = 0,
/// unused [3:3]
_unused3: u1 = 0,
/// EXTI5 [4:6]
/// EXTI 5 configuration bits
EXTI5: u3 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// EXTI6 [8:10]
/// EXTI 6 configuration bits
EXTI6: u3 = 0,
/// unused [11:11]
_unused11: u1 = 0,
/// EXTI7 [12:14]
/// EXTI 7 configuration bits
EXTI7: u3 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// external interrupt configuration register
pub const EXTICR2 = Register(EXTICR2_val).init(base_address + 0xc);

/// EXTICR3
const EXTICR3_val = packed struct {
/// EXTI8 [0:2]
/// EXTI 8 configuration bits
EXTI8: u3 = 0,
/// unused [3:3]
_unused3: u1 = 0,
/// EXTI9 [4:6]
/// EXTI 9 configuration bits
EXTI9: u3 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// EXTI10 [8:10]
/// EXTI 10 configuration bits
EXTI10: u3 = 0,
/// unused [11:11]
_unused11: u1 = 0,
/// EXTI11 [12:14]
/// EXTI 11 configuration bits
EXTI11: u3 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// external interrupt configuration register
pub const EXTICR3 = Register(EXTICR3_val).init(base_address + 0x10);

/// EXTICR4
const EXTICR4_val = packed struct {
/// EXTI12 [0:2]
/// EXTI12 configuration bits
EXTI12: u3 = 0,
/// unused [3:3]
_unused3: u1 = 0,
/// EXTI13 [4:6]
/// EXTI13 configuration bits
EXTI13: u3 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// EXTI14 [8:10]
/// EXTI14 configuration bits
EXTI14: u3 = 0,
/// unused [11:11]
_unused11: u1 = 0,
/// EXTI15 [12:14]
/// EXTI15 configuration bits
EXTI15: u3 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// external interrupt configuration register
pub const EXTICR4 = Register(EXTICR4_val).init(base_address + 0x14);

/// SCSR
const SCSR_val = packed struct {
/// SRAM2ER [0:0]
/// SRAM2 Erase
SRAM2ER: u1 = 0,
/// SRAM2BSY [1:1]
/// SRAM2 busy by erase
SRAM2BSY: u1 = 0,
/// unused [2:31]
_unused2: u6 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// SCSR
pub const SCSR = Register(SCSR_val).init(base_address + 0x18);

/// CFGR2
const CFGR2_val = packed struct {
/// CLL [0:0]
/// OCKUP (Hardfault) output enable
CLL: u1 = 0,
/// SPL [1:1]
/// SRAM2 parity lock bit
SPL: u1 = 0,
/// PVDL [2:2]
/// PVD lock enable bit
PVDL: u1 = 0,
/// ECCL [3:3]
/// ECC Lock
ECCL: u1 = 0,
/// unused [4:7]
_unused4: u4 = 0,
/// SPF [8:8]
/// SRAM2 parity error flag
SPF: u1 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// CFGR2
pub const CFGR2 = Register(CFGR2_val).init(base_address + 0x1c);

/// SWPR
const SWPR_val = packed struct {
/// P0WP [0:0]
/// P0WP
P0WP: u1 = 0,
/// P1WP [1:1]
/// P1WP
P1WP: u1 = 0,
/// P2WP [2:2]
/// P2WP
P2WP: u1 = 0,
/// P3WP [3:3]
/// P3WP
P3WP: u1 = 0,
/// P4WP [4:4]
/// P4WP
P4WP: u1 = 0,
/// P5WP [5:5]
/// P5WP
P5WP: u1 = 0,
/// P6WP [6:6]
/// P6WP
P6WP: u1 = 0,
/// P7WP [7:7]
/// P7WP
P7WP: u1 = 0,
/// P8WP [8:8]
/// P8WP
P8WP: u1 = 0,
/// P9WP [9:9]
/// P9WP
P9WP: u1 = 0,
/// P10WP [10:10]
/// P10WP
P10WP: u1 = 0,
/// P11WP [11:11]
/// P11WP
P11WP: u1 = 0,
/// P12WP [12:12]
/// P12WP
P12WP: u1 = 0,
/// P13WP [13:13]
/// P13WP
P13WP: u1 = 0,
/// P14WP [14:14]
/// P14WP
P14WP: u1 = 0,
/// P15WP [15:15]
/// P15WP
P15WP: u1 = 0,
/// P16WP [16:16]
/// P16WP
P16WP: u1 = 0,
/// P17WP [17:17]
/// P17WP
P17WP: u1 = 0,
/// P18WP [18:18]
/// P18WP
P18WP: u1 = 0,
/// P19WP [19:19]
/// P19WP
P19WP: u1 = 0,
/// P20WP [20:20]
/// P20WP
P20WP: u1 = 0,
/// P21WP [21:21]
/// P21WP
P21WP: u1 = 0,
/// P22WP [22:22]
/// P22WP
P22WP: u1 = 0,
/// P23WP [23:23]
/// P23WP
P23WP: u1 = 0,
/// P24WP [24:24]
/// P24WP
P24WP: u1 = 0,
/// P25WP [25:25]
/// P25WP
P25WP: u1 = 0,
/// P26WP [26:26]
/// P26WP
P26WP: u1 = 0,
/// P27WP [27:27]
/// P27WP
P27WP: u1 = 0,
/// P28WP [28:28]
/// P28WP
P28WP: u1 = 0,
/// P29WP [29:29]
/// P29WP
P29WP: u1 = 0,
/// P30WP [30:30]
/// P30WP
P30WP: u1 = 0,
/// P31WP [31:31]
/// SRAM2 page 31 write
P31WP: u1 = 0,
};
/// SWPR
pub const SWPR = Register(SWPR_val).init(base_address + 0x20);

/// SKR
const SKR_val = packed struct {
/// KEY [0:7]
/// SRAM2 write protection key for software
KEY: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// SKR
pub const SKR = Register(SKR_val).init(base_address + 0x24);
};

/// Random number generator
pub const RNG = struct {

const base_address = 0x50060800;
/// CR
const CR_val = packed struct {
/// unused [0:1]
_unused0: u2 = 0,
/// RNGEN [2:2]
/// Random number generator
RNGEN: u1 = 0,
/// IE [3:3]
/// Interrupt enable
IE: u1 = 0,
/// unused [4:31]
_unused4: u4 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register
pub const CR = Register(CR_val).init(base_address + 0x0);

/// SR
const SR_val = packed struct {
/// DRDY [0:0]
/// Data ready
DRDY: u1 = 0,
/// CECS [1:1]
/// Clock error current status
CECS: u1 = 0,
/// SECS [2:2]
/// Seed error current status
SECS: u1 = 0,
/// unused [3:4]
_unused3: u2 = 0,
/// CEIS [5:5]
/// Clock error interrupt
CEIS: u1 = 0,
/// SEIS [6:6]
/// Seed error interrupt
SEIS: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// status register
pub const SR = Register(SR_val).init(base_address + 0x4);

/// DR
const DR_val = packed struct {
/// RNDATA [0:31]
/// Random data
RNDATA: u32 = 0,
};
/// data register
pub const DR = Register(DR_val).init(base_address + 0x8);
};

/// Advanced encryption standard hardware
pub const AES = struct {

const base_address = 0x50060000;
/// CR
const CR_val = packed struct {
/// EN [0:0]
/// AES enable
EN: u1 = 0,
/// DATATYPE [1:2]
/// Data type selection (for data in and
DATATYPE: u2 = 0,
/// MODE [3:4]
/// AES operating mode
MODE: u2 = 0,
/// CHMOD [5:6]
/// AES chaining mode
CHMOD: u2 = 0,
/// CCFC [7:7]
/// Computation Complete Flag
CCFC: u1 = 0,
/// ERRC [8:8]
/// Error clear
ERRC: u1 = 0,
/// CCFIE [9:9]
/// CCF flag interrupt enable
CCFIE: u1 = 0,
/// ERRIE [10:10]
/// Error interrupt enable
ERRIE: u1 = 0,
/// DMAINEN [11:11]
/// Enable DMA management of data input
DMAINEN: u1 = 0,
/// DMAOUTEN [12:12]
/// Enable DMA management of data output
DMAOUTEN: u1 = 0,
/// unused [13:31]
_unused13: u3 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register
pub const CR = Register(CR_val).init(base_address + 0x0);

/// SR
const SR_val = packed struct {
/// CCF [0:0]
/// Computation complete flag
CCF: u1 = 0,
/// RDERR [1:1]
/// Read error flag
RDERR: u1 = 0,
/// WRERR [2:2]
/// Write error flag
WRERR: u1 = 0,
/// unused [3:31]
_unused3: u5 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// status register
pub const SR = Register(SR_val).init(base_address + 0x4);

/// DINR
const DINR_val = packed struct {
/// AES_DINR [0:31]
/// Data Input Register
AES_DINR: u32 = 0,
};
/// data input register
pub const DINR = Register(DINR_val).init(base_address + 0x8);

/// DOUTR
const DOUTR_val = packed struct {
/// AES_DOUTR [0:31]
/// Data output register
AES_DOUTR: u32 = 0,
};
/// data output register
pub const DOUTR = Register(DOUTR_val).init(base_address + 0xc);

/// KEYR0
const KEYR0_val = packed struct {
/// AES_KEYR0 [0:31]
/// Data Output Register (LSB key
AES_KEYR0: u32 = 0,
};
/// key register 0
pub const KEYR0 = Register(KEYR0_val).init(base_address + 0x10);

/// KEYR1
const KEYR1_val = packed struct {
/// AES_KEYR1 [0:31]
/// AES key register (key
AES_KEYR1: u32 = 0,
};
/// key register 1
pub const KEYR1 = Register(KEYR1_val).init(base_address + 0x14);

/// KEYR2
const KEYR2_val = packed struct {
/// AES_KEYR2 [0:31]
/// AES key register (key
AES_KEYR2: u32 = 0,
};
/// key register 2
pub const KEYR2 = Register(KEYR2_val).init(base_address + 0x18);

/// KEYR3
const KEYR3_val = packed struct {
/// AES_KEYR3 [0:31]
/// AES key register (MSB key
AES_KEYR3: u32 = 0,
};
/// key register 3
pub const KEYR3 = Register(KEYR3_val).init(base_address + 0x1c);

/// IVR0
const IVR0_val = packed struct {
/// AES_IVR0 [0:31]
/// initialization vector register (LSB IVR
AES_IVR0: u32 = 0,
};
/// initialization vector register
pub const IVR0 = Register(IVR0_val).init(base_address + 0x20);

/// IVR1
const IVR1_val = packed struct {
/// AES_IVR1 [0:31]
/// Initialization Vector Register (IVR
AES_IVR1: u32 = 0,
};
/// initialization vector register
pub const IVR1 = Register(IVR1_val).init(base_address + 0x24);

/// IVR2
const IVR2_val = packed struct {
/// AES_IVR2 [0:31]
/// Initialization Vector Register (IVR
AES_IVR2: u32 = 0,
};
/// initialization vector register
pub const IVR2 = Register(IVR2_val).init(base_address + 0x28);

/// IVR3
const IVR3_val = packed struct {
/// AES_IVR3 [0:31]
/// Initialization Vector Register (MSB IVR
AES_IVR3: u32 = 0,
};
/// initialization vector register
pub const IVR3 = Register(IVR3_val).init(base_address + 0x2c);
};

/// Analog-to-Digital Converter
pub const ADC = struct {

const base_address = 0x50040000;
/// ISR
const ISR_val = packed struct {
/// ADRDY [0:0]
/// ADRDY
ADRDY: u1 = 0,
/// EOSMP [1:1]
/// EOSMP
EOSMP: u1 = 0,
/// EOC [2:2]
/// EOC
EOC: u1 = 0,
/// EOS [3:3]
/// EOS
EOS: u1 = 0,
/// OVR [4:4]
/// OVR
OVR: u1 = 0,
/// JEOC [5:5]
/// JEOC
JEOC: u1 = 0,
/// JEOS [6:6]
/// JEOS
JEOS: u1 = 0,
/// AWD1 [7:7]
/// AWD1
AWD1: u1 = 0,
/// AWD2 [8:8]
/// AWD2
AWD2: u1 = 0,
/// AWD3 [9:9]
/// AWD3
AWD3: u1 = 0,
/// JQOVF [10:10]
/// JQOVF
JQOVF: u1 = 0,
/// unused [11:31]
_unused11: u5 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// interrupt and status register
pub const ISR = Register(ISR_val).init(base_address + 0x0);

/// IER
const IER_val = packed struct {
/// ADRDYIE [0:0]
/// ADRDYIE
ADRDYIE: u1 = 0,
/// EOSMPIE [1:1]
/// EOSMPIE
EOSMPIE: u1 = 0,
/// EOCIE [2:2]
/// EOCIE
EOCIE: u1 = 0,
/// EOSIE [3:3]
/// EOSIE
EOSIE: u1 = 0,
/// OVRIE [4:4]
/// OVRIE
OVRIE: u1 = 0,
/// JEOCIE [5:5]
/// JEOCIE
JEOCIE: u1 = 0,
/// JEOSIE [6:6]
/// JEOSIE
JEOSIE: u1 = 0,
/// AWD1IE [7:7]
/// AWD1IE
AWD1IE: u1 = 0,
/// AWD2IE [8:8]
/// AWD2IE
AWD2IE: u1 = 0,
/// AWD3IE [9:9]
/// AWD3IE
AWD3IE: u1 = 0,
/// JQOVFIE [10:10]
/// JQOVFIE
JQOVFIE: u1 = 0,
/// unused [11:31]
_unused11: u5 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// interrupt enable register
pub const IER = Register(IER_val).init(base_address + 0x4);

/// CR
const CR_val = packed struct {
/// ADEN [0:0]
/// ADEN
ADEN: u1 = 0,
/// ADDIS [1:1]
/// ADDIS
ADDIS: u1 = 0,
/// ADSTART [2:2]
/// ADSTART
ADSTART: u1 = 0,
/// JADSTART [3:3]
/// JADSTART
JADSTART: u1 = 0,
/// ADSTP [4:4]
/// ADSTP
ADSTP: u1 = 0,
/// JADSTP [5:5]
/// JADSTP
JADSTP: u1 = 0,
/// unused [6:27]
_unused6: u2 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u4 = 0,
/// ADVREGEN [28:28]
/// ADVREGEN
ADVREGEN: u1 = 0,
/// DEEPPWD [29:29]
/// DEEPPWD
DEEPPWD: u1 = 0,
/// ADCALDIF [30:30]
/// ADCALDIF
ADCALDIF: u1 = 0,
/// ADCAL [31:31]
/// ADCAL
ADCAL: u1 = 0,
};
/// control register
pub const CR = Register(CR_val).init(base_address + 0x8);

/// CFGR
const CFGR_val = packed struct {
/// DMAEN [0:0]
/// DMAEN
DMAEN: u1 = 0,
/// DMACFG [1:1]
/// DMACFG
DMACFG: u1 = 0,
/// unused [2:2]
_unused2: u1 = 0,
/// RES [3:4]
/// RES
RES: u2 = 0,
/// ALIGN [5:5]
/// ALIGN
ALIGN: u1 = 0,
/// EXTSEL [6:9]
/// EXTSEL
EXTSEL: u4 = 0,
/// EXTEN [10:11]
/// EXTEN
EXTEN: u2 = 0,
/// OVRMOD [12:12]
/// OVRMOD
OVRMOD: u1 = 0,
/// CONT [13:13]
/// CONT
CONT: u1 = 0,
/// AUTDLY [14:14]
/// AUTDLY
AUTDLY: u1 = 0,
/// AUTOFF [15:15]
/// AUTOFF
AUTOFF: u1 = 0,
/// DISCEN [16:16]
/// DISCEN
DISCEN: u1 = 0,
/// DISCNUM [17:19]
/// DISCNUM
DISCNUM: u3 = 0,
/// JDISCEN [20:20]
/// JDISCEN
JDISCEN: u1 = 0,
/// JQM [21:21]
/// JQM
JQM: u1 = 0,
/// AWD1SGL [22:22]
/// AWD1SGL
AWD1SGL: u1 = 0,
/// AWD1EN [23:23]
/// AWD1EN
AWD1EN: u1 = 0,
/// JAWD1EN [24:24]
/// JAWD1EN
JAWD1EN: u1 = 0,
/// JAUTO [25:25]
/// JAUTO
JAUTO: u1 = 0,
/// AWDCH1CH [26:30]
/// AWDCH1CH
AWDCH1CH: u5 = 0,
/// unused [31:31]
_unused31: u1 = 0,
};
/// configuration register
pub const CFGR = Register(CFGR_val).init(base_address + 0xc);

/// CFGR2
const CFGR2_val = packed struct {
/// ROVSE [0:0]
/// DMAEN
ROVSE: u1 = 0,
/// JOVSE [1:1]
/// DMACFG
JOVSE: u1 = 0,
/// OVSR [2:4]
/// RES
OVSR: u3 = 0,
/// OVSS [5:8]
/// ALIGN
OVSS: u4 = 0,
/// TOVS [9:9]
/// EXTSEL
TOVS: u1 = 0,
/// ROVSM [10:10]
/// EXTEN
ROVSM: u1 = 0,
/// unused [11:31]
_unused11: u5 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// configuration register
pub const CFGR2 = Register(CFGR2_val).init(base_address + 0x10);

/// SMPR1
const SMPR1_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// SMP1 [3:5]
/// SMP1
SMP1: u3 = 0,
/// SMP2 [6:8]
/// SMP2
SMP2: u3 = 0,
/// SMP3 [9:11]
/// SMP3
SMP3: u3 = 0,
/// SMP4 [12:14]
/// SMP4
SMP4: u3 = 0,
/// SMP5 [15:17]
/// SMP5
SMP5: u3 = 0,
/// SMP6 [18:20]
/// SMP6
SMP6: u3 = 0,
/// SMP7 [21:23]
/// SMP7
SMP7: u3 = 0,
/// SMP8 [24:26]
/// SMP8
SMP8: u3 = 0,
/// SMP9 [27:29]
/// SMP9
SMP9: u3 = 0,
/// unused [30:31]
_unused30: u2 = 0,
};
/// sample time register 1
pub const SMPR1 = Register(SMPR1_val).init(base_address + 0x14);

/// SMPR2
const SMPR2_val = packed struct {
/// SMP10 [0:2]
/// SMP10
SMP10: u3 = 0,
/// SMP11 [3:5]
/// SMP11
SMP11: u3 = 0,
/// SMP12 [6:8]
/// SMP12
SMP12: u3 = 0,
/// SMP13 [9:11]
/// SMP13
SMP13: u3 = 0,
/// SMP14 [12:14]
/// SMP14
SMP14: u3 = 0,
/// SMP15 [15:17]
/// SMP15
SMP15: u3 = 0,
/// SMP16 [18:20]
/// SMP16
SMP16: u3 = 0,
/// SMP17 [21:23]
/// SMP17
SMP17: u3 = 0,
/// SMP18 [24:26]
/// SMP18
SMP18: u3 = 0,
/// unused [27:31]
_unused27: u5 = 0,
};
/// sample time register 2
pub const SMPR2 = Register(SMPR2_val).init(base_address + 0x18);

/// TR1
const TR1_val = packed struct {
/// LT1 [0:11]
/// LT1
LT1: u12 = 0,
/// unused [12:15]
_unused12: u4 = 0,
/// HT1 [16:27]
/// HT1
HT1: u12 = 4095,
/// unused [28:31]
_unused28: u4 = 0,
};
/// watchdog threshold register 1
pub const TR1 = Register(TR1_val).init(base_address + 0x20);

/// TR2
const TR2_val = packed struct {
/// LT2 [0:7]
/// LT2
LT2: u8 = 0,
/// unused [8:15]
_unused8: u8 = 0,
/// HT2 [16:23]
/// HT2
HT2: u8 = 255,
/// unused [24:31]
_unused24: u8 = 15,
};
/// watchdog threshold register
pub const TR2 = Register(TR2_val).init(base_address + 0x24);

/// TR3
const TR3_val = packed struct {
/// LT3 [0:7]
/// LT3
LT3: u8 = 0,
/// unused [8:15]
_unused8: u8 = 0,
/// HT3 [16:23]
/// HT3
HT3: u8 = 255,
/// unused [24:31]
_unused24: u8 = 15,
};
/// watchdog threshold register 3
pub const TR3 = Register(TR3_val).init(base_address + 0x28);

/// SQR1
const SQR1_val = packed struct {
/// L3 [0:3]
/// L3
L3: u4 = 0,
/// unused [4:5]
_unused4: u2 = 0,
/// SQ1 [6:10]
/// SQ1
SQ1: u5 = 0,
/// unused [11:11]
_unused11: u1 = 0,
/// SQ2 [12:16]
/// SQ2
SQ2: u5 = 0,
/// unused [17:17]
_unused17: u1 = 0,
/// SQ3 [18:22]
/// SQ3
SQ3: u5 = 0,
/// unused [23:23]
_unused23: u1 = 0,
/// SQ4 [24:28]
/// SQ4
SQ4: u5 = 0,
/// unused [29:31]
_unused29: u3 = 0,
};
/// regular sequence register 1
pub const SQR1 = Register(SQR1_val).init(base_address + 0x30);

/// SQR2
const SQR2_val = packed struct {
/// SQ5 [0:4]
/// SQ5
SQ5: u5 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// SQ6 [6:10]
/// SQ6
SQ6: u5 = 0,
/// unused [11:11]
_unused11: u1 = 0,
/// SQ7 [12:16]
/// SQ7
SQ7: u5 = 0,
/// unused [17:17]
_unused17: u1 = 0,
/// SQ8 [18:22]
/// SQ8
SQ8: u5 = 0,
/// unused [23:23]
_unused23: u1 = 0,
/// SQ9 [24:28]
/// SQ9
SQ9: u5 = 0,
/// unused [29:31]
_unused29: u3 = 0,
};
/// regular sequence register 2
pub const SQR2 = Register(SQR2_val).init(base_address + 0x34);

/// SQR3
const SQR3_val = packed struct {
/// SQ10 [0:4]
/// SQ10
SQ10: u5 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// SQ11 [6:10]
/// SQ11
SQ11: u5 = 0,
/// unused [11:11]
_unused11: u1 = 0,
/// SQ12 [12:16]
/// SQ12
SQ12: u5 = 0,
/// unused [17:17]
_unused17: u1 = 0,
/// SQ13 [18:22]
/// SQ13
SQ13: u5 = 0,
/// unused [23:23]
_unused23: u1 = 0,
/// SQ14 [24:28]
/// SQ14
SQ14: u5 = 0,
/// unused [29:31]
_unused29: u3 = 0,
};
/// regular sequence register 3
pub const SQR3 = Register(SQR3_val).init(base_address + 0x38);

/// SQR4
const SQR4_val = packed struct {
/// SQ15 [0:4]
/// SQ15
SQ15: u5 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// SQ16 [6:10]
/// SQ16
SQ16: u5 = 0,
/// unused [11:31]
_unused11: u5 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// regular sequence register 4
pub const SQR4 = Register(SQR4_val).init(base_address + 0x3c);

/// DR
const DR_val = packed struct {
/// regularDATA [0:15]
/// regularDATA
regularDATA: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// regular Data Register
pub const DR = Register(DR_val).init(base_address + 0x40);

/// JSQR
const JSQR_val = packed struct {
/// JL [0:1]
/// JL
JL: u2 = 0,
/// JEXTSEL [2:5]
/// JEXTSEL
JEXTSEL: u4 = 0,
/// JEXTEN [6:7]
/// JEXTEN
JEXTEN: u2 = 0,
/// JSQ1 [8:12]
/// JSQ1
JSQ1: u5 = 0,
/// unused [13:13]
_unused13: u1 = 0,
/// JSQ2 [14:18]
/// JSQ2
JSQ2: u5 = 0,
/// unused [19:19]
_unused19: u1 = 0,
/// JSQ3 [20:24]
/// JSQ3
JSQ3: u5 = 0,
/// unused [25:25]
_unused25: u1 = 0,
/// JSQ4 [26:30]
/// JSQ4
JSQ4: u5 = 0,
/// unused [31:31]
_unused31: u1 = 0,
};
/// injected sequence register
pub const JSQR = Register(JSQR_val).init(base_address + 0x4c);

/// OFR1
const OFR1_val = packed struct {
/// OFFSET1 [0:11]
/// OFFSET1
OFFSET1: u12 = 0,
/// unused [12:25]
_unused12: u4 = 0,
_unused16: u8 = 0,
_unused24: u2 = 0,
/// OFFSET1_CH [26:30]
/// OFFSET1_CH
OFFSET1_CH: u5 = 0,
/// OFFSET1_EN [31:31]
/// OFFSET1_EN
OFFSET1_EN: u1 = 0,
};
/// offset register 1
pub const OFR1 = Register(OFR1_val).init(base_address + 0x60);

/// OFR2
const OFR2_val = packed struct {
/// OFFSET2 [0:11]
/// OFFSET2
OFFSET2: u12 = 0,
/// unused [12:25]
_unused12: u4 = 0,
_unused16: u8 = 0,
_unused24: u2 = 0,
/// OFFSET2_CH [26:30]
/// OFFSET2_CH
OFFSET2_CH: u5 = 0,
/// OFFSET2_EN [31:31]
/// OFFSET2_EN
OFFSET2_EN: u1 = 0,
};
/// offset register 2
pub const OFR2 = Register(OFR2_val).init(base_address + 0x64);

/// OFR3
const OFR3_val = packed struct {
/// OFFSET3 [0:11]
/// OFFSET3
OFFSET3: u12 = 0,
/// unused [12:25]
_unused12: u4 = 0,
_unused16: u8 = 0,
_unused24: u2 = 0,
/// OFFSET3_CH [26:30]
/// OFFSET3_CH
OFFSET3_CH: u5 = 0,
/// OFFSET3_EN [31:31]
/// OFFSET3_EN
OFFSET3_EN: u1 = 0,
};
/// offset register 3
pub const OFR3 = Register(OFR3_val).init(base_address + 0x68);

/// OFR4
const OFR4_val = packed struct {
/// OFFSET4 [0:11]
/// OFFSET4
OFFSET4: u12 = 0,
/// unused [12:25]
_unused12: u4 = 0,
_unused16: u8 = 0,
_unused24: u2 = 0,
/// OFFSET4_CH [26:30]
/// OFFSET4_CH
OFFSET4_CH: u5 = 0,
/// OFFSET4_EN [31:31]
/// OFFSET4_EN
OFFSET4_EN: u1 = 0,
};
/// offset register 4
pub const OFR4 = Register(OFR4_val).init(base_address + 0x6c);

/// JDR1
const JDR1_val = packed struct {
/// JDATA1 [0:15]
/// JDATA1
JDATA1: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// injected data register 1
pub const JDR1 = Register(JDR1_val).init(base_address + 0x80);

/// JDR2
const JDR2_val = packed struct {
/// JDATA2 [0:15]
/// JDATA2
JDATA2: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// injected data register 2
pub const JDR2 = Register(JDR2_val).init(base_address + 0x84);

/// JDR3
const JDR3_val = packed struct {
/// JDATA3 [0:15]
/// JDATA3
JDATA3: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// injected data register 3
pub const JDR3 = Register(JDR3_val).init(base_address + 0x88);

/// JDR4
const JDR4_val = packed struct {
/// JDATA4 [0:15]
/// JDATA4
JDATA4: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// injected data register 4
pub const JDR4 = Register(JDR4_val).init(base_address + 0x8c);

/// AWD2CR
const AWD2CR_val = packed struct {
/// unused [0:0]
_unused0: u1 = 0,
/// AWD2CH [1:18]
/// AWD2CH
AWD2CH: u18 = 0,
/// unused [19:31]
_unused19: u5 = 0,
_unused24: u8 = 0,
};
/// Analog Watchdog 2 Configuration
pub const AWD2CR = Register(AWD2CR_val).init(base_address + 0xa0);

/// AWD3CR
const AWD3CR_val = packed struct {
/// unused [0:0]
_unused0: u1 = 0,
/// AWD3CH [1:18]
/// AWD3CH
AWD3CH: u18 = 0,
/// unused [19:31]
_unused19: u5 = 0,
_unused24: u8 = 0,
};
/// Analog Watchdog 3 Configuration
pub const AWD3CR = Register(AWD3CR_val).init(base_address + 0xa4);

/// DIFSEL
const DIFSEL_val = packed struct {
/// unused [0:0]
_unused0: u1 = 0,
/// DIFSEL_1_15 [1:15]
/// Differential mode for channels 15 to
DIFSEL_1_15: u15 = 0,
/// DIFSEL_16_18 [16:18]
/// Differential mode for channels 18 to
DIFSEL_16_18: u3 = 0,
/// unused [19:31]
_unused19: u5 = 0,
_unused24: u8 = 0,
};
/// Differential Mode Selection Register
pub const DIFSEL = Register(DIFSEL_val).init(base_address + 0xb0);

/// CALFACT
const CALFACT_val = packed struct {
/// CALFACT_S [0:6]
/// CALFACT_S
CALFACT_S: u7 = 0,
/// unused [7:15]
_unused7: u1 = 0,
_unused8: u8 = 0,
/// CALFACT_D [16:22]
/// CALFACT_D
CALFACT_D: u7 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// Calibration Factors
pub const CALFACT = Register(CALFACT_val).init(base_address + 0xb4);
};

/// General-purpose I/Os
pub const GPIOA = struct {

const base_address = 0x48000000;
/// MODER
const MODER_val = packed struct {
/// MODER0 [0:1]
/// Port x configuration bits (y =
MODER0: u2 = 0,
/// MODER1 [2:3]
/// Port x configuration bits (y =
MODER1: u2 = 0,
/// MODER2 [4:5]
/// Port x configuration bits (y =
MODER2: u2 = 0,
/// MODER3 [6:7]
/// Port x configuration bits (y =
MODER3: u2 = 0,
/// MODER4 [8:9]
/// Port x configuration bits (y =
MODER4: u2 = 0,
/// MODER5 [10:11]
/// Port x configuration bits (y =
MODER5: u2 = 0,
/// MODER6 [12:13]
/// Port x configuration bits (y =
MODER6: u2 = 0,
/// MODER7 [14:15]
/// Port x configuration bits (y =
MODER7: u2 = 0,
/// MODER8 [16:17]
/// Port x configuration bits (y =
MODER8: u2 = 0,
/// MODER9 [18:19]
/// Port x configuration bits (y =
MODER9: u2 = 0,
/// MODER10 [20:21]
/// Port x configuration bits (y =
MODER10: u2 = 0,
/// MODER11 [22:23]
/// Port x configuration bits (y =
MODER11: u2 = 0,
/// MODER12 [24:25]
/// Port x configuration bits (y =
MODER12: u2 = 0,
/// MODER13 [26:27]
/// Port x configuration bits (y =
MODER13: u2 = 2,
/// MODER14 [28:29]
/// Port x configuration bits (y =
MODER14: u2 = 2,
/// MODER15 [30:31]
/// Port x configuration bits (y =
MODER15: u2 = 2,
};
/// GPIO port mode register
pub const MODER = Register(MODER_val).init(base_address + 0x0);

/// OTYPER
const OTYPER_val = packed struct {
/// OT0 [0:0]
/// Port x configuration bits (y =
OT0: u1 = 0,
/// OT1 [1:1]
/// Port x configuration bits (y =
OT1: u1 = 0,
/// OT2 [2:2]
/// Port x configuration bits (y =
OT2: u1 = 0,
/// OT3 [3:3]
/// Port x configuration bits (y =
OT3: u1 = 0,
/// OT4 [4:4]
/// Port x configuration bits (y =
OT4: u1 = 0,
/// OT5 [5:5]
/// Port x configuration bits (y =
OT5: u1 = 0,
/// OT6 [6:6]
/// Port x configuration bits (y =
OT6: u1 = 0,
/// OT7 [7:7]
/// Port x configuration bits (y =
OT7: u1 = 0,
/// OT8 [8:8]
/// Port x configuration bits (y =
OT8: u1 = 0,
/// OT9 [9:9]
/// Port x configuration bits (y =
OT9: u1 = 0,
/// OT10 [10:10]
/// Port x configuration bits (y =
OT10: u1 = 0,
/// OT11 [11:11]
/// Port x configuration bits (y =
OT11: u1 = 0,
/// OT12 [12:12]
/// Port x configuration bits (y =
OT12: u1 = 0,
/// OT13 [13:13]
/// Port x configuration bits (y =
OT13: u1 = 0,
/// OT14 [14:14]
/// Port x configuration bits (y =
OT14: u1 = 0,
/// OT15 [15:15]
/// Port x configuration bits (y =
OT15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port output type register
pub const OTYPER = Register(OTYPER_val).init(base_address + 0x4);

/// OSPEEDR
const OSPEEDR_val = packed struct {
/// OSPEEDR0 [0:1]
/// Port x configuration bits (y =
OSPEEDR0: u2 = 0,
/// OSPEEDR1 [2:3]
/// Port x configuration bits (y =
OSPEEDR1: u2 = 0,
/// OSPEEDR2 [4:5]
/// Port x configuration bits (y =
OSPEEDR2: u2 = 0,
/// OSPEEDR3 [6:7]
/// Port x configuration bits (y =
OSPEEDR3: u2 = 0,
/// OSPEEDR4 [8:9]
/// Port x configuration bits (y =
OSPEEDR4: u2 = 0,
/// OSPEEDR5 [10:11]
/// Port x configuration bits (y =
OSPEEDR5: u2 = 0,
/// OSPEEDR6 [12:13]
/// Port x configuration bits (y =
OSPEEDR6: u2 = 0,
/// OSPEEDR7 [14:15]
/// Port x configuration bits (y =
OSPEEDR7: u2 = 0,
/// OSPEEDR8 [16:17]
/// Port x configuration bits (y =
OSPEEDR8: u2 = 0,
/// OSPEEDR9 [18:19]
/// Port x configuration bits (y =
OSPEEDR9: u2 = 0,
/// OSPEEDR10 [20:21]
/// Port x configuration bits (y =
OSPEEDR10: u2 = 0,
/// OSPEEDR11 [22:23]
/// Port x configuration bits (y =
OSPEEDR11: u2 = 0,
/// OSPEEDR12 [24:25]
/// Port x configuration bits (y =
OSPEEDR12: u2 = 0,
/// OSPEEDR13 [26:27]
/// Port x configuration bits (y =
OSPEEDR13: u2 = 0,
/// OSPEEDR14 [28:29]
/// Port x configuration bits (y =
OSPEEDR14: u2 = 0,
/// OSPEEDR15 [30:31]
/// Port x configuration bits (y =
OSPEEDR15: u2 = 0,
};
/// GPIO port output speed
pub const OSPEEDR = Register(OSPEEDR_val).init(base_address + 0x8);

/// PUPDR
const PUPDR_val = packed struct {
/// PUPDR0 [0:1]
/// Port x configuration bits (y =
PUPDR0: u2 = 0,
/// PUPDR1 [2:3]
/// Port x configuration bits (y =
PUPDR1: u2 = 0,
/// PUPDR2 [4:5]
/// Port x configuration bits (y =
PUPDR2: u2 = 0,
/// PUPDR3 [6:7]
/// Port x configuration bits (y =
PUPDR3: u2 = 0,
/// PUPDR4 [8:9]
/// Port x configuration bits (y =
PUPDR4: u2 = 0,
/// PUPDR5 [10:11]
/// Port x configuration bits (y =
PUPDR5: u2 = 0,
/// PUPDR6 [12:13]
/// Port x configuration bits (y =
PUPDR6: u2 = 0,
/// PUPDR7 [14:15]
/// Port x configuration bits (y =
PUPDR7: u2 = 0,
/// PUPDR8 [16:17]
/// Port x configuration bits (y =
PUPDR8: u2 = 0,
/// PUPDR9 [18:19]
/// Port x configuration bits (y =
PUPDR9: u2 = 0,
/// PUPDR10 [20:21]
/// Port x configuration bits (y =
PUPDR10: u2 = 0,
/// PUPDR11 [22:23]
/// Port x configuration bits (y =
PUPDR11: u2 = 0,
/// PUPDR12 [24:25]
/// Port x configuration bits (y =
PUPDR12: u2 = 0,
/// PUPDR13 [26:27]
/// Port x configuration bits (y =
PUPDR13: u2 = 1,
/// PUPDR14 [28:29]
/// Port x configuration bits (y =
PUPDR14: u2 = 2,
/// PUPDR15 [30:31]
/// Port x configuration bits (y =
PUPDR15: u2 = 1,
};
/// GPIO port pull-up/pull-down
pub const PUPDR = Register(PUPDR_val).init(base_address + 0xc);

/// IDR
const IDR_val = packed struct {
/// IDR0 [0:0]
/// Port input data (y =
IDR0: u1 = 0,
/// IDR1 [1:1]
/// Port input data (y =
IDR1: u1 = 0,
/// IDR2 [2:2]
/// Port input data (y =
IDR2: u1 = 0,
/// IDR3 [3:3]
/// Port input data (y =
IDR3: u1 = 0,
/// IDR4 [4:4]
/// Port input data (y =
IDR4: u1 = 0,
/// IDR5 [5:5]
/// Port input data (y =
IDR5: u1 = 0,
/// IDR6 [6:6]
/// Port input data (y =
IDR6: u1 = 0,
/// IDR7 [7:7]
/// Port input data (y =
IDR7: u1 = 0,
/// IDR8 [8:8]
/// Port input data (y =
IDR8: u1 = 0,
/// IDR9 [9:9]
/// Port input data (y =
IDR9: u1 = 0,
/// IDR10 [10:10]
/// Port input data (y =
IDR10: u1 = 0,
/// IDR11 [11:11]
/// Port input data (y =
IDR11: u1 = 0,
/// IDR12 [12:12]
/// Port input data (y =
IDR12: u1 = 0,
/// IDR13 [13:13]
/// Port input data (y =
IDR13: u1 = 0,
/// IDR14 [14:14]
/// Port input data (y =
IDR14: u1 = 0,
/// IDR15 [15:15]
/// Port input data (y =
IDR15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port input data register
pub const IDR = Register(IDR_val).init(base_address + 0x10);

/// ODR
const ODR_val = packed struct {
/// ODR0 [0:0]
/// Port output data (y =
ODR0: u1 = 0,
/// ODR1 [1:1]
/// Port output data (y =
ODR1: u1 = 0,
/// ODR2 [2:2]
/// Port output data (y =
ODR2: u1 = 0,
/// ODR3 [3:3]
/// Port output data (y =
ODR3: u1 = 0,
/// ODR4 [4:4]
/// Port output data (y =
ODR4: u1 = 0,
/// ODR5 [5:5]
/// Port output data (y =
ODR5: u1 = 0,
/// ODR6 [6:6]
/// Port output data (y =
ODR6: u1 = 0,
/// ODR7 [7:7]
/// Port output data (y =
ODR7: u1 = 0,
/// ODR8 [8:8]
/// Port output data (y =
ODR8: u1 = 0,
/// ODR9 [9:9]
/// Port output data (y =
ODR9: u1 = 0,
/// ODR10 [10:10]
/// Port output data (y =
ODR10: u1 = 0,
/// ODR11 [11:11]
/// Port output data (y =
ODR11: u1 = 0,
/// ODR12 [12:12]
/// Port output data (y =
ODR12: u1 = 0,
/// ODR13 [13:13]
/// Port output data (y =
ODR13: u1 = 0,
/// ODR14 [14:14]
/// Port output data (y =
ODR14: u1 = 0,
/// ODR15 [15:15]
/// Port output data (y =
ODR15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port output data register
pub const ODR = Register(ODR_val).init(base_address + 0x14);

/// BSRR
const BSRR_val = packed struct {
/// BS0 [0:0]
/// Port x set bit y (y=
BS0: u1 = 0,
/// BS1 [1:1]
/// Port x set bit y (y=
BS1: u1 = 0,
/// BS2 [2:2]
/// Port x set bit y (y=
BS2: u1 = 0,
/// BS3 [3:3]
/// Port x set bit y (y=
BS3: u1 = 0,
/// BS4 [4:4]
/// Port x set bit y (y=
BS4: u1 = 0,
/// BS5 [5:5]
/// Port x set bit y (y=
BS5: u1 = 0,
/// BS6 [6:6]
/// Port x set bit y (y=
BS6: u1 = 0,
/// BS7 [7:7]
/// Port x set bit y (y=
BS7: u1 = 0,
/// BS8 [8:8]
/// Port x set bit y (y=
BS8: u1 = 0,
/// BS9 [9:9]
/// Port x set bit y (y=
BS9: u1 = 0,
/// BS10 [10:10]
/// Port x set bit y (y=
BS10: u1 = 0,
/// BS11 [11:11]
/// Port x set bit y (y=
BS11: u1 = 0,
/// BS12 [12:12]
/// Port x set bit y (y=
BS12: u1 = 0,
/// BS13 [13:13]
/// Port x set bit y (y=
BS13: u1 = 0,
/// BS14 [14:14]
/// Port x set bit y (y=
BS14: u1 = 0,
/// BS15 [15:15]
/// Port x set bit y (y=
BS15: u1 = 0,
/// BR0 [16:16]
/// Port x set bit y (y=
BR0: u1 = 0,
/// BR1 [17:17]
/// Port x reset bit y (y =
BR1: u1 = 0,
/// BR2 [18:18]
/// Port x reset bit y (y =
BR2: u1 = 0,
/// BR3 [19:19]
/// Port x reset bit y (y =
BR3: u1 = 0,
/// BR4 [20:20]
/// Port x reset bit y (y =
BR4: u1 = 0,
/// BR5 [21:21]
/// Port x reset bit y (y =
BR5: u1 = 0,
/// BR6 [22:22]
/// Port x reset bit y (y =
BR6: u1 = 0,
/// BR7 [23:23]
/// Port x reset bit y (y =
BR7: u1 = 0,
/// BR8 [24:24]
/// Port x reset bit y (y =
BR8: u1 = 0,
/// BR9 [25:25]
/// Port x reset bit y (y =
BR9: u1 = 0,
/// BR10 [26:26]
/// Port x reset bit y (y =
BR10: u1 = 0,
/// BR11 [27:27]
/// Port x reset bit y (y =
BR11: u1 = 0,
/// BR12 [28:28]
/// Port x reset bit y (y =
BR12: u1 = 0,
/// BR13 [29:29]
/// Port x reset bit y (y =
BR13: u1 = 0,
/// BR14 [30:30]
/// Port x reset bit y (y =
BR14: u1 = 0,
/// BR15 [31:31]
/// Port x reset bit y (y =
BR15: u1 = 0,
};
/// GPIO port bit set/reset
pub const BSRR = Register(BSRR_val).init(base_address + 0x18);

/// LCKR
const LCKR_val = packed struct {
/// LCK0 [0:0]
/// Port x lock bit y (y=
LCK0: u1 = 0,
/// LCK1 [1:1]
/// Port x lock bit y (y=
LCK1: u1 = 0,
/// LCK2 [2:2]
/// Port x lock bit y (y=
LCK2: u1 = 0,
/// LCK3 [3:3]
/// Port x lock bit y (y=
LCK3: u1 = 0,
/// LCK4 [4:4]
/// Port x lock bit y (y=
LCK4: u1 = 0,
/// LCK5 [5:5]
/// Port x lock bit y (y=
LCK5: u1 = 0,
/// LCK6 [6:6]
/// Port x lock bit y (y=
LCK6: u1 = 0,
/// LCK7 [7:7]
/// Port x lock bit y (y=
LCK7: u1 = 0,
/// LCK8 [8:8]
/// Port x lock bit y (y=
LCK8: u1 = 0,
/// LCK9 [9:9]
/// Port x lock bit y (y=
LCK9: u1 = 0,
/// LCK10 [10:10]
/// Port x lock bit y (y=
LCK10: u1 = 0,
/// LCK11 [11:11]
/// Port x lock bit y (y=
LCK11: u1 = 0,
/// LCK12 [12:12]
/// Port x lock bit y (y=
LCK12: u1 = 0,
/// LCK13 [13:13]
/// Port x lock bit y (y=
LCK13: u1 = 0,
/// LCK14 [14:14]
/// Port x lock bit y (y=
LCK14: u1 = 0,
/// LCK15 [15:15]
/// Port x lock bit y (y=
LCK15: u1 = 0,
/// LCKK [16:16]
/// Port x lock bit y (y=
LCKK: u1 = 0,
/// unused [17:31]
_unused17: u7 = 0,
_unused24: u8 = 0,
};
/// GPIO port configuration lock
pub const LCKR = Register(LCKR_val).init(base_address + 0x1c);

/// AFRL
const AFRL_val = packed struct {
/// AFRL0 [0:3]
/// Alternate function selection for port x
AFRL0: u4 = 0,
/// AFRL1 [4:7]
/// Alternate function selection for port x
AFRL1: u4 = 0,
/// AFRL2 [8:11]
/// Alternate function selection for port x
AFRL2: u4 = 0,
/// AFRL3 [12:15]
/// Alternate function selection for port x
AFRL3: u4 = 0,
/// AFRL4 [16:19]
/// Alternate function selection for port x
AFRL4: u4 = 0,
/// AFRL5 [20:23]
/// Alternate function selection for port x
AFRL5: u4 = 0,
/// AFRL6 [24:27]
/// Alternate function selection for port x
AFRL6: u4 = 0,
/// AFRL7 [28:31]
/// Alternate function selection for port x
AFRL7: u4 = 0,
};
/// GPIO alternate function low
pub const AFRL = Register(AFRL_val).init(base_address + 0x20);

/// AFRH
const AFRH_val = packed struct {
/// AFRH8 [0:3]
/// Alternate function selection for port x
AFRH8: u4 = 0,
/// AFRH9 [4:7]
/// Alternate function selection for port x
AFRH9: u4 = 0,
/// AFRH10 [8:11]
/// Alternate function selection for port x
AFRH10: u4 = 0,
/// AFRH11 [12:15]
/// Alternate function selection for port x
AFRH11: u4 = 0,
/// AFRH12 [16:19]
/// Alternate function selection for port x
AFRH12: u4 = 0,
/// AFRH13 [20:23]
/// Alternate function selection for port x
AFRH13: u4 = 0,
/// AFRH14 [24:27]
/// Alternate function selection for port x
AFRH14: u4 = 0,
/// AFRH15 [28:31]
/// Alternate function selection for port x
AFRH15: u4 = 0,
};
/// GPIO alternate function high
pub const AFRH = Register(AFRH_val).init(base_address + 0x24);
};

/// General-purpose I/Os
pub const GPIOB = struct {

const base_address = 0x48000400;
/// MODER
const MODER_val = packed struct {
/// MODER0 [0:1]
/// Port x configuration bits (y =
MODER0: u2 = 0,
/// MODER1 [2:3]
/// Port x configuration bits (y =
MODER1: u2 = 0,
/// MODER2 [4:5]
/// Port x configuration bits (y =
MODER2: u2 = 0,
/// MODER3 [6:7]
/// Port x configuration bits (y =
MODER3: u2 = 2,
/// MODER4 [8:9]
/// Port x configuration bits (y =
MODER4: u2 = 2,
/// MODER5 [10:11]
/// Port x configuration bits (y =
MODER5: u2 = 0,
/// MODER6 [12:13]
/// Port x configuration bits (y =
MODER6: u2 = 0,
/// MODER7 [14:15]
/// Port x configuration bits (y =
MODER7: u2 = 0,
/// MODER8 [16:17]
/// Port x configuration bits (y =
MODER8: u2 = 0,
/// MODER9 [18:19]
/// Port x configuration bits (y =
MODER9: u2 = 0,
/// MODER10 [20:21]
/// Port x configuration bits (y =
MODER10: u2 = 0,
/// MODER11 [22:23]
/// Port x configuration bits (y =
MODER11: u2 = 0,
/// MODER12 [24:25]
/// Port x configuration bits (y =
MODER12: u2 = 0,
/// MODER13 [26:27]
/// Port x configuration bits (y =
MODER13: u2 = 0,
/// MODER14 [28:29]
/// Port x configuration bits (y =
MODER14: u2 = 0,
/// MODER15 [30:31]
/// Port x configuration bits (y =
MODER15: u2 = 0,
};
/// GPIO port mode register
pub const MODER = Register(MODER_val).init(base_address + 0x0);

/// OTYPER
const OTYPER_val = packed struct {
/// OT0 [0:0]
/// Port x configuration bits (y =
OT0: u1 = 0,
/// OT1 [1:1]
/// Port x configuration bits (y =
OT1: u1 = 0,
/// OT2 [2:2]
/// Port x configuration bits (y =
OT2: u1 = 0,
/// OT3 [3:3]
/// Port x configuration bits (y =
OT3: u1 = 0,
/// OT4 [4:4]
/// Port x configuration bits (y =
OT4: u1 = 0,
/// OT5 [5:5]
/// Port x configuration bits (y =
OT5: u1 = 0,
/// OT6 [6:6]
/// Port x configuration bits (y =
OT6: u1 = 0,
/// OT7 [7:7]
/// Port x configuration bits (y =
OT7: u1 = 0,
/// OT8 [8:8]
/// Port x configuration bits (y =
OT8: u1 = 0,
/// OT9 [9:9]
/// Port x configuration bits (y =
OT9: u1 = 0,
/// OT10 [10:10]
/// Port x configuration bits (y =
OT10: u1 = 0,
/// OT11 [11:11]
/// Port x configuration bits (y =
OT11: u1 = 0,
/// OT12 [12:12]
/// Port x configuration bits (y =
OT12: u1 = 0,
/// OT13 [13:13]
/// Port x configuration bits (y =
OT13: u1 = 0,
/// OT14 [14:14]
/// Port x configuration bits (y =
OT14: u1 = 0,
/// OT15 [15:15]
/// Port x configuration bits (y =
OT15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port output type register
pub const OTYPER = Register(OTYPER_val).init(base_address + 0x4);

/// OSPEEDR
const OSPEEDR_val = packed struct {
/// OSPEEDR0 [0:1]
/// Port x configuration bits (y =
OSPEEDR0: u2 = 0,
/// OSPEEDR1 [2:3]
/// Port x configuration bits (y =
OSPEEDR1: u2 = 0,
/// OSPEEDR2 [4:5]
/// Port x configuration bits (y =
OSPEEDR2: u2 = 0,
/// OSPEEDR3 [6:7]
/// Port x configuration bits (y =
OSPEEDR3: u2 = 3,
/// OSPEEDR4 [8:9]
/// Port x configuration bits (y =
OSPEEDR4: u2 = 0,
/// OSPEEDR5 [10:11]
/// Port x configuration bits (y =
OSPEEDR5: u2 = 0,
/// OSPEEDR6 [12:13]
/// Port x configuration bits (y =
OSPEEDR6: u2 = 0,
/// OSPEEDR7 [14:15]
/// Port x configuration bits (y =
OSPEEDR7: u2 = 0,
/// OSPEEDR8 [16:17]
/// Port x configuration bits (y =
OSPEEDR8: u2 = 0,
/// OSPEEDR9 [18:19]
/// Port x configuration bits (y =
OSPEEDR9: u2 = 0,
/// OSPEEDR10 [20:21]
/// Port x configuration bits (y =
OSPEEDR10: u2 = 0,
/// OSPEEDR11 [22:23]
/// Port x configuration bits (y =
OSPEEDR11: u2 = 0,
/// OSPEEDR12 [24:25]
/// Port x configuration bits (y =
OSPEEDR12: u2 = 0,
/// OSPEEDR13 [26:27]
/// Port x configuration bits (y =
OSPEEDR13: u2 = 0,
/// OSPEEDR14 [28:29]
/// Port x configuration bits (y =
OSPEEDR14: u2 = 0,
/// OSPEEDR15 [30:31]
/// Port x configuration bits (y =
OSPEEDR15: u2 = 0,
};
/// GPIO port output speed
pub const OSPEEDR = Register(OSPEEDR_val).init(base_address + 0x8);

/// PUPDR
const PUPDR_val = packed struct {
/// PUPDR0 [0:1]
/// Port x configuration bits (y =
PUPDR0: u2 = 0,
/// PUPDR1 [2:3]
/// Port x configuration bits (y =
PUPDR1: u2 = 0,
/// PUPDR2 [4:5]
/// Port x configuration bits (y =
PUPDR2: u2 = 0,
/// PUPDR3 [6:7]
/// Port x configuration bits (y =
PUPDR3: u2 = 0,
/// PUPDR4 [8:9]
/// Port x configuration bits (y =
PUPDR4: u2 = 1,
/// PUPDR5 [10:11]
/// Port x configuration bits (y =
PUPDR5: u2 = 0,
/// PUPDR6 [12:13]
/// Port x configuration bits (y =
PUPDR6: u2 = 0,
/// PUPDR7 [14:15]
/// Port x configuration bits (y =
PUPDR7: u2 = 0,
/// PUPDR8 [16:17]
/// Port x configuration bits (y =
PUPDR8: u2 = 0,
/// PUPDR9 [18:19]
/// Port x configuration bits (y =
PUPDR9: u2 = 0,
/// PUPDR10 [20:21]
/// Port x configuration bits (y =
PUPDR10: u2 = 0,
/// PUPDR11 [22:23]
/// Port x configuration bits (y =
PUPDR11: u2 = 0,
/// PUPDR12 [24:25]
/// Port x configuration bits (y =
PUPDR12: u2 = 0,
/// PUPDR13 [26:27]
/// Port x configuration bits (y =
PUPDR13: u2 = 0,
/// PUPDR14 [28:29]
/// Port x configuration bits (y =
PUPDR14: u2 = 0,
/// PUPDR15 [30:31]
/// Port x configuration bits (y =
PUPDR15: u2 = 0,
};
/// GPIO port pull-up/pull-down
pub const PUPDR = Register(PUPDR_val).init(base_address + 0xc);

/// IDR
const IDR_val = packed struct {
/// IDR0 [0:0]
/// Port input data (y =
IDR0: u1 = 0,
/// IDR1 [1:1]
/// Port input data (y =
IDR1: u1 = 0,
/// IDR2 [2:2]
/// Port input data (y =
IDR2: u1 = 0,
/// IDR3 [3:3]
/// Port input data (y =
IDR3: u1 = 0,
/// IDR4 [4:4]
/// Port input data (y =
IDR4: u1 = 0,
/// IDR5 [5:5]
/// Port input data (y =
IDR5: u1 = 0,
/// IDR6 [6:6]
/// Port input data (y =
IDR6: u1 = 0,
/// IDR7 [7:7]
/// Port input data (y =
IDR7: u1 = 0,
/// IDR8 [8:8]
/// Port input data (y =
IDR8: u1 = 0,
/// IDR9 [9:9]
/// Port input data (y =
IDR9: u1 = 0,
/// IDR10 [10:10]
/// Port input data (y =
IDR10: u1 = 0,
/// IDR11 [11:11]
/// Port input data (y =
IDR11: u1 = 0,
/// IDR12 [12:12]
/// Port input data (y =
IDR12: u1 = 0,
/// IDR13 [13:13]
/// Port input data (y =
IDR13: u1 = 0,
/// IDR14 [14:14]
/// Port input data (y =
IDR14: u1 = 0,
/// IDR15 [15:15]
/// Port input data (y =
IDR15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port input data register
pub const IDR = Register(IDR_val).init(base_address + 0x10);

/// ODR
const ODR_val = packed struct {
/// ODR0 [0:0]
/// Port output data (y =
ODR0: u1 = 0,
/// ODR1 [1:1]
/// Port output data (y =
ODR1: u1 = 0,
/// ODR2 [2:2]
/// Port output data (y =
ODR2: u1 = 0,
/// ODR3 [3:3]
/// Port output data (y =
ODR3: u1 = 0,
/// ODR4 [4:4]
/// Port output data (y =
ODR4: u1 = 0,
/// ODR5 [5:5]
/// Port output data (y =
ODR5: u1 = 0,
/// ODR6 [6:6]
/// Port output data (y =
ODR6: u1 = 0,
/// ODR7 [7:7]
/// Port output data (y =
ODR7: u1 = 0,
/// ODR8 [8:8]
/// Port output data (y =
ODR8: u1 = 0,
/// ODR9 [9:9]
/// Port output data (y =
ODR9: u1 = 0,
/// ODR10 [10:10]
/// Port output data (y =
ODR10: u1 = 0,
/// ODR11 [11:11]
/// Port output data (y =
ODR11: u1 = 0,
/// ODR12 [12:12]
/// Port output data (y =
ODR12: u1 = 0,
/// ODR13 [13:13]
/// Port output data (y =
ODR13: u1 = 0,
/// ODR14 [14:14]
/// Port output data (y =
ODR14: u1 = 0,
/// ODR15 [15:15]
/// Port output data (y =
ODR15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port output data register
pub const ODR = Register(ODR_val).init(base_address + 0x14);

/// BSRR
const BSRR_val = packed struct {
/// BS0 [0:0]
/// Port x set bit y (y=
BS0: u1 = 0,
/// BS1 [1:1]
/// Port x set bit y (y=
BS1: u1 = 0,
/// BS2 [2:2]
/// Port x set bit y (y=
BS2: u1 = 0,
/// BS3 [3:3]
/// Port x set bit y (y=
BS3: u1 = 0,
/// BS4 [4:4]
/// Port x set bit y (y=
BS4: u1 = 0,
/// BS5 [5:5]
/// Port x set bit y (y=
BS5: u1 = 0,
/// BS6 [6:6]
/// Port x set bit y (y=
BS6: u1 = 0,
/// BS7 [7:7]
/// Port x set bit y (y=
BS7: u1 = 0,
/// BS8 [8:8]
/// Port x set bit y (y=
BS8: u1 = 0,
/// BS9 [9:9]
/// Port x set bit y (y=
BS9: u1 = 0,
/// BS10 [10:10]
/// Port x set bit y (y=
BS10: u1 = 0,
/// BS11 [11:11]
/// Port x set bit y (y=
BS11: u1 = 0,
/// BS12 [12:12]
/// Port x set bit y (y=
BS12: u1 = 0,
/// BS13 [13:13]
/// Port x set bit y (y=
BS13: u1 = 0,
/// BS14 [14:14]
/// Port x set bit y (y=
BS14: u1 = 0,
/// BS15 [15:15]
/// Port x set bit y (y=
BS15: u1 = 0,
/// BR0 [16:16]
/// Port x set bit y (y=
BR0: u1 = 0,
/// BR1 [17:17]
/// Port x reset bit y (y =
BR1: u1 = 0,
/// BR2 [18:18]
/// Port x reset bit y (y =
BR2: u1 = 0,
/// BR3 [19:19]
/// Port x reset bit y (y =
BR3: u1 = 0,
/// BR4 [20:20]
/// Port x reset bit y (y =
BR4: u1 = 0,
/// BR5 [21:21]
/// Port x reset bit y (y =
BR5: u1 = 0,
/// BR6 [22:22]
/// Port x reset bit y (y =
BR6: u1 = 0,
/// BR7 [23:23]
/// Port x reset bit y (y =
BR7: u1 = 0,
/// BR8 [24:24]
/// Port x reset bit y (y =
BR8: u1 = 0,
/// BR9 [25:25]
/// Port x reset bit y (y =
BR9: u1 = 0,
/// BR10 [26:26]
/// Port x reset bit y (y =
BR10: u1 = 0,
/// BR11 [27:27]
/// Port x reset bit y (y =
BR11: u1 = 0,
/// BR12 [28:28]
/// Port x reset bit y (y =
BR12: u1 = 0,
/// BR13 [29:29]
/// Port x reset bit y (y =
BR13: u1 = 0,
/// BR14 [30:30]
/// Port x reset bit y (y =
BR14: u1 = 0,
/// BR15 [31:31]
/// Port x reset bit y (y =
BR15: u1 = 0,
};
/// GPIO port bit set/reset
pub const BSRR = Register(BSRR_val).init(base_address + 0x18);

/// LCKR
const LCKR_val = packed struct {
/// LCK0 [0:0]
/// Port x lock bit y (y=
LCK0: u1 = 0,
/// LCK1 [1:1]
/// Port x lock bit y (y=
LCK1: u1 = 0,
/// LCK2 [2:2]
/// Port x lock bit y (y=
LCK2: u1 = 0,
/// LCK3 [3:3]
/// Port x lock bit y (y=
LCK3: u1 = 0,
/// LCK4 [4:4]
/// Port x lock bit y (y=
LCK4: u1 = 0,
/// LCK5 [5:5]
/// Port x lock bit y (y=
LCK5: u1 = 0,
/// LCK6 [6:6]
/// Port x lock bit y (y=
LCK6: u1 = 0,
/// LCK7 [7:7]
/// Port x lock bit y (y=
LCK7: u1 = 0,
/// LCK8 [8:8]
/// Port x lock bit y (y=
LCK8: u1 = 0,
/// LCK9 [9:9]
/// Port x lock bit y (y=
LCK9: u1 = 0,
/// LCK10 [10:10]
/// Port x lock bit y (y=
LCK10: u1 = 0,
/// LCK11 [11:11]
/// Port x lock bit y (y=
LCK11: u1 = 0,
/// LCK12 [12:12]
/// Port x lock bit y (y=
LCK12: u1 = 0,
/// LCK13 [13:13]
/// Port x lock bit y (y=
LCK13: u1 = 0,
/// LCK14 [14:14]
/// Port x lock bit y (y=
LCK14: u1 = 0,
/// LCK15 [15:15]
/// Port x lock bit y (y=
LCK15: u1 = 0,
/// LCKK [16:16]
/// Port x lock bit y (y=
LCKK: u1 = 0,
/// unused [17:31]
_unused17: u7 = 0,
_unused24: u8 = 0,
};
/// GPIO port configuration lock
pub const LCKR = Register(LCKR_val).init(base_address + 0x1c);

/// AFRL
const AFRL_val = packed struct {
/// AFRL0 [0:3]
/// Alternate function selection for port x
AFRL0: u4 = 0,
/// AFRL1 [4:7]
/// Alternate function selection for port x
AFRL1: u4 = 0,
/// AFRL2 [8:11]
/// Alternate function selection for port x
AFRL2: u4 = 0,
/// AFRL3 [12:15]
/// Alternate function selection for port x
AFRL3: u4 = 0,
/// AFRL4 [16:19]
/// Alternate function selection for port x
AFRL4: u4 = 0,
/// AFRL5 [20:23]
/// Alternate function selection for port x
AFRL5: u4 = 0,
/// AFRL6 [24:27]
/// Alternate function selection for port x
AFRL6: u4 = 0,
/// AFRL7 [28:31]
/// Alternate function selection for port x
AFRL7: u4 = 0,
};
/// GPIO alternate function low
pub const AFRL = Register(AFRL_val).init(base_address + 0x20);

/// AFRH
const AFRH_val = packed struct {
/// AFRH8 [0:3]
/// Alternate function selection for port x
AFRH8: u4 = 0,
/// AFRH9 [4:7]
/// Alternate function selection for port x
AFRH9: u4 = 0,
/// AFRH10 [8:11]
/// Alternate function selection for port x
AFRH10: u4 = 0,
/// AFRH11 [12:15]
/// Alternate function selection for port x
AFRH11: u4 = 0,
/// AFRH12 [16:19]
/// Alternate function selection for port x
AFRH12: u4 = 0,
/// AFRH13 [20:23]
/// Alternate function selection for port x
AFRH13: u4 = 0,
/// AFRH14 [24:27]
/// Alternate function selection for port x
AFRH14: u4 = 0,
/// AFRH15 [28:31]
/// Alternate function selection for port x
AFRH15: u4 = 0,
};
/// GPIO alternate function high
pub const AFRH = Register(AFRH_val).init(base_address + 0x24);
};

/// General-purpose I/Os
pub const GPIOC = struct {

const base_address = 0x48000800;
/// MODER
const MODER_val = packed struct {
/// MODER0 [0:1]
/// Port x configuration bits (y =
MODER0: u2 = 0,
/// MODER1 [2:3]
/// Port x configuration bits (y =
MODER1: u2 = 0,
/// MODER2 [4:5]
/// Port x configuration bits (y =
MODER2: u2 = 0,
/// MODER3 [6:7]
/// Port x configuration bits (y =
MODER3: u2 = 0,
/// MODER4 [8:9]
/// Port x configuration bits (y =
MODER4: u2 = 0,
/// MODER5 [10:11]
/// Port x configuration bits (y =
MODER5: u2 = 0,
/// MODER6 [12:13]
/// Port x configuration bits (y =
MODER6: u2 = 0,
/// MODER7 [14:15]
/// Port x configuration bits (y =
MODER7: u2 = 0,
/// MODER8 [16:17]
/// Port x configuration bits (y =
MODER8: u2 = 0,
/// MODER9 [18:19]
/// Port x configuration bits (y =
MODER9: u2 = 0,
/// MODER10 [20:21]
/// Port x configuration bits (y =
MODER10: u2 = 0,
/// MODER11 [22:23]
/// Port x configuration bits (y =
MODER11: u2 = 0,
/// MODER12 [24:25]
/// Port x configuration bits (y =
MODER12: u2 = 0,
/// MODER13 [26:27]
/// Port x configuration bits (y =
MODER13: u2 = 0,
/// MODER14 [28:29]
/// Port x configuration bits (y =
MODER14: u2 = 0,
/// MODER15 [30:31]
/// Port x configuration bits (y =
MODER15: u2 = 0,
};
/// GPIO port mode register
pub const MODER = Register(MODER_val).init(base_address + 0x0);

/// OTYPER
const OTYPER_val = packed struct {
/// OT0 [0:0]
/// Port x configuration bits (y =
OT0: u1 = 0,
/// OT1 [1:1]
/// Port x configuration bits (y =
OT1: u1 = 0,
/// OT2 [2:2]
/// Port x configuration bits (y =
OT2: u1 = 0,
/// OT3 [3:3]
/// Port x configuration bits (y =
OT3: u1 = 0,
/// OT4 [4:4]
/// Port x configuration bits (y =
OT4: u1 = 0,
/// OT5 [5:5]
/// Port x configuration bits (y =
OT5: u1 = 0,
/// OT6 [6:6]
/// Port x configuration bits (y =
OT6: u1 = 0,
/// OT7 [7:7]
/// Port x configuration bits (y =
OT7: u1 = 0,
/// OT8 [8:8]
/// Port x configuration bits (y =
OT8: u1 = 0,
/// OT9 [9:9]
/// Port x configuration bits (y =
OT9: u1 = 0,
/// OT10 [10:10]
/// Port x configuration bits (y =
OT10: u1 = 0,
/// OT11 [11:11]
/// Port x configuration bits (y =
OT11: u1 = 0,
/// OT12 [12:12]
/// Port x configuration bits (y =
OT12: u1 = 0,
/// OT13 [13:13]
/// Port x configuration bits (y =
OT13: u1 = 0,
/// OT14 [14:14]
/// Port x configuration bits (y =
OT14: u1 = 0,
/// OT15 [15:15]
/// Port x configuration bits (y =
OT15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port output type register
pub const OTYPER = Register(OTYPER_val).init(base_address + 0x4);

/// OSPEEDR
const OSPEEDR_val = packed struct {
/// OSPEEDR0 [0:1]
/// Port x configuration bits (y =
OSPEEDR0: u2 = 0,
/// OSPEEDR1 [2:3]
/// Port x configuration bits (y =
OSPEEDR1: u2 = 0,
/// OSPEEDR2 [4:5]
/// Port x configuration bits (y =
OSPEEDR2: u2 = 0,
/// OSPEEDR3 [6:7]
/// Port x configuration bits (y =
OSPEEDR3: u2 = 0,
/// OSPEEDR4 [8:9]
/// Port x configuration bits (y =
OSPEEDR4: u2 = 0,
/// OSPEEDR5 [10:11]
/// Port x configuration bits (y =
OSPEEDR5: u2 = 0,
/// OSPEEDR6 [12:13]
/// Port x configuration bits (y =
OSPEEDR6: u2 = 0,
/// OSPEEDR7 [14:15]
/// Port x configuration bits (y =
OSPEEDR7: u2 = 0,
/// OSPEEDR8 [16:17]
/// Port x configuration bits (y =
OSPEEDR8: u2 = 0,
/// OSPEEDR9 [18:19]
/// Port x configuration bits (y =
OSPEEDR9: u2 = 0,
/// OSPEEDR10 [20:21]
/// Port x configuration bits (y =
OSPEEDR10: u2 = 0,
/// OSPEEDR11 [22:23]
/// Port x configuration bits (y =
OSPEEDR11: u2 = 0,
/// OSPEEDR12 [24:25]
/// Port x configuration bits (y =
OSPEEDR12: u2 = 0,
/// OSPEEDR13 [26:27]
/// Port x configuration bits (y =
OSPEEDR13: u2 = 0,
/// OSPEEDR14 [28:29]
/// Port x configuration bits (y =
OSPEEDR14: u2 = 0,
/// OSPEEDR15 [30:31]
/// Port x configuration bits (y =
OSPEEDR15: u2 = 0,
};
/// GPIO port output speed
pub const OSPEEDR = Register(OSPEEDR_val).init(base_address + 0x8);

/// PUPDR
const PUPDR_val = packed struct {
/// PUPDR0 [0:1]
/// Port x configuration bits (y =
PUPDR0: u2 = 0,
/// PUPDR1 [2:3]
/// Port x configuration bits (y =
PUPDR1: u2 = 0,
/// PUPDR2 [4:5]
/// Port x configuration bits (y =
PUPDR2: u2 = 0,
/// PUPDR3 [6:7]
/// Port x configuration bits (y =
PUPDR3: u2 = 0,
/// PUPDR4 [8:9]
/// Port x configuration bits (y =
PUPDR4: u2 = 0,
/// PUPDR5 [10:11]
/// Port x configuration bits (y =
PUPDR5: u2 = 0,
/// PUPDR6 [12:13]
/// Port x configuration bits (y =
PUPDR6: u2 = 0,
/// PUPDR7 [14:15]
/// Port x configuration bits (y =
PUPDR7: u2 = 0,
/// PUPDR8 [16:17]
/// Port x configuration bits (y =
PUPDR8: u2 = 0,
/// PUPDR9 [18:19]
/// Port x configuration bits (y =
PUPDR9: u2 = 0,
/// PUPDR10 [20:21]
/// Port x configuration bits (y =
PUPDR10: u2 = 0,
/// PUPDR11 [22:23]
/// Port x configuration bits (y =
PUPDR11: u2 = 0,
/// PUPDR12 [24:25]
/// Port x configuration bits (y =
PUPDR12: u2 = 0,
/// PUPDR13 [26:27]
/// Port x configuration bits (y =
PUPDR13: u2 = 0,
/// PUPDR14 [28:29]
/// Port x configuration bits (y =
PUPDR14: u2 = 0,
/// PUPDR15 [30:31]
/// Port x configuration bits (y =
PUPDR15: u2 = 0,
};
/// GPIO port pull-up/pull-down
pub const PUPDR = Register(PUPDR_val).init(base_address + 0xc);

/// IDR
const IDR_val = packed struct {
/// IDR0 [0:0]
/// Port input data (y =
IDR0: u1 = 0,
/// IDR1 [1:1]
/// Port input data (y =
IDR1: u1 = 0,
/// IDR2 [2:2]
/// Port input data (y =
IDR2: u1 = 0,
/// IDR3 [3:3]
/// Port input data (y =
IDR3: u1 = 0,
/// IDR4 [4:4]
/// Port input data (y =
IDR4: u1 = 0,
/// IDR5 [5:5]
/// Port input data (y =
IDR5: u1 = 0,
/// IDR6 [6:6]
/// Port input data (y =
IDR6: u1 = 0,
/// IDR7 [7:7]
/// Port input data (y =
IDR7: u1 = 0,
/// IDR8 [8:8]
/// Port input data (y =
IDR8: u1 = 0,
/// IDR9 [9:9]
/// Port input data (y =
IDR9: u1 = 0,
/// IDR10 [10:10]
/// Port input data (y =
IDR10: u1 = 0,
/// IDR11 [11:11]
/// Port input data (y =
IDR11: u1 = 0,
/// IDR12 [12:12]
/// Port input data (y =
IDR12: u1 = 0,
/// IDR13 [13:13]
/// Port input data (y =
IDR13: u1 = 0,
/// IDR14 [14:14]
/// Port input data (y =
IDR14: u1 = 0,
/// IDR15 [15:15]
/// Port input data (y =
IDR15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port input data register
pub const IDR = Register(IDR_val).init(base_address + 0x10);

/// ODR
const ODR_val = packed struct {
/// ODR0 [0:0]
/// Port output data (y =
ODR0: u1 = 0,
/// ODR1 [1:1]
/// Port output data (y =
ODR1: u1 = 0,
/// ODR2 [2:2]
/// Port output data (y =
ODR2: u1 = 0,
/// ODR3 [3:3]
/// Port output data (y =
ODR3: u1 = 0,
/// ODR4 [4:4]
/// Port output data (y =
ODR4: u1 = 0,
/// ODR5 [5:5]
/// Port output data (y =
ODR5: u1 = 0,
/// ODR6 [6:6]
/// Port output data (y =
ODR6: u1 = 0,
/// ODR7 [7:7]
/// Port output data (y =
ODR7: u1 = 0,
/// ODR8 [8:8]
/// Port output data (y =
ODR8: u1 = 0,
/// ODR9 [9:9]
/// Port output data (y =
ODR9: u1 = 0,
/// ODR10 [10:10]
/// Port output data (y =
ODR10: u1 = 0,
/// ODR11 [11:11]
/// Port output data (y =
ODR11: u1 = 0,
/// ODR12 [12:12]
/// Port output data (y =
ODR12: u1 = 0,
/// ODR13 [13:13]
/// Port output data (y =
ODR13: u1 = 0,
/// ODR14 [14:14]
/// Port output data (y =
ODR14: u1 = 0,
/// ODR15 [15:15]
/// Port output data (y =
ODR15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port output data register
pub const ODR = Register(ODR_val).init(base_address + 0x14);

/// BSRR
const BSRR_val = packed struct {
/// BS0 [0:0]
/// Port x set bit y (y=
BS0: u1 = 0,
/// BS1 [1:1]
/// Port x set bit y (y=
BS1: u1 = 0,
/// BS2 [2:2]
/// Port x set bit y (y=
BS2: u1 = 0,
/// BS3 [3:3]
/// Port x set bit y (y=
BS3: u1 = 0,
/// BS4 [4:4]
/// Port x set bit y (y=
BS4: u1 = 0,
/// BS5 [5:5]
/// Port x set bit y (y=
BS5: u1 = 0,
/// BS6 [6:6]
/// Port x set bit y (y=
BS6: u1 = 0,
/// BS7 [7:7]
/// Port x set bit y (y=
BS7: u1 = 0,
/// BS8 [8:8]
/// Port x set bit y (y=
BS8: u1 = 0,
/// BS9 [9:9]
/// Port x set bit y (y=
BS9: u1 = 0,
/// BS10 [10:10]
/// Port x set bit y (y=
BS10: u1 = 0,
/// BS11 [11:11]
/// Port x set bit y (y=
BS11: u1 = 0,
/// BS12 [12:12]
/// Port x set bit y (y=
BS12: u1 = 0,
/// BS13 [13:13]
/// Port x set bit y (y=
BS13: u1 = 0,
/// BS14 [14:14]
/// Port x set bit y (y=
BS14: u1 = 0,
/// BS15 [15:15]
/// Port x set bit y (y=
BS15: u1 = 0,
/// BR0 [16:16]
/// Port x set bit y (y=
BR0: u1 = 0,
/// BR1 [17:17]
/// Port x reset bit y (y =
BR1: u1 = 0,
/// BR2 [18:18]
/// Port x reset bit y (y =
BR2: u1 = 0,
/// BR3 [19:19]
/// Port x reset bit y (y =
BR3: u1 = 0,
/// BR4 [20:20]
/// Port x reset bit y (y =
BR4: u1 = 0,
/// BR5 [21:21]
/// Port x reset bit y (y =
BR5: u1 = 0,
/// BR6 [22:22]
/// Port x reset bit y (y =
BR6: u1 = 0,
/// BR7 [23:23]
/// Port x reset bit y (y =
BR7: u1 = 0,
/// BR8 [24:24]
/// Port x reset bit y (y =
BR8: u1 = 0,
/// BR9 [25:25]
/// Port x reset bit y (y =
BR9: u1 = 0,
/// BR10 [26:26]
/// Port x reset bit y (y =
BR10: u1 = 0,
/// BR11 [27:27]
/// Port x reset bit y (y =
BR11: u1 = 0,
/// BR12 [28:28]
/// Port x reset bit y (y =
BR12: u1 = 0,
/// BR13 [29:29]
/// Port x reset bit y (y =
BR13: u1 = 0,
/// BR14 [30:30]
/// Port x reset bit y (y =
BR14: u1 = 0,
/// BR15 [31:31]
/// Port x reset bit y (y =
BR15: u1 = 0,
};
/// GPIO port bit set/reset
pub const BSRR = Register(BSRR_val).init(base_address + 0x18);

/// LCKR
const LCKR_val = packed struct {
/// LCK0 [0:0]
/// Port x lock bit y (y=
LCK0: u1 = 0,
/// LCK1 [1:1]
/// Port x lock bit y (y=
LCK1: u1 = 0,
/// LCK2 [2:2]
/// Port x lock bit y (y=
LCK2: u1 = 0,
/// LCK3 [3:3]
/// Port x lock bit y (y=
LCK3: u1 = 0,
/// LCK4 [4:4]
/// Port x lock bit y (y=
LCK4: u1 = 0,
/// LCK5 [5:5]
/// Port x lock bit y (y=
LCK5: u1 = 0,
/// LCK6 [6:6]
/// Port x lock bit y (y=
LCK6: u1 = 0,
/// LCK7 [7:7]
/// Port x lock bit y (y=
LCK7: u1 = 0,
/// LCK8 [8:8]
/// Port x lock bit y (y=
LCK8: u1 = 0,
/// LCK9 [9:9]
/// Port x lock bit y (y=
LCK9: u1 = 0,
/// LCK10 [10:10]
/// Port x lock bit y (y=
LCK10: u1 = 0,
/// LCK11 [11:11]
/// Port x lock bit y (y=
LCK11: u1 = 0,
/// LCK12 [12:12]
/// Port x lock bit y (y=
LCK12: u1 = 0,
/// LCK13 [13:13]
/// Port x lock bit y (y=
LCK13: u1 = 0,
/// LCK14 [14:14]
/// Port x lock bit y (y=
LCK14: u1 = 0,
/// LCK15 [15:15]
/// Port x lock bit y (y=
LCK15: u1 = 0,
/// LCKK [16:16]
/// Port x lock bit y (y=
LCKK: u1 = 0,
/// unused [17:31]
_unused17: u7 = 0,
_unused24: u8 = 0,
};
/// GPIO port configuration lock
pub const LCKR = Register(LCKR_val).init(base_address + 0x1c);

/// AFRL
const AFRL_val = packed struct {
/// AFRL0 [0:3]
/// Alternate function selection for port x
AFRL0: u4 = 0,
/// AFRL1 [4:7]
/// Alternate function selection for port x
AFRL1: u4 = 0,
/// AFRL2 [8:11]
/// Alternate function selection for port x
AFRL2: u4 = 0,
/// AFRL3 [12:15]
/// Alternate function selection for port x
AFRL3: u4 = 0,
/// AFRL4 [16:19]
/// Alternate function selection for port x
AFRL4: u4 = 0,
/// AFRL5 [20:23]
/// Alternate function selection for port x
AFRL5: u4 = 0,
/// AFRL6 [24:27]
/// Alternate function selection for port x
AFRL6: u4 = 0,
/// AFRL7 [28:31]
/// Alternate function selection for port x
AFRL7: u4 = 0,
};
/// GPIO alternate function low
pub const AFRL = Register(AFRL_val).init(base_address + 0x20);

/// AFRH
const AFRH_val = packed struct {
/// AFRH8 [0:3]
/// Alternate function selection for port x
AFRH8: u4 = 0,
/// AFRH9 [4:7]
/// Alternate function selection for port x
AFRH9: u4 = 0,
/// AFRH10 [8:11]
/// Alternate function selection for port x
AFRH10: u4 = 0,
/// AFRH11 [12:15]
/// Alternate function selection for port x
AFRH11: u4 = 0,
/// AFRH12 [16:19]
/// Alternate function selection for port x
AFRH12: u4 = 0,
/// AFRH13 [20:23]
/// Alternate function selection for port x
AFRH13: u4 = 0,
/// AFRH14 [24:27]
/// Alternate function selection for port x
AFRH14: u4 = 0,
/// AFRH15 [28:31]
/// Alternate function selection for port x
AFRH15: u4 = 0,
};
/// GPIO alternate function high
pub const AFRH = Register(AFRH_val).init(base_address + 0x24);
};

/// General-purpose I/Os
pub const GPIOD = struct {

const base_address = 0x48000c00;
/// MODER
const MODER_val = packed struct {
/// MODER0 [0:1]
/// Port x configuration bits (y =
MODER0: u2 = 0,
/// MODER1 [2:3]
/// Port x configuration bits (y =
MODER1: u2 = 0,
/// MODER2 [4:5]
/// Port x configuration bits (y =
MODER2: u2 = 0,
/// MODER3 [6:7]
/// Port x configuration bits (y =
MODER3: u2 = 0,
/// MODER4 [8:9]
/// Port x configuration bits (y =
MODER4: u2 = 0,
/// MODER5 [10:11]
/// Port x configuration bits (y =
MODER5: u2 = 0,
/// MODER6 [12:13]
/// Port x configuration bits (y =
MODER6: u2 = 0,
/// MODER7 [14:15]
/// Port x configuration bits (y =
MODER7: u2 = 0,
/// MODER8 [16:17]
/// Port x configuration bits (y =
MODER8: u2 = 0,
/// MODER9 [18:19]
/// Port x configuration bits (y =
MODER9: u2 = 0,
/// MODER10 [20:21]
/// Port x configuration bits (y =
MODER10: u2 = 0,
/// MODER11 [22:23]
/// Port x configuration bits (y =
MODER11: u2 = 0,
/// MODER12 [24:25]
/// Port x configuration bits (y =
MODER12: u2 = 0,
/// MODER13 [26:27]
/// Port x configuration bits (y =
MODER13: u2 = 0,
/// MODER14 [28:29]
/// Port x configuration bits (y =
MODER14: u2 = 0,
/// MODER15 [30:31]
/// Port x configuration bits (y =
MODER15: u2 = 0,
};
/// GPIO port mode register
pub const MODER = Register(MODER_val).init(base_address + 0x0);

/// OTYPER
const OTYPER_val = packed struct {
/// OT0 [0:0]
/// Port x configuration bits (y =
OT0: u1 = 0,
/// OT1 [1:1]
/// Port x configuration bits (y =
OT1: u1 = 0,
/// OT2 [2:2]
/// Port x configuration bits (y =
OT2: u1 = 0,
/// OT3 [3:3]
/// Port x configuration bits (y =
OT3: u1 = 0,
/// OT4 [4:4]
/// Port x configuration bits (y =
OT4: u1 = 0,
/// OT5 [5:5]
/// Port x configuration bits (y =
OT5: u1 = 0,
/// OT6 [6:6]
/// Port x configuration bits (y =
OT6: u1 = 0,
/// OT7 [7:7]
/// Port x configuration bits (y =
OT7: u1 = 0,
/// OT8 [8:8]
/// Port x configuration bits (y =
OT8: u1 = 0,
/// OT9 [9:9]
/// Port x configuration bits (y =
OT9: u1 = 0,
/// OT10 [10:10]
/// Port x configuration bits (y =
OT10: u1 = 0,
/// OT11 [11:11]
/// Port x configuration bits (y =
OT11: u1 = 0,
/// OT12 [12:12]
/// Port x configuration bits (y =
OT12: u1 = 0,
/// OT13 [13:13]
/// Port x configuration bits (y =
OT13: u1 = 0,
/// OT14 [14:14]
/// Port x configuration bits (y =
OT14: u1 = 0,
/// OT15 [15:15]
/// Port x configuration bits (y =
OT15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port output type register
pub const OTYPER = Register(OTYPER_val).init(base_address + 0x4);

/// OSPEEDR
const OSPEEDR_val = packed struct {
/// OSPEEDR0 [0:1]
/// Port x configuration bits (y =
OSPEEDR0: u2 = 0,
/// OSPEEDR1 [2:3]
/// Port x configuration bits (y =
OSPEEDR1: u2 = 0,
/// OSPEEDR2 [4:5]
/// Port x configuration bits (y =
OSPEEDR2: u2 = 0,
/// OSPEEDR3 [6:7]
/// Port x configuration bits (y =
OSPEEDR3: u2 = 0,
/// OSPEEDR4 [8:9]
/// Port x configuration bits (y =
OSPEEDR4: u2 = 0,
/// OSPEEDR5 [10:11]
/// Port x configuration bits (y =
OSPEEDR5: u2 = 0,
/// OSPEEDR6 [12:13]
/// Port x configuration bits (y =
OSPEEDR6: u2 = 0,
/// OSPEEDR7 [14:15]
/// Port x configuration bits (y =
OSPEEDR7: u2 = 0,
/// OSPEEDR8 [16:17]
/// Port x configuration bits (y =
OSPEEDR8: u2 = 0,
/// OSPEEDR9 [18:19]
/// Port x configuration bits (y =
OSPEEDR9: u2 = 0,
/// OSPEEDR10 [20:21]
/// Port x configuration bits (y =
OSPEEDR10: u2 = 0,
/// OSPEEDR11 [22:23]
/// Port x configuration bits (y =
OSPEEDR11: u2 = 0,
/// OSPEEDR12 [24:25]
/// Port x configuration bits (y =
OSPEEDR12: u2 = 0,
/// OSPEEDR13 [26:27]
/// Port x configuration bits (y =
OSPEEDR13: u2 = 0,
/// OSPEEDR14 [28:29]
/// Port x configuration bits (y =
OSPEEDR14: u2 = 0,
/// OSPEEDR15 [30:31]
/// Port x configuration bits (y =
OSPEEDR15: u2 = 0,
};
/// GPIO port output speed
pub const OSPEEDR = Register(OSPEEDR_val).init(base_address + 0x8);

/// PUPDR
const PUPDR_val = packed struct {
/// PUPDR0 [0:1]
/// Port x configuration bits (y =
PUPDR0: u2 = 0,
/// PUPDR1 [2:3]
/// Port x configuration bits (y =
PUPDR1: u2 = 0,
/// PUPDR2 [4:5]
/// Port x configuration bits (y =
PUPDR2: u2 = 0,
/// PUPDR3 [6:7]
/// Port x configuration bits (y =
PUPDR3: u2 = 0,
/// PUPDR4 [8:9]
/// Port x configuration bits (y =
PUPDR4: u2 = 0,
/// PUPDR5 [10:11]
/// Port x configuration bits (y =
PUPDR5: u2 = 0,
/// PUPDR6 [12:13]
/// Port x configuration bits (y =
PUPDR6: u2 = 0,
/// PUPDR7 [14:15]
/// Port x configuration bits (y =
PUPDR7: u2 = 0,
/// PUPDR8 [16:17]
/// Port x configuration bits (y =
PUPDR8: u2 = 0,
/// PUPDR9 [18:19]
/// Port x configuration bits (y =
PUPDR9: u2 = 0,
/// PUPDR10 [20:21]
/// Port x configuration bits (y =
PUPDR10: u2 = 0,
/// PUPDR11 [22:23]
/// Port x configuration bits (y =
PUPDR11: u2 = 0,
/// PUPDR12 [24:25]
/// Port x configuration bits (y =
PUPDR12: u2 = 0,
/// PUPDR13 [26:27]
/// Port x configuration bits (y =
PUPDR13: u2 = 0,
/// PUPDR14 [28:29]
/// Port x configuration bits (y =
PUPDR14: u2 = 0,
/// PUPDR15 [30:31]
/// Port x configuration bits (y =
PUPDR15: u2 = 0,
};
/// GPIO port pull-up/pull-down
pub const PUPDR = Register(PUPDR_val).init(base_address + 0xc);

/// IDR
const IDR_val = packed struct {
/// IDR0 [0:0]
/// Port input data (y =
IDR0: u1 = 0,
/// IDR1 [1:1]
/// Port input data (y =
IDR1: u1 = 0,
/// IDR2 [2:2]
/// Port input data (y =
IDR2: u1 = 0,
/// IDR3 [3:3]
/// Port input data (y =
IDR3: u1 = 0,
/// IDR4 [4:4]
/// Port input data (y =
IDR4: u1 = 0,
/// IDR5 [5:5]
/// Port input data (y =
IDR5: u1 = 0,
/// IDR6 [6:6]
/// Port input data (y =
IDR6: u1 = 0,
/// IDR7 [7:7]
/// Port input data (y =
IDR7: u1 = 0,
/// IDR8 [8:8]
/// Port input data (y =
IDR8: u1 = 0,
/// IDR9 [9:9]
/// Port input data (y =
IDR9: u1 = 0,
/// IDR10 [10:10]
/// Port input data (y =
IDR10: u1 = 0,
/// IDR11 [11:11]
/// Port input data (y =
IDR11: u1 = 0,
/// IDR12 [12:12]
/// Port input data (y =
IDR12: u1 = 0,
/// IDR13 [13:13]
/// Port input data (y =
IDR13: u1 = 0,
/// IDR14 [14:14]
/// Port input data (y =
IDR14: u1 = 0,
/// IDR15 [15:15]
/// Port input data (y =
IDR15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port input data register
pub const IDR = Register(IDR_val).init(base_address + 0x10);

/// ODR
const ODR_val = packed struct {
/// ODR0 [0:0]
/// Port output data (y =
ODR0: u1 = 0,
/// ODR1 [1:1]
/// Port output data (y =
ODR1: u1 = 0,
/// ODR2 [2:2]
/// Port output data (y =
ODR2: u1 = 0,
/// ODR3 [3:3]
/// Port output data (y =
ODR3: u1 = 0,
/// ODR4 [4:4]
/// Port output data (y =
ODR4: u1 = 0,
/// ODR5 [5:5]
/// Port output data (y =
ODR5: u1 = 0,
/// ODR6 [6:6]
/// Port output data (y =
ODR6: u1 = 0,
/// ODR7 [7:7]
/// Port output data (y =
ODR7: u1 = 0,
/// ODR8 [8:8]
/// Port output data (y =
ODR8: u1 = 0,
/// ODR9 [9:9]
/// Port output data (y =
ODR9: u1 = 0,
/// ODR10 [10:10]
/// Port output data (y =
ODR10: u1 = 0,
/// ODR11 [11:11]
/// Port output data (y =
ODR11: u1 = 0,
/// ODR12 [12:12]
/// Port output data (y =
ODR12: u1 = 0,
/// ODR13 [13:13]
/// Port output data (y =
ODR13: u1 = 0,
/// ODR14 [14:14]
/// Port output data (y =
ODR14: u1 = 0,
/// ODR15 [15:15]
/// Port output data (y =
ODR15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port output data register
pub const ODR = Register(ODR_val).init(base_address + 0x14);

/// BSRR
const BSRR_val = packed struct {
/// BS0 [0:0]
/// Port x set bit y (y=
BS0: u1 = 0,
/// BS1 [1:1]
/// Port x set bit y (y=
BS1: u1 = 0,
/// BS2 [2:2]
/// Port x set bit y (y=
BS2: u1 = 0,
/// BS3 [3:3]
/// Port x set bit y (y=
BS3: u1 = 0,
/// BS4 [4:4]
/// Port x set bit y (y=
BS4: u1 = 0,
/// BS5 [5:5]
/// Port x set bit y (y=
BS5: u1 = 0,
/// BS6 [6:6]
/// Port x set bit y (y=
BS6: u1 = 0,
/// BS7 [7:7]
/// Port x set bit y (y=
BS7: u1 = 0,
/// BS8 [8:8]
/// Port x set bit y (y=
BS8: u1 = 0,
/// BS9 [9:9]
/// Port x set bit y (y=
BS9: u1 = 0,
/// BS10 [10:10]
/// Port x set bit y (y=
BS10: u1 = 0,
/// BS11 [11:11]
/// Port x set bit y (y=
BS11: u1 = 0,
/// BS12 [12:12]
/// Port x set bit y (y=
BS12: u1 = 0,
/// BS13 [13:13]
/// Port x set bit y (y=
BS13: u1 = 0,
/// BS14 [14:14]
/// Port x set bit y (y=
BS14: u1 = 0,
/// BS15 [15:15]
/// Port x set bit y (y=
BS15: u1 = 0,
/// BR0 [16:16]
/// Port x set bit y (y=
BR0: u1 = 0,
/// BR1 [17:17]
/// Port x reset bit y (y =
BR1: u1 = 0,
/// BR2 [18:18]
/// Port x reset bit y (y =
BR2: u1 = 0,
/// BR3 [19:19]
/// Port x reset bit y (y =
BR3: u1 = 0,
/// BR4 [20:20]
/// Port x reset bit y (y =
BR4: u1 = 0,
/// BR5 [21:21]
/// Port x reset bit y (y =
BR5: u1 = 0,
/// BR6 [22:22]
/// Port x reset bit y (y =
BR6: u1 = 0,
/// BR7 [23:23]
/// Port x reset bit y (y =
BR7: u1 = 0,
/// BR8 [24:24]
/// Port x reset bit y (y =
BR8: u1 = 0,
/// BR9 [25:25]
/// Port x reset bit y (y =
BR9: u1 = 0,
/// BR10 [26:26]
/// Port x reset bit y (y =
BR10: u1 = 0,
/// BR11 [27:27]
/// Port x reset bit y (y =
BR11: u1 = 0,
/// BR12 [28:28]
/// Port x reset bit y (y =
BR12: u1 = 0,
/// BR13 [29:29]
/// Port x reset bit y (y =
BR13: u1 = 0,
/// BR14 [30:30]
/// Port x reset bit y (y =
BR14: u1 = 0,
/// BR15 [31:31]
/// Port x reset bit y (y =
BR15: u1 = 0,
};
/// GPIO port bit set/reset
pub const BSRR = Register(BSRR_val).init(base_address + 0x18);

/// LCKR
const LCKR_val = packed struct {
/// LCK0 [0:0]
/// Port x lock bit y (y=
LCK0: u1 = 0,
/// LCK1 [1:1]
/// Port x lock bit y (y=
LCK1: u1 = 0,
/// LCK2 [2:2]
/// Port x lock bit y (y=
LCK2: u1 = 0,
/// LCK3 [3:3]
/// Port x lock bit y (y=
LCK3: u1 = 0,
/// LCK4 [4:4]
/// Port x lock bit y (y=
LCK4: u1 = 0,
/// LCK5 [5:5]
/// Port x lock bit y (y=
LCK5: u1 = 0,
/// LCK6 [6:6]
/// Port x lock bit y (y=
LCK6: u1 = 0,
/// LCK7 [7:7]
/// Port x lock bit y (y=
LCK7: u1 = 0,
/// LCK8 [8:8]
/// Port x lock bit y (y=
LCK8: u1 = 0,
/// LCK9 [9:9]
/// Port x lock bit y (y=
LCK9: u1 = 0,
/// LCK10 [10:10]
/// Port x lock bit y (y=
LCK10: u1 = 0,
/// LCK11 [11:11]
/// Port x lock bit y (y=
LCK11: u1 = 0,
/// LCK12 [12:12]
/// Port x lock bit y (y=
LCK12: u1 = 0,
/// LCK13 [13:13]
/// Port x lock bit y (y=
LCK13: u1 = 0,
/// LCK14 [14:14]
/// Port x lock bit y (y=
LCK14: u1 = 0,
/// LCK15 [15:15]
/// Port x lock bit y (y=
LCK15: u1 = 0,
/// LCKK [16:16]
/// Port x lock bit y (y=
LCKK: u1 = 0,
/// unused [17:31]
_unused17: u7 = 0,
_unused24: u8 = 0,
};
/// GPIO port configuration lock
pub const LCKR = Register(LCKR_val).init(base_address + 0x1c);

/// AFRL
const AFRL_val = packed struct {
/// AFRL0 [0:3]
/// Alternate function selection for port x
AFRL0: u4 = 0,
/// AFRL1 [4:7]
/// Alternate function selection for port x
AFRL1: u4 = 0,
/// AFRL2 [8:11]
/// Alternate function selection for port x
AFRL2: u4 = 0,
/// AFRL3 [12:15]
/// Alternate function selection for port x
AFRL3: u4 = 0,
/// AFRL4 [16:19]
/// Alternate function selection for port x
AFRL4: u4 = 0,
/// AFRL5 [20:23]
/// Alternate function selection for port x
AFRL5: u4 = 0,
/// AFRL6 [24:27]
/// Alternate function selection for port x
AFRL6: u4 = 0,
/// AFRL7 [28:31]
/// Alternate function selection for port x
AFRL7: u4 = 0,
};
/// GPIO alternate function low
pub const AFRL = Register(AFRL_val).init(base_address + 0x20);

/// AFRH
const AFRH_val = packed struct {
/// AFRH8 [0:3]
/// Alternate function selection for port x
AFRH8: u4 = 0,
/// AFRH9 [4:7]
/// Alternate function selection for port x
AFRH9: u4 = 0,
/// AFRH10 [8:11]
/// Alternate function selection for port x
AFRH10: u4 = 0,
/// AFRH11 [12:15]
/// Alternate function selection for port x
AFRH11: u4 = 0,
/// AFRH12 [16:19]
/// Alternate function selection for port x
AFRH12: u4 = 0,
/// AFRH13 [20:23]
/// Alternate function selection for port x
AFRH13: u4 = 0,
/// AFRH14 [24:27]
/// Alternate function selection for port x
AFRH14: u4 = 0,
/// AFRH15 [28:31]
/// Alternate function selection for port x
AFRH15: u4 = 0,
};
/// GPIO alternate function high
pub const AFRH = Register(AFRH_val).init(base_address + 0x24);
};

/// General-purpose I/Os
pub const GPIOE = struct {

const base_address = 0x48001000;
/// MODER
const MODER_val = packed struct {
/// MODER0 [0:1]
/// Port x configuration bits (y =
MODER0: u2 = 0,
/// MODER1 [2:3]
/// Port x configuration bits (y =
MODER1: u2 = 0,
/// MODER2 [4:5]
/// Port x configuration bits (y =
MODER2: u2 = 0,
/// MODER3 [6:7]
/// Port x configuration bits (y =
MODER3: u2 = 0,
/// MODER4 [8:9]
/// Port x configuration bits (y =
MODER4: u2 = 0,
/// MODER5 [10:11]
/// Port x configuration bits (y =
MODER5: u2 = 0,
/// MODER6 [12:13]
/// Port x configuration bits (y =
MODER6: u2 = 0,
/// MODER7 [14:15]
/// Port x configuration bits (y =
MODER7: u2 = 0,
/// MODER8 [16:17]
/// Port x configuration bits (y =
MODER8: u2 = 0,
/// MODER9 [18:19]
/// Port x configuration bits (y =
MODER9: u2 = 0,
/// MODER10 [20:21]
/// Port x configuration bits (y =
MODER10: u2 = 0,
/// MODER11 [22:23]
/// Port x configuration bits (y =
MODER11: u2 = 0,
/// MODER12 [24:25]
/// Port x configuration bits (y =
MODER12: u2 = 0,
/// MODER13 [26:27]
/// Port x configuration bits (y =
MODER13: u2 = 0,
/// MODER14 [28:29]
/// Port x configuration bits (y =
MODER14: u2 = 0,
/// MODER15 [30:31]
/// Port x configuration bits (y =
MODER15: u2 = 0,
};
/// GPIO port mode register
pub const MODER = Register(MODER_val).init(base_address + 0x0);

/// OTYPER
const OTYPER_val = packed struct {
/// OT0 [0:0]
/// Port x configuration bits (y =
OT0: u1 = 0,
/// OT1 [1:1]
/// Port x configuration bits (y =
OT1: u1 = 0,
/// OT2 [2:2]
/// Port x configuration bits (y =
OT2: u1 = 0,
/// OT3 [3:3]
/// Port x configuration bits (y =
OT3: u1 = 0,
/// OT4 [4:4]
/// Port x configuration bits (y =
OT4: u1 = 0,
/// OT5 [5:5]
/// Port x configuration bits (y =
OT5: u1 = 0,
/// OT6 [6:6]
/// Port x configuration bits (y =
OT6: u1 = 0,
/// OT7 [7:7]
/// Port x configuration bits (y =
OT7: u1 = 0,
/// OT8 [8:8]
/// Port x configuration bits (y =
OT8: u1 = 0,
/// OT9 [9:9]
/// Port x configuration bits (y =
OT9: u1 = 0,
/// OT10 [10:10]
/// Port x configuration bits (y =
OT10: u1 = 0,
/// OT11 [11:11]
/// Port x configuration bits (y =
OT11: u1 = 0,
/// OT12 [12:12]
/// Port x configuration bits (y =
OT12: u1 = 0,
/// OT13 [13:13]
/// Port x configuration bits (y =
OT13: u1 = 0,
/// OT14 [14:14]
/// Port x configuration bits (y =
OT14: u1 = 0,
/// OT15 [15:15]
/// Port x configuration bits (y =
OT15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port output type register
pub const OTYPER = Register(OTYPER_val).init(base_address + 0x4);

/// OSPEEDR
const OSPEEDR_val = packed struct {
/// OSPEEDR0 [0:1]
/// Port x configuration bits (y =
OSPEEDR0: u2 = 0,
/// OSPEEDR1 [2:3]
/// Port x configuration bits (y =
OSPEEDR1: u2 = 0,
/// OSPEEDR2 [4:5]
/// Port x configuration bits (y =
OSPEEDR2: u2 = 0,
/// OSPEEDR3 [6:7]
/// Port x configuration bits (y =
OSPEEDR3: u2 = 0,
/// OSPEEDR4 [8:9]
/// Port x configuration bits (y =
OSPEEDR4: u2 = 0,
/// OSPEEDR5 [10:11]
/// Port x configuration bits (y =
OSPEEDR5: u2 = 0,
/// OSPEEDR6 [12:13]
/// Port x configuration bits (y =
OSPEEDR6: u2 = 0,
/// OSPEEDR7 [14:15]
/// Port x configuration bits (y =
OSPEEDR7: u2 = 0,
/// OSPEEDR8 [16:17]
/// Port x configuration bits (y =
OSPEEDR8: u2 = 0,
/// OSPEEDR9 [18:19]
/// Port x configuration bits (y =
OSPEEDR9: u2 = 0,
/// OSPEEDR10 [20:21]
/// Port x configuration bits (y =
OSPEEDR10: u2 = 0,
/// OSPEEDR11 [22:23]
/// Port x configuration bits (y =
OSPEEDR11: u2 = 0,
/// OSPEEDR12 [24:25]
/// Port x configuration bits (y =
OSPEEDR12: u2 = 0,
/// OSPEEDR13 [26:27]
/// Port x configuration bits (y =
OSPEEDR13: u2 = 0,
/// OSPEEDR14 [28:29]
/// Port x configuration bits (y =
OSPEEDR14: u2 = 0,
/// OSPEEDR15 [30:31]
/// Port x configuration bits (y =
OSPEEDR15: u2 = 0,
};
/// GPIO port output speed
pub const OSPEEDR = Register(OSPEEDR_val).init(base_address + 0x8);

/// PUPDR
const PUPDR_val = packed struct {
/// PUPDR0 [0:1]
/// Port x configuration bits (y =
PUPDR0: u2 = 0,
/// PUPDR1 [2:3]
/// Port x configuration bits (y =
PUPDR1: u2 = 0,
/// PUPDR2 [4:5]
/// Port x configuration bits (y =
PUPDR2: u2 = 0,
/// PUPDR3 [6:7]
/// Port x configuration bits (y =
PUPDR3: u2 = 0,
/// PUPDR4 [8:9]
/// Port x configuration bits (y =
PUPDR4: u2 = 0,
/// PUPDR5 [10:11]
/// Port x configuration bits (y =
PUPDR5: u2 = 0,
/// PUPDR6 [12:13]
/// Port x configuration bits (y =
PUPDR6: u2 = 0,
/// PUPDR7 [14:15]
/// Port x configuration bits (y =
PUPDR7: u2 = 0,
/// PUPDR8 [16:17]
/// Port x configuration bits (y =
PUPDR8: u2 = 0,
/// PUPDR9 [18:19]
/// Port x configuration bits (y =
PUPDR9: u2 = 0,
/// PUPDR10 [20:21]
/// Port x configuration bits (y =
PUPDR10: u2 = 0,
/// PUPDR11 [22:23]
/// Port x configuration bits (y =
PUPDR11: u2 = 0,
/// PUPDR12 [24:25]
/// Port x configuration bits (y =
PUPDR12: u2 = 0,
/// PUPDR13 [26:27]
/// Port x configuration bits (y =
PUPDR13: u2 = 0,
/// PUPDR14 [28:29]
/// Port x configuration bits (y =
PUPDR14: u2 = 0,
/// PUPDR15 [30:31]
/// Port x configuration bits (y =
PUPDR15: u2 = 0,
};
/// GPIO port pull-up/pull-down
pub const PUPDR = Register(PUPDR_val).init(base_address + 0xc);

/// IDR
const IDR_val = packed struct {
/// IDR0 [0:0]
/// Port input data (y =
IDR0: u1 = 0,
/// IDR1 [1:1]
/// Port input data (y =
IDR1: u1 = 0,
/// IDR2 [2:2]
/// Port input data (y =
IDR2: u1 = 0,
/// IDR3 [3:3]
/// Port input data (y =
IDR3: u1 = 0,
/// IDR4 [4:4]
/// Port input data (y =
IDR4: u1 = 0,
/// IDR5 [5:5]
/// Port input data (y =
IDR5: u1 = 0,
/// IDR6 [6:6]
/// Port input data (y =
IDR6: u1 = 0,
/// IDR7 [7:7]
/// Port input data (y =
IDR7: u1 = 0,
/// IDR8 [8:8]
/// Port input data (y =
IDR8: u1 = 0,
/// IDR9 [9:9]
/// Port input data (y =
IDR9: u1 = 0,
/// IDR10 [10:10]
/// Port input data (y =
IDR10: u1 = 0,
/// IDR11 [11:11]
/// Port input data (y =
IDR11: u1 = 0,
/// IDR12 [12:12]
/// Port input data (y =
IDR12: u1 = 0,
/// IDR13 [13:13]
/// Port input data (y =
IDR13: u1 = 0,
/// IDR14 [14:14]
/// Port input data (y =
IDR14: u1 = 0,
/// IDR15 [15:15]
/// Port input data (y =
IDR15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port input data register
pub const IDR = Register(IDR_val).init(base_address + 0x10);

/// ODR
const ODR_val = packed struct {
/// ODR0 [0:0]
/// Port output data (y =
ODR0: u1 = 0,
/// ODR1 [1:1]
/// Port output data (y =
ODR1: u1 = 0,
/// ODR2 [2:2]
/// Port output data (y =
ODR2: u1 = 0,
/// ODR3 [3:3]
/// Port output data (y =
ODR3: u1 = 0,
/// ODR4 [4:4]
/// Port output data (y =
ODR4: u1 = 0,
/// ODR5 [5:5]
/// Port output data (y =
ODR5: u1 = 0,
/// ODR6 [6:6]
/// Port output data (y =
ODR6: u1 = 0,
/// ODR7 [7:7]
/// Port output data (y =
ODR7: u1 = 0,
/// ODR8 [8:8]
/// Port output data (y =
ODR8: u1 = 0,
/// ODR9 [9:9]
/// Port output data (y =
ODR9: u1 = 0,
/// ODR10 [10:10]
/// Port output data (y =
ODR10: u1 = 0,
/// ODR11 [11:11]
/// Port output data (y =
ODR11: u1 = 0,
/// ODR12 [12:12]
/// Port output data (y =
ODR12: u1 = 0,
/// ODR13 [13:13]
/// Port output data (y =
ODR13: u1 = 0,
/// ODR14 [14:14]
/// Port output data (y =
ODR14: u1 = 0,
/// ODR15 [15:15]
/// Port output data (y =
ODR15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port output data register
pub const ODR = Register(ODR_val).init(base_address + 0x14);

/// BSRR
const BSRR_val = packed struct {
/// BS0 [0:0]
/// Port x set bit y (y=
BS0: u1 = 0,
/// BS1 [1:1]
/// Port x set bit y (y=
BS1: u1 = 0,
/// BS2 [2:2]
/// Port x set bit y (y=
BS2: u1 = 0,
/// BS3 [3:3]
/// Port x set bit y (y=
BS3: u1 = 0,
/// BS4 [4:4]
/// Port x set bit y (y=
BS4: u1 = 0,
/// BS5 [5:5]
/// Port x set bit y (y=
BS5: u1 = 0,
/// BS6 [6:6]
/// Port x set bit y (y=
BS6: u1 = 0,
/// BS7 [7:7]
/// Port x set bit y (y=
BS7: u1 = 0,
/// BS8 [8:8]
/// Port x set bit y (y=
BS8: u1 = 0,
/// BS9 [9:9]
/// Port x set bit y (y=
BS9: u1 = 0,
/// BS10 [10:10]
/// Port x set bit y (y=
BS10: u1 = 0,
/// BS11 [11:11]
/// Port x set bit y (y=
BS11: u1 = 0,
/// BS12 [12:12]
/// Port x set bit y (y=
BS12: u1 = 0,
/// BS13 [13:13]
/// Port x set bit y (y=
BS13: u1 = 0,
/// BS14 [14:14]
/// Port x set bit y (y=
BS14: u1 = 0,
/// BS15 [15:15]
/// Port x set bit y (y=
BS15: u1 = 0,
/// BR0 [16:16]
/// Port x set bit y (y=
BR0: u1 = 0,
/// BR1 [17:17]
/// Port x reset bit y (y =
BR1: u1 = 0,
/// BR2 [18:18]
/// Port x reset bit y (y =
BR2: u1 = 0,
/// BR3 [19:19]
/// Port x reset bit y (y =
BR3: u1 = 0,
/// BR4 [20:20]
/// Port x reset bit y (y =
BR4: u1 = 0,
/// BR5 [21:21]
/// Port x reset bit y (y =
BR5: u1 = 0,
/// BR6 [22:22]
/// Port x reset bit y (y =
BR6: u1 = 0,
/// BR7 [23:23]
/// Port x reset bit y (y =
BR7: u1 = 0,
/// BR8 [24:24]
/// Port x reset bit y (y =
BR8: u1 = 0,
/// BR9 [25:25]
/// Port x reset bit y (y =
BR9: u1 = 0,
/// BR10 [26:26]
/// Port x reset bit y (y =
BR10: u1 = 0,
/// BR11 [27:27]
/// Port x reset bit y (y =
BR11: u1 = 0,
/// BR12 [28:28]
/// Port x reset bit y (y =
BR12: u1 = 0,
/// BR13 [29:29]
/// Port x reset bit y (y =
BR13: u1 = 0,
/// BR14 [30:30]
/// Port x reset bit y (y =
BR14: u1 = 0,
/// BR15 [31:31]
/// Port x reset bit y (y =
BR15: u1 = 0,
};
/// GPIO port bit set/reset
pub const BSRR = Register(BSRR_val).init(base_address + 0x18);

/// LCKR
const LCKR_val = packed struct {
/// LCK0 [0:0]
/// Port x lock bit y (y=
LCK0: u1 = 0,
/// LCK1 [1:1]
/// Port x lock bit y (y=
LCK1: u1 = 0,
/// LCK2 [2:2]
/// Port x lock bit y (y=
LCK2: u1 = 0,
/// LCK3 [3:3]
/// Port x lock bit y (y=
LCK3: u1 = 0,
/// LCK4 [4:4]
/// Port x lock bit y (y=
LCK4: u1 = 0,
/// LCK5 [5:5]
/// Port x lock bit y (y=
LCK5: u1 = 0,
/// LCK6 [6:6]
/// Port x lock bit y (y=
LCK6: u1 = 0,
/// LCK7 [7:7]
/// Port x lock bit y (y=
LCK7: u1 = 0,
/// LCK8 [8:8]
/// Port x lock bit y (y=
LCK8: u1 = 0,
/// LCK9 [9:9]
/// Port x lock bit y (y=
LCK9: u1 = 0,
/// LCK10 [10:10]
/// Port x lock bit y (y=
LCK10: u1 = 0,
/// LCK11 [11:11]
/// Port x lock bit y (y=
LCK11: u1 = 0,
/// LCK12 [12:12]
/// Port x lock bit y (y=
LCK12: u1 = 0,
/// LCK13 [13:13]
/// Port x lock bit y (y=
LCK13: u1 = 0,
/// LCK14 [14:14]
/// Port x lock bit y (y=
LCK14: u1 = 0,
/// LCK15 [15:15]
/// Port x lock bit y (y=
LCK15: u1 = 0,
/// LCKK [16:16]
/// Port x lock bit y (y=
LCKK: u1 = 0,
/// unused [17:31]
_unused17: u7 = 0,
_unused24: u8 = 0,
};
/// GPIO port configuration lock
pub const LCKR = Register(LCKR_val).init(base_address + 0x1c);

/// AFRL
const AFRL_val = packed struct {
/// AFRL0 [0:3]
/// Alternate function selection for port x
AFRL0: u4 = 0,
/// AFRL1 [4:7]
/// Alternate function selection for port x
AFRL1: u4 = 0,
/// AFRL2 [8:11]
/// Alternate function selection for port x
AFRL2: u4 = 0,
/// AFRL3 [12:15]
/// Alternate function selection for port x
AFRL3: u4 = 0,
/// AFRL4 [16:19]
/// Alternate function selection for port x
AFRL4: u4 = 0,
/// AFRL5 [20:23]
/// Alternate function selection for port x
AFRL5: u4 = 0,
/// AFRL6 [24:27]
/// Alternate function selection for port x
AFRL6: u4 = 0,
/// AFRL7 [28:31]
/// Alternate function selection for port x
AFRL7: u4 = 0,
};
/// GPIO alternate function low
pub const AFRL = Register(AFRL_val).init(base_address + 0x20);

/// AFRH
const AFRH_val = packed struct {
/// AFRH8 [0:3]
/// Alternate function selection for port x
AFRH8: u4 = 0,
/// AFRH9 [4:7]
/// Alternate function selection for port x
AFRH9: u4 = 0,
/// AFRH10 [8:11]
/// Alternate function selection for port x
AFRH10: u4 = 0,
/// AFRH11 [12:15]
/// Alternate function selection for port x
AFRH11: u4 = 0,
/// AFRH12 [16:19]
/// Alternate function selection for port x
AFRH12: u4 = 0,
/// AFRH13 [20:23]
/// Alternate function selection for port x
AFRH13: u4 = 0,
/// AFRH14 [24:27]
/// Alternate function selection for port x
AFRH14: u4 = 0,
/// AFRH15 [28:31]
/// Alternate function selection for port x
AFRH15: u4 = 0,
};
/// GPIO alternate function high
pub const AFRH = Register(AFRH_val).init(base_address + 0x24);
};

/// General-purpose I/Os
pub const GPIOH = struct {

const base_address = 0x48001c00;
/// MODER
const MODER_val = packed struct {
/// MODER0 [0:1]
/// Port x configuration bits (y =
MODER0: u2 = 0,
/// MODER1 [2:3]
/// Port x configuration bits (y =
MODER1: u2 = 0,
/// MODER2 [4:5]
/// Port x configuration bits (y =
MODER2: u2 = 0,
/// MODER3 [6:7]
/// Port x configuration bits (y =
MODER3: u2 = 0,
/// MODER4 [8:9]
/// Port x configuration bits (y =
MODER4: u2 = 0,
/// MODER5 [10:11]
/// Port x configuration bits (y =
MODER5: u2 = 0,
/// MODER6 [12:13]
/// Port x configuration bits (y =
MODER6: u2 = 0,
/// MODER7 [14:15]
/// Port x configuration bits (y =
MODER7: u2 = 0,
/// MODER8 [16:17]
/// Port x configuration bits (y =
MODER8: u2 = 0,
/// MODER9 [18:19]
/// Port x configuration bits (y =
MODER9: u2 = 0,
/// MODER10 [20:21]
/// Port x configuration bits (y =
MODER10: u2 = 0,
/// MODER11 [22:23]
/// Port x configuration bits (y =
MODER11: u2 = 0,
/// MODER12 [24:25]
/// Port x configuration bits (y =
MODER12: u2 = 0,
/// MODER13 [26:27]
/// Port x configuration bits (y =
MODER13: u2 = 0,
/// MODER14 [28:29]
/// Port x configuration bits (y =
MODER14: u2 = 0,
/// MODER15 [30:31]
/// Port x configuration bits (y =
MODER15: u2 = 0,
};
/// GPIO port mode register
pub const MODER = Register(MODER_val).init(base_address + 0x0);

/// OTYPER
const OTYPER_val = packed struct {
/// OT0 [0:0]
/// Port x configuration bits (y =
OT0: u1 = 0,
/// OT1 [1:1]
/// Port x configuration bits (y =
OT1: u1 = 0,
/// OT2 [2:2]
/// Port x configuration bits (y =
OT2: u1 = 0,
/// OT3 [3:3]
/// Port x configuration bits (y =
OT3: u1 = 0,
/// OT4 [4:4]
/// Port x configuration bits (y =
OT4: u1 = 0,
/// OT5 [5:5]
/// Port x configuration bits (y =
OT5: u1 = 0,
/// OT6 [6:6]
/// Port x configuration bits (y =
OT6: u1 = 0,
/// OT7 [7:7]
/// Port x configuration bits (y =
OT7: u1 = 0,
/// OT8 [8:8]
/// Port x configuration bits (y =
OT8: u1 = 0,
/// OT9 [9:9]
/// Port x configuration bits (y =
OT9: u1 = 0,
/// OT10 [10:10]
/// Port x configuration bits (y =
OT10: u1 = 0,
/// OT11 [11:11]
/// Port x configuration bits (y =
OT11: u1 = 0,
/// OT12 [12:12]
/// Port x configuration bits (y =
OT12: u1 = 0,
/// OT13 [13:13]
/// Port x configuration bits (y =
OT13: u1 = 0,
/// OT14 [14:14]
/// Port x configuration bits (y =
OT14: u1 = 0,
/// OT15 [15:15]
/// Port x configuration bits (y =
OT15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port output type register
pub const OTYPER = Register(OTYPER_val).init(base_address + 0x4);

/// OSPEEDR
const OSPEEDR_val = packed struct {
/// OSPEEDR0 [0:1]
/// Port x configuration bits (y =
OSPEEDR0: u2 = 0,
/// OSPEEDR1 [2:3]
/// Port x configuration bits (y =
OSPEEDR1: u2 = 0,
/// OSPEEDR2 [4:5]
/// Port x configuration bits (y =
OSPEEDR2: u2 = 0,
/// OSPEEDR3 [6:7]
/// Port x configuration bits (y =
OSPEEDR3: u2 = 0,
/// OSPEEDR4 [8:9]
/// Port x configuration bits (y =
OSPEEDR4: u2 = 0,
/// OSPEEDR5 [10:11]
/// Port x configuration bits (y =
OSPEEDR5: u2 = 0,
/// OSPEEDR6 [12:13]
/// Port x configuration bits (y =
OSPEEDR6: u2 = 0,
/// OSPEEDR7 [14:15]
/// Port x configuration bits (y =
OSPEEDR7: u2 = 0,
/// OSPEEDR8 [16:17]
/// Port x configuration bits (y =
OSPEEDR8: u2 = 0,
/// OSPEEDR9 [18:19]
/// Port x configuration bits (y =
OSPEEDR9: u2 = 0,
/// OSPEEDR10 [20:21]
/// Port x configuration bits (y =
OSPEEDR10: u2 = 0,
/// OSPEEDR11 [22:23]
/// Port x configuration bits (y =
OSPEEDR11: u2 = 0,
/// OSPEEDR12 [24:25]
/// Port x configuration bits (y =
OSPEEDR12: u2 = 0,
/// OSPEEDR13 [26:27]
/// Port x configuration bits (y =
OSPEEDR13: u2 = 0,
/// OSPEEDR14 [28:29]
/// Port x configuration bits (y =
OSPEEDR14: u2 = 0,
/// OSPEEDR15 [30:31]
/// Port x configuration bits (y =
OSPEEDR15: u2 = 0,
};
/// GPIO port output speed
pub const OSPEEDR = Register(OSPEEDR_val).init(base_address + 0x8);

/// PUPDR
const PUPDR_val = packed struct {
/// PUPDR0 [0:1]
/// Port x configuration bits (y =
PUPDR0: u2 = 0,
/// PUPDR1 [2:3]
/// Port x configuration bits (y =
PUPDR1: u2 = 0,
/// PUPDR2 [4:5]
/// Port x configuration bits (y =
PUPDR2: u2 = 0,
/// PUPDR3 [6:7]
/// Port x configuration bits (y =
PUPDR3: u2 = 0,
/// PUPDR4 [8:9]
/// Port x configuration bits (y =
PUPDR4: u2 = 0,
/// PUPDR5 [10:11]
/// Port x configuration bits (y =
PUPDR5: u2 = 0,
/// PUPDR6 [12:13]
/// Port x configuration bits (y =
PUPDR6: u2 = 0,
/// PUPDR7 [14:15]
/// Port x configuration bits (y =
PUPDR7: u2 = 0,
/// PUPDR8 [16:17]
/// Port x configuration bits (y =
PUPDR8: u2 = 0,
/// PUPDR9 [18:19]
/// Port x configuration bits (y =
PUPDR9: u2 = 0,
/// PUPDR10 [20:21]
/// Port x configuration bits (y =
PUPDR10: u2 = 0,
/// PUPDR11 [22:23]
/// Port x configuration bits (y =
PUPDR11: u2 = 0,
/// PUPDR12 [24:25]
/// Port x configuration bits (y =
PUPDR12: u2 = 0,
/// PUPDR13 [26:27]
/// Port x configuration bits (y =
PUPDR13: u2 = 0,
/// PUPDR14 [28:29]
/// Port x configuration bits (y =
PUPDR14: u2 = 0,
/// PUPDR15 [30:31]
/// Port x configuration bits (y =
PUPDR15: u2 = 0,
};
/// GPIO port pull-up/pull-down
pub const PUPDR = Register(PUPDR_val).init(base_address + 0xc);

/// IDR
const IDR_val = packed struct {
/// IDR0 [0:0]
/// Port input data (y =
IDR0: u1 = 0,
/// IDR1 [1:1]
/// Port input data (y =
IDR1: u1 = 0,
/// IDR2 [2:2]
/// Port input data (y =
IDR2: u1 = 0,
/// IDR3 [3:3]
/// Port input data (y =
IDR3: u1 = 0,
/// IDR4 [4:4]
/// Port input data (y =
IDR4: u1 = 0,
/// IDR5 [5:5]
/// Port input data (y =
IDR5: u1 = 0,
/// IDR6 [6:6]
/// Port input data (y =
IDR6: u1 = 0,
/// IDR7 [7:7]
/// Port input data (y =
IDR7: u1 = 0,
/// IDR8 [8:8]
/// Port input data (y =
IDR8: u1 = 0,
/// IDR9 [9:9]
/// Port input data (y =
IDR9: u1 = 0,
/// IDR10 [10:10]
/// Port input data (y =
IDR10: u1 = 0,
/// IDR11 [11:11]
/// Port input data (y =
IDR11: u1 = 0,
/// IDR12 [12:12]
/// Port input data (y =
IDR12: u1 = 0,
/// IDR13 [13:13]
/// Port input data (y =
IDR13: u1 = 0,
/// IDR14 [14:14]
/// Port input data (y =
IDR14: u1 = 0,
/// IDR15 [15:15]
/// Port input data (y =
IDR15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port input data register
pub const IDR = Register(IDR_val).init(base_address + 0x10);

/// ODR
const ODR_val = packed struct {
/// ODR0 [0:0]
/// Port output data (y =
ODR0: u1 = 0,
/// ODR1 [1:1]
/// Port output data (y =
ODR1: u1 = 0,
/// ODR2 [2:2]
/// Port output data (y =
ODR2: u1 = 0,
/// ODR3 [3:3]
/// Port output data (y =
ODR3: u1 = 0,
/// ODR4 [4:4]
/// Port output data (y =
ODR4: u1 = 0,
/// ODR5 [5:5]
/// Port output data (y =
ODR5: u1 = 0,
/// ODR6 [6:6]
/// Port output data (y =
ODR6: u1 = 0,
/// ODR7 [7:7]
/// Port output data (y =
ODR7: u1 = 0,
/// ODR8 [8:8]
/// Port output data (y =
ODR8: u1 = 0,
/// ODR9 [9:9]
/// Port output data (y =
ODR9: u1 = 0,
/// ODR10 [10:10]
/// Port output data (y =
ODR10: u1 = 0,
/// ODR11 [11:11]
/// Port output data (y =
ODR11: u1 = 0,
/// ODR12 [12:12]
/// Port output data (y =
ODR12: u1 = 0,
/// ODR13 [13:13]
/// Port output data (y =
ODR13: u1 = 0,
/// ODR14 [14:14]
/// Port output data (y =
ODR14: u1 = 0,
/// ODR15 [15:15]
/// Port output data (y =
ODR15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port output data register
pub const ODR = Register(ODR_val).init(base_address + 0x14);

/// BSRR
const BSRR_val = packed struct {
/// BS0 [0:0]
/// Port x set bit y (y=
BS0: u1 = 0,
/// BS1 [1:1]
/// Port x set bit y (y=
BS1: u1 = 0,
/// BS2 [2:2]
/// Port x set bit y (y=
BS2: u1 = 0,
/// BS3 [3:3]
/// Port x set bit y (y=
BS3: u1 = 0,
/// BS4 [4:4]
/// Port x set bit y (y=
BS4: u1 = 0,
/// BS5 [5:5]
/// Port x set bit y (y=
BS5: u1 = 0,
/// BS6 [6:6]
/// Port x set bit y (y=
BS6: u1 = 0,
/// BS7 [7:7]
/// Port x set bit y (y=
BS7: u1 = 0,
/// BS8 [8:8]
/// Port x set bit y (y=
BS8: u1 = 0,
/// BS9 [9:9]
/// Port x set bit y (y=
BS9: u1 = 0,
/// BS10 [10:10]
/// Port x set bit y (y=
BS10: u1 = 0,
/// BS11 [11:11]
/// Port x set bit y (y=
BS11: u1 = 0,
/// BS12 [12:12]
/// Port x set bit y (y=
BS12: u1 = 0,
/// BS13 [13:13]
/// Port x set bit y (y=
BS13: u1 = 0,
/// BS14 [14:14]
/// Port x set bit y (y=
BS14: u1 = 0,
/// BS15 [15:15]
/// Port x set bit y (y=
BS15: u1 = 0,
/// BR0 [16:16]
/// Port x set bit y (y=
BR0: u1 = 0,
/// BR1 [17:17]
/// Port x reset bit y (y =
BR1: u1 = 0,
/// BR2 [18:18]
/// Port x reset bit y (y =
BR2: u1 = 0,
/// BR3 [19:19]
/// Port x reset bit y (y =
BR3: u1 = 0,
/// BR4 [20:20]
/// Port x reset bit y (y =
BR4: u1 = 0,
/// BR5 [21:21]
/// Port x reset bit y (y =
BR5: u1 = 0,
/// BR6 [22:22]
/// Port x reset bit y (y =
BR6: u1 = 0,
/// BR7 [23:23]
/// Port x reset bit y (y =
BR7: u1 = 0,
/// BR8 [24:24]
/// Port x reset bit y (y =
BR8: u1 = 0,
/// BR9 [25:25]
/// Port x reset bit y (y =
BR9: u1 = 0,
/// BR10 [26:26]
/// Port x reset bit y (y =
BR10: u1 = 0,
/// BR11 [27:27]
/// Port x reset bit y (y =
BR11: u1 = 0,
/// BR12 [28:28]
/// Port x reset bit y (y =
BR12: u1 = 0,
/// BR13 [29:29]
/// Port x reset bit y (y =
BR13: u1 = 0,
/// BR14 [30:30]
/// Port x reset bit y (y =
BR14: u1 = 0,
/// BR15 [31:31]
/// Port x reset bit y (y =
BR15: u1 = 0,
};
/// GPIO port bit set/reset
pub const BSRR = Register(BSRR_val).init(base_address + 0x18);

/// LCKR
const LCKR_val = packed struct {
/// LCK0 [0:0]
/// Port x lock bit y (y=
LCK0: u1 = 0,
/// LCK1 [1:1]
/// Port x lock bit y (y=
LCK1: u1 = 0,
/// LCK2 [2:2]
/// Port x lock bit y (y=
LCK2: u1 = 0,
/// LCK3 [3:3]
/// Port x lock bit y (y=
LCK3: u1 = 0,
/// LCK4 [4:4]
/// Port x lock bit y (y=
LCK4: u1 = 0,
/// LCK5 [5:5]
/// Port x lock bit y (y=
LCK5: u1 = 0,
/// LCK6 [6:6]
/// Port x lock bit y (y=
LCK6: u1 = 0,
/// LCK7 [7:7]
/// Port x lock bit y (y=
LCK7: u1 = 0,
/// LCK8 [8:8]
/// Port x lock bit y (y=
LCK8: u1 = 0,
/// LCK9 [9:9]
/// Port x lock bit y (y=
LCK9: u1 = 0,
/// LCK10 [10:10]
/// Port x lock bit y (y=
LCK10: u1 = 0,
/// LCK11 [11:11]
/// Port x lock bit y (y=
LCK11: u1 = 0,
/// LCK12 [12:12]
/// Port x lock bit y (y=
LCK12: u1 = 0,
/// LCK13 [13:13]
/// Port x lock bit y (y=
LCK13: u1 = 0,
/// LCK14 [14:14]
/// Port x lock bit y (y=
LCK14: u1 = 0,
/// LCK15 [15:15]
/// Port x lock bit y (y=
LCK15: u1 = 0,
/// LCKK [16:16]
/// Port x lock bit y (y=
LCKK: u1 = 0,
/// unused [17:31]
_unused17: u7 = 0,
_unused24: u8 = 0,
};
/// GPIO port configuration lock
pub const LCKR = Register(LCKR_val).init(base_address + 0x1c);

/// AFRL
const AFRL_val = packed struct {
/// AFRL0 [0:3]
/// Alternate function selection for port x
AFRL0: u4 = 0,
/// AFRL1 [4:7]
/// Alternate function selection for port x
AFRL1: u4 = 0,
/// AFRL2 [8:11]
/// Alternate function selection for port x
AFRL2: u4 = 0,
/// AFRL3 [12:15]
/// Alternate function selection for port x
AFRL3: u4 = 0,
/// AFRL4 [16:19]
/// Alternate function selection for port x
AFRL4: u4 = 0,
/// AFRL5 [20:23]
/// Alternate function selection for port x
AFRL5: u4 = 0,
/// AFRL6 [24:27]
/// Alternate function selection for port x
AFRL6: u4 = 0,
/// AFRL7 [28:31]
/// Alternate function selection for port x
AFRL7: u4 = 0,
};
/// GPIO alternate function low
pub const AFRL = Register(AFRL_val).init(base_address + 0x20);

/// AFRH
const AFRH_val = packed struct {
/// AFRH8 [0:3]
/// Alternate function selection for port x
AFRH8: u4 = 0,
/// AFRH9 [4:7]
/// Alternate function selection for port x
AFRH9: u4 = 0,
/// AFRH10 [8:11]
/// Alternate function selection for port x
AFRH10: u4 = 0,
/// AFRH11 [12:15]
/// Alternate function selection for port x
AFRH11: u4 = 0,
/// AFRH12 [16:19]
/// Alternate function selection for port x
AFRH12: u4 = 0,
/// AFRH13 [20:23]
/// Alternate function selection for port x
AFRH13: u4 = 0,
/// AFRH14 [24:27]
/// Alternate function selection for port x
AFRH14: u4 = 0,
/// AFRH15 [28:31]
/// Alternate function selection for port x
AFRH15: u4 = 0,
};
/// GPIO alternate function high
pub const AFRH = Register(AFRH_val).init(base_address + 0x24);
};

/// Serial audio interface
pub const SAI1 = struct {

const base_address = 0x40015400;
/// BCR1
const BCR1_val = packed struct {
/// MODE [0:1]
/// Audio block mode
MODE: u2 = 0,
/// PRTCFG [2:3]
/// Protocol configuration
PRTCFG: u2 = 0,
/// unused [4:4]
_unused4: u1 = 0,
/// DS [5:7]
/// Data size
DS: u3 = 2,
/// LSBFIRST [8:8]
/// Least significant bit
LSBFIRST: u1 = 0,
/// CKSTR [9:9]
/// Clock strobing edge
CKSTR: u1 = 0,
/// SYNCEN [10:11]
/// Synchronization enable
SYNCEN: u2 = 0,
/// MONO [12:12]
/// Mono mode
MONO: u1 = 0,
/// OutDri [13:13]
/// Output drive
OutDri: u1 = 0,
/// unused [14:15]
_unused14: u2 = 0,
/// SAIBEN [16:16]
/// Audio block B enable
SAIBEN: u1 = 0,
/// DMAEN [17:17]
/// DMA enable
DMAEN: u1 = 0,
/// unused [18:18]
_unused18: u1 = 0,
/// NODIV [19:19]
/// No divider
NODIV: u1 = 0,
/// MCJDIV [20:23]
/// Master clock divider
MCJDIV: u4 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// BConfiguration register 1
pub const BCR1 = Register(BCR1_val).init(base_address + 0x24);

/// BCR2
const BCR2_val = packed struct {
/// FTH [0:2]
/// FIFO threshold
FTH: u3 = 0,
/// FFLUS [3:3]
/// FIFO flush
FFLUS: u1 = 0,
/// TRIS [4:4]
/// Tristate management on data
TRIS: u1 = 0,
/// MUTE [5:5]
/// Mute
MUTE: u1 = 0,
/// MUTEVAL [6:6]
/// Mute value
MUTEVAL: u1 = 0,
/// MUTECN [7:12]
/// Mute counter
MUTECN: u6 = 0,
/// CPL [13:13]
/// Complement bit
CPL: u1 = 0,
/// COMP [14:15]
/// Companding mode
COMP: u2 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// BConfiguration register 2
pub const BCR2 = Register(BCR2_val).init(base_address + 0x28);

/// BFRCR
const BFRCR_val = packed struct {
/// FRL [0:7]
/// Frame length
FRL: u8 = 7,
/// FSALL [8:14]
/// Frame synchronization active level
FSALL: u7 = 0,
/// unused [15:15]
_unused15: u1 = 0,
/// FSDEF [16:16]
/// Frame synchronization
FSDEF: u1 = 0,
/// FSPOL [17:17]
/// Frame synchronization
FSPOL: u1 = 0,
/// FSOFF [18:18]
/// Frame synchronization
FSOFF: u1 = 0,
/// unused [19:31]
_unused19: u5 = 0,
_unused24: u8 = 0,
};
/// BFRCR
pub const BFRCR = Register(BFRCR_val).init(base_address + 0x2c);

/// BSLOTR
const BSLOTR_val = packed struct {
/// FBOFF [0:4]
/// First bit offset
FBOFF: u5 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// SLOTSZ [6:7]
/// Slot size
SLOTSZ: u2 = 0,
/// NBSLOT [8:11]
/// Number of slots in an audio
NBSLOT: u4 = 0,
/// unused [12:15]
_unused12: u4 = 0,
/// SLOTEN [16:31]
/// Slot enable
SLOTEN: u16 = 0,
};
/// BSlot register
pub const BSLOTR = Register(BSLOTR_val).init(base_address + 0x30);

/// BIM
const BIM_val = packed struct {
/// OVRUDRIE [0:0]
/// Overrun/underrun interrupt
OVRUDRIE: u1 = 0,
/// MUTEDET [1:1]
/// Mute detection interrupt
MUTEDET: u1 = 0,
/// WCKCFG [2:2]
/// Wrong clock configuration interrupt
WCKCFG: u1 = 0,
/// FREQIE [3:3]
/// FIFO request interrupt
FREQIE: u1 = 0,
/// CNRDYIE [4:4]
/// Codec not ready interrupt
CNRDYIE: u1 = 0,
/// AFSDETIE [5:5]
/// Anticipated frame synchronization
AFSDETIE: u1 = 0,
/// LFSDETIE [6:6]
/// Late frame synchronization detection
LFSDETIE: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// BInterrupt mask register2
pub const BIM = Register(BIM_val).init(base_address + 0x34);

/// BSR
const BSR_val = packed struct {
/// OVRUDR [0:0]
/// Overrun / underrun
OVRUDR: u1 = 0,
/// MUTEDET [1:1]
/// Mute detection
MUTEDET: u1 = 0,
/// WCKCFG [2:2]
/// Wrong clock configuration
WCKCFG: u1 = 0,
/// FREQ [3:3]
/// FIFO request
FREQ: u1 = 0,
/// CNRDY [4:4]
/// Codec not ready
CNRDY: u1 = 0,
/// AFSDET [5:5]
/// Anticipated frame synchronization
AFSDET: u1 = 0,
/// LFSDET [6:6]
/// Late frame synchronization
LFSDET: u1 = 0,
/// unused [7:15]
_unused7: u1 = 0,
_unused8: u8 = 0,
/// FLVL [16:18]
/// FIFO level threshold
FLVL: u3 = 0,
/// unused [19:31]
_unused19: u5 = 0,
_unused24: u8 = 0,
};
/// BStatus register
pub const BSR = Register(BSR_val).init(base_address + 0x38);

/// BCLRFR
const BCLRFR_val = packed struct {
/// OVRUDR [0:0]
/// Clear overrun / underrun
OVRUDR: u1 = 0,
/// MUTEDET [1:1]
/// Mute detection flag
MUTEDET: u1 = 0,
/// WCKCFG [2:2]
/// Clear wrong clock configuration
WCKCFG: u1 = 0,
/// unused [3:3]
_unused3: u1 = 0,
/// CNRDY [4:4]
/// Clear codec not ready flag
CNRDY: u1 = 0,
/// CAFSDET [5:5]
/// Clear anticipated frame synchronization
CAFSDET: u1 = 0,
/// LFSDET [6:6]
/// Clear late frame synchronization
LFSDET: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// BClear flag register
pub const BCLRFR = Register(BCLRFR_val).init(base_address + 0x3c);

/// BDR
const BDR_val = packed struct {
/// DATA [0:31]
/// Data
DATA: u32 = 0,
};
/// BData register
pub const BDR = Register(BDR_val).init(base_address + 0x40);

/// ACR1
const ACR1_val = packed struct {
/// MODE [0:1]
/// Audio block mode
MODE: u2 = 0,
/// PRTCFG [2:3]
/// Protocol configuration
PRTCFG: u2 = 0,
/// unused [4:4]
_unused4: u1 = 0,
/// DS [5:7]
/// Data size
DS: u3 = 2,
/// LSBFIRST [8:8]
/// Least significant bit
LSBFIRST: u1 = 0,
/// CKSTR [9:9]
/// Clock strobing edge
CKSTR: u1 = 0,
/// SYNCEN [10:11]
/// Synchronization enable
SYNCEN: u2 = 0,
/// MONO [12:12]
/// Mono mode
MONO: u1 = 0,
/// OutDri [13:13]
/// Output drive
OutDri: u1 = 0,
/// unused [14:15]
_unused14: u2 = 0,
/// SAIAEN [16:16]
/// Audio block A enable
SAIAEN: u1 = 0,
/// DMAEN [17:17]
/// DMA enable
DMAEN: u1 = 0,
/// unused [18:18]
_unused18: u1 = 0,
/// NODIV [19:19]
/// No divider
NODIV: u1 = 0,
/// MCJDIV [20:23]
/// Master clock divider
MCJDIV: u4 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// AConfiguration register 1
pub const ACR1 = Register(ACR1_val).init(base_address + 0x4);

/// ACR2
const ACR2_val = packed struct {
/// FTH [0:2]
/// FIFO threshold
FTH: u3 = 0,
/// FFLUS [3:3]
/// FIFO flush
FFLUS: u1 = 0,
/// TRIS [4:4]
/// Tristate management on data
TRIS: u1 = 0,
/// MUTE [5:5]
/// Mute
MUTE: u1 = 0,
/// MUTEVAL [6:6]
/// Mute value
MUTEVAL: u1 = 0,
/// MUTECN [7:12]
/// Mute counter
MUTECN: u6 = 0,
/// CPL [13:13]
/// Complement bit
CPL: u1 = 0,
/// COMP [14:15]
/// Companding mode
COMP: u2 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// AConfiguration register 2
pub const ACR2 = Register(ACR2_val).init(base_address + 0x8);

/// AFRCR
const AFRCR_val = packed struct {
/// FRL [0:7]
/// Frame length
FRL: u8 = 7,
/// FSALL [8:14]
/// Frame synchronization active level
FSALL: u7 = 0,
/// unused [15:15]
_unused15: u1 = 0,
/// FSDEF [16:16]
/// Frame synchronization
FSDEF: u1 = 0,
/// FSPOL [17:17]
/// Frame synchronization
FSPOL: u1 = 0,
/// FSOFF [18:18]
/// Frame synchronization
FSOFF: u1 = 0,
/// unused [19:31]
_unused19: u5 = 0,
_unused24: u8 = 0,
};
/// AFRCR
pub const AFRCR = Register(AFRCR_val).init(base_address + 0xc);

/// ASLOTR
const ASLOTR_val = packed struct {
/// FBOFF [0:4]
/// First bit offset
FBOFF: u5 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// SLOTSZ [6:7]
/// Slot size
SLOTSZ: u2 = 0,
/// NBSLOT [8:11]
/// Number of slots in an audio
NBSLOT: u4 = 0,
/// unused [12:15]
_unused12: u4 = 0,
/// SLOTEN [16:31]
/// Slot enable
SLOTEN: u16 = 0,
};
/// ASlot register
pub const ASLOTR = Register(ASLOTR_val).init(base_address + 0x10);

/// AIM
const AIM_val = packed struct {
/// OVRUDRIE [0:0]
/// Overrun/underrun interrupt
OVRUDRIE: u1 = 0,
/// MUTEDET [1:1]
/// Mute detection interrupt
MUTEDET: u1 = 0,
/// WCKCFG [2:2]
/// Wrong clock configuration interrupt
WCKCFG: u1 = 0,
/// FREQIE [3:3]
/// FIFO request interrupt
FREQIE: u1 = 0,
/// CNRDYIE [4:4]
/// Codec not ready interrupt
CNRDYIE: u1 = 0,
/// AFSDETIE [5:5]
/// Anticipated frame synchronization
AFSDETIE: u1 = 0,
/// LFSDET [6:6]
/// Late frame synchronization detection
LFSDET: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// AInterrupt mask register2
pub const AIM = Register(AIM_val).init(base_address + 0x14);

/// ASR
const ASR_val = packed struct {
/// OVRUDR [0:0]
/// Overrun / underrun
OVRUDR: u1 = 0,
/// MUTEDET [1:1]
/// Mute detection
MUTEDET: u1 = 0,
/// WCKCFG [2:2]
/// Wrong clock configuration flag. This bit
WCKCFG: u1 = 0,
/// FREQ [3:3]
/// FIFO request
FREQ: u1 = 0,
/// CNRDY [4:4]
/// Codec not ready
CNRDY: u1 = 0,
/// AFSDET [5:5]
/// Anticipated frame synchronization
AFSDET: u1 = 0,
/// LFSDET [6:6]
/// Late frame synchronization
LFSDET: u1 = 0,
/// unused [7:15]
_unused7: u1 = 0,
_unused8: u8 = 0,
/// FLVL [16:18]
/// FIFO level threshold
FLVL: u3 = 0,
/// unused [19:31]
_unused19: u5 = 0,
_unused24: u8 = 0,
};
/// AStatus register
pub const ASR = Register(ASR_val).init(base_address + 0x18);

/// ACLRFR
const ACLRFR_val = packed struct {
/// OVRUDR [0:0]
/// Clear overrun / underrun
OVRUDR: u1 = 0,
/// MUTEDET [1:1]
/// Mute detection flag
MUTEDET: u1 = 0,
/// WCKCFG [2:2]
/// Clear wrong clock configuration
WCKCFG: u1 = 0,
/// unused [3:3]
_unused3: u1 = 0,
/// CNRDY [4:4]
/// Clear codec not ready flag
CNRDY: u1 = 0,
/// CAFSDET [5:5]
/// Clear anticipated frame synchronization
CAFSDET: u1 = 0,
/// LFSDET [6:6]
/// Clear late frame synchronization
LFSDET: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// AClear flag register
pub const ACLRFR = Register(ACLRFR_val).init(base_address + 0x1c);

/// ADR
const ADR_val = packed struct {
/// DATA [0:31]
/// Data
DATA: u32 = 0,
};
/// AData register
pub const ADR = Register(ADR_val).init(base_address + 0x20);
};

/// General-purpose-timers
pub const TIM2 = struct {

const base_address = 0x40000000;
/// CR1
const CR1_val = packed struct {
/// CEN [0:0]
/// Counter enable
CEN: u1 = 0,
/// UDIS [1:1]
/// Update disable
UDIS: u1 = 0,
/// URS [2:2]
/// Update request source
URS: u1 = 0,
/// OPM [3:3]
/// One-pulse mode
OPM: u1 = 0,
/// DIR [4:4]
/// Direction
DIR: u1 = 0,
/// CMS [5:6]
/// Center-aligned mode
CMS: u2 = 0,
/// ARPE [7:7]
/// Auto-reload preload enable
ARPE: u1 = 0,
/// CKD [8:9]
/// Clock division
CKD: u2 = 0,
/// unused [10:31]
_unused10: u6 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// CCDS [3:3]
/// Capture/compare DMA
CCDS: u1 = 0,
/// MMS [4:6]
/// Master mode selection
MMS: u3 = 0,
/// TI1S [7:7]
/// TI1 selection
TI1S: u1 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// SMCR
const SMCR_val = packed struct {
/// SMS [0:2]
/// Slave mode selection
SMS: u3 = 0,
/// unused [3:3]
_unused3: u1 = 0,
/// TS [4:6]
/// Trigger selection
TS: u3 = 0,
/// MSM [7:7]
/// Master/Slave mode
MSM: u1 = 0,
/// ETF [8:11]
/// External trigger filter
ETF: u4 = 0,
/// ETPS [12:13]
/// External trigger prescaler
ETPS: u2 = 0,
/// ECE [14:14]
/// External clock enable
ECE: u1 = 0,
/// ETP [15:15]
/// External trigger polarity
ETP: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// slave mode control register
pub const SMCR = Register(SMCR_val).init(base_address + 0x8);

/// DIER
const DIER_val = packed struct {
/// UIE [0:0]
/// Update interrupt enable
UIE: u1 = 0,
/// CC1IE [1:1]
/// Capture/Compare 1 interrupt
CC1IE: u1 = 0,
/// CC2IE [2:2]
/// Capture/Compare 2 interrupt
CC2IE: u1 = 0,
/// CC3IE [3:3]
/// Capture/Compare 3 interrupt
CC3IE: u1 = 0,
/// CC4IE [4:4]
/// Capture/Compare 4 interrupt
CC4IE: u1 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// TIE [6:6]
/// Trigger interrupt enable
TIE: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// UDE [8:8]
/// Update DMA request enable
UDE: u1 = 0,
/// CC1DE [9:9]
/// Capture/Compare 1 DMA request
CC1DE: u1 = 0,
/// CC2DE [10:10]
/// Capture/Compare 2 DMA request
CC2DE: u1 = 0,
/// CC3DE [11:11]
/// Capture/Compare 3 DMA request
CC3DE: u1 = 0,
/// CC4DE [12:12]
/// Capture/Compare 4 DMA request
CC4DE: u1 = 0,
/// COMDE [13:13]
/// COM DMA request enable
COMDE: u1 = 0,
/// TDE [14:14]
/// Trigger DMA request enable
TDE: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA/Interrupt enable register
pub const DIER = Register(DIER_val).init(base_address + 0xc);

/// SR
const SR_val = packed struct {
/// UIF [0:0]
/// Update interrupt flag
UIF: u1 = 0,
/// CC1IF [1:1]
/// Capture/compare 1 interrupt
CC1IF: u1 = 0,
/// CC2IF [2:2]
/// Capture/Compare 2 interrupt
CC2IF: u1 = 0,
/// CC3IF [3:3]
/// Capture/Compare 3 interrupt
CC3IF: u1 = 0,
/// CC4IF [4:4]
/// Capture/Compare 4 interrupt
CC4IF: u1 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// TIF [6:6]
/// Trigger interrupt flag
TIF: u1 = 0,
/// unused [7:8]
_unused7: u1 = 0,
_unused8: u1 = 0,
/// CC1OF [9:9]
/// Capture/Compare 1 overcapture
CC1OF: u1 = 0,
/// CC2OF [10:10]
/// Capture/compare 2 overcapture
CC2OF: u1 = 0,
/// CC3OF [11:11]
/// Capture/Compare 3 overcapture
CC3OF: u1 = 0,
/// CC4OF [12:12]
/// Capture/Compare 4 overcapture
CC4OF: u1 = 0,
/// unused [13:31]
_unused13: u3 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// status register
pub const SR = Register(SR_val).init(base_address + 0x10);

/// EGR
const EGR_val = packed struct {
/// UG [0:0]
/// Update generation
UG: u1 = 0,
/// CC1G [1:1]
/// Capture/compare 1
CC1G: u1 = 0,
/// CC2G [2:2]
/// Capture/compare 2
CC2G: u1 = 0,
/// CC3G [3:3]
/// Capture/compare 3
CC3G: u1 = 0,
/// CC4G [4:4]
/// Capture/compare 4
CC4G: u1 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// TG [6:6]
/// Trigger generation
TG: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// event generation register
pub const EGR = Register(EGR_val).init(base_address + 0x14);

/// CCMR1_Output
const CCMR1_Output_val = packed struct {
/// CC1S [0:1]
/// Capture/Compare 1
CC1S: u2 = 0,
/// OC1FE [2:2]
/// Output compare 1 fast
OC1FE: u1 = 0,
/// OC1PE [3:3]
/// Output compare 1 preload
OC1PE: u1 = 0,
/// OC1M [4:6]
/// Output compare 1 mode
OC1M: u3 = 0,
/// OC1CE [7:7]
/// Output compare 1 clear
OC1CE: u1 = 0,
/// CC2S [8:9]
/// Capture/Compare 2
CC2S: u2 = 0,
/// OC2FE [10:10]
/// Output compare 2 fast
OC2FE: u1 = 0,
/// OC2PE [11:11]
/// Output compare 2 preload
OC2PE: u1 = 0,
/// OC2M [12:14]
/// Output compare 2 mode
OC2M: u3 = 0,
/// OC2CE [15:15]
/// Output compare 2 clear
OC2CE: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare mode register 1 (output
pub const CCMR1_Output = Register(CCMR1_Output_val).init(base_address + 0x18);

/// CCMR1_Input
const CCMR1_Input_val = packed struct {
/// CC1S [0:1]
/// Capture/Compare 1
CC1S: u2 = 0,
/// IC1PSC [2:3]
/// Input capture 1 prescaler
IC1PSC: u2 = 0,
/// IC1F [4:7]
/// Input capture 1 filter
IC1F: u4 = 0,
/// CC2S [8:9]
/// Capture/compare 2
CC2S: u2 = 0,
/// IC2PSC [10:11]
/// Input capture 2 prescaler
IC2PSC: u2 = 0,
/// IC2F [12:15]
/// Input capture 2 filter
IC2F: u4 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare mode register 1 (input
pub const CCMR1_Input = Register(CCMR1_Input_val).init(base_address + 0x18);

/// CCMR2_Output
const CCMR2_Output_val = packed struct {
/// CC3S [0:1]
/// Capture/Compare 3
CC3S: u2 = 0,
/// OC3FE [2:2]
/// Output compare 3 fast
OC3FE: u1 = 0,
/// OC3PE [3:3]
/// Output compare 3 preload
OC3PE: u1 = 0,
/// OC3M [4:6]
/// Output compare 3 mode
OC3M: u3 = 0,
/// OC3CE [7:7]
/// Output compare 3 clear
OC3CE: u1 = 0,
/// CC4S [8:9]
/// Capture/Compare 4
CC4S: u2 = 0,
/// OC4FE [10:10]
/// Output compare 4 fast
OC4FE: u1 = 0,
/// OC4PE [11:11]
/// Output compare 4 preload
OC4PE: u1 = 0,
/// OC4M [12:14]
/// Output compare 4 mode
OC4M: u3 = 0,
/// OC4CE [15:15]
/// Output compare 4 clear
OC4CE: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare mode register 2 (output
pub const CCMR2_Output = Register(CCMR2_Output_val).init(base_address + 0x1c);

/// CCMR2_Input
const CCMR2_Input_val = packed struct {
/// CC3S [0:1]
/// Capture/Compare 3
CC3S: u2 = 0,
/// IC3PSC [2:3]
/// Input capture 3 prescaler
IC3PSC: u2 = 0,
/// IC3F [4:7]
/// Input capture 3 filter
IC3F: u4 = 0,
/// CC4S [8:9]
/// Capture/Compare 4
CC4S: u2 = 0,
/// IC4PSC [10:11]
/// Input capture 4 prescaler
IC4PSC: u2 = 0,
/// IC4F [12:15]
/// Input capture 4 filter
IC4F: u4 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare mode register 2 (input
pub const CCMR2_Input = Register(CCMR2_Input_val).init(base_address + 0x1c);

/// CCER
const CCER_val = packed struct {
/// CC1E [0:0]
/// Capture/Compare 1 output
CC1E: u1 = 0,
/// CC1P [1:1]
/// Capture/Compare 1 output
CC1P: u1 = 0,
/// unused [2:2]
_unused2: u1 = 0,
/// CC1NP [3:3]
/// Capture/Compare 1 output
CC1NP: u1 = 0,
/// CC2E [4:4]
/// Capture/Compare 2 output
CC2E: u1 = 0,
/// CC2P [5:5]
/// Capture/Compare 2 output
CC2P: u1 = 0,
/// unused [6:6]
_unused6: u1 = 0,
/// CC2NP [7:7]
/// Capture/Compare 2 output
CC2NP: u1 = 0,
/// CC3E [8:8]
/// Capture/Compare 3 output
CC3E: u1 = 0,
/// CC3P [9:9]
/// Capture/Compare 3 output
CC3P: u1 = 0,
/// unused [10:10]
_unused10: u1 = 0,
/// CC3NP [11:11]
/// Capture/Compare 3 output
CC3NP: u1 = 0,
/// CC4E [12:12]
/// Capture/Compare 4 output
CC4E: u1 = 0,
/// CC4P [13:13]
/// Capture/Compare 3 output
CC4P: u1 = 0,
/// unused [14:14]
_unused14: u1 = 0,
/// CC4NP [15:15]
/// Capture/Compare 4 output
CC4NP: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare enable
pub const CCER = Register(CCER_val).init(base_address + 0x20);

/// CNT
const CNT_val = packed struct {
/// CNT_L [0:15]
/// Low counter value
CNT_L: u16 = 0,
/// CNT_H [16:31]
/// High counter value (TIM2
CNT_H: u16 = 0,
};
/// counter
pub const CNT = Register(CNT_val).init(base_address + 0x24);

/// PSC
const PSC_val = packed struct {
/// PSC [0:15]
/// Prescaler value
PSC: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// prescaler
pub const PSC = Register(PSC_val).init(base_address + 0x28);

/// ARR
const ARR_val = packed struct {
/// ARR_L [0:15]
/// Low Auto-reload value
ARR_L: u16 = 0,
/// ARR_H [16:31]
/// High Auto-reload value (TIM2
ARR_H: u16 = 0,
};
/// auto-reload register
pub const ARR = Register(ARR_val).init(base_address + 0x2c);

/// CCR1
const CCR1_val = packed struct {
/// CCR1_L [0:15]
/// Low Capture/Compare 1
CCR1_L: u16 = 0,
/// CCR1_H [16:31]
/// High Capture/Compare 1 value (TIM2
CCR1_H: u16 = 0,
};
/// capture/compare register 1
pub const CCR1 = Register(CCR1_val).init(base_address + 0x34);

/// CCR2
const CCR2_val = packed struct {
/// CCR2_L [0:15]
/// Low Capture/Compare 2
CCR2_L: u16 = 0,
/// CCR2_H [16:31]
/// High Capture/Compare 2 value (TIM2
CCR2_H: u16 = 0,
};
/// capture/compare register 2
pub const CCR2 = Register(CCR2_val).init(base_address + 0x38);

/// CCR3
const CCR3_val = packed struct {
/// CCR3_L [0:15]
/// Low Capture/Compare value
CCR3_L: u16 = 0,
/// CCR3_H [16:31]
/// High Capture/Compare value (TIM2
CCR3_H: u16 = 0,
};
/// capture/compare register 3
pub const CCR3 = Register(CCR3_val).init(base_address + 0x3c);

/// CCR4
const CCR4_val = packed struct {
/// CCR4_L [0:15]
/// Low Capture/Compare value
CCR4_L: u16 = 0,
/// CCR4_H [16:31]
/// High Capture/Compare value (TIM2
CCR4_H: u16 = 0,
};
/// capture/compare register 4
pub const CCR4 = Register(CCR4_val).init(base_address + 0x40);

/// DCR
const DCR_val = packed struct {
/// DBA [0:4]
/// DMA base address
DBA: u5 = 0,
/// unused [5:7]
_unused5: u3 = 0,
/// DBL [8:12]
/// DMA burst length
DBL: u5 = 0,
/// unused [13:31]
_unused13: u3 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA control register
pub const DCR = Register(DCR_val).init(base_address + 0x48);

/// DMAR
const DMAR_val = packed struct {
/// DMAB [0:15]
/// DMA register for burst
DMAB: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA address for full transfer
pub const DMAR = Register(DMAR_val).init(base_address + 0x4c);

/// OR
const OR_val = packed struct {
/// ETR_RMP [0:2]
/// Timer2 ETR remap
ETR_RMP: u3 = 0,
/// TI4_RMP [3:4]
/// Internal trigger
TI4_RMP: u2 = 0,
/// unused [5:31]
_unused5: u3 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// TIM2 option register
pub const OR = Register(OR_val).init(base_address + 0x50);
};

/// General-purpose-timers
pub const TIM3 = struct {

const base_address = 0x40000400;
/// CR1
const CR1_val = packed struct {
/// CEN [0:0]
/// Counter enable
CEN: u1 = 0,
/// UDIS [1:1]
/// Update disable
UDIS: u1 = 0,
/// URS [2:2]
/// Update request source
URS: u1 = 0,
/// OPM [3:3]
/// One-pulse mode
OPM: u1 = 0,
/// DIR [4:4]
/// Direction
DIR: u1 = 0,
/// CMS [5:6]
/// Center-aligned mode
CMS: u2 = 0,
/// ARPE [7:7]
/// Auto-reload preload enable
ARPE: u1 = 0,
/// CKD [8:9]
/// Clock division
CKD: u2 = 0,
/// unused [10:31]
_unused10: u6 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// CCDS [3:3]
/// Capture/compare DMA
CCDS: u1 = 0,
/// MMS [4:6]
/// Master mode selection
MMS: u3 = 0,
/// TI1S [7:7]
/// TI1 selection
TI1S: u1 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// SMCR
const SMCR_val = packed struct {
/// SMS [0:2]
/// Slave mode selection
SMS: u3 = 0,
/// unused [3:3]
_unused3: u1 = 0,
/// TS [4:6]
/// Trigger selection
TS: u3 = 0,
/// MSM [7:7]
/// Master/Slave mode
MSM: u1 = 0,
/// ETF [8:11]
/// External trigger filter
ETF: u4 = 0,
/// ETPS [12:13]
/// External trigger prescaler
ETPS: u2 = 0,
/// ECE [14:14]
/// External clock enable
ECE: u1 = 0,
/// ETP [15:15]
/// External trigger polarity
ETP: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// slave mode control register
pub const SMCR = Register(SMCR_val).init(base_address + 0x8);

/// DIER
const DIER_val = packed struct {
/// UIE [0:0]
/// Update interrupt enable
UIE: u1 = 0,
/// CC1IE [1:1]
/// Capture/Compare 1 interrupt
CC1IE: u1 = 0,
/// CC2IE [2:2]
/// Capture/Compare 2 interrupt
CC2IE: u1 = 0,
/// CC3IE [3:3]
/// Capture/Compare 3 interrupt
CC3IE: u1 = 0,
/// CC4IE [4:4]
/// Capture/Compare 4 interrupt
CC4IE: u1 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// TIE [6:6]
/// Trigger interrupt enable
TIE: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// UDE [8:8]
/// Update DMA request enable
UDE: u1 = 0,
/// CC1DE [9:9]
/// Capture/Compare 1 DMA request
CC1DE: u1 = 0,
/// CC2DE [10:10]
/// Capture/Compare 2 DMA request
CC2DE: u1 = 0,
/// CC3DE [11:11]
/// Capture/Compare 3 DMA request
CC3DE: u1 = 0,
/// CC4DE [12:12]
/// Capture/Compare 4 DMA request
CC4DE: u1 = 0,
/// COMDE [13:13]
/// COM DMA request enable
COMDE: u1 = 0,
/// TDE [14:14]
/// Trigger DMA request enable
TDE: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA/Interrupt enable register
pub const DIER = Register(DIER_val).init(base_address + 0xc);

/// SR
const SR_val = packed struct {
/// UIF [0:0]
/// Update interrupt flag
UIF: u1 = 0,
/// CC1IF [1:1]
/// Capture/compare 1 interrupt
CC1IF: u1 = 0,
/// CC2IF [2:2]
/// Capture/Compare 2 interrupt
CC2IF: u1 = 0,
/// CC3IF [3:3]
/// Capture/Compare 3 interrupt
CC3IF: u1 = 0,
/// CC4IF [4:4]
/// Capture/Compare 4 interrupt
CC4IF: u1 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// TIF [6:6]
/// Trigger interrupt flag
TIF: u1 = 0,
/// unused [7:8]
_unused7: u1 = 0,
_unused8: u1 = 0,
/// CC1OF [9:9]
/// Capture/Compare 1 overcapture
CC1OF: u1 = 0,
/// CC2OF [10:10]
/// Capture/compare 2 overcapture
CC2OF: u1 = 0,
/// CC3OF [11:11]
/// Capture/Compare 3 overcapture
CC3OF: u1 = 0,
/// CC4OF [12:12]
/// Capture/Compare 4 overcapture
CC4OF: u1 = 0,
/// unused [13:31]
_unused13: u3 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// status register
pub const SR = Register(SR_val).init(base_address + 0x10);

/// EGR
const EGR_val = packed struct {
/// UG [0:0]
/// Update generation
UG: u1 = 0,
/// CC1G [1:1]
/// Capture/compare 1
CC1G: u1 = 0,
/// CC2G [2:2]
/// Capture/compare 2
CC2G: u1 = 0,
/// CC3G [3:3]
/// Capture/compare 3
CC3G: u1 = 0,
/// CC4G [4:4]
/// Capture/compare 4
CC4G: u1 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// TG [6:6]
/// Trigger generation
TG: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// event generation register
pub const EGR = Register(EGR_val).init(base_address + 0x14);

/// CCMR1_Output
const CCMR1_Output_val = packed struct {
/// CC1S [0:1]
/// Capture/Compare 1
CC1S: u2 = 0,
/// OC1FE [2:2]
/// Output compare 1 fast
OC1FE: u1 = 0,
/// OC1PE [3:3]
/// Output compare 1 preload
OC1PE: u1 = 0,
/// OC1M [4:6]
/// Output compare 1 mode
OC1M: u3 = 0,
/// OC1CE [7:7]
/// Output compare 1 clear
OC1CE: u1 = 0,
/// CC2S [8:9]
/// Capture/Compare 2
CC2S: u2 = 0,
/// OC2FE [10:10]
/// Output compare 2 fast
OC2FE: u1 = 0,
/// OC2PE [11:11]
/// Output compare 2 preload
OC2PE: u1 = 0,
/// OC2M [12:14]
/// Output compare 2 mode
OC2M: u3 = 0,
/// OC2CE [15:15]
/// Output compare 2 clear
OC2CE: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare mode register 1 (output
pub const CCMR1_Output = Register(CCMR1_Output_val).init(base_address + 0x18);

/// CCMR1_Input
const CCMR1_Input_val = packed struct {
/// CC1S [0:1]
/// Capture/Compare 1
CC1S: u2 = 0,
/// IC1PSC [2:3]
/// Input capture 1 prescaler
IC1PSC: u2 = 0,
/// IC1F [4:7]
/// Input capture 1 filter
IC1F: u4 = 0,
/// CC2S [8:9]
/// Capture/compare 2
CC2S: u2 = 0,
/// IC2PSC [10:11]
/// Input capture 2 prescaler
IC2PSC: u2 = 0,
/// IC2F [12:15]
/// Input capture 2 filter
IC2F: u4 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare mode register 1 (input
pub const CCMR1_Input = Register(CCMR1_Input_val).init(base_address + 0x18);

/// CCMR2_Output
const CCMR2_Output_val = packed struct {
/// CC3S [0:1]
/// Capture/Compare 3
CC3S: u2 = 0,
/// OC3FE [2:2]
/// Output compare 3 fast
OC3FE: u1 = 0,
/// OC3PE [3:3]
/// Output compare 3 preload
OC3PE: u1 = 0,
/// OC3M [4:6]
/// Output compare 3 mode
OC3M: u3 = 0,
/// OC3CE [7:7]
/// Output compare 3 clear
OC3CE: u1 = 0,
/// CC4S [8:9]
/// Capture/Compare 4
CC4S: u2 = 0,
/// OC4FE [10:10]
/// Output compare 4 fast
OC4FE: u1 = 0,
/// OC4PE [11:11]
/// Output compare 4 preload
OC4PE: u1 = 0,
/// OC4M [12:14]
/// Output compare 4 mode
OC4M: u3 = 0,
/// OC4CE [15:15]
/// Output compare 4 clear
OC4CE: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare mode register 2 (output
pub const CCMR2_Output = Register(CCMR2_Output_val).init(base_address + 0x1c);

/// CCMR2_Input
const CCMR2_Input_val = packed struct {
/// CC3S [0:1]
/// Capture/Compare 3
CC3S: u2 = 0,
/// IC3PSC [2:3]
/// Input capture 3 prescaler
IC3PSC: u2 = 0,
/// IC3F [4:7]
/// Input capture 3 filter
IC3F: u4 = 0,
/// CC4S [8:9]
/// Capture/Compare 4
CC4S: u2 = 0,
/// IC4PSC [10:11]
/// Input capture 4 prescaler
IC4PSC: u2 = 0,
/// IC4F [12:15]
/// Input capture 4 filter
IC4F: u4 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare mode register 2 (input
pub const CCMR2_Input = Register(CCMR2_Input_val).init(base_address + 0x1c);

/// CCER
const CCER_val = packed struct {
/// CC1E [0:0]
/// Capture/Compare 1 output
CC1E: u1 = 0,
/// CC1P [1:1]
/// Capture/Compare 1 output
CC1P: u1 = 0,
/// unused [2:2]
_unused2: u1 = 0,
/// CC1NP [3:3]
/// Capture/Compare 1 output
CC1NP: u1 = 0,
/// CC2E [4:4]
/// Capture/Compare 2 output
CC2E: u1 = 0,
/// CC2P [5:5]
/// Capture/Compare 2 output
CC2P: u1 = 0,
/// unused [6:6]
_unused6: u1 = 0,
/// CC2NP [7:7]
/// Capture/Compare 2 output
CC2NP: u1 = 0,
/// CC3E [8:8]
/// Capture/Compare 3 output
CC3E: u1 = 0,
/// CC3P [9:9]
/// Capture/Compare 3 output
CC3P: u1 = 0,
/// unused [10:10]
_unused10: u1 = 0,
/// CC3NP [11:11]
/// Capture/Compare 3 output
CC3NP: u1 = 0,
/// CC4E [12:12]
/// Capture/Compare 4 output
CC4E: u1 = 0,
/// CC4P [13:13]
/// Capture/Compare 3 output
CC4P: u1 = 0,
/// unused [14:14]
_unused14: u1 = 0,
/// CC4NP [15:15]
/// Capture/Compare 4 output
CC4NP: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare enable
pub const CCER = Register(CCER_val).init(base_address + 0x20);

/// CNT
const CNT_val = packed struct {
/// CNT_L [0:15]
/// Low counter value
CNT_L: u16 = 0,
/// CNT_H [16:31]
/// High counter value (TIM2
CNT_H: u16 = 0,
};
/// counter
pub const CNT = Register(CNT_val).init(base_address + 0x24);

/// PSC
const PSC_val = packed struct {
/// PSC [0:15]
/// Prescaler value
PSC: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// prescaler
pub const PSC = Register(PSC_val).init(base_address + 0x28);

/// ARR
const ARR_val = packed struct {
/// ARR_L [0:15]
/// Low Auto-reload value
ARR_L: u16 = 0,
/// ARR_H [16:31]
/// High Auto-reload value (TIM2
ARR_H: u16 = 0,
};
/// auto-reload register
pub const ARR = Register(ARR_val).init(base_address + 0x2c);

/// CCR1
const CCR1_val = packed struct {
/// CCR1_L [0:15]
/// Low Capture/Compare 1
CCR1_L: u16 = 0,
/// CCR1_H [16:31]
/// High Capture/Compare 1 value (TIM2
CCR1_H: u16 = 0,
};
/// capture/compare register 1
pub const CCR1 = Register(CCR1_val).init(base_address + 0x34);

/// CCR2
const CCR2_val = packed struct {
/// CCR2_L [0:15]
/// Low Capture/Compare 2
CCR2_L: u16 = 0,
/// CCR2_H [16:31]
/// High Capture/Compare 2 value (TIM2
CCR2_H: u16 = 0,
};
/// capture/compare register 2
pub const CCR2 = Register(CCR2_val).init(base_address + 0x38);

/// CCR3
const CCR3_val = packed struct {
/// CCR3_L [0:15]
/// Low Capture/Compare value
CCR3_L: u16 = 0,
/// CCR3_H [16:31]
/// High Capture/Compare value (TIM2
CCR3_H: u16 = 0,
};
/// capture/compare register 3
pub const CCR3 = Register(CCR3_val).init(base_address + 0x3c);

/// CCR4
const CCR4_val = packed struct {
/// CCR4_L [0:15]
/// Low Capture/Compare value
CCR4_L: u16 = 0,
/// CCR4_H [16:31]
/// High Capture/Compare value (TIM2
CCR4_H: u16 = 0,
};
/// capture/compare register 4
pub const CCR4 = Register(CCR4_val).init(base_address + 0x40);

/// DCR
const DCR_val = packed struct {
/// DBA [0:4]
/// DMA base address
DBA: u5 = 0,
/// unused [5:7]
_unused5: u3 = 0,
/// DBL [8:12]
/// DMA burst length
DBL: u5 = 0,
/// unused [13:31]
_unused13: u3 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA control register
pub const DCR = Register(DCR_val).init(base_address + 0x48);

/// DMAR
const DMAR_val = packed struct {
/// DMAB [0:15]
/// DMA register for burst
DMAB: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA address for full transfer
pub const DMAR = Register(DMAR_val).init(base_address + 0x4c);

/// OR
const OR_val = packed struct {
/// ETR_RMP [0:2]
/// Timer2 ETR remap
ETR_RMP: u3 = 0,
/// TI4_RMP [3:4]
/// Internal trigger
TI4_RMP: u2 = 0,
/// unused [5:31]
_unused5: u3 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// TIM2 option register
pub const OR = Register(OR_val).init(base_address + 0x50);
};

/// General purpose timers
pub const TIM15 = struct {

const base_address = 0x40014000;
/// CR1
const CR1_val = packed struct {
/// CEN [0:0]
/// Counter enable
CEN: u1 = 0,
/// UDIS [1:1]
/// Update disable
UDIS: u1 = 0,
/// URS [2:2]
/// Update request source
URS: u1 = 0,
/// OPM [3:3]
/// One-pulse mode
OPM: u1 = 0,
/// unused [4:6]
_unused4: u3 = 0,
/// ARPE [7:7]
/// Auto-reload preload enable
ARPE: u1 = 0,
/// CKD [8:9]
/// Clock division
CKD: u2 = 0,
/// unused [10:10]
_unused10: u1 = 0,
/// UIFREMAP [11:11]
/// UIF status bit remapping
UIFREMAP: u1 = 0,
/// unused [12:31]
_unused12: u4 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// CCPC [0:0]
/// Capture/compare preloaded
CCPC: u1 = 0,
/// unused [1:1]
_unused1: u1 = 0,
/// CCUS [2:2]
/// Capture/compare control update
CCUS: u1 = 0,
/// CCDS [3:3]
/// Capture/compare DMA
CCDS: u1 = 0,
/// unused [4:7]
_unused4: u4 = 0,
/// OIS1 [8:8]
/// Output Idle state 1
OIS1: u1 = 0,
/// OIS1N [9:9]
/// Output Idle state 1
OIS1N: u1 = 0,
/// unused [10:31]
_unused10: u6 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// DIER
const DIER_val = packed struct {
/// UIE [0:0]
/// Update interrupt enable
UIE: u1 = 0,
/// CC1IE [1:1]
/// Capture/Compare 1 interrupt
CC1IE: u1 = 0,
/// unused [2:4]
_unused2: u3 = 0,
/// COMIE [5:5]
/// COM interrupt enable
COMIE: u1 = 0,
/// TIE [6:6]
/// Trigger interrupt enable
TIE: u1 = 0,
/// BIE [7:7]
/// Break interrupt enable
BIE: u1 = 0,
/// UDE [8:8]
/// Update DMA request enable
UDE: u1 = 0,
/// CC1DE [9:9]
/// Capture/Compare 1 DMA request
CC1DE: u1 = 0,
/// unused [10:12]
_unused10: u3 = 0,
/// COMDE [13:13]
/// COM DMA request enable
COMDE: u1 = 0,
/// TDE [14:14]
/// Trigger DMA request enable
TDE: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA/Interrupt enable register
pub const DIER = Register(DIER_val).init(base_address + 0xc);

/// SR
const SR_val = packed struct {
/// UIF [0:0]
/// Update interrupt flag
UIF: u1 = 0,
/// CC1IF [1:1]
/// Capture/compare 1 interrupt
CC1IF: u1 = 0,
/// unused [2:4]
_unused2: u3 = 0,
/// COMIF [5:5]
/// COM interrupt flag
COMIF: u1 = 0,
/// TIF [6:6]
/// Trigger interrupt flag
TIF: u1 = 0,
/// BIF [7:7]
/// Break interrupt flag
BIF: u1 = 0,
/// unused [8:8]
_unused8: u1 = 0,
/// CC1OF [9:9]
/// Capture/Compare 1 overcapture
CC1OF: u1 = 0,
/// unused [10:31]
_unused10: u6 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// status register
pub const SR = Register(SR_val).init(base_address + 0x10);

/// EGR
const EGR_val = packed struct {
/// UG [0:0]
/// Update generation
UG: u1 = 0,
/// CC1G [1:1]
/// Capture/compare 1
CC1G: u1 = 0,
/// unused [2:4]
_unused2: u3 = 0,
/// COMG [5:5]
/// Capture/Compare control update
COMG: u1 = 0,
/// TG [6:6]
/// Trigger generation
TG: u1 = 0,
/// BG [7:7]
/// Break generation
BG: u1 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// event generation register
pub const EGR = Register(EGR_val).init(base_address + 0x14);

/// CCMR1_Output
const CCMR1_Output_val = packed struct {
/// CC1S [0:1]
/// Capture/Compare 1
CC1S: u2 = 0,
/// OC1FE [2:2]
/// Output Compare 1 fast
OC1FE: u1 = 0,
/// OC1PE [3:3]
/// Output Compare 1 preload
OC1PE: u1 = 0,
/// OC1M [4:6]
/// Output Compare 1 mode
OC1M: u3 = 0,
/// unused [7:15]
_unused7: u1 = 0,
_unused8: u8 = 0,
/// OC1M_2 [16:16]
/// Output Compare 1 mode
OC1M_2: u1 = 0,
/// unused [17:31]
_unused17: u7 = 0,
_unused24: u8 = 0,
};
/// capture/compare mode register (output
pub const CCMR1_Output = Register(CCMR1_Output_val).init(base_address + 0x18);

/// CCMR1_Input
const CCMR1_Input_val = packed struct {
/// CC1S [0:1]
/// Capture/Compare 1
CC1S: u2 = 0,
/// IC1PSC [2:3]
/// Input capture 1 prescaler
IC1PSC: u2 = 0,
/// IC1F [4:7]
/// Input capture 1 filter
IC1F: u4 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare mode register 1 (input
pub const CCMR1_Input = Register(CCMR1_Input_val).init(base_address + 0x18);

/// CCER
const CCER_val = packed struct {
/// CC1E [0:0]
/// Capture/Compare 1 output
CC1E: u1 = 0,
/// CC1P [1:1]
/// Capture/Compare 1 output
CC1P: u1 = 0,
/// CC1NE [2:2]
/// Capture/Compare 1 complementary output
CC1NE: u1 = 0,
/// CC1NP [3:3]
/// Capture/Compare 1 output
CC1NP: u1 = 0,
/// unused [4:31]
_unused4: u4 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare enable
pub const CCER = Register(CCER_val).init(base_address + 0x20);

/// CNT
const CNT_val = packed struct {
/// CNT [0:15]
/// counter value
CNT: u16 = 0,
/// unused [16:30]
_unused16: u8 = 0,
_unused24: u7 = 0,
/// UIFCPY [31:31]
/// UIF Copy
UIFCPY: u1 = 0,
};
/// counter
pub const CNT = Register(CNT_val).init(base_address + 0x24);

/// PSC
const PSC_val = packed struct {
/// PSC [0:15]
/// Prescaler value
PSC: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// prescaler
pub const PSC = Register(PSC_val).init(base_address + 0x28);

/// ARR
const ARR_val = packed struct {
/// ARR [0:15]
/// Auto-reload value
ARR: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// auto-reload register
pub const ARR = Register(ARR_val).init(base_address + 0x2c);

/// RCR
const RCR_val = packed struct {
/// REP [0:7]
/// Repetition counter value
REP: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// repetition counter register
pub const RCR = Register(RCR_val).init(base_address + 0x30);

/// CCR1
const CCR1_val = packed struct {
/// CCR1 [0:15]
/// Capture/Compare 1 value
CCR1: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare register 1
pub const CCR1 = Register(CCR1_val).init(base_address + 0x34);

/// BDTR
const BDTR_val = packed struct {
/// DTG [0:7]
/// Dead-time generator setup
DTG: u8 = 0,
/// LOCK [8:9]
/// Lock configuration
LOCK: u2 = 0,
/// OSSI [10:10]
/// Off-state selection for Idle
OSSI: u1 = 0,
/// OSSR [11:11]
/// Off-state selection for Run
OSSR: u1 = 0,
/// BKE [12:12]
/// Break enable
BKE: u1 = 0,
/// BKP [13:13]
/// Break polarity
BKP: u1 = 0,
/// AOE [14:14]
/// Automatic output enable
AOE: u1 = 0,
/// MOE [15:15]
/// Main output enable
MOE: u1 = 0,
/// BKF [16:19]
/// Break filter
BKF: u4 = 0,
/// unused [20:31]
_unused20: u4 = 0,
_unused24: u8 = 0,
};
/// break and dead-time register
pub const BDTR = Register(BDTR_val).init(base_address + 0x44);

/// DCR
const DCR_val = packed struct {
/// DBA [0:4]
/// DMA base address
DBA: u5 = 0,
/// unused [5:7]
_unused5: u3 = 0,
/// DBL [8:12]
/// DMA burst length
DBL: u5 = 0,
/// unused [13:31]
_unused13: u3 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA control register
pub const DCR = Register(DCR_val).init(base_address + 0x48);

/// DMAR
const DMAR_val = packed struct {
/// DMAB [0:15]
/// DMA register for burst
DMAB: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA address for full transfer
pub const DMAR = Register(DMAR_val).init(base_address + 0x4c);
};

/// General purpose timers
pub const TIM16 = struct {

const base_address = 0x40014400;
/// CR1
const CR1_val = packed struct {
/// CEN [0:0]
/// Counter enable
CEN: u1 = 0,
/// UDIS [1:1]
/// Update disable
UDIS: u1 = 0,
/// URS [2:2]
/// Update request source
URS: u1 = 0,
/// OPM [3:3]
/// One-pulse mode
OPM: u1 = 0,
/// unused [4:6]
_unused4: u3 = 0,
/// ARPE [7:7]
/// Auto-reload preload enable
ARPE: u1 = 0,
/// CKD [8:9]
/// Clock division
CKD: u2 = 0,
/// unused [10:10]
_unused10: u1 = 0,
/// UIFREMAP [11:11]
/// UIF status bit remapping
UIFREMAP: u1 = 0,
/// unused [12:31]
_unused12: u4 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// CCPC [0:0]
/// Capture/compare preloaded
CCPC: u1 = 0,
/// unused [1:1]
_unused1: u1 = 0,
/// CCUS [2:2]
/// Capture/compare control update
CCUS: u1 = 0,
/// CCDS [3:3]
/// Capture/compare DMA
CCDS: u1 = 0,
/// unused [4:7]
_unused4: u4 = 0,
/// OIS1 [8:8]
/// Output Idle state 1
OIS1: u1 = 0,
/// OIS1N [9:9]
/// Output Idle state 1
OIS1N: u1 = 0,
/// unused [10:31]
_unused10: u6 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// DIER
const DIER_val = packed struct {
/// UIE [0:0]
/// Update interrupt enable
UIE: u1 = 0,
/// CC1IE [1:1]
/// Capture/Compare 1 interrupt
CC1IE: u1 = 0,
/// unused [2:4]
_unused2: u3 = 0,
/// COMIE [5:5]
/// COM interrupt enable
COMIE: u1 = 0,
/// TIE [6:6]
/// Trigger interrupt enable
TIE: u1 = 0,
/// BIE [7:7]
/// Break interrupt enable
BIE: u1 = 0,
/// UDE [8:8]
/// Update DMA request enable
UDE: u1 = 0,
/// CC1DE [9:9]
/// Capture/Compare 1 DMA request
CC1DE: u1 = 0,
/// unused [10:12]
_unused10: u3 = 0,
/// COMDE [13:13]
/// COM DMA request enable
COMDE: u1 = 0,
/// TDE [14:14]
/// Trigger DMA request enable
TDE: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA/Interrupt enable register
pub const DIER = Register(DIER_val).init(base_address + 0xc);

/// SR
const SR_val = packed struct {
/// UIF [0:0]
/// Update interrupt flag
UIF: u1 = 0,
/// CC1IF [1:1]
/// Capture/compare 1 interrupt
CC1IF: u1 = 0,
/// unused [2:4]
_unused2: u3 = 0,
/// COMIF [5:5]
/// COM interrupt flag
COMIF: u1 = 0,
/// TIF [6:6]
/// Trigger interrupt flag
TIF: u1 = 0,
/// BIF [7:7]
/// Break interrupt flag
BIF: u1 = 0,
/// unused [8:8]
_unused8: u1 = 0,
/// CC1OF [9:9]
/// Capture/Compare 1 overcapture
CC1OF: u1 = 0,
/// unused [10:31]
_unused10: u6 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// status register
pub const SR = Register(SR_val).init(base_address + 0x10);

/// EGR
const EGR_val = packed struct {
/// UG [0:0]
/// Update generation
UG: u1 = 0,
/// CC1G [1:1]
/// Capture/compare 1
CC1G: u1 = 0,
/// unused [2:4]
_unused2: u3 = 0,
/// COMG [5:5]
/// Capture/Compare control update
COMG: u1 = 0,
/// TG [6:6]
/// Trigger generation
TG: u1 = 0,
/// BG [7:7]
/// Break generation
BG: u1 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// event generation register
pub const EGR = Register(EGR_val).init(base_address + 0x14);

/// CCMR1_Output
const CCMR1_Output_val = packed struct {
/// CC1S [0:1]
/// Capture/Compare 1
CC1S: u2 = 0,
/// OC1FE [2:2]
/// Output Compare 1 fast
OC1FE: u1 = 0,
/// OC1PE [3:3]
/// Output Compare 1 preload
OC1PE: u1 = 0,
/// OC1M [4:6]
/// Output Compare 1 mode
OC1M: u3 = 0,
/// unused [7:15]
_unused7: u1 = 0,
_unused8: u8 = 0,
/// OC1M_2 [16:16]
/// Output Compare 1 mode
OC1M_2: u1 = 0,
/// unused [17:31]
_unused17: u7 = 0,
_unused24: u8 = 0,
};
/// capture/compare mode register (output
pub const CCMR1_Output = Register(CCMR1_Output_val).init(base_address + 0x18);

/// CCMR1_Input
const CCMR1_Input_val = packed struct {
/// CC1S [0:1]
/// Capture/Compare 1
CC1S: u2 = 0,
/// IC1PSC [2:3]
/// Input capture 1 prescaler
IC1PSC: u2 = 0,
/// IC1F [4:7]
/// Input capture 1 filter
IC1F: u4 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare mode register 1 (input
pub const CCMR1_Input = Register(CCMR1_Input_val).init(base_address + 0x18);

/// CCER
const CCER_val = packed struct {
/// CC1E [0:0]
/// Capture/Compare 1 output
CC1E: u1 = 0,
/// CC1P [1:1]
/// Capture/Compare 1 output
CC1P: u1 = 0,
/// CC1NE [2:2]
/// Capture/Compare 1 complementary output
CC1NE: u1 = 0,
/// CC1NP [3:3]
/// Capture/Compare 1 output
CC1NP: u1 = 0,
/// unused [4:31]
_unused4: u4 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare enable
pub const CCER = Register(CCER_val).init(base_address + 0x20);

/// CNT
const CNT_val = packed struct {
/// CNT [0:15]
/// counter value
CNT: u16 = 0,
/// unused [16:30]
_unused16: u8 = 0,
_unused24: u7 = 0,
/// UIFCPY [31:31]
/// UIF Copy
UIFCPY: u1 = 0,
};
/// counter
pub const CNT = Register(CNT_val).init(base_address + 0x24);

/// PSC
const PSC_val = packed struct {
/// PSC [0:15]
/// Prescaler value
PSC: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// prescaler
pub const PSC = Register(PSC_val).init(base_address + 0x28);

/// ARR
const ARR_val = packed struct {
/// ARR [0:15]
/// Auto-reload value
ARR: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// auto-reload register
pub const ARR = Register(ARR_val).init(base_address + 0x2c);

/// RCR
const RCR_val = packed struct {
/// REP [0:7]
/// Repetition counter value
REP: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// repetition counter register
pub const RCR = Register(RCR_val).init(base_address + 0x30);

/// CCR1
const CCR1_val = packed struct {
/// CCR1 [0:15]
/// Capture/Compare 1 value
CCR1: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare register 1
pub const CCR1 = Register(CCR1_val).init(base_address + 0x34);

/// BDTR
const BDTR_val = packed struct {
/// DTG [0:7]
/// Dead-time generator setup
DTG: u8 = 0,
/// LOCK [8:9]
/// Lock configuration
LOCK: u2 = 0,
/// OSSI [10:10]
/// Off-state selection for Idle
OSSI: u1 = 0,
/// OSSR [11:11]
/// Off-state selection for Run
OSSR: u1 = 0,
/// BKE [12:12]
/// Break enable
BKE: u1 = 0,
/// BKP [13:13]
/// Break polarity
BKP: u1 = 0,
/// AOE [14:14]
/// Automatic output enable
AOE: u1 = 0,
/// MOE [15:15]
/// Main output enable
MOE: u1 = 0,
/// BKF [16:19]
/// Break filter
BKF: u4 = 0,
/// unused [20:31]
_unused20: u4 = 0,
_unused24: u8 = 0,
};
/// break and dead-time register
pub const BDTR = Register(BDTR_val).init(base_address + 0x44);

/// DCR
const DCR_val = packed struct {
/// DBA [0:4]
/// DMA base address
DBA: u5 = 0,
/// unused [5:7]
_unused5: u3 = 0,
/// DBL [8:12]
/// DMA burst length
DBL: u5 = 0,
/// unused [13:31]
_unused13: u3 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA control register
pub const DCR = Register(DCR_val).init(base_address + 0x48);

/// DMAR
const DMAR_val = packed struct {
/// DMAB [0:15]
/// DMA register for burst
DMAB: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA address for full transfer
pub const DMAR = Register(DMAR_val).init(base_address + 0x4c);

/// OR1
const OR1_val = packed struct {
/// TI1_RMP [0:1]
/// Input capture 1 remap
TI1_RMP: u2 = 0,
/// unused [2:31]
_unused2: u6 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// TIM16 option register 1
pub const OR1 = Register(OR1_val).init(base_address + 0x50);

/// OR2
const OR2_val = packed struct {
/// BKINE [0:0]
/// BRK BKIN input enable
BKINE: u1 = 0,
/// BKCMP1E [1:1]
/// BRK COMP1 enable
BKCMP1E: u1 = 0,
/// BKCMP2E [2:2]
/// BRK COMP2 enable
BKCMP2E: u1 = 0,
/// unused [3:7]
_unused3: u5 = 0,
/// BKDFBK1E [8:8]
/// BRK DFSDM_BREAK1 enable
BKDFBK1E: u1 = 0,
/// BKINP [9:9]
/// BRK BKIN input polarity
BKINP: u1 = 0,
/// BKCMP1P [10:10]
/// BRK COMP1 input polarity
BKCMP1P: u1 = 0,
/// BKCMP2P [11:11]
/// BRK COMP2 input polarit
BKCMP2P: u1 = 0,
/// unused [12:31]
_unused12: u4 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// TIM17 option register 1
pub const OR2 = Register(OR2_val).init(base_address + 0x60);
};

/// Advanced-timers
pub const TIM1 = struct {

const base_address = 0x40012c00;
/// CR1
const CR1_val = packed struct {
/// CEN [0:0]
/// Counter enable
CEN: u1 = 0,
/// UDIS [1:1]
/// Update disable
UDIS: u1 = 0,
/// URS [2:2]
/// Update request source
URS: u1 = 0,
/// OPM [3:3]
/// One-pulse mode
OPM: u1 = 0,
/// DIR [4:4]
/// Direction
DIR: u1 = 0,
/// CMS [5:6]
/// Center-aligned mode
CMS: u2 = 0,
/// ARPE [7:7]
/// Auto-reload preload enable
ARPE: u1 = 0,
/// CKD [8:9]
/// Clock division
CKD: u2 = 0,
/// unused [10:31]
_unused10: u6 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// CCPC [0:0]
/// Capture/compare preloaded
CCPC: u1 = 0,
/// unused [1:1]
_unused1: u1 = 0,
/// CCUS [2:2]
/// Capture/compare control update
CCUS: u1 = 0,
/// CCDS [3:3]
/// Capture/compare DMA
CCDS: u1 = 0,
/// MMS [4:6]
/// Master mode selection
MMS: u3 = 0,
/// TI1S [7:7]
/// TI1 selection
TI1S: u1 = 0,
/// OIS1 [8:8]
/// Output Idle state 1
OIS1: u1 = 0,
/// OIS1N [9:9]
/// Output Idle state 1
OIS1N: u1 = 0,
/// OIS2 [10:10]
/// Output Idle state 2
OIS2: u1 = 0,
/// OIS2N [11:11]
/// Output Idle state 2
OIS2N: u1 = 0,
/// OIS3 [12:12]
/// Output Idle state 3
OIS3: u1 = 0,
/// OIS3N [13:13]
/// Output Idle state 3
OIS3N: u1 = 0,
/// OIS4 [14:14]
/// Output Idle state 4
OIS4: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// SMCR
const SMCR_val = packed struct {
/// SMS [0:2]
/// Slave mode selection
SMS: u3 = 0,
/// unused [3:3]
_unused3: u1 = 0,
/// TS [4:6]
/// Trigger selection
TS: u3 = 0,
/// MSM [7:7]
/// Master/Slave mode
MSM: u1 = 0,
/// ETF [8:11]
/// External trigger filter
ETF: u4 = 0,
/// ETPS [12:13]
/// External trigger prescaler
ETPS: u2 = 0,
/// ECE [14:14]
/// External clock enable
ECE: u1 = 0,
/// ETP [15:15]
/// External trigger polarity
ETP: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// slave mode control register
pub const SMCR = Register(SMCR_val).init(base_address + 0x8);

/// DIER
const DIER_val = packed struct {
/// UIE [0:0]
/// Update interrupt enable
UIE: u1 = 0,
/// CC1IE [1:1]
/// Capture/Compare 1 interrupt
CC1IE: u1 = 0,
/// CC2IE [2:2]
/// Capture/Compare 2 interrupt
CC2IE: u1 = 0,
/// CC3IE [3:3]
/// Capture/Compare 3 interrupt
CC3IE: u1 = 0,
/// CC4IE [4:4]
/// Capture/Compare 4 interrupt
CC4IE: u1 = 0,
/// COMIE [5:5]
/// COM interrupt enable
COMIE: u1 = 0,
/// TIE [6:6]
/// Trigger interrupt enable
TIE: u1 = 0,
/// BIE [7:7]
/// Break interrupt enable
BIE: u1 = 0,
/// UDE [8:8]
/// Update DMA request enable
UDE: u1 = 0,
/// CC1DE [9:9]
/// Capture/Compare 1 DMA request
CC1DE: u1 = 0,
/// CC2DE [10:10]
/// Capture/Compare 2 DMA request
CC2DE: u1 = 0,
/// CC3DE [11:11]
/// Capture/Compare 3 DMA request
CC3DE: u1 = 0,
/// CC4DE [12:12]
/// Capture/Compare 4 DMA request
CC4DE: u1 = 0,
/// COMDE [13:13]
/// COM DMA request enable
COMDE: u1 = 0,
/// TDE [14:14]
/// Trigger DMA request enable
TDE: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA/Interrupt enable register
pub const DIER = Register(DIER_val).init(base_address + 0xc);

/// SR
const SR_val = packed struct {
/// UIF [0:0]
/// Update interrupt flag
UIF: u1 = 0,
/// CC1IF [1:1]
/// Capture/compare 1 interrupt
CC1IF: u1 = 0,
/// CC2IF [2:2]
/// Capture/Compare 2 interrupt
CC2IF: u1 = 0,
/// CC3IF [3:3]
/// Capture/Compare 3 interrupt
CC3IF: u1 = 0,
/// CC4IF [4:4]
/// Capture/Compare 4 interrupt
CC4IF: u1 = 0,
/// COMIF [5:5]
/// COM interrupt flag
COMIF: u1 = 0,
/// TIF [6:6]
/// Trigger interrupt flag
TIF: u1 = 0,
/// BIF [7:7]
/// Break interrupt flag
BIF: u1 = 0,
/// unused [8:8]
_unused8: u1 = 0,
/// CC1OF [9:9]
/// Capture/Compare 1 overcapture
CC1OF: u1 = 0,
/// CC2OF [10:10]
/// Capture/compare 2 overcapture
CC2OF: u1 = 0,
/// CC3OF [11:11]
/// Capture/Compare 3 overcapture
CC3OF: u1 = 0,
/// CC4OF [12:12]
/// Capture/Compare 4 overcapture
CC4OF: u1 = 0,
/// unused [13:31]
_unused13: u3 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// status register
pub const SR = Register(SR_val).init(base_address + 0x10);

/// EGR
const EGR_val = packed struct {
/// UG [0:0]
/// Update generation
UG: u1 = 0,
/// CC1G [1:1]
/// Capture/compare 1
CC1G: u1 = 0,
/// CC2G [2:2]
/// Capture/compare 2
CC2G: u1 = 0,
/// CC3G [3:3]
/// Capture/compare 3
CC3G: u1 = 0,
/// CC4G [4:4]
/// Capture/compare 4
CC4G: u1 = 0,
/// COMG [5:5]
/// Capture/Compare control update
COMG: u1 = 0,
/// TG [6:6]
/// Trigger generation
TG: u1 = 0,
/// BG [7:7]
/// Break generation
BG: u1 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// event generation register
pub const EGR = Register(EGR_val).init(base_address + 0x14);

/// CCMR1_Output
const CCMR1_Output_val = packed struct {
/// CC1S [0:1]
/// Capture/Compare 1
CC1S: u2 = 0,
/// OC1FE [2:2]
/// Output Compare 1 fast
OC1FE: u1 = 0,
/// OC1PE [3:3]
/// Output Compare 1 preload
OC1PE: u1 = 0,
/// OC1M [4:6]
/// Output Compare 1 mode
OC1M: u3 = 0,
/// OC1CE [7:7]
/// Output Compare 1 clear
OC1CE: u1 = 0,
/// CC2S [8:9]
/// Capture/Compare 2
CC2S: u2 = 0,
/// OC2FE [10:10]
/// Output Compare 2 fast
OC2FE: u1 = 0,
/// OC2PE [11:11]
/// Output Compare 2 preload
OC2PE: u1 = 0,
/// OC2M [12:14]
/// Output Compare 2 mode
OC2M: u3 = 0,
/// OC2CE [15:15]
/// Output Compare 2 clear
OC2CE: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare mode register 1 (output
pub const CCMR1_Output = Register(CCMR1_Output_val).init(base_address + 0x18);

/// CCMR1_Input
const CCMR1_Input_val = packed struct {
/// CC1S [0:1]
/// Capture/Compare 1
CC1S: u2 = 0,
/// ICPCS [2:3]
/// Input capture 1 prescaler
ICPCS: u2 = 0,
/// IC1F [4:7]
/// Input capture 1 filter
IC1F: u4 = 0,
/// CC2S [8:9]
/// Capture/Compare 2
CC2S: u2 = 0,
/// IC2PCS [10:11]
/// Input capture 2 prescaler
IC2PCS: u2 = 0,
/// IC2F [12:15]
/// Input capture 2 filter
IC2F: u4 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare mode register 1 (input
pub const CCMR1_Input = Register(CCMR1_Input_val).init(base_address + 0x18);

/// CCMR2_Output
const CCMR2_Output_val = packed struct {
/// CC3S [0:1]
/// Capture/Compare 3
CC3S: u2 = 0,
/// OC3FE [2:2]
/// Output compare 3 fast
OC3FE: u1 = 0,
/// OC3PE [3:3]
/// Output compare 3 preload
OC3PE: u1 = 0,
/// OC3M [4:6]
/// Output compare 3 mode
OC3M: u3 = 0,
/// OC3CE [7:7]
/// Output compare 3 clear
OC3CE: u1 = 0,
/// CC4S [8:9]
/// Capture/Compare 4
CC4S: u2 = 0,
/// OC4FE [10:10]
/// Output compare 4 fast
OC4FE: u1 = 0,
/// OC4PE [11:11]
/// Output compare 4 preload
OC4PE: u1 = 0,
/// OC4M [12:14]
/// Output compare 4 mode
OC4M: u3 = 0,
/// OC4CE [15:15]
/// Output compare 4 clear
OC4CE: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare mode register 2 (output
pub const CCMR2_Output = Register(CCMR2_Output_val).init(base_address + 0x1c);

/// CCMR2_Input
const CCMR2_Input_val = packed struct {
/// CC3S [0:1]
/// Capture/compare 3
CC3S: u2 = 0,
/// IC3PSC [2:3]
/// Input capture 3 prescaler
IC3PSC: u2 = 0,
/// IC3F [4:7]
/// Input capture 3 filter
IC3F: u4 = 0,
/// CC4S [8:9]
/// Capture/Compare 4
CC4S: u2 = 0,
/// IC4PSC [10:11]
/// Input capture 4 prescaler
IC4PSC: u2 = 0,
/// IC4F [12:15]
/// Input capture 4 filter
IC4F: u4 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare mode register 2 (input
pub const CCMR2_Input = Register(CCMR2_Input_val).init(base_address + 0x1c);

/// CCER
const CCER_val = packed struct {
/// CC1E [0:0]
/// Capture/Compare 1 output
CC1E: u1 = 0,
/// CC1P [1:1]
/// Capture/Compare 1 output
CC1P: u1 = 0,
/// CC1NE [2:2]
/// Capture/Compare 1 complementary output
CC1NE: u1 = 0,
/// CC1NP [3:3]
/// Capture/Compare 1 output
CC1NP: u1 = 0,
/// CC2E [4:4]
/// Capture/Compare 2 output
CC2E: u1 = 0,
/// CC2P [5:5]
/// Capture/Compare 2 output
CC2P: u1 = 0,
/// CC2NE [6:6]
/// Capture/Compare 2 complementary output
CC2NE: u1 = 0,
/// CC2NP [7:7]
/// Capture/Compare 2 output
CC2NP: u1 = 0,
/// CC3E [8:8]
/// Capture/Compare 3 output
CC3E: u1 = 0,
/// CC3P [9:9]
/// Capture/Compare 3 output
CC3P: u1 = 0,
/// CC3NE [10:10]
/// Capture/Compare 3 complementary output
CC3NE: u1 = 0,
/// CC3NP [11:11]
/// Capture/Compare 3 output
CC3NP: u1 = 0,
/// CC4E [12:12]
/// Capture/Compare 4 output
CC4E: u1 = 0,
/// CC4P [13:13]
/// Capture/Compare 3 output
CC4P: u1 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare enable
pub const CCER = Register(CCER_val).init(base_address + 0x20);

/// CNT
const CNT_val = packed struct {
/// CNT [0:15]
/// counter value
CNT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// counter
pub const CNT = Register(CNT_val).init(base_address + 0x24);

/// PSC
const PSC_val = packed struct {
/// PSC [0:15]
/// Prescaler value
PSC: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// prescaler
pub const PSC = Register(PSC_val).init(base_address + 0x28);

/// ARR
const ARR_val = packed struct {
/// ARR [0:15]
/// Auto-reload value
ARR: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// auto-reload register
pub const ARR = Register(ARR_val).init(base_address + 0x2c);

/// RCR
const RCR_val = packed struct {
/// REP [0:7]
/// Repetition counter value
REP: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// repetition counter register
pub const RCR = Register(RCR_val).init(base_address + 0x30);

/// CCR1
const CCR1_val = packed struct {
/// CCR1 [0:15]
/// Capture/Compare 1 value
CCR1: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare register 1
pub const CCR1 = Register(CCR1_val).init(base_address + 0x34);

/// CCR2
const CCR2_val = packed struct {
/// CCR2 [0:15]
/// Capture/Compare 2 value
CCR2: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare register 2
pub const CCR2 = Register(CCR2_val).init(base_address + 0x38);

/// CCR3
const CCR3_val = packed struct {
/// CCR3 [0:15]
/// Capture/Compare value
CCR3: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare register 3
pub const CCR3 = Register(CCR3_val).init(base_address + 0x3c);

/// CCR4
const CCR4_val = packed struct {
/// CCR4 [0:15]
/// Capture/Compare value
CCR4: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare register 4
pub const CCR4 = Register(CCR4_val).init(base_address + 0x40);

/// BDTR
const BDTR_val = packed struct {
/// DTG [0:7]
/// Dead-time generator setup
DTG: u8 = 0,
/// LOCK [8:9]
/// Lock configuration
LOCK: u2 = 0,
/// OSSI [10:10]
/// Off-state selection for Idle
OSSI: u1 = 0,
/// OSSR [11:11]
/// Off-state selection for Run
OSSR: u1 = 0,
/// BKE [12:12]
/// Break enable
BKE: u1 = 0,
/// BKP [13:13]
/// Break polarity
BKP: u1 = 0,
/// AOE [14:14]
/// Automatic output enable
AOE: u1 = 0,
/// MOE [15:15]
/// Main output enable
MOE: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// break and dead-time register
pub const BDTR = Register(BDTR_val).init(base_address + 0x44);

/// DCR
const DCR_val = packed struct {
/// DBA [0:4]
/// DMA base address
DBA: u5 = 0,
/// unused [5:7]
_unused5: u3 = 0,
/// DBL [8:12]
/// DMA burst length
DBL: u5 = 0,
/// unused [13:31]
_unused13: u3 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA control register
pub const DCR = Register(DCR_val).init(base_address + 0x48);

/// DMAR
const DMAR_val = packed struct {
/// DMAB [0:15]
/// DMA register for burst
DMAB: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA address for full transfer
pub const DMAR = Register(DMAR_val).init(base_address + 0x4c);

/// OR1
const OR1_val = packed struct {
/// ETR_ADC1_RMP [0:1]
/// External trigger remap on ADC1 analog
ETR_ADC1_RMP: u2 = 0,
/// ETR_ADC3_RMP [2:3]
/// External trigger remap on ADC3 analog
ETR_ADC3_RMP: u2 = 0,
/// TI1_RMP [4:4]
/// Input Capture 1 remap
TI1_RMP: u1 = 0,
/// unused [5:31]
_unused5: u3 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA address for full transfer
pub const OR1 = Register(OR1_val).init(base_address + 0x50);

/// CCMR3_Output
const CCMR3_Output_val = packed struct {
/// unused [0:1]
_unused0: u2 = 0,
/// OC5FE [2:2]
/// Output compare 5 fast
OC5FE: u1 = 0,
/// OC5PE [3:3]
/// Output compare 5 preload
OC5PE: u1 = 0,
/// OC5M [4:6]
/// Output compare 5 mode
OC5M: u3 = 0,
/// OC5CE [7:7]
/// Output compare 5 clear
OC5CE: u1 = 0,
/// unused [8:9]
_unused8: u2 = 0,
/// OC6FE [10:10]
/// Output compare 6 fast
OC6FE: u1 = 0,
/// OC6PE [11:11]
/// Output compare 6 preload
OC6PE: u1 = 0,
/// OC6M [12:14]
/// Output compare 6 mode
OC6M: u3 = 0,
/// OC6CE [15:15]
/// Output compare 6 clear
OC6CE: u1 = 0,
/// OC5M_bit3 [16:18]
/// Output Compare 5 mode bit
OC5M_bit3: u3 = 0,
/// unused [19:23]
_unused19: u5 = 0,
/// OC6M_bit3 [24:24]
/// Output Compare 6 mode bit
OC6M_bit3: u1 = 0,
/// unused [25:31]
_unused25: u7 = 0,
};
/// capture/compare mode register 2 (output
pub const CCMR3_Output = Register(CCMR3_Output_val).init(base_address + 0x54);

/// CCR5
const CCR5_val = packed struct {
/// CCR5 [0:15]
/// Capture/Compare value
CCR5: u16 = 0,
/// unused [16:28]
_unused16: u8 = 0,
_unused24: u5 = 0,
/// GC5C1 [29:29]
/// Group Channel 5 and Channel
GC5C1: u1 = 0,
/// GC5C2 [30:30]
/// Group Channel 5 and Channel
GC5C2: u1 = 0,
/// GC5C3 [31:31]
/// Group Channel 5 and Channel
GC5C3: u1 = 0,
};
/// capture/compare register 4
pub const CCR5 = Register(CCR5_val).init(base_address + 0x58);

/// CCR6
const CCR6_val = packed struct {
/// CCR6 [0:15]
/// Capture/Compare value
CCR6: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare register 4
pub const CCR6 = Register(CCR6_val).init(base_address + 0x5c);

/// OR2
const OR2_val = packed struct {
/// BKINE [0:0]
/// BRK BKIN input enable
BKINE: u1 = 1,
/// BKCMP1E [1:1]
/// BRK COMP1 enable
BKCMP1E: u1 = 0,
/// BKCMP2E [2:2]
/// BRK COMP2 enable
BKCMP2E: u1 = 0,
/// unused [3:7]
_unused3: u5 = 0,
/// BKDFBK0E [8:8]
/// BRK DFSDM_BREAK0 enable
BKDFBK0E: u1 = 0,
/// BKINP [9:9]
/// BRK BKIN input polarity
BKINP: u1 = 0,
/// BKCMP1P [10:10]
/// BRK COMP1 input polarity
BKCMP1P: u1 = 0,
/// BKCMP2P [11:11]
/// BRK COMP2 input polarity
BKCMP2P: u1 = 0,
/// unused [12:13]
_unused12: u2 = 0,
/// ETRSEL [14:16]
/// ETR source selection
ETRSEL: u3 = 0,
/// unused [17:31]
_unused17: u7 = 0,
_unused24: u8 = 0,
};
/// DMA address for full transfer
pub const OR2 = Register(OR2_val).init(base_address + 0x60);

/// OR3
const OR3_val = packed struct {
/// BK2INE [0:0]
/// BRK2 BKIN input enable
BK2INE: u1 = 1,
/// BK2CMP1E [1:1]
/// BRK2 COMP1 enable
BK2CMP1E: u1 = 0,
/// BK2CMP2E [2:2]
/// BRK2 COMP2 enable
BK2CMP2E: u1 = 0,
/// unused [3:7]
_unused3: u5 = 0,
/// BK2DFBK0E [8:8]
/// BRK2 DFSDM_BREAK0 enable
BK2DFBK0E: u1 = 0,
/// BK2INP [9:9]
/// BRK2 BKIN input polarity
BK2INP: u1 = 0,
/// BK2CMP1P [10:10]
/// BRK2 COMP1 input polarity
BK2CMP1P: u1 = 0,
/// BK2CMP2P [11:11]
/// BRK2 COMP2 input polarity
BK2CMP2P: u1 = 0,
/// unused [12:31]
_unused12: u4 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA address for full transfer
pub const OR3 = Register(OR3_val).init(base_address + 0x64);
};

/// Basic-timers
pub const TIM6 = struct {

const base_address = 0x40001000;
/// CR1
const CR1_val = packed struct {
/// CEN [0:0]
/// Counter enable
CEN: u1 = 0,
/// UDIS [1:1]
/// Update disable
UDIS: u1 = 0,
/// URS [2:2]
/// Update request source
URS: u1 = 0,
/// OPM [3:3]
/// One-pulse mode
OPM: u1 = 0,
/// unused [4:6]
_unused4: u3 = 0,
/// ARPE [7:7]
/// Auto-reload preload enable
ARPE: u1 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// unused [0:3]
_unused0: u4 = 0,
/// MMS [4:6]
/// Master mode selection
MMS: u3 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// DIER
const DIER_val = packed struct {
/// UIE [0:0]
/// Update interrupt enable
UIE: u1 = 0,
/// unused [1:7]
_unused1: u7 = 0,
/// UDE [8:8]
/// Update DMA request enable
UDE: u1 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA/Interrupt enable register
pub const DIER = Register(DIER_val).init(base_address + 0xc);

/// SR
const SR_val = packed struct {
/// UIF [0:0]
/// Update interrupt flag
UIF: u1 = 0,
/// unused [1:31]
_unused1: u7 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// status register
pub const SR = Register(SR_val).init(base_address + 0x10);

/// EGR
const EGR_val = packed struct {
/// UG [0:0]
/// Update generation
UG: u1 = 0,
/// unused [1:31]
_unused1: u7 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// event generation register
pub const EGR = Register(EGR_val).init(base_address + 0x14);

/// CNT
const CNT_val = packed struct {
/// CNT [0:15]
/// Low counter value
CNT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// counter
pub const CNT = Register(CNT_val).init(base_address + 0x24);

/// PSC
const PSC_val = packed struct {
/// PSC [0:15]
/// Prescaler value
PSC: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// prescaler
pub const PSC = Register(PSC_val).init(base_address + 0x28);

/// ARR
const ARR_val = packed struct {
/// ARR [0:15]
/// Low Auto-reload value
ARR: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// auto-reload register
pub const ARR = Register(ARR_val).init(base_address + 0x2c);
};

/// Basic-timers
pub const TIM7 = struct {

const base_address = 0x40001400;
/// CR1
const CR1_val = packed struct {
/// CEN [0:0]
/// Counter enable
CEN: u1 = 0,
/// UDIS [1:1]
/// Update disable
UDIS: u1 = 0,
/// URS [2:2]
/// Update request source
URS: u1 = 0,
/// OPM [3:3]
/// One-pulse mode
OPM: u1 = 0,
/// unused [4:6]
_unused4: u3 = 0,
/// ARPE [7:7]
/// Auto-reload preload enable
ARPE: u1 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// unused [0:3]
_unused0: u4 = 0,
/// MMS [4:6]
/// Master mode selection
MMS: u3 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// DIER
const DIER_val = packed struct {
/// UIE [0:0]
/// Update interrupt enable
UIE: u1 = 0,
/// unused [1:7]
_unused1: u7 = 0,
/// UDE [8:8]
/// Update DMA request enable
UDE: u1 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA/Interrupt enable register
pub const DIER = Register(DIER_val).init(base_address + 0xc);

/// SR
const SR_val = packed struct {
/// UIF [0:0]
/// Update interrupt flag
UIF: u1 = 0,
/// unused [1:31]
_unused1: u7 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// status register
pub const SR = Register(SR_val).init(base_address + 0x10);

/// EGR
const EGR_val = packed struct {
/// UG [0:0]
/// Update generation
UG: u1 = 0,
/// unused [1:31]
_unused1: u7 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// event generation register
pub const EGR = Register(EGR_val).init(base_address + 0x14);

/// CNT
const CNT_val = packed struct {
/// CNT [0:15]
/// Low counter value
CNT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// counter
pub const CNT = Register(CNT_val).init(base_address + 0x24);

/// PSC
const PSC_val = packed struct {
/// PSC [0:15]
/// Prescaler value
PSC: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// prescaler
pub const PSC = Register(PSC_val).init(base_address + 0x28);

/// ARR
const ARR_val = packed struct {
/// ARR [0:15]
/// Low Auto-reload value
ARR: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// auto-reload register
pub const ARR = Register(ARR_val).init(base_address + 0x2c);
};

/// Low power timer
pub const LPTIM1 = struct {

const base_address = 0x40007c00;
/// ISR
const ISR_val = packed struct {
/// CMPM [0:0]
/// Compare match
CMPM: u1 = 0,
/// ARRM [1:1]
/// Autoreload match
ARRM: u1 = 0,
/// EXTTRIG [2:2]
/// External trigger edge
EXTTRIG: u1 = 0,
/// CMPOK [3:3]
/// Compare register update OK
CMPOK: u1 = 0,
/// ARROK [4:4]
/// Autoreload register update
ARROK: u1 = 0,
/// UP [5:5]
/// Counter direction change down to
UP: u1 = 0,
/// DOWN [6:6]
/// Counter direction change up to
DOWN: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Interrupt and Status Register
pub const ISR = Register(ISR_val).init(base_address + 0x0);

/// ICR
const ICR_val = packed struct {
/// CMPMCF [0:0]
/// compare match Clear Flag
CMPMCF: u1 = 0,
/// ARRMCF [1:1]
/// Autoreload match Clear
ARRMCF: u1 = 0,
/// EXTTRIGCF [2:2]
/// External trigger valid edge Clear
EXTTRIGCF: u1 = 0,
/// CMPOKCF [3:3]
/// Compare register update OK Clear
CMPOKCF: u1 = 0,
/// ARROKCF [4:4]
/// Autoreload register update OK Clear
ARROKCF: u1 = 0,
/// UPCF [5:5]
/// Direction change to UP Clear
UPCF: u1 = 0,
/// DOWNCF [6:6]
/// Direction change to down Clear
DOWNCF: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Interrupt Clear Register
pub const ICR = Register(ICR_val).init(base_address + 0x4);

/// IER
const IER_val = packed struct {
/// CMPMIE [0:0]
/// Compare match Interrupt
CMPMIE: u1 = 0,
/// ARRMIE [1:1]
/// Autoreload match Interrupt
ARRMIE: u1 = 0,
/// EXTTRIGIE [2:2]
/// External trigger valid edge Interrupt
EXTTRIGIE: u1 = 0,
/// CMPOKIE [3:3]
/// Compare register update OK Interrupt
CMPOKIE: u1 = 0,
/// ARROKIE [4:4]
/// Autoreload register update OK Interrupt
ARROKIE: u1 = 0,
/// UPIE [5:5]
/// Direction change to UP Interrupt
UPIE: u1 = 0,
/// DOWNIE [6:6]
/// Direction change to down Interrupt
DOWNIE: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Interrupt Enable Register
pub const IER = Register(IER_val).init(base_address + 0x8);

/// CFGR
const CFGR_val = packed struct {
/// CKSEL [0:0]
/// Clock selector
CKSEL: u1 = 0,
/// CKPOL [1:2]
/// Clock Polarity
CKPOL: u2 = 0,
/// CKFLT [3:4]
/// Configurable digital filter for external
CKFLT: u2 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// TRGFLT [6:7]
/// Configurable digital filter for
TRGFLT: u2 = 0,
/// unused [8:8]
_unused8: u1 = 0,
/// PRESC [9:11]
/// Clock prescaler
PRESC: u3 = 0,
/// unused [12:12]
_unused12: u1 = 0,
/// TRIGSEL [13:15]
/// Trigger selector
TRIGSEL: u3 = 0,
/// unused [16:16]
_unused16: u1 = 0,
/// TRIGEN [17:18]
/// Trigger enable and
TRIGEN: u2 = 0,
/// TIMOUT [19:19]
/// Timeout enable
TIMOUT: u1 = 0,
/// WAVE [20:20]
/// Waveform shape
WAVE: u1 = 0,
/// WAVPOL [21:21]
/// Waveform shape polarity
WAVPOL: u1 = 0,
/// PRELOAD [22:22]
/// Registers update mode
PRELOAD: u1 = 0,
/// COUNTMODE [23:23]
/// counter mode enabled
COUNTMODE: u1 = 0,
/// ENC [24:24]
/// Encoder mode enable
ENC: u1 = 0,
/// unused [25:31]
_unused25: u7 = 0,
};
/// Configuration Register
pub const CFGR = Register(CFGR_val).init(base_address + 0xc);

/// CR
const CR_val = packed struct {
/// ENABLE [0:0]
/// LPTIM Enable
ENABLE: u1 = 0,
/// SNGSTRT [1:1]
/// LPTIM start in single mode
SNGSTRT: u1 = 0,
/// CNTSTRT [2:2]
/// Timer start in continuous
CNTSTRT: u1 = 0,
/// unused [3:31]
_unused3: u5 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Control Register
pub const CR = Register(CR_val).init(base_address + 0x10);

/// CMP
const CMP_val = packed struct {
/// CMP [0:15]
/// Compare value
CMP: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Compare Register
pub const CMP = Register(CMP_val).init(base_address + 0x14);

/// ARR
const ARR_val = packed struct {
/// ARR [0:15]
/// Auto reload value
ARR: u16 = 1,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Autoreload Register
pub const ARR = Register(ARR_val).init(base_address + 0x18);

/// CNT
const CNT_val = packed struct {
/// CNT [0:15]
/// Counter value
CNT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Counter Register
pub const CNT = Register(CNT_val).init(base_address + 0x1c);
};

/// Low power timer
pub const LPTIM2 = struct {

const base_address = 0x40009400;
/// ISR
const ISR_val = packed struct {
/// CMPM [0:0]
/// Compare match
CMPM: u1 = 0,
/// ARRM [1:1]
/// Autoreload match
ARRM: u1 = 0,
/// EXTTRIG [2:2]
/// External trigger edge
EXTTRIG: u1 = 0,
/// CMPOK [3:3]
/// Compare register update OK
CMPOK: u1 = 0,
/// ARROK [4:4]
/// Autoreload register update
ARROK: u1 = 0,
/// UP [5:5]
/// Counter direction change down to
UP: u1 = 0,
/// DOWN [6:6]
/// Counter direction change up to
DOWN: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Interrupt and Status Register
pub const ISR = Register(ISR_val).init(base_address + 0x0);

/// ICR
const ICR_val = packed struct {
/// CMPMCF [0:0]
/// compare match Clear Flag
CMPMCF: u1 = 0,
/// ARRMCF [1:1]
/// Autoreload match Clear
ARRMCF: u1 = 0,
/// EXTTRIGCF [2:2]
/// External trigger valid edge Clear
EXTTRIGCF: u1 = 0,
/// CMPOKCF [3:3]
/// Compare register update OK Clear
CMPOKCF: u1 = 0,
/// ARROKCF [4:4]
/// Autoreload register update OK Clear
ARROKCF: u1 = 0,
/// UPCF [5:5]
/// Direction change to UP Clear
UPCF: u1 = 0,
/// DOWNCF [6:6]
/// Direction change to down Clear
DOWNCF: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Interrupt Clear Register
pub const ICR = Register(ICR_val).init(base_address + 0x4);

/// IER
const IER_val = packed struct {
/// CMPMIE [0:0]
/// Compare match Interrupt
CMPMIE: u1 = 0,
/// ARRMIE [1:1]
/// Autoreload match Interrupt
ARRMIE: u1 = 0,
/// EXTTRIGIE [2:2]
/// External trigger valid edge Interrupt
EXTTRIGIE: u1 = 0,
/// CMPOKIE [3:3]
/// Compare register update OK Interrupt
CMPOKIE: u1 = 0,
/// ARROKIE [4:4]
/// Autoreload register update OK Interrupt
ARROKIE: u1 = 0,
/// UPIE [5:5]
/// Direction change to UP Interrupt
UPIE: u1 = 0,
/// DOWNIE [6:6]
/// Direction change to down Interrupt
DOWNIE: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Interrupt Enable Register
pub const IER = Register(IER_val).init(base_address + 0x8);

/// CFGR
const CFGR_val = packed struct {
/// CKSEL [0:0]
/// Clock selector
CKSEL: u1 = 0,
/// CKPOL [1:2]
/// Clock Polarity
CKPOL: u2 = 0,
/// CKFLT [3:4]
/// Configurable digital filter for external
CKFLT: u2 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// TRGFLT [6:7]
/// Configurable digital filter for
TRGFLT: u2 = 0,
/// unused [8:8]
_unused8: u1 = 0,
/// PRESC [9:11]
/// Clock prescaler
PRESC: u3 = 0,
/// unused [12:12]
_unused12: u1 = 0,
/// TRIGSEL [13:15]
/// Trigger selector
TRIGSEL: u3 = 0,
/// unused [16:16]
_unused16: u1 = 0,
/// TRIGEN [17:18]
/// Trigger enable and
TRIGEN: u2 = 0,
/// TIMOUT [19:19]
/// Timeout enable
TIMOUT: u1 = 0,
/// WAVE [20:20]
/// Waveform shape
WAVE: u1 = 0,
/// WAVPOL [21:21]
/// Waveform shape polarity
WAVPOL: u1 = 0,
/// PRELOAD [22:22]
/// Registers update mode
PRELOAD: u1 = 0,
/// COUNTMODE [23:23]
/// counter mode enabled
COUNTMODE: u1 = 0,
/// ENC [24:24]
/// Encoder mode enable
ENC: u1 = 0,
/// unused [25:31]
_unused25: u7 = 0,
};
/// Configuration Register
pub const CFGR = Register(CFGR_val).init(base_address + 0xc);

/// CR
const CR_val = packed struct {
/// ENABLE [0:0]
/// LPTIM Enable
ENABLE: u1 = 0,
/// SNGSTRT [1:1]
/// LPTIM start in single mode
SNGSTRT: u1 = 0,
/// CNTSTRT [2:2]
/// Timer start in continuous
CNTSTRT: u1 = 0,
/// unused [3:31]
_unused3: u5 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Control Register
pub const CR = Register(CR_val).init(base_address + 0x10);

/// CMP
const CMP_val = packed struct {
/// CMP [0:15]
/// Compare value
CMP: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Compare Register
pub const CMP = Register(CMP_val).init(base_address + 0x14);

/// ARR
const ARR_val = packed struct {
/// ARR [0:15]
/// Auto reload value
ARR: u16 = 1,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Autoreload Register
pub const ARR = Register(ARR_val).init(base_address + 0x18);

/// CNT
const CNT_val = packed struct {
/// CNT [0:15]
/// Counter value
CNT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Counter Register
pub const CNT = Register(CNT_val).init(base_address + 0x1c);
};

/// Universal synchronous asynchronous receiver
pub const USART1 = struct {

const base_address = 0x40013800;
/// CR1
const CR1_val = packed struct {
/// UE [0:0]
/// USART enable
UE: u1 = 0,
/// UESM [1:1]
/// USART enable in Stop mode
UESM: u1 = 0,
/// RE [2:2]
/// Receiver enable
RE: u1 = 0,
/// TE [3:3]
/// Transmitter enable
TE: u1 = 0,
/// IDLEIE [4:4]
/// IDLE interrupt enable
IDLEIE: u1 = 0,
/// RXNEIE [5:5]
/// RXNE interrupt enable
RXNEIE: u1 = 0,
/// TCIE [6:6]
/// Transmission complete interrupt
TCIE: u1 = 0,
/// TXEIE [7:7]
/// interrupt enable
TXEIE: u1 = 0,
/// PEIE [8:8]
/// PE interrupt enable
PEIE: u1 = 0,
/// PS [9:9]
/// Parity selection
PS: u1 = 0,
/// PCE [10:10]
/// Parity control enable
PCE: u1 = 0,
/// WAKE [11:11]
/// Receiver wakeup method
WAKE: u1 = 0,
/// M0 [12:12]
/// Word length
M0: u1 = 0,
/// MME [13:13]
/// Mute mode enable
MME: u1 = 0,
/// CMIE [14:14]
/// Character match interrupt
CMIE: u1 = 0,
/// OVER8 [15:15]
/// Oversampling mode
OVER8: u1 = 0,
/// DEDT0 [16:16]
/// DEDT0
DEDT0: u1 = 0,
/// DEDT1 [17:17]
/// DEDT1
DEDT1: u1 = 0,
/// DEDT2 [18:18]
/// DEDT2
DEDT2: u1 = 0,
/// DEDT3 [19:19]
/// DEDT3
DEDT3: u1 = 0,
/// DEDT4 [20:20]
/// Driver Enable de-assertion
DEDT4: u1 = 0,
/// DEAT0 [21:21]
/// DEAT0
DEAT0: u1 = 0,
/// DEAT1 [22:22]
/// DEAT1
DEAT1: u1 = 0,
/// DEAT2 [23:23]
/// DEAT2
DEAT2: u1 = 0,
/// DEAT3 [24:24]
/// DEAT3
DEAT3: u1 = 0,
/// DEAT4 [25:25]
/// Driver Enable assertion
DEAT4: u1 = 0,
/// RTOIE [26:26]
/// Receiver timeout interrupt
RTOIE: u1 = 0,
/// EOBIE [27:27]
/// End of Block interrupt
EOBIE: u1 = 0,
/// M1 [28:28]
/// Word length
M1: u1 = 0,
/// unused [29:31]
_unused29: u3 = 0,
};
/// Control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// unused [0:3]
_unused0: u4 = 0,
/// ADDM7 [4:4]
/// 7-bit Address Detection/4-bit Address
ADDM7: u1 = 0,
/// LBDL [5:5]
/// LIN break detection length
LBDL: u1 = 0,
/// LBDIE [6:6]
/// LIN break detection interrupt
LBDIE: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// LBCL [8:8]
/// Last bit clock pulse
LBCL: u1 = 0,
/// CPHA [9:9]
/// Clock phase
CPHA: u1 = 0,
/// CPOL [10:10]
/// Clock polarity
CPOL: u1 = 0,
/// CLKEN [11:11]
/// Clock enable
CLKEN: u1 = 0,
/// STOP [12:13]
/// STOP bits
STOP: u2 = 0,
/// LINEN [14:14]
/// LIN mode enable
LINEN: u1 = 0,
/// SWAP [15:15]
/// Swap TX/RX pins
SWAP: u1 = 0,
/// RXINV [16:16]
/// RX pin active level
RXINV: u1 = 0,
/// TXINV [17:17]
/// TX pin active level
TXINV: u1 = 0,
/// TAINV [18:18]
/// Binary data inversion
TAINV: u1 = 0,
/// MSBFIRST [19:19]
/// Most significant bit first
MSBFIRST: u1 = 0,
/// ABREN [20:20]
/// Auto baud rate enable
ABREN: u1 = 0,
/// ABRMOD0 [21:21]
/// ABRMOD0
ABRMOD0: u1 = 0,
/// ABRMOD1 [22:22]
/// Auto baud rate mode
ABRMOD1: u1 = 0,
/// RTOEN [23:23]
/// Receiver timeout enable
RTOEN: u1 = 0,
/// ADD0_3 [24:27]
/// Address of the USART node
ADD0_3: u4 = 0,
/// ADD4_7 [28:31]
/// Address of the USART node
ADD4_7: u4 = 0,
};
/// Control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// CR3
const CR3_val = packed struct {
/// EIE [0:0]
/// Error interrupt enable
EIE: u1 = 0,
/// IREN [1:1]
/// Ir mode enable
IREN: u1 = 0,
/// IRLP [2:2]
/// Ir low-power
IRLP: u1 = 0,
/// HDSEL [3:3]
/// Half-duplex selection
HDSEL: u1 = 0,
/// NACK [4:4]
/// Smartcard NACK enable
NACK: u1 = 0,
/// SCEN [5:5]
/// Smartcard mode enable
SCEN: u1 = 0,
/// DMAR [6:6]
/// DMA enable receiver
DMAR: u1 = 0,
/// DMAT [7:7]
/// DMA enable transmitter
DMAT: u1 = 0,
/// RTSE [8:8]
/// RTS enable
RTSE: u1 = 0,
/// CTSE [9:9]
/// CTS enable
CTSE: u1 = 0,
/// CTSIE [10:10]
/// CTS interrupt enable
CTSIE: u1 = 0,
/// ONEBIT [11:11]
/// One sample bit method
ONEBIT: u1 = 0,
/// OVRDIS [12:12]
/// Overrun Disable
OVRDIS: u1 = 0,
/// DDRE [13:13]
/// DMA Disable on Reception
DDRE: u1 = 0,
/// DEM [14:14]
/// Driver enable mode
DEM: u1 = 0,
/// DEP [15:15]
/// Driver enable polarity
DEP: u1 = 0,
/// unused [16:16]
_unused16: u1 = 0,
/// SCARCNT [17:19]
/// Smartcard auto-retry count
SCARCNT: u3 = 0,
/// WUS [20:21]
/// Wakeup from Stop mode interrupt flag
WUS: u2 = 0,
/// WUFIE [22:22]
/// Wakeup from Stop mode interrupt
WUFIE: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// Control register 3
pub const CR3 = Register(CR3_val).init(base_address + 0x8);

/// BRR
const BRR_val = packed struct {
/// DIV_Fraction [0:3]
/// DIV_Fraction
DIV_Fraction: u4 = 0,
/// DIV_Mantissa [4:15]
/// DIV_Mantissa
DIV_Mantissa: u12 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Baud rate register
pub const BRR = Register(BRR_val).init(base_address + 0xc);

/// GTPR
const GTPR_val = packed struct {
/// PSC [0:7]
/// Prescaler value
PSC: u8 = 0,
/// GT [8:15]
/// Guard time value
GT: u8 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Guard time and prescaler
pub const GTPR = Register(GTPR_val).init(base_address + 0x10);

/// RTOR
const RTOR_val = packed struct {
/// RTO [0:23]
/// Receiver timeout value
RTO: u24 = 0,
/// BLEN [24:31]
/// Block Length
BLEN: u8 = 0,
};
/// Receiver timeout register
pub const RTOR = Register(RTOR_val).init(base_address + 0x14);

/// RQR
const RQR_val = packed struct {
/// ABRRQ [0:0]
/// Auto baud rate request
ABRRQ: u1 = 0,
/// SBKRQ [1:1]
/// Send break request
SBKRQ: u1 = 0,
/// MMRQ [2:2]
/// Mute mode request
MMRQ: u1 = 0,
/// RXFRQ [3:3]
/// Receive data flush request
RXFRQ: u1 = 0,
/// TXFRQ [4:4]
/// Transmit data flush
TXFRQ: u1 = 0,
/// unused [5:31]
_unused5: u3 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Request register
pub const RQR = Register(RQR_val).init(base_address + 0x18);

/// ISR
const ISR_val = packed struct {
/// PE [0:0]
/// PE
PE: u1 = 0,
/// FE [1:1]
/// FE
FE: u1 = 0,
/// NF [2:2]
/// NF
NF: u1 = 0,
/// ORE [3:3]
/// ORE
ORE: u1 = 0,
/// IDLE [4:4]
/// IDLE
IDLE: u1 = 0,
/// RXNE [5:5]
/// RXNE
RXNE: u1 = 0,
/// TC [6:6]
/// TC
TC: u1 = 1,
/// TXE [7:7]
/// TXE
TXE: u1 = 1,
/// LBDF [8:8]
/// LBDF
LBDF: u1 = 0,
/// CTSIF [9:9]
/// CTSIF
CTSIF: u1 = 0,
/// CTS [10:10]
/// CTS
CTS: u1 = 0,
/// RTOF [11:11]
/// RTOF
RTOF: u1 = 0,
/// EOBF [12:12]
/// EOBF
EOBF: u1 = 0,
/// unused [13:13]
_unused13: u1 = 0,
/// ABRE [14:14]
/// ABRE
ABRE: u1 = 0,
/// ABRF [15:15]
/// ABRF
ABRF: u1 = 0,
/// BUSY [16:16]
/// BUSY
BUSY: u1 = 0,
/// CMF [17:17]
/// CMF
CMF: u1 = 0,
/// SBKF [18:18]
/// SBKF
SBKF: u1 = 0,
/// RWU [19:19]
/// RWU
RWU: u1 = 0,
/// WUF [20:20]
/// WUF
WUF: u1 = 0,
/// TEACK [21:21]
/// TEACK
TEACK: u1 = 0,
/// REACK [22:22]
/// REACK
REACK: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// Interrupt &amp; status
pub const ISR = Register(ISR_val).init(base_address + 0x1c);

/// ICR
const ICR_val = packed struct {
/// PECF [0:0]
/// Parity error clear flag
PECF: u1 = 0,
/// FECF [1:1]
/// Framing error clear flag
FECF: u1 = 0,
/// NCF [2:2]
/// Noise detected clear flag
NCF: u1 = 0,
/// ORECF [3:3]
/// Overrun error clear flag
ORECF: u1 = 0,
/// IDLECF [4:4]
/// Idle line detected clear
IDLECF: u1 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// TCCF [6:6]
/// Transmission complete clear
TCCF: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// LBDCF [8:8]
/// LIN break detection clear
LBDCF: u1 = 0,
/// CTSCF [9:9]
/// CTS clear flag
CTSCF: u1 = 0,
/// unused [10:10]
_unused10: u1 = 0,
/// RTOCF [11:11]
/// Receiver timeout clear
RTOCF: u1 = 0,
/// EOBCF [12:12]
/// End of block clear flag
EOBCF: u1 = 0,
/// unused [13:16]
_unused13: u3 = 0,
_unused16: u1 = 0,
/// CMCF [17:17]
/// Character match clear flag
CMCF: u1 = 0,
/// unused [18:19]
_unused18: u2 = 0,
/// WUCF [20:20]
/// Wakeup from Stop mode clear
WUCF: u1 = 0,
/// unused [21:31]
_unused21: u3 = 0,
_unused24: u8 = 0,
};
/// Interrupt flag clear register
pub const ICR = Register(ICR_val).init(base_address + 0x20);

/// RDR
const RDR_val = packed struct {
/// RDR [0:8]
/// Receive data value
RDR: u9 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Receive data register
pub const RDR = Register(RDR_val).init(base_address + 0x24);

/// TDR
const TDR_val = packed struct {
/// TDR [0:8]
/// Transmit data value
TDR: u9 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Transmit data register
pub const TDR = Register(TDR_val).init(base_address + 0x28);
};

/// Universal synchronous asynchronous receiver
pub const USART2 = struct {

const base_address = 0x40004400;
/// CR1
const CR1_val = packed struct {
/// UE [0:0]
/// USART enable
UE: u1 = 0,
/// UESM [1:1]
/// USART enable in Stop mode
UESM: u1 = 0,
/// RE [2:2]
/// Receiver enable
RE: u1 = 0,
/// TE [3:3]
/// Transmitter enable
TE: u1 = 0,
/// IDLEIE [4:4]
/// IDLE interrupt enable
IDLEIE: u1 = 0,
/// RXNEIE [5:5]
/// RXNE interrupt enable
RXNEIE: u1 = 0,
/// TCIE [6:6]
/// Transmission complete interrupt
TCIE: u1 = 0,
/// TXEIE [7:7]
/// interrupt enable
TXEIE: u1 = 0,
/// PEIE [8:8]
/// PE interrupt enable
PEIE: u1 = 0,
/// PS [9:9]
/// Parity selection
PS: u1 = 0,
/// PCE [10:10]
/// Parity control enable
PCE: u1 = 0,
/// WAKE [11:11]
/// Receiver wakeup method
WAKE: u1 = 0,
/// M0 [12:12]
/// Word length
M0: u1 = 0,
/// MME [13:13]
/// Mute mode enable
MME: u1 = 0,
/// CMIE [14:14]
/// Character match interrupt
CMIE: u1 = 0,
/// OVER8 [15:15]
/// Oversampling mode
OVER8: u1 = 0,
/// DEDT0 [16:16]
/// DEDT0
DEDT0: u1 = 0,
/// DEDT1 [17:17]
/// DEDT1
DEDT1: u1 = 0,
/// DEDT2 [18:18]
/// DEDT2
DEDT2: u1 = 0,
/// DEDT3 [19:19]
/// DEDT3
DEDT3: u1 = 0,
/// DEDT4 [20:20]
/// Driver Enable de-assertion
DEDT4: u1 = 0,
/// DEAT0 [21:21]
/// DEAT0
DEAT0: u1 = 0,
/// DEAT1 [22:22]
/// DEAT1
DEAT1: u1 = 0,
/// DEAT2 [23:23]
/// DEAT2
DEAT2: u1 = 0,
/// DEAT3 [24:24]
/// DEAT3
DEAT3: u1 = 0,
/// DEAT4 [25:25]
/// Driver Enable assertion
DEAT4: u1 = 0,
/// RTOIE [26:26]
/// Receiver timeout interrupt
RTOIE: u1 = 0,
/// EOBIE [27:27]
/// End of Block interrupt
EOBIE: u1 = 0,
/// M1 [28:28]
/// Word length
M1: u1 = 0,
/// unused [29:31]
_unused29: u3 = 0,
};
/// Control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// unused [0:3]
_unused0: u4 = 0,
/// ADDM7 [4:4]
/// 7-bit Address Detection/4-bit Address
ADDM7: u1 = 0,
/// LBDL [5:5]
/// LIN break detection length
LBDL: u1 = 0,
/// LBDIE [6:6]
/// LIN break detection interrupt
LBDIE: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// LBCL [8:8]
/// Last bit clock pulse
LBCL: u1 = 0,
/// CPHA [9:9]
/// Clock phase
CPHA: u1 = 0,
/// CPOL [10:10]
/// Clock polarity
CPOL: u1 = 0,
/// CLKEN [11:11]
/// Clock enable
CLKEN: u1 = 0,
/// STOP [12:13]
/// STOP bits
STOP: u2 = 0,
/// LINEN [14:14]
/// LIN mode enable
LINEN: u1 = 0,
/// SWAP [15:15]
/// Swap TX/RX pins
SWAP: u1 = 0,
/// RXINV [16:16]
/// RX pin active level
RXINV: u1 = 0,
/// TXINV [17:17]
/// TX pin active level
TXINV: u1 = 0,
/// TAINV [18:18]
/// Binary data inversion
TAINV: u1 = 0,
/// MSBFIRST [19:19]
/// Most significant bit first
MSBFIRST: u1 = 0,
/// ABREN [20:20]
/// Auto baud rate enable
ABREN: u1 = 0,
/// ABRMOD0 [21:21]
/// ABRMOD0
ABRMOD0: u1 = 0,
/// ABRMOD1 [22:22]
/// Auto baud rate mode
ABRMOD1: u1 = 0,
/// RTOEN [23:23]
/// Receiver timeout enable
RTOEN: u1 = 0,
/// ADD0_3 [24:27]
/// Address of the USART node
ADD0_3: u4 = 0,
/// ADD4_7 [28:31]
/// Address of the USART node
ADD4_7: u4 = 0,
};
/// Control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// CR3
const CR3_val = packed struct {
/// EIE [0:0]
/// Error interrupt enable
EIE: u1 = 0,
/// IREN [1:1]
/// Ir mode enable
IREN: u1 = 0,
/// IRLP [2:2]
/// Ir low-power
IRLP: u1 = 0,
/// HDSEL [3:3]
/// Half-duplex selection
HDSEL: u1 = 0,
/// NACK [4:4]
/// Smartcard NACK enable
NACK: u1 = 0,
/// SCEN [5:5]
/// Smartcard mode enable
SCEN: u1 = 0,
/// DMAR [6:6]
/// DMA enable receiver
DMAR: u1 = 0,
/// DMAT [7:7]
/// DMA enable transmitter
DMAT: u1 = 0,
/// RTSE [8:8]
/// RTS enable
RTSE: u1 = 0,
/// CTSE [9:9]
/// CTS enable
CTSE: u1 = 0,
/// CTSIE [10:10]
/// CTS interrupt enable
CTSIE: u1 = 0,
/// ONEBIT [11:11]
/// One sample bit method
ONEBIT: u1 = 0,
/// OVRDIS [12:12]
/// Overrun Disable
OVRDIS: u1 = 0,
/// DDRE [13:13]
/// DMA Disable on Reception
DDRE: u1 = 0,
/// DEM [14:14]
/// Driver enable mode
DEM: u1 = 0,
/// DEP [15:15]
/// Driver enable polarity
DEP: u1 = 0,
/// unused [16:16]
_unused16: u1 = 0,
/// SCARCNT [17:19]
/// Smartcard auto-retry count
SCARCNT: u3 = 0,
/// WUS [20:21]
/// Wakeup from Stop mode interrupt flag
WUS: u2 = 0,
/// WUFIE [22:22]
/// Wakeup from Stop mode interrupt
WUFIE: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// Control register 3
pub const CR3 = Register(CR3_val).init(base_address + 0x8);

/// BRR
const BRR_val = packed struct {
/// DIV_Fraction [0:3]
/// DIV_Fraction
DIV_Fraction: u4 = 0,
/// DIV_Mantissa [4:15]
/// DIV_Mantissa
DIV_Mantissa: u12 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Baud rate register
pub const BRR = Register(BRR_val).init(base_address + 0xc);

/// GTPR
const GTPR_val = packed struct {
/// PSC [0:7]
/// Prescaler value
PSC: u8 = 0,
/// GT [8:15]
/// Guard time value
GT: u8 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Guard time and prescaler
pub const GTPR = Register(GTPR_val).init(base_address + 0x10);

/// RTOR
const RTOR_val = packed struct {
/// RTO [0:23]
/// Receiver timeout value
RTO: u24 = 0,
/// BLEN [24:31]
/// Block Length
BLEN: u8 = 0,
};
/// Receiver timeout register
pub const RTOR = Register(RTOR_val).init(base_address + 0x14);

/// RQR
const RQR_val = packed struct {
/// ABRRQ [0:0]
/// Auto baud rate request
ABRRQ: u1 = 0,
/// SBKRQ [1:1]
/// Send break request
SBKRQ: u1 = 0,
/// MMRQ [2:2]
/// Mute mode request
MMRQ: u1 = 0,
/// RXFRQ [3:3]
/// Receive data flush request
RXFRQ: u1 = 0,
/// TXFRQ [4:4]
/// Transmit data flush
TXFRQ: u1 = 0,
/// unused [5:31]
_unused5: u3 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Request register
pub const RQR = Register(RQR_val).init(base_address + 0x18);

/// ISR
const ISR_val = packed struct {
/// PE [0:0]
/// PE
PE: u1 = 0,
/// FE [1:1]
/// FE
FE: u1 = 0,
/// NF [2:2]
/// NF
NF: u1 = 0,
/// ORE [3:3]
/// ORE
ORE: u1 = 0,
/// IDLE [4:4]
/// IDLE
IDLE: u1 = 0,
/// RXNE [5:5]
/// RXNE
RXNE: u1 = 0,
/// TC [6:6]
/// TC
TC: u1 = 1,
/// TXE [7:7]
/// TXE
TXE: u1 = 1,
/// LBDF [8:8]
/// LBDF
LBDF: u1 = 0,
/// CTSIF [9:9]
/// CTSIF
CTSIF: u1 = 0,
/// CTS [10:10]
/// CTS
CTS: u1 = 0,
/// RTOF [11:11]
/// RTOF
RTOF: u1 = 0,
/// EOBF [12:12]
/// EOBF
EOBF: u1 = 0,
/// unused [13:13]
_unused13: u1 = 0,
/// ABRE [14:14]
/// ABRE
ABRE: u1 = 0,
/// ABRF [15:15]
/// ABRF
ABRF: u1 = 0,
/// BUSY [16:16]
/// BUSY
BUSY: u1 = 0,
/// CMF [17:17]
/// CMF
CMF: u1 = 0,
/// SBKF [18:18]
/// SBKF
SBKF: u1 = 0,
/// RWU [19:19]
/// RWU
RWU: u1 = 0,
/// WUF [20:20]
/// WUF
WUF: u1 = 0,
/// TEACK [21:21]
/// TEACK
TEACK: u1 = 0,
/// REACK [22:22]
/// REACK
REACK: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// Interrupt &amp; status
pub const ISR = Register(ISR_val).init(base_address + 0x1c);

/// ICR
const ICR_val = packed struct {
/// PECF [0:0]
/// Parity error clear flag
PECF: u1 = 0,
/// FECF [1:1]
/// Framing error clear flag
FECF: u1 = 0,
/// NCF [2:2]
/// Noise detected clear flag
NCF: u1 = 0,
/// ORECF [3:3]
/// Overrun error clear flag
ORECF: u1 = 0,
/// IDLECF [4:4]
/// Idle line detected clear
IDLECF: u1 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// TCCF [6:6]
/// Transmission complete clear
TCCF: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// LBDCF [8:8]
/// LIN break detection clear
LBDCF: u1 = 0,
/// CTSCF [9:9]
/// CTS clear flag
CTSCF: u1 = 0,
/// unused [10:10]
_unused10: u1 = 0,
/// RTOCF [11:11]
/// Receiver timeout clear
RTOCF: u1 = 0,
/// EOBCF [12:12]
/// End of block clear flag
EOBCF: u1 = 0,
/// unused [13:16]
_unused13: u3 = 0,
_unused16: u1 = 0,
/// CMCF [17:17]
/// Character match clear flag
CMCF: u1 = 0,
/// unused [18:19]
_unused18: u2 = 0,
/// WUCF [20:20]
/// Wakeup from Stop mode clear
WUCF: u1 = 0,
/// unused [21:31]
_unused21: u3 = 0,
_unused24: u8 = 0,
};
/// Interrupt flag clear register
pub const ICR = Register(ICR_val).init(base_address + 0x20);

/// RDR
const RDR_val = packed struct {
/// RDR [0:8]
/// Receive data value
RDR: u9 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Receive data register
pub const RDR = Register(RDR_val).init(base_address + 0x24);

/// TDR
const TDR_val = packed struct {
/// TDR [0:8]
/// Transmit data value
TDR: u9 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Transmit data register
pub const TDR = Register(TDR_val).init(base_address + 0x28);
};

/// Universal synchronous asynchronous receiver
pub const UART4 = struct {

const base_address = 0x40004c00;
/// CR1
const CR1_val = packed struct {
/// UE [0:0]
/// USART enable
UE: u1 = 0,
/// UESM [1:1]
/// USART enable in Stop mode
UESM: u1 = 0,
/// RE [2:2]
/// Receiver enable
RE: u1 = 0,
/// TE [3:3]
/// Transmitter enable
TE: u1 = 0,
/// IDLEIE [4:4]
/// IDLE interrupt enable
IDLEIE: u1 = 0,
/// RXNEIE [5:5]
/// RXNE interrupt enable
RXNEIE: u1 = 0,
/// TCIE [6:6]
/// Transmission complete interrupt
TCIE: u1 = 0,
/// TXEIE [7:7]
/// interrupt enable
TXEIE: u1 = 0,
/// PEIE [8:8]
/// PE interrupt enable
PEIE: u1 = 0,
/// PS [9:9]
/// Parity selection
PS: u1 = 0,
/// PCE [10:10]
/// Parity control enable
PCE: u1 = 0,
/// WAKE [11:11]
/// Receiver wakeup method
WAKE: u1 = 0,
/// M0 [12:12]
/// Word length
M0: u1 = 0,
/// MME [13:13]
/// Mute mode enable
MME: u1 = 0,
/// CMIE [14:14]
/// Character match interrupt
CMIE: u1 = 0,
/// OVER8 [15:15]
/// Oversampling mode
OVER8: u1 = 0,
/// DEDT0 [16:16]
/// DEDT0
DEDT0: u1 = 0,
/// DEDT1 [17:17]
/// DEDT1
DEDT1: u1 = 0,
/// DEDT2 [18:18]
/// DEDT2
DEDT2: u1 = 0,
/// DEDT3 [19:19]
/// DEDT3
DEDT3: u1 = 0,
/// DEDT4 [20:20]
/// Driver Enable de-assertion
DEDT4: u1 = 0,
/// DEAT0 [21:21]
/// DEAT0
DEAT0: u1 = 0,
/// DEAT1 [22:22]
/// DEAT1
DEAT1: u1 = 0,
/// DEAT2 [23:23]
/// DEAT2
DEAT2: u1 = 0,
/// DEAT3 [24:24]
/// DEAT3
DEAT3: u1 = 0,
/// DEAT4 [25:25]
/// Driver Enable assertion
DEAT4: u1 = 0,
/// RTOIE [26:26]
/// Receiver timeout interrupt
RTOIE: u1 = 0,
/// EOBIE [27:27]
/// End of Block interrupt
EOBIE: u1 = 0,
/// M1 [28:28]
/// Word length
M1: u1 = 0,
/// unused [29:31]
_unused29: u3 = 0,
};
/// Control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// unused [0:3]
_unused0: u4 = 0,
/// ADDM7 [4:4]
/// 7-bit Address Detection/4-bit Address
ADDM7: u1 = 0,
/// LBDL [5:5]
/// LIN break detection length
LBDL: u1 = 0,
/// LBDIE [6:6]
/// LIN break detection interrupt
LBDIE: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// LBCL [8:8]
/// Last bit clock pulse
LBCL: u1 = 0,
/// CPHA [9:9]
/// Clock phase
CPHA: u1 = 0,
/// CPOL [10:10]
/// Clock polarity
CPOL: u1 = 0,
/// CLKEN [11:11]
/// Clock enable
CLKEN: u1 = 0,
/// STOP [12:13]
/// STOP bits
STOP: u2 = 0,
/// LINEN [14:14]
/// LIN mode enable
LINEN: u1 = 0,
/// SWAP [15:15]
/// Swap TX/RX pins
SWAP: u1 = 0,
/// RXINV [16:16]
/// RX pin active level
RXINV: u1 = 0,
/// TXINV [17:17]
/// TX pin active level
TXINV: u1 = 0,
/// TAINV [18:18]
/// Binary data inversion
TAINV: u1 = 0,
/// MSBFIRST [19:19]
/// Most significant bit first
MSBFIRST: u1 = 0,
/// ABREN [20:20]
/// Auto baud rate enable
ABREN: u1 = 0,
/// ABRMOD0 [21:21]
/// ABRMOD0
ABRMOD0: u1 = 0,
/// ABRMOD1 [22:22]
/// Auto baud rate mode
ABRMOD1: u1 = 0,
/// RTOEN [23:23]
/// Receiver timeout enable
RTOEN: u1 = 0,
/// ADD0_3 [24:27]
/// Address of the USART node
ADD0_3: u4 = 0,
/// ADD4_7 [28:31]
/// Address of the USART node
ADD4_7: u4 = 0,
};
/// Control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// CR3
const CR3_val = packed struct {
/// EIE [0:0]
/// Error interrupt enable
EIE: u1 = 0,
/// IREN [1:1]
/// Ir mode enable
IREN: u1 = 0,
/// IRLP [2:2]
/// Ir low-power
IRLP: u1 = 0,
/// HDSEL [3:3]
/// Half-duplex selection
HDSEL: u1 = 0,
/// NACK [4:4]
/// Smartcard NACK enable
NACK: u1 = 0,
/// SCEN [5:5]
/// Smartcard mode enable
SCEN: u1 = 0,
/// DMAR [6:6]
/// DMA enable receiver
DMAR: u1 = 0,
/// DMAT [7:7]
/// DMA enable transmitter
DMAT: u1 = 0,
/// RTSE [8:8]
/// RTS enable
RTSE: u1 = 0,
/// CTSE [9:9]
/// CTS enable
CTSE: u1 = 0,
/// CTSIE [10:10]
/// CTS interrupt enable
CTSIE: u1 = 0,
/// ONEBIT [11:11]
/// One sample bit method
ONEBIT: u1 = 0,
/// OVRDIS [12:12]
/// Overrun Disable
OVRDIS: u1 = 0,
/// DDRE [13:13]
/// DMA Disable on Reception
DDRE: u1 = 0,
/// DEM [14:14]
/// Driver enable mode
DEM: u1 = 0,
/// DEP [15:15]
/// Driver enable polarity
DEP: u1 = 0,
/// unused [16:16]
_unused16: u1 = 0,
/// SCARCNT [17:19]
/// Smartcard auto-retry count
SCARCNT: u3 = 0,
/// WUS [20:21]
/// Wakeup from Stop mode interrupt flag
WUS: u2 = 0,
/// WUFIE [22:22]
/// Wakeup from Stop mode interrupt
WUFIE: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// Control register 3
pub const CR3 = Register(CR3_val).init(base_address + 0x8);

/// BRR
const BRR_val = packed struct {
/// DIV_Fraction [0:3]
/// DIV_Fraction
DIV_Fraction: u4 = 0,
/// DIV_Mantissa [4:15]
/// DIV_Mantissa
DIV_Mantissa: u12 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Baud rate register
pub const BRR = Register(BRR_val).init(base_address + 0xc);

/// GTPR
const GTPR_val = packed struct {
/// PSC [0:7]
/// Prescaler value
PSC: u8 = 0,
/// GT [8:15]
/// Guard time value
GT: u8 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Guard time and prescaler
pub const GTPR = Register(GTPR_val).init(base_address + 0x10);

/// RTOR
const RTOR_val = packed struct {
/// RTO [0:23]
/// Receiver timeout value
RTO: u24 = 0,
/// BLEN [24:31]
/// Block Length
BLEN: u8 = 0,
};
/// Receiver timeout register
pub const RTOR = Register(RTOR_val).init(base_address + 0x14);

/// RQR
const RQR_val = packed struct {
/// ABRRQ [0:0]
/// Auto baud rate request
ABRRQ: u1 = 0,
/// SBKRQ [1:1]
/// Send break request
SBKRQ: u1 = 0,
/// MMRQ [2:2]
/// Mute mode request
MMRQ: u1 = 0,
/// RXFRQ [3:3]
/// Receive data flush request
RXFRQ: u1 = 0,
/// TXFRQ [4:4]
/// Transmit data flush
TXFRQ: u1 = 0,
/// unused [5:31]
_unused5: u3 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Request register
pub const RQR = Register(RQR_val).init(base_address + 0x18);

/// ISR
const ISR_val = packed struct {
/// PE [0:0]
/// PE
PE: u1 = 0,
/// FE [1:1]
/// FE
FE: u1 = 0,
/// NF [2:2]
/// NF
NF: u1 = 0,
/// ORE [3:3]
/// ORE
ORE: u1 = 0,
/// IDLE [4:4]
/// IDLE
IDLE: u1 = 0,
/// RXNE [5:5]
/// RXNE
RXNE: u1 = 0,
/// TC [6:6]
/// TC
TC: u1 = 1,
/// TXE [7:7]
/// TXE
TXE: u1 = 1,
/// LBDF [8:8]
/// LBDF
LBDF: u1 = 0,
/// CTSIF [9:9]
/// CTSIF
CTSIF: u1 = 0,
/// CTS [10:10]
/// CTS
CTS: u1 = 0,
/// RTOF [11:11]
/// RTOF
RTOF: u1 = 0,
/// EOBF [12:12]
/// EOBF
EOBF: u1 = 0,
/// unused [13:13]
_unused13: u1 = 0,
/// ABRE [14:14]
/// ABRE
ABRE: u1 = 0,
/// ABRF [15:15]
/// ABRF
ABRF: u1 = 0,
/// BUSY [16:16]
/// BUSY
BUSY: u1 = 0,
/// CMF [17:17]
/// CMF
CMF: u1 = 0,
/// SBKF [18:18]
/// SBKF
SBKF: u1 = 0,
/// RWU [19:19]
/// RWU
RWU: u1 = 0,
/// WUF [20:20]
/// WUF
WUF: u1 = 0,
/// TEACK [21:21]
/// TEACK
TEACK: u1 = 0,
/// REACK [22:22]
/// REACK
REACK: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// Interrupt &amp; status
pub const ISR = Register(ISR_val).init(base_address + 0x1c);

/// ICR
const ICR_val = packed struct {
/// PECF [0:0]
/// Parity error clear flag
PECF: u1 = 0,
/// FECF [1:1]
/// Framing error clear flag
FECF: u1 = 0,
/// NCF [2:2]
/// Noise detected clear flag
NCF: u1 = 0,
/// ORECF [3:3]
/// Overrun error clear flag
ORECF: u1 = 0,
/// IDLECF [4:4]
/// Idle line detected clear
IDLECF: u1 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// TCCF [6:6]
/// Transmission complete clear
TCCF: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// LBDCF [8:8]
/// LIN break detection clear
LBDCF: u1 = 0,
/// CTSCF [9:9]
/// CTS clear flag
CTSCF: u1 = 0,
/// unused [10:10]
_unused10: u1 = 0,
/// RTOCF [11:11]
/// Receiver timeout clear
RTOCF: u1 = 0,
/// EOBCF [12:12]
/// End of block clear flag
EOBCF: u1 = 0,
/// unused [13:16]
_unused13: u3 = 0,
_unused16: u1 = 0,
/// CMCF [17:17]
/// Character match clear flag
CMCF: u1 = 0,
/// unused [18:19]
_unused18: u2 = 0,
/// WUCF [20:20]
/// Wakeup from Stop mode clear
WUCF: u1 = 0,
/// unused [21:31]
_unused21: u3 = 0,
_unused24: u8 = 0,
};
/// Interrupt flag clear register
pub const ICR = Register(ICR_val).init(base_address + 0x20);

/// RDR
const RDR_val = packed struct {
/// RDR [0:8]
/// Receive data value
RDR: u9 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Receive data register
pub const RDR = Register(RDR_val).init(base_address + 0x24);

/// TDR
const TDR_val = packed struct {
/// TDR [0:8]
/// Transmit data value
TDR: u9 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Transmit data register
pub const TDR = Register(TDR_val).init(base_address + 0x28);
};

/// Universal synchronous asynchronous receiver
pub const USART3 = struct {

const base_address = 0x40004800;
/// CR1
const CR1_val = packed struct {
/// UE [0:0]
/// USART enable
UE: u1 = 0,
/// UESM [1:1]
/// USART enable in Stop mode
UESM: u1 = 0,
/// RE [2:2]
/// Receiver enable
RE: u1 = 0,
/// TE [3:3]
/// Transmitter enable
TE: u1 = 0,
/// IDLEIE [4:4]
/// IDLE interrupt enable
IDLEIE: u1 = 0,
/// RXNEIE [5:5]
/// RXNE interrupt enable
RXNEIE: u1 = 0,
/// TCIE [6:6]
/// Transmission complete interrupt
TCIE: u1 = 0,
/// TXEIE [7:7]
/// interrupt enable
TXEIE: u1 = 0,
/// PEIE [8:8]
/// PE interrupt enable
PEIE: u1 = 0,
/// PS [9:9]
/// Parity selection
PS: u1 = 0,
/// PCE [10:10]
/// Parity control enable
PCE: u1 = 0,
/// WAKE [11:11]
/// Receiver wakeup method
WAKE: u1 = 0,
/// M0 [12:12]
/// Word length
M0: u1 = 0,
/// MME [13:13]
/// Mute mode enable
MME: u1 = 0,
/// CMIE [14:14]
/// Character match interrupt
CMIE: u1 = 0,
/// OVER8 [15:15]
/// Oversampling mode
OVER8: u1 = 0,
/// DEDT0 [16:16]
/// DEDT0
DEDT0: u1 = 0,
/// DEDT1 [17:17]
/// DEDT1
DEDT1: u1 = 0,
/// DEDT2 [18:18]
/// DEDT2
DEDT2: u1 = 0,
/// DEDT3 [19:19]
/// DEDT3
DEDT3: u1 = 0,
/// DEDT4 [20:20]
/// Driver Enable de-assertion
DEDT4: u1 = 0,
/// DEAT0 [21:21]
/// DEAT0
DEAT0: u1 = 0,
/// DEAT1 [22:22]
/// DEAT1
DEAT1: u1 = 0,
/// DEAT2 [23:23]
/// DEAT2
DEAT2: u1 = 0,
/// DEAT3 [24:24]
/// DEAT3
DEAT3: u1 = 0,
/// DEAT4 [25:25]
/// Driver Enable assertion
DEAT4: u1 = 0,
/// RTOIE [26:26]
/// Receiver timeout interrupt
RTOIE: u1 = 0,
/// EOBIE [27:27]
/// End of Block interrupt
EOBIE: u1 = 0,
/// M1 [28:28]
/// Word length
M1: u1 = 0,
/// unused [29:31]
_unused29: u3 = 0,
};
/// Control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// unused [0:3]
_unused0: u4 = 0,
/// ADDM7 [4:4]
/// 7-bit Address Detection/4-bit Address
ADDM7: u1 = 0,
/// LBDL [5:5]
/// LIN break detection length
LBDL: u1 = 0,
/// LBDIE [6:6]
/// LIN break detection interrupt
LBDIE: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// LBCL [8:8]
/// Last bit clock pulse
LBCL: u1 = 0,
/// CPHA [9:9]
/// Clock phase
CPHA: u1 = 0,
/// CPOL [10:10]
/// Clock polarity
CPOL: u1 = 0,
/// CLKEN [11:11]
/// Clock enable
CLKEN: u1 = 0,
/// STOP [12:13]
/// STOP bits
STOP: u2 = 0,
/// LINEN [14:14]
/// LIN mode enable
LINEN: u1 = 0,
/// SWAP [15:15]
/// Swap TX/RX pins
SWAP: u1 = 0,
/// RXINV [16:16]
/// RX pin active level
RXINV: u1 = 0,
/// TXINV [17:17]
/// TX pin active level
TXINV: u1 = 0,
/// TAINV [18:18]
/// Binary data inversion
TAINV: u1 = 0,
/// MSBFIRST [19:19]
/// Most significant bit first
MSBFIRST: u1 = 0,
/// ABREN [20:20]
/// Auto baud rate enable
ABREN: u1 = 0,
/// ABRMOD0 [21:21]
/// ABRMOD0
ABRMOD0: u1 = 0,
/// ABRMOD1 [22:22]
/// Auto baud rate mode
ABRMOD1: u1 = 0,
/// RTOEN [23:23]
/// Receiver timeout enable
RTOEN: u1 = 0,
/// ADD0_3 [24:27]
/// Address of the USART node
ADD0_3: u4 = 0,
/// ADD4_7 [28:31]
/// Address of the USART node
ADD4_7: u4 = 0,
};
/// Control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// CR3
const CR3_val = packed struct {
/// EIE [0:0]
/// Error interrupt enable
EIE: u1 = 0,
/// IREN [1:1]
/// Ir mode enable
IREN: u1 = 0,
/// IRLP [2:2]
/// Ir low-power
IRLP: u1 = 0,
/// HDSEL [3:3]
/// Half-duplex selection
HDSEL: u1 = 0,
/// NACK [4:4]
/// Smartcard NACK enable
NACK: u1 = 0,
/// SCEN [5:5]
/// Smartcard mode enable
SCEN: u1 = 0,
/// DMAR [6:6]
/// DMA enable receiver
DMAR: u1 = 0,
/// DMAT [7:7]
/// DMA enable transmitter
DMAT: u1 = 0,
/// RTSE [8:8]
/// RTS enable
RTSE: u1 = 0,
/// CTSE [9:9]
/// CTS enable
CTSE: u1 = 0,
/// CTSIE [10:10]
/// CTS interrupt enable
CTSIE: u1 = 0,
/// ONEBIT [11:11]
/// One sample bit method
ONEBIT: u1 = 0,
/// OVRDIS [12:12]
/// Overrun Disable
OVRDIS: u1 = 0,
/// DDRE [13:13]
/// DMA Disable on Reception
DDRE: u1 = 0,
/// DEM [14:14]
/// Driver enable mode
DEM: u1 = 0,
/// DEP [15:15]
/// Driver enable polarity
DEP: u1 = 0,
/// unused [16:16]
_unused16: u1 = 0,
/// SCARCNT [17:19]
/// Smartcard auto-retry count
SCARCNT: u3 = 0,
/// WUS [20:21]
/// Wakeup from Stop mode interrupt flag
WUS: u2 = 0,
/// WUFIE [22:22]
/// Wakeup from Stop mode interrupt
WUFIE: u1 = 0,
/// UCESM [23:23]
/// USART Clock Enable in Stop
UCESM: u1 = 0,
/// TCBGTIE [24:24]
/// Transmission complete before guard time
TCBGTIE: u1 = 0,
/// unused [25:31]
_unused25: u7 = 0,
};
/// Control register 3
pub const CR3 = Register(CR3_val).init(base_address + 0x8);

/// BRR
const BRR_val = packed struct {
/// BRR [0:11]
/// USARTDIV
BRR: u12 = 0,
/// unused [12:31]
_unused12: u4 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Baud rate register
pub const BRR = Register(BRR_val).init(base_address + 0xc);

/// GTPR
const GTPR_val = packed struct {
/// PSC [0:7]
/// Prescaler value
PSC: u8 = 0,
/// GT [8:15]
/// Guard time value
GT: u8 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Guard time and prescaler
pub const GTPR = Register(GTPR_val).init(base_address + 0x10);

/// RTOR
const RTOR_val = packed struct {
/// RTO [0:23]
/// Receiver timeout value
RTO: u24 = 0,
/// BLEN [24:31]
/// Block Length
BLEN: u8 = 0,
};
/// Receiver timeout register
pub const RTOR = Register(RTOR_val).init(base_address + 0x14);

/// RQR
const RQR_val = packed struct {
/// ABRRQ [0:0]
/// Auto baud rate request
ABRRQ: u1 = 0,
/// SBKRQ [1:1]
/// Send break request
SBKRQ: u1 = 0,
/// MMRQ [2:2]
/// Mute mode request
MMRQ: u1 = 0,
/// RXFRQ [3:3]
/// Receive data flush request
RXFRQ: u1 = 0,
/// TXFRQ [4:4]
/// Transmit data flush
TXFRQ: u1 = 0,
/// unused [5:31]
_unused5: u3 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Request register
pub const RQR = Register(RQR_val).init(base_address + 0x18);

/// ISR
const ISR_val = packed struct {
/// PE [0:0]
/// PE
PE: u1 = 0,
/// FE [1:1]
/// FE
FE: u1 = 0,
/// NF [2:2]
/// NF
NF: u1 = 0,
/// ORE [3:3]
/// ORE
ORE: u1 = 0,
/// IDLE [4:4]
/// IDLE
IDLE: u1 = 0,
/// RXNE [5:5]
/// RXNE
RXNE: u1 = 0,
/// TC [6:6]
/// TC
TC: u1 = 1,
/// TXE [7:7]
/// TXE
TXE: u1 = 1,
/// LBDF [8:8]
/// LBDF
LBDF: u1 = 0,
/// CTSIF [9:9]
/// CTSIF
CTSIF: u1 = 0,
/// CTS [10:10]
/// CTS
CTS: u1 = 0,
/// RTOF [11:11]
/// RTOF
RTOF: u1 = 0,
/// EOBF [12:12]
/// EOBF
EOBF: u1 = 0,
/// unused [13:13]
_unused13: u1 = 0,
/// ABRE [14:14]
/// ABRE
ABRE: u1 = 0,
/// ABRF [15:15]
/// ABRF
ABRF: u1 = 0,
/// BUSY [16:16]
/// BUSY
BUSY: u1 = 0,
/// CMF [17:17]
/// CMF
CMF: u1 = 0,
/// SBKF [18:18]
/// SBKF
SBKF: u1 = 0,
/// RWU [19:19]
/// RWU
RWU: u1 = 0,
/// WUF [20:20]
/// WUF
WUF: u1 = 0,
/// TEACK [21:21]
/// TEACK
TEACK: u1 = 0,
/// REACK [22:22]
/// REACK
REACK: u1 = 0,
/// unused [23:24]
_unused23: u1 = 0,
_unused24: u1 = 0,
/// TCBGT [25:25]
/// Transmission complete before guard time
TCBGT: u1 = 0,
/// unused [26:31]
_unused26: u6 = 0,
};
/// Interrupt &amp; status
pub const ISR = Register(ISR_val).init(base_address + 0x1c);

/// ICR
const ICR_val = packed struct {
/// PECF [0:0]
/// Parity error clear flag
PECF: u1 = 0,
/// FECF [1:1]
/// Framing error clear flag
FECF: u1 = 0,
/// NCF [2:2]
/// Noise detected clear flag
NCF: u1 = 0,
/// ORECF [3:3]
/// Overrun error clear flag
ORECF: u1 = 0,
/// IDLECF [4:4]
/// Idle line detected clear
IDLECF: u1 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// TCCF [6:6]
/// Transmission complete clear
TCCF: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// LBDCF [8:8]
/// LIN break detection clear
LBDCF: u1 = 0,
/// CTSCF [9:9]
/// CTS clear flag
CTSCF: u1 = 0,
/// unused [10:10]
_unused10: u1 = 0,
/// RTOCF [11:11]
/// Receiver timeout clear
RTOCF: u1 = 0,
/// EOBCF [12:12]
/// End of block clear flag
EOBCF: u1 = 0,
/// unused [13:16]
_unused13: u3 = 0,
_unused16: u1 = 0,
/// CMCF [17:17]
/// Character match clear flag
CMCF: u1 = 0,
/// unused [18:19]
_unused18: u2 = 0,
/// WUCF [20:20]
/// Wakeup from Stop mode clear
WUCF: u1 = 0,
/// unused [21:31]
_unused21: u3 = 0,
_unused24: u8 = 0,
};
/// Interrupt flag clear register
pub const ICR = Register(ICR_val).init(base_address + 0x20);

/// RDR
const RDR_val = packed struct {
/// RDR [0:8]
/// Receive data value
RDR: u9 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Receive data register
pub const RDR = Register(RDR_val).init(base_address + 0x24);

/// TDR
const TDR_val = packed struct {
/// TDR [0:8]
/// Transmit data value
TDR: u9 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Transmit data register
pub const TDR = Register(TDR_val).init(base_address + 0x28);
};

/// Universal synchronous asynchronous receiver
pub const LPUART1 = struct {

const base_address = 0x40008000;
/// CR1
const CR1_val = packed struct {
/// UE [0:0]
/// USART enable
UE: u1 = 0,
/// UESM [1:1]
/// USART enable in Stop mode
UESM: u1 = 0,
/// RE [2:2]
/// Receiver enable
RE: u1 = 0,
/// TE [3:3]
/// Transmitter enable
TE: u1 = 0,
/// IDLEIE [4:4]
/// IDLE interrupt enable
IDLEIE: u1 = 0,
/// RXNEIE [5:5]
/// RXNE interrupt enable
RXNEIE: u1 = 0,
/// TCIE [6:6]
/// Transmission complete interrupt
TCIE: u1 = 0,
/// TXEIE [7:7]
/// interrupt enable
TXEIE: u1 = 0,
/// PEIE [8:8]
/// PE interrupt enable
PEIE: u1 = 0,
/// PS [9:9]
/// Parity selection
PS: u1 = 0,
/// PCE [10:10]
/// Parity control enable
PCE: u1 = 0,
/// WAKE [11:11]
/// Receiver wakeup method
WAKE: u1 = 0,
/// M0 [12:12]
/// Word length
M0: u1 = 0,
/// MME [13:13]
/// Mute mode enable
MME: u1 = 0,
/// CMIE [14:14]
/// Character match interrupt
CMIE: u1 = 0,
/// unused [15:15]
_unused15: u1 = 0,
/// DEDT0 [16:16]
/// DEDT0
DEDT0: u1 = 0,
/// DEDT1 [17:17]
/// DEDT1
DEDT1: u1 = 0,
/// DEDT2 [18:18]
/// DEDT2
DEDT2: u1 = 0,
/// DEDT3 [19:19]
/// DEDT3
DEDT3: u1 = 0,
/// DEDT4 [20:20]
/// Driver Enable de-assertion
DEDT4: u1 = 0,
/// DEAT0 [21:21]
/// DEAT0
DEAT0: u1 = 0,
/// DEAT1 [22:22]
/// DEAT1
DEAT1: u1 = 0,
/// DEAT2 [23:23]
/// DEAT2
DEAT2: u1 = 0,
/// DEAT3 [24:24]
/// DEAT3
DEAT3: u1 = 0,
/// DEAT4 [25:25]
/// Driver Enable assertion
DEAT4: u1 = 0,
/// unused [26:27]
_unused26: u2 = 0,
/// M1 [28:28]
/// Word length
M1: u1 = 0,
/// unused [29:31]
_unused29: u3 = 0,
};
/// Control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// unused [0:3]
_unused0: u4 = 0,
/// ADDM7 [4:4]
/// 7-bit Address Detection/4-bit Address
ADDM7: u1 = 0,
/// unused [5:10]
_unused5: u3 = 0,
_unused8: u3 = 0,
/// CLKEN [11:11]
/// Clock enable
CLKEN: u1 = 0,
/// STOP [12:13]
/// STOP bits
STOP: u2 = 0,
/// unused [14:14]
_unused14: u1 = 0,
/// SWAP [15:15]
/// Swap TX/RX pins
SWAP: u1 = 0,
/// RXINV [16:16]
/// RX pin active level
RXINV: u1 = 0,
/// TXINV [17:17]
/// TX pin active level
TXINV: u1 = 0,
/// TAINV [18:18]
/// Binary data inversion
TAINV: u1 = 0,
/// MSBFIRST [19:19]
/// Most significant bit first
MSBFIRST: u1 = 0,
/// unused [20:23]
_unused20: u4 = 0,
/// ADD0_3 [24:27]
/// Address of the USART node
ADD0_3: u4 = 0,
/// ADD4_7 [28:31]
/// Address of the USART node
ADD4_7: u4 = 0,
};
/// Control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// CR3
const CR3_val = packed struct {
/// EIE [0:0]
/// Error interrupt enable
EIE: u1 = 0,
/// unused [1:2]
_unused1: u2 = 0,
/// HDSEL [3:3]
/// Half-duplex selection
HDSEL: u1 = 0,
/// unused [4:5]
_unused4: u2 = 0,
/// DMAR [6:6]
/// DMA enable receiver
DMAR: u1 = 0,
/// DMAT [7:7]
/// DMA enable transmitter
DMAT: u1 = 0,
/// RTSE [8:8]
/// RTS enable
RTSE: u1 = 0,
/// CTSE [9:9]
/// CTS enable
CTSE: u1 = 0,
/// CTSIE [10:10]
/// CTS interrupt enable
CTSIE: u1 = 0,
/// unused [11:11]
_unused11: u1 = 0,
/// OVRDIS [12:12]
/// Overrun Disable
OVRDIS: u1 = 0,
/// DDRE [13:13]
/// DMA Disable on Reception
DDRE: u1 = 0,
/// DEM [14:14]
/// Driver enable mode
DEM: u1 = 0,
/// DEP [15:15]
/// Driver enable polarity
DEP: u1 = 0,
/// unused [16:19]
_unused16: u4 = 0,
/// WUS [20:21]
/// Wakeup from Stop mode interrupt flag
WUS: u2 = 0,
/// WUFIE [22:22]
/// Wakeup from Stop mode interrupt
WUFIE: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// Control register 3
pub const CR3 = Register(CR3_val).init(base_address + 0x8);

/// BRR
const BRR_val = packed struct {
/// BRR [0:19]
/// BRR
BRR: u20 = 0,
/// unused [20:31]
_unused20: u4 = 0,
_unused24: u8 = 0,
};
/// Baud rate register
pub const BRR = Register(BRR_val).init(base_address + 0xc);

/// RQR
const RQR_val = packed struct {
/// unused [0:0]
_unused0: u1 = 0,
/// SBKRQ [1:1]
/// Send break request
SBKRQ: u1 = 0,
/// MMRQ [2:2]
/// Mute mode request
MMRQ: u1 = 0,
/// RXFRQ [3:3]
/// Receive data flush request
RXFRQ: u1 = 0,
/// unused [4:31]
_unused4: u4 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Request register
pub const RQR = Register(RQR_val).init(base_address + 0x18);

/// ISR
const ISR_val = packed struct {
/// PE [0:0]
/// PE
PE: u1 = 0,
/// FE [1:1]
/// FE
FE: u1 = 0,
/// NF [2:2]
/// NF
NF: u1 = 0,
/// ORE [3:3]
/// ORE
ORE: u1 = 0,
/// IDLE [4:4]
/// IDLE
IDLE: u1 = 0,
/// RXNE [5:5]
/// RXNE
RXNE: u1 = 0,
/// TC [6:6]
/// TC
TC: u1 = 1,
/// TXE [7:7]
/// TXE
TXE: u1 = 1,
/// unused [8:8]
_unused8: u1 = 0,
/// CTSIF [9:9]
/// CTSIF
CTSIF: u1 = 0,
/// CTS [10:10]
/// CTS
CTS: u1 = 0,
/// unused [11:15]
_unused11: u5 = 0,
/// BUSY [16:16]
/// BUSY
BUSY: u1 = 0,
/// CMF [17:17]
/// CMF
CMF: u1 = 0,
/// SBKF [18:18]
/// SBKF
SBKF: u1 = 0,
/// RWU [19:19]
/// RWU
RWU: u1 = 0,
/// WUF [20:20]
/// WUF
WUF: u1 = 0,
/// TEACK [21:21]
/// TEACK
TEACK: u1 = 0,
/// REACK [22:22]
/// REACK
REACK: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// Interrupt &amp; status
pub const ISR = Register(ISR_val).init(base_address + 0x1c);

/// ICR
const ICR_val = packed struct {
/// PECF [0:0]
/// Parity error clear flag
PECF: u1 = 0,
/// FECF [1:1]
/// Framing error clear flag
FECF: u1 = 0,
/// NCF [2:2]
/// Noise detected clear flag
NCF: u1 = 0,
/// ORECF [3:3]
/// Overrun error clear flag
ORECF: u1 = 0,
/// IDLECF [4:4]
/// Idle line detected clear
IDLECF: u1 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// TCCF [6:6]
/// Transmission complete clear
TCCF: u1 = 0,
/// unused [7:8]
_unused7: u1 = 0,
_unused8: u1 = 0,
/// CTSCF [9:9]
/// CTS clear flag
CTSCF: u1 = 0,
/// unused [10:16]
_unused10: u6 = 0,
_unused16: u1 = 0,
/// CMCF [17:17]
/// Character match clear flag
CMCF: u1 = 0,
/// unused [18:19]
_unused18: u2 = 0,
/// WUCF [20:20]
/// Wakeup from Stop mode clear
WUCF: u1 = 0,
/// unused [21:31]
_unused21: u3 = 0,
_unused24: u8 = 0,
};
/// Interrupt flag clear register
pub const ICR = Register(ICR_val).init(base_address + 0x20);

/// RDR
const RDR_val = packed struct {
/// RDR [0:8]
/// Receive data value
RDR: u9 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Receive data register
pub const RDR = Register(RDR_val).init(base_address + 0x24);

/// TDR
const TDR_val = packed struct {
/// TDR [0:8]
/// Transmit data value
TDR: u9 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Transmit data register
pub const TDR = Register(TDR_val).init(base_address + 0x28);
};

/// Serial peripheral interface/Inter-IC
pub const SPI1 = struct {

const base_address = 0x40013000;
/// CR1
const CR1_val = packed struct {
/// CPHA [0:0]
/// Clock phase
CPHA: u1 = 0,
/// CPOL [1:1]
/// Clock polarity
CPOL: u1 = 0,
/// MSTR [2:2]
/// Master selection
MSTR: u1 = 0,
/// BR [3:5]
/// Baud rate control
BR: u3 = 0,
/// SPE [6:6]
/// SPI enable
SPE: u1 = 0,
/// LSBFIRST [7:7]
/// Frame format
LSBFIRST: u1 = 0,
/// SSI [8:8]
/// Internal slave select
SSI: u1 = 0,
/// SSM [9:9]
/// Software slave management
SSM: u1 = 0,
/// RXONLY [10:10]
/// Receive only
RXONLY: u1 = 0,
/// DFF [11:11]
/// Data frame format
DFF: u1 = 0,
/// CRCNEXT [12:12]
/// CRC transfer next
CRCNEXT: u1 = 0,
/// CRCEN [13:13]
/// Hardware CRC calculation
CRCEN: u1 = 0,
/// BIDIOE [14:14]
/// Output enable in bidirectional
BIDIOE: u1 = 0,
/// BIDIMODE [15:15]
/// Bidirectional data mode
BIDIMODE: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// RXDMAEN [0:0]
/// Rx buffer DMA enable
RXDMAEN: u1 = 0,
/// TXDMAEN [1:1]
/// Tx buffer DMA enable
TXDMAEN: u1 = 0,
/// SSOE [2:2]
/// SS output enable
SSOE: u1 = 0,
/// NSSP [3:3]
/// NSS pulse management
NSSP: u1 = 0,
/// FRF [4:4]
/// Frame format
FRF: u1 = 0,
/// ERRIE [5:5]
/// Error interrupt enable
ERRIE: u1 = 0,
/// RXNEIE [6:6]
/// RX buffer not empty interrupt
RXNEIE: u1 = 0,
/// TXEIE [7:7]
/// Tx buffer empty interrupt
TXEIE: u1 = 0,
/// DS [8:11]
/// Data size
DS: u4 = 0,
/// FRXTH [12:12]
/// FIFO reception threshold
FRXTH: u1 = 0,
/// LDMA_RX [13:13]
/// Last DMA transfer for
LDMA_RX: u1 = 0,
/// LDMA_TX [14:14]
/// Last DMA transfer for
LDMA_TX: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// SR
const SR_val = packed struct {
/// RXNE [0:0]
/// Receive buffer not empty
RXNE: u1 = 0,
/// TXE [1:1]
/// Transmit buffer empty
TXE: u1 = 1,
/// unused [2:3]
_unused2: u2 = 0,
/// CRCERR [4:4]
/// CRC error flag
CRCERR: u1 = 0,
/// MODF [5:5]
/// Mode fault
MODF: u1 = 0,
/// OVR [6:6]
/// Overrun flag
OVR: u1 = 0,
/// BSY [7:7]
/// Busy flag
BSY: u1 = 0,
/// TIFRFE [8:8]
/// TI frame format error
TIFRFE: u1 = 0,
/// FRLVL [9:10]
/// FIFO reception level
FRLVL: u2 = 0,
/// FTLVL [11:12]
/// FIFO transmission level
FTLVL: u2 = 0,
/// unused [13:31]
_unused13: u3 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// status register
pub const SR = Register(SR_val).init(base_address + 0x8);

/// DR
const DR_val = packed struct {
/// DR [0:15]
/// Data register
DR: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// data register
pub const DR = Register(DR_val).init(base_address + 0xc);

/// CRCPR
const CRCPR_val = packed struct {
/// CRCPOLY [0:15]
/// CRC polynomial register
CRCPOLY: u16 = 7,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// CRC polynomial register
pub const CRCPR = Register(CRCPR_val).init(base_address + 0x10);

/// RXCRCR
const RXCRCR_val = packed struct {
/// RxCRC [0:15]
/// Rx CRC register
RxCRC: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// RX CRC register
pub const RXCRCR = Register(RXCRCR_val).init(base_address + 0x14);

/// TXCRCR
const TXCRCR_val = packed struct {
/// TxCRC [0:15]
/// Tx CRC register
TxCRC: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// TX CRC register
pub const TXCRCR = Register(TXCRCR_val).init(base_address + 0x18);
};

/// Serial peripheral interface/Inter-IC
pub const SPI3 = struct {

const base_address = 0x40003c00;
/// CR1
const CR1_val = packed struct {
/// CPHA [0:0]
/// Clock phase
CPHA: u1 = 0,
/// CPOL [1:1]
/// Clock polarity
CPOL: u1 = 0,
/// MSTR [2:2]
/// Master selection
MSTR: u1 = 0,
/// BR [3:5]
/// Baud rate control
BR: u3 = 0,
/// SPE [6:6]
/// SPI enable
SPE: u1 = 0,
/// LSBFIRST [7:7]
/// Frame format
LSBFIRST: u1 = 0,
/// SSI [8:8]
/// Internal slave select
SSI: u1 = 0,
/// SSM [9:9]
/// Software slave management
SSM: u1 = 0,
/// RXONLY [10:10]
/// Receive only
RXONLY: u1 = 0,
/// DFF [11:11]
/// Data frame format
DFF: u1 = 0,
/// CRCNEXT [12:12]
/// CRC transfer next
CRCNEXT: u1 = 0,
/// CRCEN [13:13]
/// Hardware CRC calculation
CRCEN: u1 = 0,
/// BIDIOE [14:14]
/// Output enable in bidirectional
BIDIOE: u1 = 0,
/// BIDIMODE [15:15]
/// Bidirectional data mode
BIDIMODE: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// RXDMAEN [0:0]
/// Rx buffer DMA enable
RXDMAEN: u1 = 0,
/// TXDMAEN [1:1]
/// Tx buffer DMA enable
TXDMAEN: u1 = 0,
/// SSOE [2:2]
/// SS output enable
SSOE: u1 = 0,
/// NSSP [3:3]
/// NSS pulse management
NSSP: u1 = 0,
/// FRF [4:4]
/// Frame format
FRF: u1 = 0,
/// ERRIE [5:5]
/// Error interrupt enable
ERRIE: u1 = 0,
/// RXNEIE [6:6]
/// RX buffer not empty interrupt
RXNEIE: u1 = 0,
/// TXEIE [7:7]
/// Tx buffer empty interrupt
TXEIE: u1 = 0,
/// DS [8:11]
/// Data size
DS: u4 = 0,
/// FRXTH [12:12]
/// FIFO reception threshold
FRXTH: u1 = 0,
/// LDMA_RX [13:13]
/// Last DMA transfer for
LDMA_RX: u1 = 0,
/// LDMA_TX [14:14]
/// Last DMA transfer for
LDMA_TX: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// SR
const SR_val = packed struct {
/// RXNE [0:0]
/// Receive buffer not empty
RXNE: u1 = 0,
/// TXE [1:1]
/// Transmit buffer empty
TXE: u1 = 1,
/// unused [2:3]
_unused2: u2 = 0,
/// CRCERR [4:4]
/// CRC error flag
CRCERR: u1 = 0,
/// MODF [5:5]
/// Mode fault
MODF: u1 = 0,
/// OVR [6:6]
/// Overrun flag
OVR: u1 = 0,
/// BSY [7:7]
/// Busy flag
BSY: u1 = 0,
/// TIFRFE [8:8]
/// TI frame format error
TIFRFE: u1 = 0,
/// FRLVL [9:10]
/// FIFO reception level
FRLVL: u2 = 0,
/// FTLVL [11:12]
/// FIFO transmission level
FTLVL: u2 = 0,
/// unused [13:31]
_unused13: u3 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// status register
pub const SR = Register(SR_val).init(base_address + 0x8);

/// DR
const DR_val = packed struct {
/// DR [0:15]
/// Data register
DR: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// data register
pub const DR = Register(DR_val).init(base_address + 0xc);

/// CRCPR
const CRCPR_val = packed struct {
/// CRCPOLY [0:15]
/// CRC polynomial register
CRCPOLY: u16 = 7,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// CRC polynomial register
pub const CRCPR = Register(CRCPR_val).init(base_address + 0x10);

/// RXCRCR
const RXCRCR_val = packed struct {
/// RxCRC [0:15]
/// Rx CRC register
RxCRC: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// RX CRC register
pub const RXCRCR = Register(RXCRCR_val).init(base_address + 0x14);

/// TXCRCR
const TXCRCR_val = packed struct {
/// TxCRC [0:15]
/// Tx CRC register
TxCRC: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// TX CRC register
pub const TXCRCR = Register(TXCRCR_val).init(base_address + 0x18);
};

/// Serial peripheral interface/Inter-IC
pub const SPI2 = struct {

const base_address = 0x40003800;
/// CR1
const CR1_val = packed struct {
/// CPHA [0:0]
/// Clock phase
CPHA: u1 = 0,
/// CPOL [1:1]
/// Clock polarity
CPOL: u1 = 0,
/// MSTR [2:2]
/// Master selection
MSTR: u1 = 0,
/// BR [3:5]
/// Baud rate control
BR: u3 = 0,
/// SPE [6:6]
/// SPI enable
SPE: u1 = 0,
/// LSBFIRST [7:7]
/// Frame format
LSBFIRST: u1 = 0,
/// SSI [8:8]
/// Internal slave select
SSI: u1 = 0,
/// SSM [9:9]
/// Software slave management
SSM: u1 = 0,
/// RXONLY [10:10]
/// Receive only
RXONLY: u1 = 0,
/// DFF [11:11]
/// Data frame format
DFF: u1 = 0,
/// CRCNEXT [12:12]
/// CRC transfer next
CRCNEXT: u1 = 0,
/// CRCEN [13:13]
/// Hardware CRC calculation
CRCEN: u1 = 0,
/// BIDIOE [14:14]
/// Output enable in bidirectional
BIDIOE: u1 = 0,
/// BIDIMODE [15:15]
/// Bidirectional data mode
BIDIMODE: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// RXDMAEN [0:0]
/// Rx buffer DMA enable
RXDMAEN: u1 = 0,
/// TXDMAEN [1:1]
/// Tx buffer DMA enable
TXDMAEN: u1 = 0,
/// SSOE [2:2]
/// SS output enable
SSOE: u1 = 0,
/// NSSP [3:3]
/// NSS pulse management
NSSP: u1 = 0,
/// FRF [4:4]
/// Frame format
FRF: u1 = 0,
/// ERRIE [5:5]
/// Error interrupt enable
ERRIE: u1 = 0,
/// RXNEIE [6:6]
/// RX buffer not empty interrupt
RXNEIE: u1 = 0,
/// TXEIE [7:7]
/// Tx buffer empty interrupt
TXEIE: u1 = 0,
/// DS [8:11]
/// Data size
DS: u4 = 0,
/// FRXTH [12:12]
/// FIFO reception threshold
FRXTH: u1 = 0,
/// LDMA_RX [13:13]
/// Last DMA transfer for
LDMA_RX: u1 = 0,
/// LDMA_TX [14:14]
/// Last DMA transfer for
LDMA_TX: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// SR
const SR_val = packed struct {
/// RXNE [0:0]
/// Receive buffer not empty
RXNE: u1 = 0,
/// TXE [1:1]
/// Transmit buffer empty
TXE: u1 = 1,
/// unused [2:3]
_unused2: u2 = 0,
/// CRCERR [4:4]
/// CRC error flag
CRCERR: u1 = 0,
/// MODF [5:5]
/// Mode fault
MODF: u1 = 0,
/// OVR [6:6]
/// Overrun flag
OVR: u1 = 0,
/// BSY [7:7]
/// Busy flag
BSY: u1 = 0,
/// TIFRFE [8:8]
/// TI frame format error
TIFRFE: u1 = 0,
/// FRLVL [9:10]
/// FIFO reception level
FRLVL: u2 = 0,
/// FTLVL [11:12]
/// FIFO transmission level
FTLVL: u2 = 0,
/// unused [13:31]
_unused13: u3 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// status register
pub const SR = Register(SR_val).init(base_address + 0x8);

/// DR
const DR_val = packed struct {
/// DR [0:15]
/// Data register
DR: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// data register
pub const DR = Register(DR_val).init(base_address + 0xc);

/// CRCPR
const CRCPR_val = packed struct {
/// CRCPOLY [0:15]
/// CRC polynomial register
CRCPOLY: u16 = 7,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// CRC polynomial register
pub const CRCPR = Register(CRCPR_val).init(base_address + 0x10);

/// RXCRCR
const RXCRCR_val = packed struct {
/// RxCRC [0:15]
/// Rx CRC register
RxCRC: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// RX CRC register
pub const RXCRCR = Register(RXCRCR_val).init(base_address + 0x14);

/// TXCRCR
const TXCRCR_val = packed struct {
/// TxCRC [0:15]
/// Tx CRC register
TxCRC: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// TX CRC register
pub const TXCRCR = Register(TXCRCR_val).init(base_address + 0x18);
};

/// Secure digital input/output
pub const SDMMC = struct {

const base_address = 0x40012800;
/// POWER
const POWER_val = packed struct {
/// PWRCTRL [0:1]
/// PWRCTRL
PWRCTRL: u2 = 0,
/// unused [2:31]
_unused2: u6 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// power control register
pub const POWER = Register(POWER_val).init(base_address + 0x0);

/// CLKCR
const CLKCR_val = packed struct {
/// CLKDIV [0:7]
/// Clock divide factor
CLKDIV: u8 = 0,
/// CLKEN [8:8]
/// Clock enable bit
CLKEN: u1 = 0,
/// PWRSAV [9:9]
/// Power saving configuration
PWRSAV: u1 = 0,
/// BYPASS [10:10]
/// Clock divider bypass enable
BYPASS: u1 = 0,
/// WIDBUS [11:12]
/// Wide bus mode enable bit
WIDBUS: u2 = 0,
/// NEGEDGE [13:13]
/// SDIO_CK dephasing selection
NEGEDGE: u1 = 0,
/// HWFC_EN [14:14]
/// HW Flow Control enable
HWFC_EN: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// SDI clock control register
pub const CLKCR = Register(CLKCR_val).init(base_address + 0x4);

/// ARG
const ARG_val = packed struct {
/// CMDARG [0:31]
/// Command argument
CMDARG: u32 = 0,
};
/// argument register
pub const ARG = Register(ARG_val).init(base_address + 0x8);

/// CMD
const CMD_val = packed struct {
/// CMDINDEX [0:5]
/// Command index
CMDINDEX: u6 = 0,
/// WAITRESP [6:7]
/// Wait for response bits
WAITRESP: u2 = 0,
/// WAITINT [8:8]
/// CPSM waits for interrupt
WAITINT: u1 = 0,
/// WAITPEND [9:9]
/// CPSM Waits for ends of data transfer
WAITPEND: u1 = 0,
/// CPSMEN [10:10]
/// Command path state machine (CPSM) Enable
CPSMEN: u1 = 0,
/// SDIOSuspend [11:11]
/// SD I/O suspend command
SDIOSuspend: u1 = 0,
/// ENCMDcompl [12:12]
/// Enable CMD completion
ENCMDcompl: u1 = 0,
/// nIEN [13:13]
/// not Interrupt Enable
nIEN: u1 = 0,
/// CE_ATACMD [14:14]
/// CE-ATA command
CE_ATACMD: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// command register
pub const CMD = Register(CMD_val).init(base_address + 0xc);

/// RESPCMD
const RESPCMD_val = packed struct {
/// RESPCMD [0:5]
/// Response command index
RESPCMD: u6 = 0,
/// unused [6:31]
_unused6: u2 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// command response register
pub const RESPCMD = Register(RESPCMD_val).init(base_address + 0x10);

/// RESP1
const RESP1_val = packed struct {
/// CARDSTATUS1 [0:31]
/// see Table 132
CARDSTATUS1: u32 = 0,
};
/// response 1..4 register
pub const RESP1 = Register(RESP1_val).init(base_address + 0x14);

/// RESP2
const RESP2_val = packed struct {
/// CARDSTATUS2 [0:31]
/// see Table 132
CARDSTATUS2: u32 = 0,
};
/// response 1..4 register
pub const RESP2 = Register(RESP2_val).init(base_address + 0x18);

/// RESP3
const RESP3_val = packed struct {
/// CARDSTATUS3 [0:31]
/// see Table 132
CARDSTATUS3: u32 = 0,
};
/// response 1..4 register
pub const RESP3 = Register(RESP3_val).init(base_address + 0x1c);

/// RESP4
const RESP4_val = packed struct {
/// CARDSTATUS4 [0:31]
/// see Table 132
CARDSTATUS4: u32 = 0,
};
/// response 1..4 register
pub const RESP4 = Register(RESP4_val).init(base_address + 0x20);

/// DTIMER
const DTIMER_val = packed struct {
/// DATATIME [0:31]
/// Data timeout period
DATATIME: u32 = 0,
};
/// data timer register
pub const DTIMER = Register(DTIMER_val).init(base_address + 0x24);

/// DLEN
const DLEN_val = packed struct {
/// DATALENGTH [0:24]
/// Data length value
DATALENGTH: u25 = 0,
/// unused [25:31]
_unused25: u7 = 0,
};
/// data length register
pub const DLEN = Register(DLEN_val).init(base_address + 0x28);

/// DCTRL
const DCTRL_val = packed struct {
/// DTEN [0:0]
/// DTEN
DTEN: u1 = 0,
/// DTDIR [1:1]
/// Data transfer direction
DTDIR: u1 = 0,
/// DTMODE [2:2]
/// Data transfer mode selection 1: Stream
DTMODE: u1 = 0,
/// DMAEN [3:3]
/// DMA enable bit
DMAEN: u1 = 0,
/// DBLOCKSIZE [4:7]
/// Data block size
DBLOCKSIZE: u4 = 0,
/// RWSTART [8:8]
/// Read wait start
RWSTART: u1 = 0,
/// RWSTOP [9:9]
/// Read wait stop
RWSTOP: u1 = 0,
/// RWMOD [10:10]
/// Read wait mode
RWMOD: u1 = 0,
/// SDIOEN [11:11]
/// SD I/O enable functions
SDIOEN: u1 = 0,
/// unused [12:31]
_unused12: u4 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// data control register
pub const DCTRL = Register(DCTRL_val).init(base_address + 0x2c);

/// DCOUNT
const DCOUNT_val = packed struct {
/// DATACOUNT [0:24]
/// Data count value
DATACOUNT: u25 = 0,
/// unused [25:31]
_unused25: u7 = 0,
};
/// data counter register
pub const DCOUNT = Register(DCOUNT_val).init(base_address + 0x30);

/// STA
const STA_val = packed struct {
/// CCRCFAIL [0:0]
/// Command response received (CRC check
CCRCFAIL: u1 = 0,
/// DCRCFAIL [1:1]
/// Data block sent/received (CRC check
DCRCFAIL: u1 = 0,
/// CTIMEOUT [2:2]
/// Command response timeout
CTIMEOUT: u1 = 0,
/// DTIMEOUT [3:3]
/// Data timeout
DTIMEOUT: u1 = 0,
/// TXUNDERR [4:4]
/// Transmit FIFO underrun
TXUNDERR: u1 = 0,
/// RXOVERR [5:5]
/// Received FIFO overrun
RXOVERR: u1 = 0,
/// CMDREND [6:6]
/// Command response received (CRC check
CMDREND: u1 = 0,
/// CMDSENT [7:7]
/// Command sent (no response
CMDSENT: u1 = 0,
/// DATAEND [8:8]
/// Data end (data counter, SDIDCOUNT, is
DATAEND: u1 = 0,
/// STBITERR [9:9]
/// Start bit not detected on all data
STBITERR: u1 = 0,
/// DBCKEND [10:10]
/// Data block sent/received (CRC check
DBCKEND: u1 = 0,
/// CMDACT [11:11]
/// Command transfer in
CMDACT: u1 = 0,
/// TXACT [12:12]
/// Data transmit in progress
TXACT: u1 = 0,
/// RXACT [13:13]
/// Data receive in progress
RXACT: u1 = 0,
/// TXFIFOHE [14:14]
/// Transmit FIFO half empty: at least 8
TXFIFOHE: u1 = 0,
/// RXFIFOHF [15:15]
/// Receive FIFO half full: there are at
RXFIFOHF: u1 = 0,
/// TXFIFOF [16:16]
/// Transmit FIFO full
TXFIFOF: u1 = 0,
/// RXFIFOF [17:17]
/// Receive FIFO full
RXFIFOF: u1 = 0,
/// TXFIFOE [18:18]
/// Transmit FIFO empty
TXFIFOE: u1 = 0,
/// RXFIFOE [19:19]
/// Receive FIFO empty
RXFIFOE: u1 = 0,
/// TXDAVL [20:20]
/// Data available in transmit
TXDAVL: u1 = 0,
/// RXDAVL [21:21]
/// Data available in receive
RXDAVL: u1 = 0,
/// SDIOIT [22:22]
/// SDIO interrupt received
SDIOIT: u1 = 0,
/// CEATAEND [23:23]
/// CE-ATA command completion signal
CEATAEND: u1 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// status register
pub const STA = Register(STA_val).init(base_address + 0x34);

/// ICR
const ICR_val = packed struct {
/// CCRCFAILC [0:0]
/// CCRCFAIL flag clear bit
CCRCFAILC: u1 = 0,
/// DCRCFAILC [1:1]
/// DCRCFAIL flag clear bit
DCRCFAILC: u1 = 0,
/// CTIMEOUTC [2:2]
/// CTIMEOUT flag clear bit
CTIMEOUTC: u1 = 0,
/// DTIMEOUTC [3:3]
/// DTIMEOUT flag clear bit
DTIMEOUTC: u1 = 0,
/// TXUNDERRC [4:4]
/// TXUNDERR flag clear bit
TXUNDERRC: u1 = 0,
/// RXOVERRC [5:5]
/// RXOVERR flag clear bit
RXOVERRC: u1 = 0,
/// CMDRENDC [6:6]
/// CMDREND flag clear bit
CMDRENDC: u1 = 0,
/// CMDSENTC [7:7]
/// CMDSENT flag clear bit
CMDSENTC: u1 = 0,
/// DATAENDC [8:8]
/// DATAEND flag clear bit
DATAENDC: u1 = 0,
/// STBITERRC [9:9]
/// STBITERR flag clear bit
STBITERRC: u1 = 0,
/// DBCKENDC [10:10]
/// DBCKEND flag clear bit
DBCKENDC: u1 = 0,
/// unused [11:21]
_unused11: u5 = 0,
_unused16: u6 = 0,
/// SDIOITC [22:22]
/// SDIOIT flag clear bit
SDIOITC: u1 = 0,
/// CEATAENDC [23:23]
/// CEATAEND flag clear bit
CEATAENDC: u1 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// interrupt clear register
pub const ICR = Register(ICR_val).init(base_address + 0x38);

/// MASK
const MASK_val = packed struct {
/// CCRCFAILIE [0:0]
/// Command CRC fail interrupt
CCRCFAILIE: u1 = 0,
/// DCRCFAILIE [1:1]
/// Data CRC fail interrupt
DCRCFAILIE: u1 = 0,
/// CTIMEOUTIE [2:2]
/// Command timeout interrupt
CTIMEOUTIE: u1 = 0,
/// DTIMEOUTIE [3:3]
/// Data timeout interrupt
DTIMEOUTIE: u1 = 0,
/// TXUNDERRIE [4:4]
/// Tx FIFO underrun error interrupt
TXUNDERRIE: u1 = 0,
/// RXOVERRIE [5:5]
/// Rx FIFO overrun error interrupt
RXOVERRIE: u1 = 0,
/// CMDRENDIE [6:6]
/// Command response received interrupt
CMDRENDIE: u1 = 0,
/// CMDSENTIE [7:7]
/// Command sent interrupt
CMDSENTIE: u1 = 0,
/// DATAENDIE [8:8]
/// Data end interrupt enable
DATAENDIE: u1 = 0,
/// STBITERRIE [9:9]
/// Start bit error interrupt
STBITERRIE: u1 = 0,
/// DBCKENDIE [10:10]
/// Data block end interrupt
DBCKENDIE: u1 = 0,
/// CMDACTIE [11:11]
/// Command acting interrupt
CMDACTIE: u1 = 0,
/// TXACTIE [12:12]
/// Data transmit acting interrupt
TXACTIE: u1 = 0,
/// RXACTIE [13:13]
/// Data receive acting interrupt
RXACTIE: u1 = 0,
/// TXFIFOHEIE [14:14]
/// Tx FIFO half empty interrupt
TXFIFOHEIE: u1 = 0,
/// RXFIFOHFIE [15:15]
/// Rx FIFO half full interrupt
RXFIFOHFIE: u1 = 0,
/// TXFIFOFIE [16:16]
/// Tx FIFO full interrupt
TXFIFOFIE: u1 = 0,
/// RXFIFOFIE [17:17]
/// Rx FIFO full interrupt
RXFIFOFIE: u1 = 0,
/// TXFIFOEIE [18:18]
/// Tx FIFO empty interrupt
TXFIFOEIE: u1 = 0,
/// RXFIFOEIE [19:19]
/// Rx FIFO empty interrupt
RXFIFOEIE: u1 = 0,
/// TXDAVLIE [20:20]
/// Data available in Tx FIFO interrupt
TXDAVLIE: u1 = 0,
/// RXDAVLIE [21:21]
/// Data available in Rx FIFO interrupt
RXDAVLIE: u1 = 0,
/// SDIOITIE [22:22]
/// SDIO mode interrupt received interrupt
SDIOITIE: u1 = 0,
/// CEATAENDIE [23:23]
/// CE-ATA command completion signal
CEATAENDIE: u1 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// mask register
pub const MASK = Register(MASK_val).init(base_address + 0x3c);

/// FIFOCNT
const FIFOCNT_val = packed struct {
/// FIFOCOUNT [0:23]
/// Remaining number of words to be written
FIFOCOUNT: u24 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// FIFO counter register
pub const FIFOCNT = Register(FIFOCNT_val).init(base_address + 0x48);

/// FIFO
const FIFO_val = packed struct {
/// FIFOData [0:31]
/// Receive and transmit FIFO
FIFOData: u32 = 0,
};
/// data FIFO register
pub const FIFO = Register(FIFO_val).init(base_address + 0x80);
};

/// External interrupt/event
pub const EXTI = struct {

const base_address = 0x40010400;
/// IMR1
const IMR1_val = packed struct {
/// MR0 [0:0]
/// Interrupt Mask on line 0
MR0: u1 = 0,
/// MR1 [1:1]
/// Interrupt Mask on line 1
MR1: u1 = 0,
/// MR2 [2:2]
/// Interrupt Mask on line 2
MR2: u1 = 0,
/// MR3 [3:3]
/// Interrupt Mask on line 3
MR3: u1 = 0,
/// MR4 [4:4]
/// Interrupt Mask on line 4
MR4: u1 = 0,
/// MR5 [5:5]
/// Interrupt Mask on line 5
MR5: u1 = 0,
/// MR6 [6:6]
/// Interrupt Mask on line 6
MR6: u1 = 0,
/// MR7 [7:7]
/// Interrupt Mask on line 7
MR7: u1 = 0,
/// MR8 [8:8]
/// Interrupt Mask on line 8
MR8: u1 = 0,
/// MR9 [9:9]
/// Interrupt Mask on line 9
MR9: u1 = 0,
/// MR10 [10:10]
/// Interrupt Mask on line 10
MR10: u1 = 0,
/// MR11 [11:11]
/// Interrupt Mask on line 11
MR11: u1 = 0,
/// MR12 [12:12]
/// Interrupt Mask on line 12
MR12: u1 = 0,
/// MR13 [13:13]
/// Interrupt Mask on line 13
MR13: u1 = 0,
/// MR14 [14:14]
/// Interrupt Mask on line 14
MR14: u1 = 0,
/// MR15 [15:15]
/// Interrupt Mask on line 15
MR15: u1 = 0,
/// MR16 [16:16]
/// Interrupt Mask on line 16
MR16: u1 = 0,
/// MR17 [17:17]
/// Interrupt Mask on line 17
MR17: u1 = 1,
/// MR18 [18:18]
/// Interrupt Mask on line 18
MR18: u1 = 0,
/// MR19 [19:19]
/// Interrupt Mask on line 19
MR19: u1 = 0,
/// MR20 [20:20]
/// Interrupt Mask on line 20
MR20: u1 = 0,
/// MR21 [21:21]
/// Interrupt Mask on line 21
MR21: u1 = 0,
/// MR22 [22:22]
/// Interrupt Mask on line 22
MR22: u1 = 0,
/// MR23 [23:23]
/// Interrupt Mask on line 23
MR23: u1 = 1,
/// MR24 [24:24]
/// Interrupt Mask on line 24
MR24: u1 = 1,
/// MR25 [25:25]
/// Interrupt Mask on line 25
MR25: u1 = 1,
/// MR26 [26:26]
/// Interrupt Mask on line 26
MR26: u1 = 1,
/// MR27 [27:27]
/// Interrupt Mask on line 27
MR27: u1 = 1,
/// MR28 [28:28]
/// Interrupt Mask on line 28
MR28: u1 = 1,
/// MR29 [29:29]
/// Interrupt Mask on line 29
MR29: u1 = 1,
/// MR30 [30:30]
/// Interrupt Mask on line 30
MR30: u1 = 1,
/// MR31 [31:31]
/// Interrupt Mask on line 31
MR31: u1 = 1,
};
/// Interrupt mask register
pub const IMR1 = Register(IMR1_val).init(base_address + 0x0);

/// EMR1
const EMR1_val = packed struct {
/// MR0 [0:0]
/// Event Mask on line 0
MR0: u1 = 0,
/// MR1 [1:1]
/// Event Mask on line 1
MR1: u1 = 0,
/// MR2 [2:2]
/// Event Mask on line 2
MR2: u1 = 0,
/// MR3 [3:3]
/// Event Mask on line 3
MR3: u1 = 0,
/// MR4 [4:4]
/// Event Mask on line 4
MR4: u1 = 0,
/// MR5 [5:5]
/// Event Mask on line 5
MR5: u1 = 0,
/// MR6 [6:6]
/// Event Mask on line 6
MR6: u1 = 0,
/// MR7 [7:7]
/// Event Mask on line 7
MR7: u1 = 0,
/// MR8 [8:8]
/// Event Mask on line 8
MR8: u1 = 0,
/// MR9 [9:9]
/// Event Mask on line 9
MR9: u1 = 0,
/// MR10 [10:10]
/// Event Mask on line 10
MR10: u1 = 0,
/// MR11 [11:11]
/// Event Mask on line 11
MR11: u1 = 0,
/// MR12 [12:12]
/// Event Mask on line 12
MR12: u1 = 0,
/// MR13 [13:13]
/// Event Mask on line 13
MR13: u1 = 0,
/// MR14 [14:14]
/// Event Mask on line 14
MR14: u1 = 0,
/// MR15 [15:15]
/// Event Mask on line 15
MR15: u1 = 0,
/// MR16 [16:16]
/// Event Mask on line 16
MR16: u1 = 0,
/// MR17 [17:17]
/// Event Mask on line 17
MR17: u1 = 0,
/// MR18 [18:18]
/// Event Mask on line 18
MR18: u1 = 0,
/// MR19 [19:19]
/// Event Mask on line 19
MR19: u1 = 0,
/// MR20 [20:20]
/// Event Mask on line 20
MR20: u1 = 0,
/// MR21 [21:21]
/// Event Mask on line 21
MR21: u1 = 0,
/// MR22 [22:22]
/// Event Mask on line 22
MR22: u1 = 0,
/// MR23 [23:23]
/// Event Mask on line 23
MR23: u1 = 0,
/// MR24 [24:24]
/// Event Mask on line 24
MR24: u1 = 0,
/// MR25 [25:25]
/// Event Mask on line 25
MR25: u1 = 0,
/// MR26 [26:26]
/// Event Mask on line 26
MR26: u1 = 0,
/// MR27 [27:27]
/// Event Mask on line 27
MR27: u1 = 0,
/// MR28 [28:28]
/// Event Mask on line 28
MR28: u1 = 0,
/// MR29 [29:29]
/// Event Mask on line 29
MR29: u1 = 0,
/// MR30 [30:30]
/// Event Mask on line 30
MR30: u1 = 0,
/// MR31 [31:31]
/// Event Mask on line 31
MR31: u1 = 0,
};
/// Event mask register
pub const EMR1 = Register(EMR1_val).init(base_address + 0x4);

/// RTSR1
const RTSR1_val = packed struct {
/// TR0 [0:0]
/// Rising trigger event configuration of
TR0: u1 = 0,
/// TR1 [1:1]
/// Rising trigger event configuration of
TR1: u1 = 0,
/// TR2 [2:2]
/// Rising trigger event configuration of
TR2: u1 = 0,
/// TR3 [3:3]
/// Rising trigger event configuration of
TR3: u1 = 0,
/// TR4 [4:4]
/// Rising trigger event configuration of
TR4: u1 = 0,
/// TR5 [5:5]
/// Rising trigger event configuration of
TR5: u1 = 0,
/// TR6 [6:6]
/// Rising trigger event configuration of
TR6: u1 = 0,
/// TR7 [7:7]
/// Rising trigger event configuration of
TR7: u1 = 0,
/// TR8 [8:8]
/// Rising trigger event configuration of
TR8: u1 = 0,
/// TR9 [9:9]
/// Rising trigger event configuration of
TR9: u1 = 0,
/// TR10 [10:10]
/// Rising trigger event configuration of
TR10: u1 = 0,
/// TR11 [11:11]
/// Rising trigger event configuration of
TR11: u1 = 0,
/// TR12 [12:12]
/// Rising trigger event configuration of
TR12: u1 = 0,
/// TR13 [13:13]
/// Rising trigger event configuration of
TR13: u1 = 0,
/// TR14 [14:14]
/// Rising trigger event configuration of
TR14: u1 = 0,
/// TR15 [15:15]
/// Rising trigger event configuration of
TR15: u1 = 0,
/// TR16 [16:16]
/// Rising trigger event configuration of
TR16: u1 = 0,
/// unused [17:17]
_unused17: u1 = 0,
/// TR18 [18:18]
/// Rising trigger event configuration of
TR18: u1 = 0,
/// TR19 [19:19]
/// Rising trigger event configuration of
TR19: u1 = 0,
/// TR20 [20:20]
/// Rising trigger event configuration of
TR20: u1 = 0,
/// TR21 [21:21]
/// Rising trigger event configuration of
TR21: u1 = 0,
/// TR22 [22:22]
/// Rising trigger event configuration of
TR22: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// Rising Trigger selection
pub const RTSR1 = Register(RTSR1_val).init(base_address + 0x8);

/// FTSR1
const FTSR1_val = packed struct {
/// TR0 [0:0]
/// Falling trigger event configuration of
TR0: u1 = 0,
/// TR1 [1:1]
/// Falling trigger event configuration of
TR1: u1 = 0,
/// TR2 [2:2]
/// Falling trigger event configuration of
TR2: u1 = 0,
/// TR3 [3:3]
/// Falling trigger event configuration of
TR3: u1 = 0,
/// TR4 [4:4]
/// Falling trigger event configuration of
TR4: u1 = 0,
/// TR5 [5:5]
/// Falling trigger event configuration of
TR5: u1 = 0,
/// TR6 [6:6]
/// Falling trigger event configuration of
TR6: u1 = 0,
/// TR7 [7:7]
/// Falling trigger event configuration of
TR7: u1 = 0,
/// TR8 [8:8]
/// Falling trigger event configuration of
TR8: u1 = 0,
/// TR9 [9:9]
/// Falling trigger event configuration of
TR9: u1 = 0,
/// TR10 [10:10]
/// Falling trigger event configuration of
TR10: u1 = 0,
/// TR11 [11:11]
/// Falling trigger event configuration of
TR11: u1 = 0,
/// TR12 [12:12]
/// Falling trigger event configuration of
TR12: u1 = 0,
/// TR13 [13:13]
/// Falling trigger event configuration of
TR13: u1 = 0,
/// TR14 [14:14]
/// Falling trigger event configuration of
TR14: u1 = 0,
/// TR15 [15:15]
/// Falling trigger event configuration of
TR15: u1 = 0,
/// TR16 [16:16]
/// Falling trigger event configuration of
TR16: u1 = 0,
/// unused [17:17]
_unused17: u1 = 0,
/// TR18 [18:18]
/// Falling trigger event configuration of
TR18: u1 = 0,
/// TR19 [19:19]
/// Falling trigger event configuration of
TR19: u1 = 0,
/// TR20 [20:20]
/// Falling trigger event configuration of
TR20: u1 = 0,
/// TR21 [21:21]
/// Falling trigger event configuration of
TR21: u1 = 0,
/// TR22 [22:22]
/// Falling trigger event configuration of
TR22: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// Falling Trigger selection
pub const FTSR1 = Register(FTSR1_val).init(base_address + 0xc);

/// SWIER1
const SWIER1_val = packed struct {
/// SWIER0 [0:0]
/// Software Interrupt on line
SWIER0: u1 = 0,
/// SWIER1 [1:1]
/// Software Interrupt on line
SWIER1: u1 = 0,
/// SWIER2 [2:2]
/// Software Interrupt on line
SWIER2: u1 = 0,
/// SWIER3 [3:3]
/// Software Interrupt on line
SWIER3: u1 = 0,
/// SWIER4 [4:4]
/// Software Interrupt on line
SWIER4: u1 = 0,
/// SWIER5 [5:5]
/// Software Interrupt on line
SWIER5: u1 = 0,
/// SWIER6 [6:6]
/// Software Interrupt on line
SWIER6: u1 = 0,
/// SWIER7 [7:7]
/// Software Interrupt on line
SWIER7: u1 = 0,
/// SWIER8 [8:8]
/// Software Interrupt on line
SWIER8: u1 = 0,
/// SWIER9 [9:9]
/// Software Interrupt on line
SWIER9: u1 = 0,
/// SWIER10 [10:10]
/// Software Interrupt on line
SWIER10: u1 = 0,
/// SWIER11 [11:11]
/// Software Interrupt on line
SWIER11: u1 = 0,
/// SWIER12 [12:12]
/// Software Interrupt on line
SWIER12: u1 = 0,
/// SWIER13 [13:13]
/// Software Interrupt on line
SWIER13: u1 = 0,
/// SWIER14 [14:14]
/// Software Interrupt on line
SWIER14: u1 = 0,
/// SWIER15 [15:15]
/// Software Interrupt on line
SWIER15: u1 = 0,
/// SWIER16 [16:16]
/// Software Interrupt on line
SWIER16: u1 = 0,
/// unused [17:17]
_unused17: u1 = 0,
/// SWIER18 [18:18]
/// Software Interrupt on line
SWIER18: u1 = 0,
/// SWIER19 [19:19]
/// Software Interrupt on line
SWIER19: u1 = 0,
/// SWIER20 [20:20]
/// Software Interrupt on line
SWIER20: u1 = 0,
/// SWIER21 [21:21]
/// Software Interrupt on line
SWIER21: u1 = 0,
/// SWIER22 [22:22]
/// Software Interrupt on line
SWIER22: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// Software interrupt event
pub const SWIER1 = Register(SWIER1_val).init(base_address + 0x10);

/// PR1
const PR1_val = packed struct {
/// PR0 [0:0]
/// Pending bit 0
PR0: u1 = 0,
/// PR1 [1:1]
/// Pending bit 1
PR1: u1 = 0,
/// PR2 [2:2]
/// Pending bit 2
PR2: u1 = 0,
/// PR3 [3:3]
/// Pending bit 3
PR3: u1 = 0,
/// PR4 [4:4]
/// Pending bit 4
PR4: u1 = 0,
/// PR5 [5:5]
/// Pending bit 5
PR5: u1 = 0,
/// PR6 [6:6]
/// Pending bit 6
PR6: u1 = 0,
/// PR7 [7:7]
/// Pending bit 7
PR7: u1 = 0,
/// PR8 [8:8]
/// Pending bit 8
PR8: u1 = 0,
/// PR9 [9:9]
/// Pending bit 9
PR9: u1 = 0,
/// PR10 [10:10]
/// Pending bit 10
PR10: u1 = 0,
/// PR11 [11:11]
/// Pending bit 11
PR11: u1 = 0,
/// PR12 [12:12]
/// Pending bit 12
PR12: u1 = 0,
/// PR13 [13:13]
/// Pending bit 13
PR13: u1 = 0,
/// PR14 [14:14]
/// Pending bit 14
PR14: u1 = 0,
/// PR15 [15:15]
/// Pending bit 15
PR15: u1 = 0,
/// PR16 [16:16]
/// Pending bit 16
PR16: u1 = 0,
/// unused [17:17]
_unused17: u1 = 0,
/// PR18 [18:18]
/// Pending bit 18
PR18: u1 = 0,
/// PR19 [19:19]
/// Pending bit 19
PR19: u1 = 0,
/// PR20 [20:20]
/// Pending bit 20
PR20: u1 = 0,
/// PR21 [21:21]
/// Pending bit 21
PR21: u1 = 0,
/// PR22 [22:22]
/// Pending bit 22
PR22: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// Pending register
pub const PR1 = Register(PR1_val).init(base_address + 0x14);

/// IMR2
const IMR2_val = packed struct {
/// MR32 [0:0]
/// Interrupt Mask on external/internal line
MR32: u1 = 1,
/// MR33 [1:1]
/// Interrupt Mask on external/internal line
MR33: u1 = 1,
/// MR34 [2:2]
/// Interrupt Mask on external/internal line
MR34: u1 = 1,
/// MR35 [3:3]
/// Interrupt Mask on external/internal line
MR35: u1 = 0,
/// MR36 [4:4]
/// Interrupt Mask on external/internal line
MR36: u1 = 0,
/// MR37 [5:5]
/// Interrupt Mask on external/internal line
MR37: u1 = 0,
/// MR38 [6:6]
/// Interrupt Mask on external/internal line
MR38: u1 = 0,
/// MR39 [7:7]
/// Interrupt Mask on external/internal line
MR39: u1 = 1,
/// unused [8:31]
_unused8: u8 = 255,
_unused16: u8 = 255,
_unused24: u8 = 255,
};
/// Interrupt mask register
pub const IMR2 = Register(IMR2_val).init(base_address + 0x20);

/// EMR2
const EMR2_val = packed struct {
/// MR32 [0:0]
/// Event mask on external/internal line
MR32: u1 = 0,
/// MR33 [1:1]
/// Event mask on external/internal line
MR33: u1 = 0,
/// MR34 [2:2]
/// Event mask on external/internal line
MR34: u1 = 0,
/// MR35 [3:3]
/// Event mask on external/internal line
MR35: u1 = 0,
/// MR36 [4:4]
/// Event mask on external/internal line
MR36: u1 = 0,
/// MR37 [5:5]
/// Event mask on external/internal line
MR37: u1 = 0,
/// MR38 [6:6]
/// Event mask on external/internal line
MR38: u1 = 0,
/// MR39 [7:7]
/// Event mask on external/internal line
MR39: u1 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Event mask register
pub const EMR2 = Register(EMR2_val).init(base_address + 0x24);

/// RTSR2
const RTSR2_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// RT35 [3:3]
/// Rising trigger event configuration bit
RT35: u1 = 0,
/// RT36 [4:4]
/// Rising trigger event configuration bit
RT36: u1 = 0,
/// RT37 [5:5]
/// Rising trigger event configuration bit
RT37: u1 = 0,
/// RT38 [6:6]
/// Rising trigger event configuration bit
RT38: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Rising Trigger selection
pub const RTSR2 = Register(RTSR2_val).init(base_address + 0x28);

/// FTSR2
const FTSR2_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// FT35 [3:3]
/// Falling trigger event configuration bit
FT35: u1 = 0,
/// FT36 [4:4]
/// Falling trigger event configuration bit
FT36: u1 = 0,
/// FT37 [5:5]
/// Falling trigger event configuration bit
FT37: u1 = 0,
/// FT38 [6:6]
/// Falling trigger event configuration bit
FT38: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Falling Trigger selection
pub const FTSR2 = Register(FTSR2_val).init(base_address + 0x2c);

/// SWIER2
const SWIER2_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// SWI35 [3:3]
/// Software interrupt on line
SWI35: u1 = 0,
/// SWI36 [4:4]
/// Software interrupt on line
SWI36: u1 = 0,
/// SWI37 [5:5]
/// Software interrupt on line
SWI37: u1 = 0,
/// SWI38 [6:6]
/// Software interrupt on line
SWI38: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Software interrupt event
pub const SWIER2 = Register(SWIER2_val).init(base_address + 0x30);

/// PR2
const PR2_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// PIF35 [3:3]
/// Pending interrupt flag on line
PIF35: u1 = 0,
/// PIF36 [4:4]
/// Pending interrupt flag on line
PIF36: u1 = 0,
/// PIF37 [5:5]
/// Pending interrupt flag on line
PIF37: u1 = 0,
/// PIF38 [6:6]
/// Pending interrupt flag on line
PIF38: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Pending register
pub const PR2 = Register(PR2_val).init(base_address + 0x34);
};

/// Voltage reference buffer
pub const VREFBUF = struct {

const base_address = 0x40010030;
/// CSR
const CSR_val = packed struct {
/// ENVR [0:0]
/// Voltage reference buffer
ENVR: u1 = 0,
/// HIZ [1:1]
/// High impedance mode
HIZ: u1 = 1,
/// VRS [2:2]
/// Voltage reference scale
VRS: u1 = 0,
/// VRR [3:3]
/// Voltage reference buffer
VRR: u1 = 0,
/// unused [4:31]
_unused4: u4 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// VREF control and status
pub const CSR = Register(CSR_val).init(base_address + 0x0);

/// CCR
const CCR_val = packed struct {
/// TRIM [0:5]
/// Trimming code
TRIM: u6 = 0,
/// unused [6:31]
_unused6: u2 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// calibration control register
pub const CCR = Register(CCR_val).init(base_address + 0x4);
};

/// Controller area network
pub const CAN1 = struct {

const base_address = 0x40006400;
/// MCR
const MCR_val = packed struct {
/// INRQ [0:0]
/// INRQ
INRQ: u1 = 0,
/// SLEEP [1:1]
/// SLEEP
SLEEP: u1 = 1,
/// TXFP [2:2]
/// TXFP
TXFP: u1 = 0,
/// RFLM [3:3]
/// RFLM
RFLM: u1 = 0,
/// NART [4:4]
/// NART
NART: u1 = 0,
/// AWUM [5:5]
/// AWUM
AWUM: u1 = 0,
/// ABOM [6:6]
/// ABOM
ABOM: u1 = 0,
/// TTCM [7:7]
/// TTCM
TTCM: u1 = 0,
/// unused [8:14]
_unused8: u7 = 0,
/// RESET [15:15]
/// RESET
RESET: u1 = 0,
/// DBF [16:16]
/// DBF
DBF: u1 = 1,
/// unused [17:31]
_unused17: u7 = 0,
_unused24: u8 = 0,
};
/// master control register
pub const MCR = Register(MCR_val).init(base_address + 0x0);

/// MSR
const MSR_val = packed struct {
/// INAK [0:0]
/// INAK
INAK: u1 = 0,
/// SLAK [1:1]
/// SLAK
SLAK: u1 = 1,
/// ERRI [2:2]
/// ERRI
ERRI: u1 = 0,
/// WKUI [3:3]
/// WKUI
WKUI: u1 = 0,
/// SLAKI [4:4]
/// SLAKI
SLAKI: u1 = 0,
/// unused [5:7]
_unused5: u3 = 0,
/// TXM [8:8]
/// TXM
TXM: u1 = 0,
/// RXM [9:9]
/// RXM
RXM: u1 = 0,
/// SAMP [10:10]
/// SAMP
SAMP: u1 = 1,
/// RX [11:11]
/// RX
RX: u1 = 1,
/// unused [12:31]
_unused12: u4 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// master status register
pub const MSR = Register(MSR_val).init(base_address + 0x4);

/// TSR
const TSR_val = packed struct {
/// RQCP0 [0:0]
/// RQCP0
RQCP0: u1 = 0,
/// TXOK0 [1:1]
/// TXOK0
TXOK0: u1 = 0,
/// ALST0 [2:2]
/// ALST0
ALST0: u1 = 0,
/// TERR0 [3:3]
/// TERR0
TERR0: u1 = 0,
/// unused [4:6]
_unused4: u3 = 0,
/// ABRQ0 [7:7]
/// ABRQ0
ABRQ0: u1 = 0,
/// RQCP1 [8:8]
/// RQCP1
RQCP1: u1 = 0,
/// TXOK1 [9:9]
/// TXOK1
TXOK1: u1 = 0,
/// ALST1 [10:10]
/// ALST1
ALST1: u1 = 0,
/// TERR1 [11:11]
/// TERR1
TERR1: u1 = 0,
/// unused [12:14]
_unused12: u3 = 0,
/// ABRQ1 [15:15]
/// ABRQ1
ABRQ1: u1 = 0,
/// RQCP2 [16:16]
/// RQCP2
RQCP2: u1 = 0,
/// TXOK2 [17:17]
/// TXOK2
TXOK2: u1 = 0,
/// ALST2 [18:18]
/// ALST2
ALST2: u1 = 0,
/// TERR2 [19:19]
/// TERR2
TERR2: u1 = 0,
/// unused [20:22]
_unused20: u3 = 0,
/// ABRQ2 [23:23]
/// ABRQ2
ABRQ2: u1 = 0,
/// CODE [24:25]
/// CODE
CODE: u2 = 0,
/// TME0 [26:26]
/// Lowest priority flag for mailbox
TME0: u1 = 1,
/// TME1 [27:27]
/// Lowest priority flag for mailbox
TME1: u1 = 1,
/// TME2 [28:28]
/// Lowest priority flag for mailbox
TME2: u1 = 1,
/// LOW0 [29:29]
/// Lowest priority flag for mailbox
LOW0: u1 = 0,
/// LOW1 [30:30]
/// Lowest priority flag for mailbox
LOW1: u1 = 0,
/// LOW2 [31:31]
/// Lowest priority flag for mailbox
LOW2: u1 = 0,
};
/// transmit status register
pub const TSR = Register(TSR_val).init(base_address + 0x8);

/// RF0R
const RF0R_val = packed struct {
/// FMP0 [0:1]
/// FMP0
FMP0: u2 = 0,
/// unused [2:2]
_unused2: u1 = 0,
/// FULL0 [3:3]
/// FULL0
FULL0: u1 = 0,
/// FOVR0 [4:4]
/// FOVR0
FOVR0: u1 = 0,
/// RFOM0 [5:5]
/// RFOM0
RFOM0: u1 = 0,
/// unused [6:31]
_unused6: u2 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// receive FIFO 0 register
pub const RF0R = Register(RF0R_val).init(base_address + 0xc);

/// RF1R
const RF1R_val = packed struct {
/// FMP1 [0:1]
/// FMP1
FMP1: u2 = 0,
/// unused [2:2]
_unused2: u1 = 0,
/// FULL1 [3:3]
/// FULL1
FULL1: u1 = 0,
/// FOVR1 [4:4]
/// FOVR1
FOVR1: u1 = 0,
/// RFOM1 [5:5]
/// RFOM1
RFOM1: u1 = 0,
/// unused [6:31]
_unused6: u2 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// receive FIFO 1 register
pub const RF1R = Register(RF1R_val).init(base_address + 0x10);

/// IER
const IER_val = packed struct {
/// TMEIE [0:0]
/// TMEIE
TMEIE: u1 = 0,
/// FMPIE0 [1:1]
/// FMPIE0
FMPIE0: u1 = 0,
/// FFIE0 [2:2]
/// FFIE0
FFIE0: u1 = 0,
/// FOVIE0 [3:3]
/// FOVIE0
FOVIE0: u1 = 0,
/// FMPIE1 [4:4]
/// FMPIE1
FMPIE1: u1 = 0,
/// FFIE1 [5:5]
/// FFIE1
FFIE1: u1 = 0,
/// FOVIE1 [6:6]
/// FOVIE1
FOVIE1: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// EWGIE [8:8]
/// EWGIE
EWGIE: u1 = 0,
/// EPVIE [9:9]
/// EPVIE
EPVIE: u1 = 0,
/// BOFIE [10:10]
/// BOFIE
BOFIE: u1 = 0,
/// LECIE [11:11]
/// LECIE
LECIE: u1 = 0,
/// unused [12:14]
_unused12: u3 = 0,
/// ERRIE [15:15]
/// ERRIE
ERRIE: u1 = 0,
/// WKUIE [16:16]
/// WKUIE
WKUIE: u1 = 0,
/// SLKIE [17:17]
/// SLKIE
SLKIE: u1 = 0,
/// unused [18:31]
_unused18: u6 = 0,
_unused24: u8 = 0,
};
/// interrupt enable register
pub const IER = Register(IER_val).init(base_address + 0x14);

/// ESR
const ESR_val = packed struct {
/// EWGF [0:0]
/// EWGF
EWGF: u1 = 0,
/// EPVF [1:1]
/// EPVF
EPVF: u1 = 0,
/// BOFF [2:2]
/// BOFF
BOFF: u1 = 0,
/// unused [3:3]
_unused3: u1 = 0,
/// LEC [4:6]
/// LEC
LEC: u3 = 0,
/// unused [7:15]
_unused7: u1 = 0,
_unused8: u8 = 0,
/// TEC [16:23]
/// TEC
TEC: u8 = 0,
/// REC [24:31]
/// REC
REC: u8 = 0,
};
/// interrupt enable register
pub const ESR = Register(ESR_val).init(base_address + 0x18);

/// BTR
const BTR_val = packed struct {
/// BRP [0:9]
/// BRP
BRP: u10 = 0,
/// unused [10:15]
_unused10: u6 = 0,
/// TS1 [16:19]
/// TS1
TS1: u4 = 0,
/// TS2 [20:22]
/// TS2
TS2: u3 = 0,
/// unused [23:23]
_unused23: u1 = 0,
/// SJW [24:25]
/// SJW
SJW: u2 = 0,
/// unused [26:29]
_unused26: u4 = 0,
/// LBKM [30:30]
/// LBKM
LBKM: u1 = 0,
/// SILM [31:31]
/// SILM
SILM: u1 = 0,
};
/// bit timing register
pub const BTR = Register(BTR_val).init(base_address + 0x1c);

/// TI0R
const TI0R_val = packed struct {
/// TXRQ [0:0]
/// TXRQ
TXRQ: u1 = 0,
/// RTR [1:1]
/// RTR
RTR: u1 = 0,
/// IDE [2:2]
/// IDE
IDE: u1 = 0,
/// EXID [3:20]
/// EXID
EXID: u18 = 0,
/// STID [21:31]
/// STID
STID: u11 = 0,
};
/// TX mailbox identifier register
pub const TI0R = Register(TI0R_val).init(base_address + 0x180);

/// TDT0R
const TDT0R_val = packed struct {
/// DLC [0:3]
/// DLC
DLC: u4 = 0,
/// unused [4:7]
_unused4: u4 = 0,
/// TGT [8:8]
/// TGT
TGT: u1 = 0,
/// unused [9:15]
_unused9: u7 = 0,
/// TIME [16:31]
/// TIME
TIME: u16 = 0,
};
/// mailbox data length control and time stamp
pub const TDT0R = Register(TDT0R_val).init(base_address + 0x184);

/// TDL0R
const TDL0R_val = packed struct {
/// DATA0 [0:7]
/// DATA0
DATA0: u8 = 0,
/// DATA1 [8:15]
/// DATA1
DATA1: u8 = 0,
/// DATA2 [16:23]
/// DATA2
DATA2: u8 = 0,
/// DATA3 [24:31]
/// DATA3
DATA3: u8 = 0,
};
/// mailbox data low register
pub const TDL0R = Register(TDL0R_val).init(base_address + 0x188);

/// TDH0R
const TDH0R_val = packed struct {
/// DATA4 [0:7]
/// DATA4
DATA4: u8 = 0,
/// DATA5 [8:15]
/// DATA5
DATA5: u8 = 0,
/// DATA6 [16:23]
/// DATA6
DATA6: u8 = 0,
/// DATA7 [24:31]
/// DATA7
DATA7: u8 = 0,
};
/// mailbox data high register
pub const TDH0R = Register(TDH0R_val).init(base_address + 0x18c);

/// TI1R
const TI1R_val = packed struct {
/// TXRQ [0:0]
/// TXRQ
TXRQ: u1 = 0,
/// RTR [1:1]
/// RTR
RTR: u1 = 0,
/// IDE [2:2]
/// IDE
IDE: u1 = 0,
/// EXID [3:20]
/// EXID
EXID: u18 = 0,
/// STID [21:31]
/// STID
STID: u11 = 0,
};
/// mailbox identifier register
pub const TI1R = Register(TI1R_val).init(base_address + 0x190);

/// TDT1R
const TDT1R_val = packed struct {
/// DLC [0:3]
/// DLC
DLC: u4 = 0,
/// unused [4:7]
_unused4: u4 = 0,
/// TGT [8:8]
/// TGT
TGT: u1 = 0,
/// unused [9:15]
_unused9: u7 = 0,
/// TIME [16:31]
/// TIME
TIME: u16 = 0,
};
/// mailbox data length control and time stamp
pub const TDT1R = Register(TDT1R_val).init(base_address + 0x194);

/// TDL1R
const TDL1R_val = packed struct {
/// DATA0 [0:7]
/// DATA0
DATA0: u8 = 0,
/// DATA1 [8:15]
/// DATA1
DATA1: u8 = 0,
/// DATA2 [16:23]
/// DATA2
DATA2: u8 = 0,
/// DATA3 [24:31]
/// DATA3
DATA3: u8 = 0,
};
/// mailbox data low register
pub const TDL1R = Register(TDL1R_val).init(base_address + 0x198);

/// TDH1R
const TDH1R_val = packed struct {
/// DATA4 [0:7]
/// DATA4
DATA4: u8 = 0,
/// DATA5 [8:15]
/// DATA5
DATA5: u8 = 0,
/// DATA6 [16:23]
/// DATA6
DATA6: u8 = 0,
/// DATA7 [24:31]
/// DATA7
DATA7: u8 = 0,
};
/// mailbox data high register
pub const TDH1R = Register(TDH1R_val).init(base_address + 0x19c);

/// TI2R
const TI2R_val = packed struct {
/// TXRQ [0:0]
/// TXRQ
TXRQ: u1 = 0,
/// RTR [1:1]
/// RTR
RTR: u1 = 0,
/// IDE [2:2]
/// IDE
IDE: u1 = 0,
/// EXID [3:20]
/// EXID
EXID: u18 = 0,
/// STID [21:31]
/// STID
STID: u11 = 0,
};
/// mailbox identifier register
pub const TI2R = Register(TI2R_val).init(base_address + 0x1a0);

/// TDT2R
const TDT2R_val = packed struct {
/// DLC [0:3]
/// DLC
DLC: u4 = 0,
/// unused [4:7]
_unused4: u4 = 0,
/// TGT [8:8]
/// TGT
TGT: u1 = 0,
/// unused [9:15]
_unused9: u7 = 0,
/// TIME [16:31]
/// TIME
TIME: u16 = 0,
};
/// mailbox data length control and time stamp
pub const TDT2R = Register(TDT2R_val).init(base_address + 0x1a4);

/// TDL2R
const TDL2R_val = packed struct {
/// DATA0 [0:7]
/// DATA0
DATA0: u8 = 0,
/// DATA1 [8:15]
/// DATA1
DATA1: u8 = 0,
/// DATA2 [16:23]
/// DATA2
DATA2: u8 = 0,
/// DATA3 [24:31]
/// DATA3
DATA3: u8 = 0,
};
/// mailbox data low register
pub const TDL2R = Register(TDL2R_val).init(base_address + 0x1a8);

/// TDH2R
const TDH2R_val = packed struct {
/// DATA4 [0:7]
/// DATA4
DATA4: u8 = 0,
/// DATA5 [8:15]
/// DATA5
DATA5: u8 = 0,
/// DATA6 [16:23]
/// DATA6
DATA6: u8 = 0,
/// DATA7 [24:31]
/// DATA7
DATA7: u8 = 0,
};
/// mailbox data high register
pub const TDH2R = Register(TDH2R_val).init(base_address + 0x1ac);

/// RI0R
const RI0R_val = packed struct {
/// unused [0:0]
_unused0: u1 = 0,
/// RTR [1:1]
/// RTR
RTR: u1 = 0,
/// IDE [2:2]
/// IDE
IDE: u1 = 0,
/// EXID [3:20]
/// EXID
EXID: u18 = 0,
/// STID [21:31]
/// STID
STID: u11 = 0,
};
/// receive FIFO mailbox identifier
pub const RI0R = Register(RI0R_val).init(base_address + 0x1b0);

/// RDT0R
const RDT0R_val = packed struct {
/// DLC [0:3]
/// DLC
DLC: u4 = 0,
/// unused [4:7]
_unused4: u4 = 0,
/// FMI [8:15]
/// FMI
FMI: u8 = 0,
/// TIME [16:31]
/// TIME
TIME: u16 = 0,
};
/// mailbox data high register
pub const RDT0R = Register(RDT0R_val).init(base_address + 0x1b4);

/// RDL0R
const RDL0R_val = packed struct {
/// DATA0 [0:7]
/// DATA0
DATA0: u8 = 0,
/// DATA1 [8:15]
/// DATA1
DATA1: u8 = 0,
/// DATA2 [16:23]
/// DATA2
DATA2: u8 = 0,
/// DATA3 [24:31]
/// DATA3
DATA3: u8 = 0,
};
/// mailbox data high register
pub const RDL0R = Register(RDL0R_val).init(base_address + 0x1b8);

/// RDH0R
const RDH0R_val = packed struct {
/// DATA4 [0:7]
/// DATA4
DATA4: u8 = 0,
/// DATA5 [8:15]
/// DATA5
DATA5: u8 = 0,
/// DATA6 [16:23]
/// DATA6
DATA6: u8 = 0,
/// DATA7 [24:31]
/// DATA7
DATA7: u8 = 0,
};
/// receive FIFO mailbox data high
pub const RDH0R = Register(RDH0R_val).init(base_address + 0x1bc);

/// RI1R
const RI1R_val = packed struct {
/// unused [0:0]
_unused0: u1 = 0,
/// RTR [1:1]
/// RTR
RTR: u1 = 0,
/// IDE [2:2]
/// IDE
IDE: u1 = 0,
/// EXID [3:20]
/// EXID
EXID: u18 = 0,
/// STID [21:31]
/// STID
STID: u11 = 0,
};
/// mailbox data high register
pub const RI1R = Register(RI1R_val).init(base_address + 0x1c0);

/// RDT1R
const RDT1R_val = packed struct {
/// DLC [0:3]
/// DLC
DLC: u4 = 0,
/// unused [4:7]
_unused4: u4 = 0,
/// FMI [8:15]
/// FMI
FMI: u8 = 0,
/// TIME [16:31]
/// TIME
TIME: u16 = 0,
};
/// mailbox data high register
pub const RDT1R = Register(RDT1R_val).init(base_address + 0x1c4);

/// RDL1R
const RDL1R_val = packed struct {
/// DATA0 [0:7]
/// DATA0
DATA0: u8 = 0,
/// DATA1 [8:15]
/// DATA1
DATA1: u8 = 0,
/// DATA2 [16:23]
/// DATA2
DATA2: u8 = 0,
/// DATA3 [24:31]
/// DATA3
DATA3: u8 = 0,
};
/// mailbox data high register
pub const RDL1R = Register(RDL1R_val).init(base_address + 0x1c8);

/// RDH1R
const RDH1R_val = packed struct {
/// DATA4 [0:7]
/// DATA4
DATA4: u8 = 0,
/// DATA5 [8:15]
/// DATA5
DATA5: u8 = 0,
/// DATA6 [16:23]
/// DATA6
DATA6: u8 = 0,
/// DATA7 [24:31]
/// DATA7
DATA7: u8 = 0,
};
/// mailbox data high register
pub const RDH1R = Register(RDH1R_val).init(base_address + 0x1cc);

/// FMR
const FMR_val = packed struct {
/// FINIT [0:0]
/// Filter initialization mode
FINIT: u1 = 1,
/// unused [1:31]
_unused1: u7 = 0,
_unused8: u8 = 14,
_unused16: u8 = 28,
_unused24: u8 = 42,
};
/// filter master register
pub const FMR = Register(FMR_val).init(base_address + 0x200);

/// FM1R
const FM1R_val = packed struct {
/// FBM0 [0:0]
/// Filter mode
FBM0: u1 = 0,
/// FBM1 [1:1]
/// Filter mode
FBM1: u1 = 0,
/// FBM2 [2:2]
/// Filter mode
FBM2: u1 = 0,
/// FBM3 [3:3]
/// Filter mode
FBM3: u1 = 0,
/// FBM4 [4:4]
/// Filter mode
FBM4: u1 = 0,
/// FBM5 [5:5]
/// Filter mode
FBM5: u1 = 0,
/// FBM6 [6:6]
/// Filter mode
FBM6: u1 = 0,
/// FBM7 [7:7]
/// Filter mode
FBM7: u1 = 0,
/// FBM8 [8:8]
/// Filter mode
FBM8: u1 = 0,
/// FBM9 [9:9]
/// Filter mode
FBM9: u1 = 0,
/// FBM10 [10:10]
/// Filter mode
FBM10: u1 = 0,
/// FBM11 [11:11]
/// Filter mode
FBM11: u1 = 0,
/// FBM12 [12:12]
/// Filter mode
FBM12: u1 = 0,
/// FBM13 [13:13]
/// Filter mode
FBM13: u1 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// filter mode register
pub const FM1R = Register(FM1R_val).init(base_address + 0x204);

/// FS1R
const FS1R_val = packed struct {
/// FSC0 [0:0]
/// Filter scale configuration
FSC0: u1 = 0,
/// FSC1 [1:1]
/// Filter scale configuration
FSC1: u1 = 0,
/// FSC2 [2:2]
/// Filter scale configuration
FSC2: u1 = 0,
/// FSC3 [3:3]
/// Filter scale configuration
FSC3: u1 = 0,
/// FSC4 [4:4]
/// Filter scale configuration
FSC4: u1 = 0,
/// FSC5 [5:5]
/// Filter scale configuration
FSC5: u1 = 0,
/// FSC6 [6:6]
/// Filter scale configuration
FSC6: u1 = 0,
/// FSC7 [7:7]
/// Filter scale configuration
FSC7: u1 = 0,
/// FSC8 [8:8]
/// Filter scale configuration
FSC8: u1 = 0,
/// FSC9 [9:9]
/// Filter scale configuration
FSC9: u1 = 0,
/// FSC10 [10:10]
/// Filter scale configuration
FSC10: u1 = 0,
/// FSC11 [11:11]
/// Filter scale configuration
FSC11: u1 = 0,
/// FSC12 [12:12]
/// Filter scale configuration
FSC12: u1 = 0,
/// FSC13 [13:13]
/// Filter scale configuration
FSC13: u1 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// filter scale register
pub const FS1R = Register(FS1R_val).init(base_address + 0x20c);

/// FFA1R
const FFA1R_val = packed struct {
/// FFA0 [0:0]
/// Filter FIFO assignment for filter
FFA0: u1 = 0,
/// FFA1 [1:1]
/// Filter FIFO assignment for filter
FFA1: u1 = 0,
/// FFA2 [2:2]
/// Filter FIFO assignment for filter
FFA2: u1 = 0,
/// FFA3 [3:3]
/// Filter FIFO assignment for filter
FFA3: u1 = 0,
/// FFA4 [4:4]
/// Filter FIFO assignment for filter
FFA4: u1 = 0,
/// FFA5 [5:5]
/// Filter FIFO assignment for filter
FFA5: u1 = 0,
/// FFA6 [6:6]
/// Filter FIFO assignment for filter
FFA6: u1 = 0,
/// FFA7 [7:7]
/// Filter FIFO assignment for filter
FFA7: u1 = 0,
/// FFA8 [8:8]
/// Filter FIFO assignment for filter
FFA8: u1 = 0,
/// FFA9 [9:9]
/// Filter FIFO assignment for filter
FFA9: u1 = 0,
/// FFA10 [10:10]
/// Filter FIFO assignment for filter
FFA10: u1 = 0,
/// FFA11 [11:11]
/// Filter FIFO assignment for filter
FFA11: u1 = 0,
/// FFA12 [12:12]
/// Filter FIFO assignment for filter
FFA12: u1 = 0,
/// FFA13 [13:13]
/// Filter FIFO assignment for filter
FFA13: u1 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// filter FIFO assignment
pub const FFA1R = Register(FFA1R_val).init(base_address + 0x214);

/// FA1R
const FA1R_val = packed struct {
/// FACT0 [0:0]
/// Filter active
FACT0: u1 = 0,
/// FACT1 [1:1]
/// Filter active
FACT1: u1 = 0,
/// FACT2 [2:2]
/// Filter active
FACT2: u1 = 0,
/// FACT3 [3:3]
/// Filter active
FACT3: u1 = 0,
/// FACT4 [4:4]
/// Filter active
FACT4: u1 = 0,
/// FACT5 [5:5]
/// Filter active
FACT5: u1 = 0,
/// FACT6 [6:6]
/// Filter active
FACT6: u1 = 0,
/// FACT7 [7:7]
/// Filter active
FACT7: u1 = 0,
/// FACT8 [8:8]
/// Filter active
FACT8: u1 = 0,
/// FACT9 [9:9]
/// Filter active
FACT9: u1 = 0,
/// FACT10 [10:10]
/// Filter active
FACT10: u1 = 0,
/// FACT11 [11:11]
/// Filter active
FACT11: u1 = 0,
/// FACT12 [12:12]
/// Filter active
FACT12: u1 = 0,
/// FACT13 [13:13]
/// Filter active
FACT13: u1 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// filter activation register
pub const FA1R = Register(FA1R_val).init(base_address + 0x21c);

/// F0R1
const F0R1_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 0 register 1
pub const F0R1 = Register(F0R1_val).init(base_address + 0x240);

/// F0R2
const F0R2_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 0 register 2
pub const F0R2 = Register(F0R2_val).init(base_address + 0x244);

/// F1R1
const F1R1_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 1 register 1
pub const F1R1 = Register(F1R1_val).init(base_address + 0x248);

/// F1R2
const F1R2_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 1 register 2
pub const F1R2 = Register(F1R2_val).init(base_address + 0x24c);

/// F2R1
const F2R1_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 2 register 1
pub const F2R1 = Register(F2R1_val).init(base_address + 0x250);

/// F2R2
const F2R2_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 2 register 2
pub const F2R2 = Register(F2R2_val).init(base_address + 0x254);

/// F3R1
const F3R1_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 3 register 1
pub const F3R1 = Register(F3R1_val).init(base_address + 0x258);

/// F3R2
const F3R2_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 3 register 2
pub const F3R2 = Register(F3R2_val).init(base_address + 0x25c);

/// F4R1
const F4R1_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 4 register 1
pub const F4R1 = Register(F4R1_val).init(base_address + 0x260);

/// F4R2
const F4R2_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 4 register 2
pub const F4R2 = Register(F4R2_val).init(base_address + 0x264);

/// F5R1
const F5R1_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 5 register 1
pub const F5R1 = Register(F5R1_val).init(base_address + 0x268);

/// F5R2
const F5R2_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 5 register 2
pub const F5R2 = Register(F5R2_val).init(base_address + 0x26c);

/// F6R1
const F6R1_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 6 register 1
pub const F6R1 = Register(F6R1_val).init(base_address + 0x270);

/// F6R2
const F6R2_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 6 register 2
pub const F6R2 = Register(F6R2_val).init(base_address + 0x274);

/// F7R1
const F7R1_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 7 register 1
pub const F7R1 = Register(F7R1_val).init(base_address + 0x278);

/// F7R2
const F7R2_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 7 register 2
pub const F7R2 = Register(F7R2_val).init(base_address + 0x27c);

/// F8R1
const F8R1_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 8 register 1
pub const F8R1 = Register(F8R1_val).init(base_address + 0x280);

/// F8R2
const F8R2_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 8 register 2
pub const F8R2 = Register(F8R2_val).init(base_address + 0x284);

/// F9R1
const F9R1_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 9 register 1
pub const F9R1 = Register(F9R1_val).init(base_address + 0x288);

/// F9R2
const F9R2_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 9 register 2
pub const F9R2 = Register(F9R2_val).init(base_address + 0x28c);

/// F10R1
const F10R1_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 10 register 1
pub const F10R1 = Register(F10R1_val).init(base_address + 0x290);

/// F10R2
const F10R2_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 10 register 2
pub const F10R2 = Register(F10R2_val).init(base_address + 0x294);

/// F11R1
const F11R1_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 11 register 1
pub const F11R1 = Register(F11R1_val).init(base_address + 0x298);

/// F11R2
const F11R2_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 11 register 2
pub const F11R2 = Register(F11R2_val).init(base_address + 0x29c);

/// F12R1
const F12R1_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 4 register 1
pub const F12R1 = Register(F12R1_val).init(base_address + 0x2a0);

/// F12R2
const F12R2_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 12 register 2
pub const F12R2 = Register(F12R2_val).init(base_address + 0x2a4);

/// F13R1
const F13R1_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 13 register 1
pub const F13R1 = Register(F13R1_val).init(base_address + 0x2a8);

/// F13R2
const F13R2_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 13 register 2
pub const F13R2 = Register(F13R2_val).init(base_address + 0x2ac);

/// F14R1
const F14R1_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 14 register 1
pub const F14R1 = Register(F14R1_val).init(base_address + 0x2b0);

/// F14R2
const F14R2_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 14 register 2
pub const F14R2 = Register(F14R2_val).init(base_address + 0x2b4);

/// F15R1
const F15R1_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 15 register 1
pub const F15R1 = Register(F15R1_val).init(base_address + 0x2b8);

/// F15R2
const F15R2_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 15 register 2
pub const F15R2 = Register(F15R2_val).init(base_address + 0x2bc);

/// F16R1
const F16R1_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 16 register 1
pub const F16R1 = Register(F16R1_val).init(base_address + 0x2c0);

/// F16R2
const F16R2_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 16 register 2
pub const F16R2 = Register(F16R2_val).init(base_address + 0x2c4);

/// F17R1
const F17R1_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 17 register 1
pub const F17R1 = Register(F17R1_val).init(base_address + 0x2c8);

/// F17R2
const F17R2_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 17 register 2
pub const F17R2 = Register(F17R2_val).init(base_address + 0x2cc);

/// F18R1
const F18R1_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 18 register 1
pub const F18R1 = Register(F18R1_val).init(base_address + 0x2d0);

/// F18R2
const F18R2_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 18 register 2
pub const F18R2 = Register(F18R2_val).init(base_address + 0x2d4);

/// F19R1
const F19R1_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 19 register 1
pub const F19R1 = Register(F19R1_val).init(base_address + 0x2d8);

/// F19R2
const F19R2_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 19 register 2
pub const F19R2 = Register(F19R2_val).init(base_address + 0x2dc);

/// F20R1
const F20R1_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 20 register 1
pub const F20R1 = Register(F20R1_val).init(base_address + 0x2e0);

/// F20R2
const F20R2_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 20 register 2
pub const F20R2 = Register(F20R2_val).init(base_address + 0x2e4);

/// F21R1
const F21R1_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 21 register 1
pub const F21R1 = Register(F21R1_val).init(base_address + 0x2e8);

/// F21R2
const F21R2_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 21 register 2
pub const F21R2 = Register(F21R2_val).init(base_address + 0x2ec);

/// F22R1
const F22R1_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 22 register 1
pub const F22R1 = Register(F22R1_val).init(base_address + 0x2f0);

/// F22R2
const F22R2_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 22 register 2
pub const F22R2 = Register(F22R2_val).init(base_address + 0x2f4);

/// F23R1
const F23R1_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 23 register 1
pub const F23R1 = Register(F23R1_val).init(base_address + 0x2f8);

/// F23R2
const F23R2_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 23 register 2
pub const F23R2 = Register(F23R2_val).init(base_address + 0x2fc);

/// F24R1
const F24R1_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 24 register 1
pub const F24R1 = Register(F24R1_val).init(base_address + 0x300);

/// F24R2
const F24R2_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 24 register 2
pub const F24R2 = Register(F24R2_val).init(base_address + 0x304);

/// F25R1
const F25R1_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 25 register 1
pub const F25R1 = Register(F25R1_val).init(base_address + 0x308);

/// F25R2
const F25R2_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 25 register 2
pub const F25R2 = Register(F25R2_val).init(base_address + 0x30c);

/// F26R1
const F26R1_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 26 register 1
pub const F26R1 = Register(F26R1_val).init(base_address + 0x310);

/// F26R2
const F26R2_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 26 register 2
pub const F26R2 = Register(F26R2_val).init(base_address + 0x314);

/// F27R1
const F27R1_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 27 register 1
pub const F27R1 = Register(F27R1_val).init(base_address + 0x318);

/// F27R2
const F27R2_val = packed struct {
/// FB0 [0:0]
/// Filter bits
FB0: u1 = 0,
/// FB1 [1:1]
/// Filter bits
FB1: u1 = 0,
/// FB2 [2:2]
/// Filter bits
FB2: u1 = 0,
/// FB3 [3:3]
/// Filter bits
FB3: u1 = 0,
/// FB4 [4:4]
/// Filter bits
FB4: u1 = 0,
/// FB5 [5:5]
/// Filter bits
FB5: u1 = 0,
/// FB6 [6:6]
/// Filter bits
FB6: u1 = 0,
/// FB7 [7:7]
/// Filter bits
FB7: u1 = 0,
/// FB8 [8:8]
/// Filter bits
FB8: u1 = 0,
/// FB9 [9:9]
/// Filter bits
FB9: u1 = 0,
/// FB10 [10:10]
/// Filter bits
FB10: u1 = 0,
/// FB11 [11:11]
/// Filter bits
FB11: u1 = 0,
/// FB12 [12:12]
/// Filter bits
FB12: u1 = 0,
/// FB13 [13:13]
/// Filter bits
FB13: u1 = 0,
/// FB14 [14:14]
/// Filter bits
FB14: u1 = 0,
/// FB15 [15:15]
/// Filter bits
FB15: u1 = 0,
/// FB16 [16:16]
/// Filter bits
FB16: u1 = 0,
/// FB17 [17:17]
/// Filter bits
FB17: u1 = 0,
/// FB18 [18:18]
/// Filter bits
FB18: u1 = 0,
/// FB19 [19:19]
/// Filter bits
FB19: u1 = 0,
/// FB20 [20:20]
/// Filter bits
FB20: u1 = 0,
/// FB21 [21:21]
/// Filter bits
FB21: u1 = 0,
/// FB22 [22:22]
/// Filter bits
FB22: u1 = 0,
/// FB23 [23:23]
/// Filter bits
FB23: u1 = 0,
/// FB24 [24:24]
/// Filter bits
FB24: u1 = 0,
/// FB25 [25:25]
/// Filter bits
FB25: u1 = 0,
/// FB26 [26:26]
/// Filter bits
FB26: u1 = 0,
/// FB27 [27:27]
/// Filter bits
FB27: u1 = 0,
/// FB28 [28:28]
/// Filter bits
FB28: u1 = 0,
/// FB29 [29:29]
/// Filter bits
FB29: u1 = 0,
/// FB30 [30:30]
/// Filter bits
FB30: u1 = 0,
/// FB31 [31:31]
/// Filter bits
FB31: u1 = 0,
};
/// Filter bank 27 register 2
pub const F27R2 = Register(F27R2_val).init(base_address + 0x31c);
};

/// Real-time clock
pub const RTC = struct {

const base_address = 0x40002800;
/// TR
const TR_val = packed struct {
/// SU [0:3]
/// Second units in BCD format
SU: u4 = 0,
/// ST [4:6]
/// Second tens in BCD format
ST: u3 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// MNU [8:11]
/// Minute units in BCD format
MNU: u4 = 0,
/// MNT [12:14]
/// Minute tens in BCD format
MNT: u3 = 0,
/// unused [15:15]
_unused15: u1 = 0,
/// HU [16:19]
/// Hour units in BCD format
HU: u4 = 0,
/// HT [20:21]
/// Hour tens in BCD format
HT: u2 = 0,
/// PM [22:22]
/// AM/PM notation
PM: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// time register
pub const TR = Register(TR_val).init(base_address + 0x0);

/// DR
const DR_val = packed struct {
/// DU [0:3]
/// Date units in BCD format
DU: u4 = 1,
/// DT [4:5]
/// Date tens in BCD format
DT: u2 = 0,
/// unused [6:7]
_unused6: u2 = 0,
/// MU [8:11]
/// Month units in BCD format
MU: u4 = 1,
/// MT [12:12]
/// Month tens in BCD format
MT: u1 = 0,
/// WDU [13:15]
/// Week day units
WDU: u3 = 1,
/// YU [16:19]
/// Year units in BCD format
YU: u4 = 0,
/// YT [20:23]
/// Year tens in BCD format
YT: u4 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// date register
pub const DR = Register(DR_val).init(base_address + 0x4);

/// CR
const CR_val = packed struct {
/// WCKSEL [0:2]
/// Wakeup clock selection
WCKSEL: u3 = 0,
/// TSEDGE [3:3]
/// Time-stamp event active
TSEDGE: u1 = 0,
/// REFCKON [4:4]
/// Reference clock detection enable (50 or
REFCKON: u1 = 0,
/// BYPSHAD [5:5]
/// Bypass the shadow
BYPSHAD: u1 = 0,
/// FMT [6:6]
/// Hour format
FMT: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// ALRAE [8:8]
/// Alarm A enable
ALRAE: u1 = 0,
/// ALRBE [9:9]
/// Alarm B enable
ALRBE: u1 = 0,
/// WUTE [10:10]
/// Wakeup timer enable
WUTE: u1 = 0,
/// TSE [11:11]
/// Time stamp enable
TSE: u1 = 0,
/// ALRAIE [12:12]
/// Alarm A interrupt enable
ALRAIE: u1 = 0,
/// ALRBIE [13:13]
/// Alarm B interrupt enable
ALRBIE: u1 = 0,
/// WUTIE [14:14]
/// Wakeup timer interrupt
WUTIE: u1 = 0,
/// TSIE [15:15]
/// Time-stamp interrupt
TSIE: u1 = 0,
/// ADD1H [16:16]
/// Add 1 hour (summer time
ADD1H: u1 = 0,
/// SUB1H [17:17]
/// Subtract 1 hour (winter time
SUB1H: u1 = 0,
/// BKP [18:18]
/// Backup
BKP: u1 = 0,
/// COSEL [19:19]
/// Calibration output
COSEL: u1 = 0,
/// POL [20:20]
/// Output polarity
POL: u1 = 0,
/// OSEL [21:22]
/// Output selection
OSEL: u2 = 0,
/// COE [23:23]
/// Calibration output enable
COE: u1 = 0,
/// ITSE [24:24]
/// timestamp on internal event
ITSE: u1 = 0,
/// unused [25:31]
_unused25: u7 = 0,
};
/// control register
pub const CR = Register(CR_val).init(base_address + 0x8);

/// ISR
const ISR_val = packed struct {
/// ALRAWF [0:0]
/// Alarm A write flag
ALRAWF: u1 = 1,
/// ALRBWF [1:1]
/// Alarm B write flag
ALRBWF: u1 = 1,
/// WUTWF [2:2]
/// Wakeup timer write flag
WUTWF: u1 = 1,
/// SHPF [3:3]
/// Shift operation pending
SHPF: u1 = 0,
/// INITS [4:4]
/// Initialization status flag
INITS: u1 = 0,
/// RSF [5:5]
/// Registers synchronization
RSF: u1 = 0,
/// INITF [6:6]
/// Initialization flag
INITF: u1 = 0,
/// INIT [7:7]
/// Initialization mode
INIT: u1 = 0,
/// ALRAF [8:8]
/// Alarm A flag
ALRAF: u1 = 0,
/// ALRBF [9:9]
/// Alarm B flag
ALRBF: u1 = 0,
/// WUTF [10:10]
/// Wakeup timer flag
WUTF: u1 = 0,
/// TSF [11:11]
/// Time-stamp flag
TSF: u1 = 0,
/// TSOVF [12:12]
/// Time-stamp overflow flag
TSOVF: u1 = 0,
/// TAMP1F [13:13]
/// Tamper detection flag
TAMP1F: u1 = 0,
/// TAMP2F [14:14]
/// RTC_TAMP2 detection flag
TAMP2F: u1 = 0,
/// TAMP3F [15:15]
/// RTC_TAMP3 detection flag
TAMP3F: u1 = 0,
/// RECALPF [16:16]
/// Recalibration pending Flag
RECALPF: u1 = 0,
/// unused [17:31]
_unused17: u7 = 0,
_unused24: u8 = 0,
};
/// initialization and status
pub const ISR = Register(ISR_val).init(base_address + 0xc);

/// PRER
const PRER_val = packed struct {
/// PREDIV_S [0:14]
/// Synchronous prescaler
PREDIV_S: u15 = 255,
/// unused [15:15]
_unused15: u1 = 0,
/// PREDIV_A [16:22]
/// Asynchronous prescaler
PREDIV_A: u7 = 127,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// prescaler register
pub const PRER = Register(PRER_val).init(base_address + 0x10);

/// WUTR
const WUTR_val = packed struct {
/// WUT [0:15]
/// Wakeup auto-reload value
WUT: u16 = 65535,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// wakeup timer register
pub const WUTR = Register(WUTR_val).init(base_address + 0x14);

/// ALRMAR
const ALRMAR_val = packed struct {
/// SU [0:3]
/// Second units in BCD format
SU: u4 = 0,
/// ST [4:6]
/// Second tens in BCD format
ST: u3 = 0,
/// MSK1 [7:7]
/// Alarm A seconds mask
MSK1: u1 = 0,
/// MNU [8:11]
/// Minute units in BCD format
MNU: u4 = 0,
/// MNT [12:14]
/// Minute tens in BCD format
MNT: u3 = 0,
/// MSK2 [15:15]
/// Alarm A minutes mask
MSK2: u1 = 0,
/// HU [16:19]
/// Hour units in BCD format
HU: u4 = 0,
/// HT [20:21]
/// Hour tens in BCD format
HT: u2 = 0,
/// PM [22:22]
/// AM/PM notation
PM: u1 = 0,
/// MSK3 [23:23]
/// Alarm A hours mask
MSK3: u1 = 0,
/// DU [24:27]
/// Date units or day in BCD
DU: u4 = 0,
/// DT [28:29]
/// Date tens in BCD format
DT: u2 = 0,
/// WDSEL [30:30]
/// Week day selection
WDSEL: u1 = 0,
/// MSK4 [31:31]
/// Alarm A date mask
MSK4: u1 = 0,
};
/// alarm A register
pub const ALRMAR = Register(ALRMAR_val).init(base_address + 0x1c);

/// ALRMBR
const ALRMBR_val = packed struct {
/// SU [0:3]
/// Second units in BCD format
SU: u4 = 0,
/// ST [4:6]
/// Second tens in BCD format
ST: u3 = 0,
/// MSK1 [7:7]
/// Alarm B seconds mask
MSK1: u1 = 0,
/// MNU [8:11]
/// Minute units in BCD format
MNU: u4 = 0,
/// MNT [12:14]
/// Minute tens in BCD format
MNT: u3 = 0,
/// MSK2 [15:15]
/// Alarm B minutes mask
MSK2: u1 = 0,
/// HU [16:19]
/// Hour units in BCD format
HU: u4 = 0,
/// HT [20:21]
/// Hour tens in BCD format
HT: u2 = 0,
/// PM [22:22]
/// AM/PM notation
PM: u1 = 0,
/// MSK3 [23:23]
/// Alarm B hours mask
MSK3: u1 = 0,
/// DU [24:27]
/// Date units or day in BCD
DU: u4 = 0,
/// DT [28:29]
/// Date tens in BCD format
DT: u2 = 0,
/// WDSEL [30:30]
/// Week day selection
WDSEL: u1 = 0,
/// MSK4 [31:31]
/// Alarm B date mask
MSK4: u1 = 0,
};
/// alarm B register
pub const ALRMBR = Register(ALRMBR_val).init(base_address + 0x20);

/// WPR
const WPR_val = packed struct {
/// KEY [0:7]
/// Write protection key
KEY: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// write protection register
pub const WPR = Register(WPR_val).init(base_address + 0x24);

/// SSR
const SSR_val = packed struct {
/// SS [0:15]
/// Sub second value
SS: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// sub second register
pub const SSR = Register(SSR_val).init(base_address + 0x28);

/// SHIFTR
const SHIFTR_val = packed struct {
/// SUBFS [0:14]
/// Subtract a fraction of a
SUBFS: u15 = 0,
/// unused [15:30]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u7 = 0,
/// ADD1S [31:31]
/// Add one second
ADD1S: u1 = 0,
};
/// shift control register
pub const SHIFTR = Register(SHIFTR_val).init(base_address + 0x2c);

/// TSTR
const TSTR_val = packed struct {
/// SU [0:3]
/// Second units in BCD format
SU: u4 = 0,
/// ST [4:6]
/// Second tens in BCD format
ST: u3 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// MNU [8:11]
/// Minute units in BCD format
MNU: u4 = 0,
/// MNT [12:14]
/// Minute tens in BCD format
MNT: u3 = 0,
/// unused [15:15]
_unused15: u1 = 0,
/// HU [16:19]
/// Hour units in BCD format
HU: u4 = 0,
/// HT [20:21]
/// Hour tens in BCD format
HT: u2 = 0,
/// PM [22:22]
/// AM/PM notation
PM: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// time stamp time register
pub const TSTR = Register(TSTR_val).init(base_address + 0x30);

/// TSDR
const TSDR_val = packed struct {
/// DU [0:3]
/// Date units in BCD format
DU: u4 = 0,
/// DT [4:5]
/// Date tens in BCD format
DT: u2 = 0,
/// unused [6:7]
_unused6: u2 = 0,
/// MU [8:11]
/// Month units in BCD format
MU: u4 = 0,
/// MT [12:12]
/// Month tens in BCD format
MT: u1 = 0,
/// WDU [13:15]
/// Week day units
WDU: u3 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// time stamp date register
pub const TSDR = Register(TSDR_val).init(base_address + 0x34);

/// TSSSR
const TSSSR_val = packed struct {
/// SS [0:15]
/// Sub second value
SS: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// timestamp sub second register
pub const TSSSR = Register(TSSSR_val).init(base_address + 0x38);

/// CALR
const CALR_val = packed struct {
/// CALM [0:8]
/// Calibration minus
CALM: u9 = 0,
/// unused [9:12]
_unused9: u4 = 0,
/// CALW16 [13:13]
/// Use a 16-second calibration cycle
CALW16: u1 = 0,
/// CALW8 [14:14]
/// Use an 8-second calibration cycle
CALW8: u1 = 0,
/// CALP [15:15]
/// Increase frequency of RTC by 488.5
CALP: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// calibration register
pub const CALR = Register(CALR_val).init(base_address + 0x3c);

/// TAMPCR
const TAMPCR_val = packed struct {
/// TAMP1E [0:0]
/// Tamper 1 detection enable
TAMP1E: u1 = 0,
/// TAMP1TRG [1:1]
/// Active level for tamper 1
TAMP1TRG: u1 = 0,
/// TAMPIE [2:2]
/// Tamper interrupt enable
TAMPIE: u1 = 0,
/// TAMP2E [3:3]
/// Tamper 2 detection enable
TAMP2E: u1 = 0,
/// TAMP2TRG [4:4]
/// Active level for tamper 2
TAMP2TRG: u1 = 0,
/// TAMP3E [5:5]
/// Tamper 3 detection enable
TAMP3E: u1 = 0,
/// TAMP3TRG [6:6]
/// Active level for tamper 3
TAMP3TRG: u1 = 0,
/// TAMPTS [7:7]
/// Activate timestamp on tamper detection
TAMPTS: u1 = 0,
/// TAMPFREQ [8:10]
/// Tamper sampling frequency
TAMPFREQ: u3 = 0,
/// TAMPFLT [11:12]
/// Tamper filter count
TAMPFLT: u2 = 0,
/// TAMPPRCH [13:14]
/// Tamper precharge duration
TAMPPRCH: u2 = 0,
/// TAMPPUDIS [15:15]
/// TAMPER pull-up disable
TAMPPUDIS: u1 = 0,
/// TAMP1IE [16:16]
/// Tamper 1 interrupt enable
TAMP1IE: u1 = 0,
/// TAMP1NOERASE [17:17]
/// Tamper 1 no erase
TAMP1NOERASE: u1 = 0,
/// TAMP1MF [18:18]
/// Tamper 1 mask flag
TAMP1MF: u1 = 0,
/// TAMP2IE [19:19]
/// Tamper 2 interrupt enable
TAMP2IE: u1 = 0,
/// TAMP2NOERASE [20:20]
/// Tamper 2 no erase
TAMP2NOERASE: u1 = 0,
/// TAMP2MF [21:21]
/// Tamper 2 mask flag
TAMP2MF: u1 = 0,
/// TAMP3IE [22:22]
/// Tamper 3 interrupt enable
TAMP3IE: u1 = 0,
/// TAMP3NOERASE [23:23]
/// Tamper 3 no erase
TAMP3NOERASE: u1 = 0,
/// TAMP3MF [24:24]
/// Tamper 3 mask flag
TAMP3MF: u1 = 0,
/// unused [25:31]
_unused25: u7 = 0,
};
/// tamper configuration register
pub const TAMPCR = Register(TAMPCR_val).init(base_address + 0x40);

/// ALRMASSR
const ALRMASSR_val = packed struct {
/// SS [0:14]
/// Sub seconds value
SS: u15 = 0,
/// unused [15:23]
_unused15: u1 = 0,
_unused16: u8 = 0,
/// MASKSS [24:27]
/// Mask the most-significant bits starting
MASKSS: u4 = 0,
/// unused [28:31]
_unused28: u4 = 0,
};
/// alarm A sub second register
pub const ALRMASSR = Register(ALRMASSR_val).init(base_address + 0x44);

/// ALRMBSSR
const ALRMBSSR_val = packed struct {
/// SS [0:14]
/// Sub seconds value
SS: u15 = 0,
/// unused [15:23]
_unused15: u1 = 0,
_unused16: u8 = 0,
/// MASKSS [24:27]
/// Mask the most-significant bits starting
MASKSS: u4 = 0,
/// unused [28:31]
_unused28: u4 = 0,
};
/// alarm B sub second register
pub const ALRMBSSR = Register(ALRMBSSR_val).init(base_address + 0x48);

/// OR
const OR_val = packed struct {
/// RTC_ALARM_TYPE [0:0]
/// RTC_ALARM on PC13 output
RTC_ALARM_TYPE: u1 = 0,
/// RTC_OUT_RMP [1:1]
/// RTC_OUT remap
RTC_OUT_RMP: u1 = 0,
/// unused [2:31]
_unused2: u6 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// option register
pub const OR = Register(OR_val).init(base_address + 0x4c);

/// BKP0R
const BKP0R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP0R = Register(BKP0R_val).init(base_address + 0x50);

/// BKP1R
const BKP1R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP1R = Register(BKP1R_val).init(base_address + 0x54);

/// BKP2R
const BKP2R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP2R = Register(BKP2R_val).init(base_address + 0x58);

/// BKP3R
const BKP3R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP3R = Register(BKP3R_val).init(base_address + 0x5c);

/// BKP4R
const BKP4R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP4R = Register(BKP4R_val).init(base_address + 0x60);

/// BKP5R
const BKP5R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP5R = Register(BKP5R_val).init(base_address + 0x64);

/// BKP6R
const BKP6R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP6R = Register(BKP6R_val).init(base_address + 0x68);

/// BKP7R
const BKP7R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP7R = Register(BKP7R_val).init(base_address + 0x6c);

/// BKP8R
const BKP8R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP8R = Register(BKP8R_val).init(base_address + 0x70);

/// BKP9R
const BKP9R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP9R = Register(BKP9R_val).init(base_address + 0x74);

/// BKP10R
const BKP10R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP10R = Register(BKP10R_val).init(base_address + 0x78);

/// BKP11R
const BKP11R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP11R = Register(BKP11R_val).init(base_address + 0x7c);

/// BKP12R
const BKP12R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP12R = Register(BKP12R_val).init(base_address + 0x80);

/// BKP13R
const BKP13R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP13R = Register(BKP13R_val).init(base_address + 0x84);

/// BKP14R
const BKP14R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP14R = Register(BKP14R_val).init(base_address + 0x88);

/// BKP15R
const BKP15R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP15R = Register(BKP15R_val).init(base_address + 0x8c);

/// BKP16R
const BKP16R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP16R = Register(BKP16R_val).init(base_address + 0x90);

/// BKP17R
const BKP17R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP17R = Register(BKP17R_val).init(base_address + 0x94);

/// BKP18R
const BKP18R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP18R = Register(BKP18R_val).init(base_address + 0x98);

/// BKP19R
const BKP19R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP19R = Register(BKP19R_val).init(base_address + 0x9c);

/// BKP20R
const BKP20R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP20R = Register(BKP20R_val).init(base_address + 0xa0);

/// BKP21R
const BKP21R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP21R = Register(BKP21R_val).init(base_address + 0xa4);

/// BKP22R
const BKP22R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP22R = Register(BKP22R_val).init(base_address + 0xa8);

/// BKP23R
const BKP23R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP23R = Register(BKP23R_val).init(base_address + 0xac);

/// BKP24R
const BKP24R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP24R = Register(BKP24R_val).init(base_address + 0xb0);

/// BKP25R
const BKP25R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP25R = Register(BKP25R_val).init(base_address + 0xb4);

/// BKP26R
const BKP26R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP26R = Register(BKP26R_val).init(base_address + 0xb8);

/// BKP27R
const BKP27R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP27R = Register(BKP27R_val).init(base_address + 0xbc);

/// BKP28R
const BKP28R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP28R = Register(BKP28R_val).init(base_address + 0xc0);

/// BKP29R
const BKP29R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP29R = Register(BKP29R_val).init(base_address + 0xc4);

/// BKP30R
const BKP30R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP30R = Register(BKP30R_val).init(base_address + 0xc8);

/// BKP31R
const BKP31R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// backup register
pub const BKP31R = Register(BKP31R_val).init(base_address + 0xcc);
};

/// Single Wire Protocol Master
pub const SWPMI1 = struct {

const base_address = 0x40008800;
/// CR
const CR_val = packed struct {
/// RXDMA [0:0]
/// Reception DMA enable
RXDMA: u1 = 0,
/// TXDMA [1:1]
/// Transmission DMA enable
TXDMA: u1 = 0,
/// RXMODE [2:2]
/// Reception buffering mode
RXMODE: u1 = 0,
/// TXMODE [3:3]
/// Transmission buffering
TXMODE: u1 = 0,
/// LPBK [4:4]
/// Loopback mode enable
LPBK: u1 = 0,
/// SWPME [5:5]
/// Single wire protocol master interface
SWPME: u1 = 0,
/// unused [6:9]
_unused6: u2 = 0,
_unused8: u2 = 0,
/// DEACT [10:10]
/// Single wire protocol master interface
DEACT: u1 = 0,
/// unused [11:31]
_unused11: u5 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// SWPMI Configuration/Control
pub const CR = Register(CR_val).init(base_address + 0x0);

/// BRR
const BRR_val = packed struct {
/// BR [0:5]
/// Bitrate prescaler
BR: u6 = 1,
/// unused [6:31]
_unused6: u2 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// SWPMI Bitrate register
pub const BRR = Register(BRR_val).init(base_address + 0x4);

/// ISR
const ISR_val = packed struct {
/// RXBFF [0:0]
/// Receive buffer full flag
RXBFF: u1 = 0,
/// TXBEF [1:1]
/// Transmit buffer empty flag
TXBEF: u1 = 1,
/// RXBERF [2:2]
/// Receive CRC error flag
RXBERF: u1 = 0,
/// RXOVRF [3:3]
/// Receive overrun error flag
RXOVRF: u1 = 0,
/// TXUNRF [4:4]
/// Transmit underrun error
TXUNRF: u1 = 0,
/// RXNE [5:5]
/// Receive data register not
RXNE: u1 = 0,
/// TXE [6:6]
/// Transmit data register
TXE: u1 = 1,
/// TCF [7:7]
/// Transfer complete flag
TCF: u1 = 1,
/// SRF [8:8]
/// Slave resume flag
SRF: u1 = 0,
/// SUSP [9:9]
/// SUSPEND flag
SUSP: u1 = 1,
/// DEACTF [10:10]
/// DEACTIVATED flag
DEACTF: u1 = 0,
/// unused [11:31]
_unused11: u5 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// SWPMI Interrupt and Status
pub const ISR = Register(ISR_val).init(base_address + 0xc);

/// ICR
const ICR_val = packed struct {
/// CRXBFF [0:0]
/// Clear receive buffer full
CRXBFF: u1 = 0,
/// CTXBEF [1:1]
/// Clear transmit buffer empty
CTXBEF: u1 = 0,
/// CRXBERF [2:2]
/// Clear receive CRC error
CRXBERF: u1 = 0,
/// CRXOVRF [3:3]
/// Clear receive overrun error
CRXOVRF: u1 = 0,
/// CTXUNRF [4:4]
/// Clear transmit underrun error
CTXUNRF: u1 = 0,
/// unused [5:6]
_unused5: u2 = 0,
/// CTCF [7:7]
/// Clear transfer complete
CTCF: u1 = 0,
/// CSRF [8:8]
/// Clear slave resume flag
CSRF: u1 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// SWPMI Interrupt Flag Clear
pub const ICR = Register(ICR_val).init(base_address + 0x10);

/// IER
const IER_val = packed struct {
/// RXBFIE [0:0]
/// Receive buffer full interrupt
RXBFIE: u1 = 0,
/// TXBEIE [1:1]
/// Transmit buffer empty interrupt
TXBEIE: u1 = 0,
/// RXBERIE [2:2]
/// Receive CRC error interrupt
RXBERIE: u1 = 0,
/// RXOVRIE [3:3]
/// Receive overrun error interrupt
RXOVRIE: u1 = 0,
/// TXUNRIE [4:4]
/// Transmit underrun error interrupt
TXUNRIE: u1 = 0,
/// RIE [5:5]
/// Receive interrupt enable
RIE: u1 = 0,
/// TIE [6:6]
/// Transmit interrupt enable
TIE: u1 = 0,
/// TCIE [7:7]
/// Transmit complete interrupt
TCIE: u1 = 0,
/// SRIE [8:8]
/// Slave resume interrupt
SRIE: u1 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// SWPMI Interrupt Enable
pub const IER = Register(IER_val).init(base_address + 0x14);

/// RFL
const RFL_val = packed struct {
/// RFL [0:4]
/// Receive frame length
RFL: u5 = 0,
/// unused [5:31]
_unused5: u3 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// SWPMI Receive Frame Length
pub const RFL = Register(RFL_val).init(base_address + 0x18);

/// TDR
const TDR_val = packed struct {
/// TD [0:31]
/// Transmit data
TD: u32 = 0,
};
/// SWPMI Transmit data register
pub const TDR = Register(TDR_val).init(base_address + 0x1c);

/// RDR
const RDR_val = packed struct {
/// RD [0:31]
/// received data
RD: u32 = 0,
};
/// SWPMI Receive data register
pub const RDR = Register(RDR_val).init(base_address + 0x20);
};

/// Operational amplifiers
pub const OPAMP = struct {

const base_address = 0x40007800;
/// OPAMP1_CSR
const OPAMP1_CSR_val = packed struct {
/// OPAEN [0:0]
/// Operational amplifier
OPAEN: u1 = 0,
/// OPALPM [1:1]
/// Operational amplifier Low Power
OPALPM: u1 = 0,
/// OPAMODE [2:3]
/// Operational amplifier PGA
OPAMODE: u2 = 0,
/// PGA_GAIN [4:5]
/// Operational amplifier Programmable
PGA_GAIN: u2 = 0,
/// unused [6:7]
_unused6: u2 = 0,
/// VM_SEL [8:9]
/// Inverting input selection
VM_SEL: u2 = 0,
/// VP_SEL [10:10]
/// Non inverted input
VP_SEL: u1 = 0,
/// unused [11:11]
_unused11: u1 = 0,
/// CALON [12:12]
/// Calibration mode enabled
CALON: u1 = 0,
/// CALSEL [13:13]
/// Calibration selection
CALSEL: u1 = 0,
/// USERTRIM [14:14]
/// allows to switch from AOP offset trimmed
USERTRIM: u1 = 0,
/// CALOUT [15:15]
/// Operational amplifier calibration
CALOUT: u1 = 0,
/// unused [16:30]
_unused16: u8 = 0,
_unused24: u7 = 0,
/// OPA_RANGE [31:31]
/// Operational amplifier power supply range
OPA_RANGE: u1 = 0,
};
/// OPAMP1 control/status register
pub const OPAMP1_CSR = Register(OPAMP1_CSR_val).init(base_address + 0x0);

/// OPAMP1_OTR
const OPAMP1_OTR_val = packed struct {
/// TRIMOFFSETN [0:4]
/// Trim for NMOS differential
TRIMOFFSETN: u5 = 0,
/// unused [5:7]
_unused5: u3 = 0,
/// TRIMOFFSETP [8:12]
/// Trim for PMOS differential
TRIMOFFSETP: u5 = 0,
/// unused [13:31]
_unused13: u3 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// OPAMP1 offset trimming register in normal
pub const OPAMP1_OTR = Register(OPAMP1_OTR_val).init(base_address + 0x4);

/// OPAMP1_LPOTR
const OPAMP1_LPOTR_val = packed struct {
/// TRIMLPOFFSETN [0:4]
/// Trim for NMOS differential
TRIMLPOFFSETN: u5 = 0,
/// unused [5:7]
_unused5: u3 = 0,
/// TRIMLPOFFSETP [8:12]
/// Trim for PMOS differential
TRIMLPOFFSETP: u5 = 0,
/// unused [13:31]
_unused13: u3 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// OPAMP1 offset trimming register in low-power
pub const OPAMP1_LPOTR = Register(OPAMP1_LPOTR_val).init(base_address + 0x8);

/// OPAMP2_CSR
const OPAMP2_CSR_val = packed struct {
/// OPAEN [0:0]
/// Operational amplifier
OPAEN: u1 = 0,
/// OPALPM [1:1]
/// Operational amplifier Low Power
OPALPM: u1 = 0,
/// OPAMODE [2:3]
/// Operational amplifier PGA
OPAMODE: u2 = 0,
/// PGA_GAIN [4:5]
/// Operational amplifier Programmable
PGA_GAIN: u2 = 0,
/// unused [6:7]
_unused6: u2 = 0,
/// VM_SEL [8:9]
/// Inverting input selection
VM_SEL: u2 = 0,
/// VP_SEL [10:10]
/// Non inverted input
VP_SEL: u1 = 0,
/// unused [11:11]
_unused11: u1 = 0,
/// CALON [12:12]
/// Calibration mode enabled
CALON: u1 = 0,
/// CALSEL [13:13]
/// Calibration selection
CALSEL: u1 = 0,
/// USERTRIM [14:14]
/// allows to switch from AOP offset trimmed
USERTRIM: u1 = 0,
/// CALOUT [15:15]
/// Operational amplifier calibration
CALOUT: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// OPAMP2 control/status register
pub const OPAMP2_CSR = Register(OPAMP2_CSR_val).init(base_address + 0x10);

/// OPAMP2_OTR
const OPAMP2_OTR_val = packed struct {
/// TRIMOFFSETN [0:4]
/// Trim for NMOS differential
TRIMOFFSETN: u5 = 0,
/// unused [5:7]
_unused5: u3 = 0,
/// TRIMOFFSETP [8:12]
/// Trim for PMOS differential
TRIMOFFSETP: u5 = 0,
/// unused [13:31]
_unused13: u3 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// OPAMP2 offset trimming register in normal
pub const OPAMP2_OTR = Register(OPAMP2_OTR_val).init(base_address + 0x14);

/// OPAMP2_LPOTR
const OPAMP2_LPOTR_val = packed struct {
/// TRIMLPOFFSETN [0:4]
/// Trim for NMOS differential
TRIMLPOFFSETN: u5 = 0,
/// unused [5:7]
_unused5: u3 = 0,
/// TRIMLPOFFSETP [8:12]
/// Trim for PMOS differential
TRIMLPOFFSETP: u5 = 0,
/// unused [13:31]
_unused13: u3 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// OPAMP2 offset trimming register in low-power
pub const OPAMP2_LPOTR = Register(OPAMP2_LPOTR_val).init(base_address + 0x18);
};

/// Nested Vectored Interrupt
pub const NVIC = struct {

const base_address = 0xe000e100;
/// ISER0
const ISER0_val = packed struct {
/// SETENA [0:31]
/// SETENA
SETENA: u32 = 0,
};
/// Interrupt Set-Enable Register
pub const ISER0 = Register(ISER0_val).init(base_address + 0x0);

/// ISER1
const ISER1_val = packed struct {
/// SETENA [0:31]
/// SETENA
SETENA: u32 = 0,
};
/// Interrupt Set-Enable Register
pub const ISER1 = Register(ISER1_val).init(base_address + 0x4);

/// ISER2
const ISER2_val = packed struct {
/// SETENA [0:31]
/// SETENA
SETENA: u32 = 0,
};
/// Interrupt Set-Enable Register
pub const ISER2 = Register(ISER2_val).init(base_address + 0x8);

/// ICER0
const ICER0_val = packed struct {
/// CLRENA [0:31]
/// CLRENA
CLRENA: u32 = 0,
};
/// Interrupt Clear-Enable
pub const ICER0 = Register(ICER0_val).init(base_address + 0x80);

/// ICER1
const ICER1_val = packed struct {
/// CLRENA [0:31]
/// CLRENA
CLRENA: u32 = 0,
};
/// Interrupt Clear-Enable
pub const ICER1 = Register(ICER1_val).init(base_address + 0x84);

/// ICER2
const ICER2_val = packed struct {
/// CLRENA [0:31]
/// CLRENA
CLRENA: u32 = 0,
};
/// Interrupt Clear-Enable
pub const ICER2 = Register(ICER2_val).init(base_address + 0x88);

/// ISPR0
const ISPR0_val = packed struct {
/// SETPEND [0:31]
/// SETPEND
SETPEND: u32 = 0,
};
/// Interrupt Set-Pending Register
pub const ISPR0 = Register(ISPR0_val).init(base_address + 0x100);

/// ISPR1
const ISPR1_val = packed struct {
/// SETPEND [0:31]
/// SETPEND
SETPEND: u32 = 0,
};
/// Interrupt Set-Pending Register
pub const ISPR1 = Register(ISPR1_val).init(base_address + 0x104);

/// ISPR2
const ISPR2_val = packed struct {
/// SETPEND [0:31]
/// SETPEND
SETPEND: u32 = 0,
};
/// Interrupt Set-Pending Register
pub const ISPR2 = Register(ISPR2_val).init(base_address + 0x108);

/// ICPR0
const ICPR0_val = packed struct {
/// CLRPEND [0:31]
/// CLRPEND
CLRPEND: u32 = 0,
};
/// Interrupt Clear-Pending
pub const ICPR0 = Register(ICPR0_val).init(base_address + 0x180);

/// ICPR1
const ICPR1_val = packed struct {
/// CLRPEND [0:31]
/// CLRPEND
CLRPEND: u32 = 0,
};
/// Interrupt Clear-Pending
pub const ICPR1 = Register(ICPR1_val).init(base_address + 0x184);

/// ICPR2
const ICPR2_val = packed struct {
/// CLRPEND [0:31]
/// CLRPEND
CLRPEND: u32 = 0,
};
/// Interrupt Clear-Pending
pub const ICPR2 = Register(ICPR2_val).init(base_address + 0x188);

/// IABR0
const IABR0_val = packed struct {
/// ACTIVE [0:31]
/// ACTIVE
ACTIVE: u32 = 0,
};
/// Interrupt Active Bit Register
pub const IABR0 = Register(IABR0_val).init(base_address + 0x200);

/// IABR1
const IABR1_val = packed struct {
/// ACTIVE [0:31]
/// ACTIVE
ACTIVE: u32 = 0,
};
/// Interrupt Active Bit Register
pub const IABR1 = Register(IABR1_val).init(base_address + 0x204);

/// IABR2
const IABR2_val = packed struct {
/// ACTIVE [0:31]
/// ACTIVE
ACTIVE: u32 = 0,
};
/// Interrupt Active Bit Register
pub const IABR2 = Register(IABR2_val).init(base_address + 0x208);

/// IPR0
const IPR0_val = packed struct {
/// IPR_N0 [0:7]
/// IPR_N0
IPR_N0: u8 = 0,
/// IPR_N1 [8:15]
/// IPR_N1
IPR_N1: u8 = 0,
/// IPR_N2 [16:23]
/// IPR_N2
IPR_N2: u8 = 0,
/// IPR_N3 [24:31]
/// IPR_N3
IPR_N3: u8 = 0,
};
/// Interrupt Priority Register
pub const IPR0 = Register(IPR0_val).init(base_address + 0x300);

/// IPR1
const IPR1_val = packed struct {
/// IPR_N0 [0:7]
/// IPR_N0
IPR_N0: u8 = 0,
/// IPR_N1 [8:15]
/// IPR_N1
IPR_N1: u8 = 0,
/// IPR_N2 [16:23]
/// IPR_N2
IPR_N2: u8 = 0,
/// IPR_N3 [24:31]
/// IPR_N3
IPR_N3: u8 = 0,
};
/// Interrupt Priority Register
pub const IPR1 = Register(IPR1_val).init(base_address + 0x304);

/// IPR2
const IPR2_val = packed struct {
/// IPR_N0 [0:7]
/// IPR_N0
IPR_N0: u8 = 0,
/// IPR_N1 [8:15]
/// IPR_N1
IPR_N1: u8 = 0,
/// IPR_N2 [16:23]
/// IPR_N2
IPR_N2: u8 = 0,
/// IPR_N3 [24:31]
/// IPR_N3
IPR_N3: u8 = 0,
};
/// Interrupt Priority Register
pub const IPR2 = Register(IPR2_val).init(base_address + 0x308);

/// IPR3
const IPR3_val = packed struct {
/// IPR_N0 [0:7]
/// IPR_N0
IPR_N0: u8 = 0,
/// IPR_N1 [8:15]
/// IPR_N1
IPR_N1: u8 = 0,
/// IPR_N2 [16:23]
/// IPR_N2
IPR_N2: u8 = 0,
/// IPR_N3 [24:31]
/// IPR_N3
IPR_N3: u8 = 0,
};
/// Interrupt Priority Register
pub const IPR3 = Register(IPR3_val).init(base_address + 0x30c);

/// IPR4
const IPR4_val = packed struct {
/// IPR_N0 [0:7]
/// IPR_N0
IPR_N0: u8 = 0,
/// IPR_N1 [8:15]
/// IPR_N1
IPR_N1: u8 = 0,
/// IPR_N2 [16:23]
/// IPR_N2
IPR_N2: u8 = 0,
/// IPR_N3 [24:31]
/// IPR_N3
IPR_N3: u8 = 0,
};
/// Interrupt Priority Register
pub const IPR4 = Register(IPR4_val).init(base_address + 0x310);

/// IPR5
const IPR5_val = packed struct {
/// IPR_N0 [0:7]
/// IPR_N0
IPR_N0: u8 = 0,
/// IPR_N1 [8:15]
/// IPR_N1
IPR_N1: u8 = 0,
/// IPR_N2 [16:23]
/// IPR_N2
IPR_N2: u8 = 0,
/// IPR_N3 [24:31]
/// IPR_N3
IPR_N3: u8 = 0,
};
/// Interrupt Priority Register
pub const IPR5 = Register(IPR5_val).init(base_address + 0x314);

/// IPR6
const IPR6_val = packed struct {
/// IPR_N0 [0:7]
/// IPR_N0
IPR_N0: u8 = 0,
/// IPR_N1 [8:15]
/// IPR_N1
IPR_N1: u8 = 0,
/// IPR_N2 [16:23]
/// IPR_N2
IPR_N2: u8 = 0,
/// IPR_N3 [24:31]
/// IPR_N3
IPR_N3: u8 = 0,
};
/// Interrupt Priority Register
pub const IPR6 = Register(IPR6_val).init(base_address + 0x318);

/// IPR7
const IPR7_val = packed struct {
/// IPR_N0 [0:7]
/// IPR_N0
IPR_N0: u8 = 0,
/// IPR_N1 [8:15]
/// IPR_N1
IPR_N1: u8 = 0,
/// IPR_N2 [16:23]
/// IPR_N2
IPR_N2: u8 = 0,
/// IPR_N3 [24:31]
/// IPR_N3
IPR_N3: u8 = 0,
};
/// Interrupt Priority Register
pub const IPR7 = Register(IPR7_val).init(base_address + 0x31c);

/// IPR8
const IPR8_val = packed struct {
/// IPR_N0 [0:7]
/// IPR_N0
IPR_N0: u8 = 0,
/// IPR_N1 [8:15]
/// IPR_N1
IPR_N1: u8 = 0,
/// IPR_N2 [16:23]
/// IPR_N2
IPR_N2: u8 = 0,
/// IPR_N3 [24:31]
/// IPR_N3
IPR_N3: u8 = 0,
};
/// Interrupt Priority Register
pub const IPR8 = Register(IPR8_val).init(base_address + 0x320);

/// IPR9
const IPR9_val = packed struct {
/// IPR_N0 [0:7]
/// IPR_N0
IPR_N0: u8 = 0,
/// IPR_N1 [8:15]
/// IPR_N1
IPR_N1: u8 = 0,
/// IPR_N2 [16:23]
/// IPR_N2
IPR_N2: u8 = 0,
/// IPR_N3 [24:31]
/// IPR_N3
IPR_N3: u8 = 0,
};
/// Interrupt Priority Register
pub const IPR9 = Register(IPR9_val).init(base_address + 0x324);

/// IPR10
const IPR10_val = packed struct {
/// IPR_N0 [0:7]
/// IPR_N0
IPR_N0: u8 = 0,
/// IPR_N1 [8:15]
/// IPR_N1
IPR_N1: u8 = 0,
/// IPR_N2 [16:23]
/// IPR_N2
IPR_N2: u8 = 0,
/// IPR_N3 [24:31]
/// IPR_N3
IPR_N3: u8 = 0,
};
/// Interrupt Priority Register
pub const IPR10 = Register(IPR10_val).init(base_address + 0x328);

/// IPR11
const IPR11_val = packed struct {
/// IPR_N0 [0:7]
/// IPR_N0
IPR_N0: u8 = 0,
/// IPR_N1 [8:15]
/// IPR_N1
IPR_N1: u8 = 0,
/// IPR_N2 [16:23]
/// IPR_N2
IPR_N2: u8 = 0,
/// IPR_N3 [24:31]
/// IPR_N3
IPR_N3: u8 = 0,
};
/// Interrupt Priority Register
pub const IPR11 = Register(IPR11_val).init(base_address + 0x32c);

/// IPR12
const IPR12_val = packed struct {
/// IPR_N0 [0:7]
/// IPR_N0
IPR_N0: u8 = 0,
/// IPR_N1 [8:15]
/// IPR_N1
IPR_N1: u8 = 0,
/// IPR_N2 [16:23]
/// IPR_N2
IPR_N2: u8 = 0,
/// IPR_N3 [24:31]
/// IPR_N3
IPR_N3: u8 = 0,
};
/// Interrupt Priority Register
pub const IPR12 = Register(IPR12_val).init(base_address + 0x330);

/// IPR13
const IPR13_val = packed struct {
/// IPR_N0 [0:7]
/// IPR_N0
IPR_N0: u8 = 0,
/// IPR_N1 [8:15]
/// IPR_N1
IPR_N1: u8 = 0,
/// IPR_N2 [16:23]
/// IPR_N2
IPR_N2: u8 = 0,
/// IPR_N3 [24:31]
/// IPR_N3
IPR_N3: u8 = 0,
};
/// Interrupt Priority Register
pub const IPR13 = Register(IPR13_val).init(base_address + 0x334);

/// IPR14
const IPR14_val = packed struct {
/// IPR_N0 [0:7]
/// IPR_N0
IPR_N0: u8 = 0,
/// IPR_N1 [8:15]
/// IPR_N1
IPR_N1: u8 = 0,
/// IPR_N2 [16:23]
/// IPR_N2
IPR_N2: u8 = 0,
/// IPR_N3 [24:31]
/// IPR_N3
IPR_N3: u8 = 0,
};
/// Interrupt Priority Register
pub const IPR14 = Register(IPR14_val).init(base_address + 0x338);

/// IPR15
const IPR15_val = packed struct {
/// IPR_N0 [0:7]
/// IPR_N0
IPR_N0: u8 = 0,
/// IPR_N1 [8:15]
/// IPR_N1
IPR_N1: u8 = 0,
/// IPR_N2 [16:23]
/// IPR_N2
IPR_N2: u8 = 0,
/// IPR_N3 [24:31]
/// IPR_N3
IPR_N3: u8 = 0,
};
/// Interrupt Priority Register
pub const IPR15 = Register(IPR15_val).init(base_address + 0x33c);

/// IPR16
const IPR16_val = packed struct {
/// IPR_N0 [0:7]
/// IPR_N0
IPR_N0: u8 = 0,
/// IPR_N1 [8:15]
/// IPR_N1
IPR_N1: u8 = 0,
/// IPR_N2 [16:23]
/// IPR_N2
IPR_N2: u8 = 0,
/// IPR_N3 [24:31]
/// IPR_N3
IPR_N3: u8 = 0,
};
/// Interrupt Priority Register
pub const IPR16 = Register(IPR16_val).init(base_address + 0x340);

/// IPR17
const IPR17_val = packed struct {
/// IPR_N0 [0:7]
/// IPR_N0
IPR_N0: u8 = 0,
/// IPR_N1 [8:15]
/// IPR_N1
IPR_N1: u8 = 0,
/// IPR_N2 [16:23]
/// IPR_N2
IPR_N2: u8 = 0,
/// IPR_N3 [24:31]
/// IPR_N3
IPR_N3: u8 = 0,
};
/// Interrupt Priority Register
pub const IPR17 = Register(IPR17_val).init(base_address + 0x344);

/// IPR18
const IPR18_val = packed struct {
/// IPR_N0 [0:7]
/// IPR_N0
IPR_N0: u8 = 0,
/// IPR_N1 [8:15]
/// IPR_N1
IPR_N1: u8 = 0,
/// IPR_N2 [16:23]
/// IPR_N2
IPR_N2: u8 = 0,
/// IPR_N3 [24:31]
/// IPR_N3
IPR_N3: u8 = 0,
};
/// Interrupt Priority Register
pub const IPR18 = Register(IPR18_val).init(base_address + 0x348);

/// IPR19
const IPR19_val = packed struct {
/// IPR_N0 [0:7]
/// IPR_N0
IPR_N0: u8 = 0,
/// IPR_N1 [8:15]
/// IPR_N1
IPR_N1: u8 = 0,
/// IPR_N2 [16:23]
/// IPR_N2
IPR_N2: u8 = 0,
/// IPR_N3 [24:31]
/// IPR_N3
IPR_N3: u8 = 0,
};
/// Interrupt Priority Register
pub const IPR19 = Register(IPR19_val).init(base_address + 0x34c);

/// IPR20
const IPR20_val = packed struct {
/// IPR_N0 [0:7]
/// IPR_N0
IPR_N0: u8 = 0,
/// IPR_N1 [8:15]
/// IPR_N1
IPR_N1: u8 = 0,
/// IPR_N2 [16:23]
/// IPR_N2
IPR_N2: u8 = 0,
/// IPR_N3 [24:31]
/// IPR_N3
IPR_N3: u8 = 0,
};
/// Interrupt Priority Register
pub const IPR20 = Register(IPR20_val).init(base_address + 0x350);
};

/// Clock recovery system
pub const CRS = struct {

const base_address = 0x40006000;
/// CR
const CR_val = packed struct {
/// SYNCOKIE [0:0]
/// SYNC event OK interrupt
SYNCOKIE: u1 = 0,
/// SYNCWARNIE [1:1]
/// SYNC warning interrupt
SYNCWARNIE: u1 = 0,
/// ERRIE [2:2]
/// Synchronization or trimming error
ERRIE: u1 = 0,
/// ESYNCIE [3:3]
/// Expected SYNC interrupt
ESYNCIE: u1 = 0,
/// unused [4:4]
_unused4: u1 = 0,
/// CEN [5:5]
/// Frequency error counter
CEN: u1 = 0,
/// AUTOTRIMEN [6:6]
/// Automatic trimming enable
AUTOTRIMEN: u1 = 0,
/// SWSYNC [7:7]
/// Generate software SYNC
SWSYNC: u1 = 0,
/// TRIM [8:13]
/// HSI48 oscillator smooth
TRIM: u6 = 32,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register
pub const CR = Register(CR_val).init(base_address + 0x0);

/// CFGR
const CFGR_val = packed struct {
/// RELOAD [0:15]
/// Counter reload value
RELOAD: u16 = 47999,
/// FELIM [16:23]
/// Frequency error limit
FELIM: u8 = 34,
/// SYNCDIV [24:26]
/// SYNC divider
SYNCDIV: u3 = 0,
/// unused [27:27]
_unused27: u1 = 0,
/// SYNCSRC [28:29]
/// SYNC signal source
SYNCSRC: u2 = 2,
/// unused [30:30]
_unused30: u1 = 0,
/// SYNCPOL [31:31]
/// SYNC polarity selection
SYNCPOL: u1 = 0,
};
/// configuration register
pub const CFGR = Register(CFGR_val).init(base_address + 0x4);

/// ISR
const ISR_val = packed struct {
/// SYNCOKF [0:0]
/// SYNC event OK flag
SYNCOKF: u1 = 0,
/// SYNCWARNF [1:1]
/// SYNC warning flag
SYNCWARNF: u1 = 0,
/// ERRF [2:2]
/// Error flag
ERRF: u1 = 0,
/// ESYNCF [3:3]
/// Expected SYNC flag
ESYNCF: u1 = 0,
/// unused [4:7]
_unused4: u4 = 0,
/// SYNCERR [8:8]
/// SYNC error
SYNCERR: u1 = 0,
/// SYNCMISS [9:9]
/// SYNC missed
SYNCMISS: u1 = 0,
/// TRIMOVF [10:10]
/// Trimming overflow or
TRIMOVF: u1 = 0,
/// unused [11:14]
_unused11: u4 = 0,
/// FEDIR [15:15]
/// Frequency error direction
FEDIR: u1 = 0,
/// FECAP [16:31]
/// Frequency error capture
FECAP: u16 = 0,
};
/// interrupt and status register
pub const ISR = Register(ISR_val).init(base_address + 0x8);

/// ICR
const ICR_val = packed struct {
/// SYNCOKC [0:0]
/// SYNC event OK clear flag
SYNCOKC: u1 = 0,
/// SYNCWARNC [1:1]
/// SYNC warning clear flag
SYNCWARNC: u1 = 0,
/// ERRC [2:2]
/// Error clear flag
ERRC: u1 = 0,
/// ESYNCC [3:3]
/// Expected SYNC clear flag
ESYNCC: u1 = 0,
/// unused [4:31]
_unused4: u4 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// interrupt flag clear register
pub const ICR = Register(ICR_val).init(base_address + 0xc);
};

/// Universal serial bus full-speed device
pub const USB_SRAM = struct {

const base_address = 0x40006c00;
/// EP0R
const EP0R_val = packed struct {
/// EA [0:3]
/// Endpoint address
EA: u4 = 0,
/// STAT_TX [4:5]
/// Status bits, for transmission
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// Data Toggle, for transmission
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// Correct Transfer for
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// Endpoint kind
EP_KIND: u1 = 0,
/// EP_TYPE [9:10]
/// Endpoint type
EP_TYPE: u2 = 0,
/// SETUP [11:11]
/// Setup transaction
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// Status bits, for reception
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// Data Toggle, for reception
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// Correct transfer for
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint 0 register
pub const EP0R = Register(EP0R_val).init(base_address + 0x0);

/// EP1R
const EP1R_val = packed struct {
/// EA [0:3]
/// Endpoint address
EA: u4 = 0,
/// STAT_TX [4:5]
/// Status bits, for transmission
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// Data Toggle, for transmission
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// Correct Transfer for
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// Endpoint kind
EP_KIND: u1 = 0,
/// EP_TYPE [9:10]
/// Endpoint type
EP_TYPE: u2 = 0,
/// SETUP [11:11]
/// Setup transaction
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// Status bits, for reception
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// Data Toggle, for reception
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// Correct transfer for
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint 1 register
pub const EP1R = Register(EP1R_val).init(base_address + 0x4);

/// EP2R
const EP2R_val = packed struct {
/// EA [0:3]
/// Endpoint address
EA: u4 = 0,
/// STAT_TX [4:5]
/// Status bits, for transmission
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// Data Toggle, for transmission
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// Correct Transfer for
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// Endpoint kind
EP_KIND: u1 = 0,
/// EP_TYPE [9:10]
/// Endpoint type
EP_TYPE: u2 = 0,
/// SETUP [11:11]
/// Setup transaction
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// Status bits, for reception
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// Data Toggle, for reception
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// Correct transfer for
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint 2 register
pub const EP2R = Register(EP2R_val).init(base_address + 0x8);

/// EP3R
const EP3R_val = packed struct {
/// EA [0:3]
/// Endpoint address
EA: u4 = 0,
/// STAT_TX [4:5]
/// Status bits, for transmission
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// Data Toggle, for transmission
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// Correct Transfer for
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// Endpoint kind
EP_KIND: u1 = 0,
/// EP_TYPE [9:10]
/// Endpoint type
EP_TYPE: u2 = 0,
/// SETUP [11:11]
/// Setup transaction
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// Status bits, for reception
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// Data Toggle, for reception
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// Correct transfer for
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint 3 register
pub const EP3R = Register(EP3R_val).init(base_address + 0xc);

/// EP4R
const EP4R_val = packed struct {
/// EA [0:3]
/// Endpoint address
EA: u4 = 0,
/// STAT_TX [4:5]
/// Status bits, for transmission
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// Data Toggle, for transmission
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// Correct Transfer for
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// Endpoint kind
EP_KIND: u1 = 0,
/// EP_TYPE [9:10]
/// Endpoint type
EP_TYPE: u2 = 0,
/// SETUP [11:11]
/// Setup transaction
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// Status bits, for reception
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// Data Toggle, for reception
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// Correct transfer for
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint 4 register
pub const EP4R = Register(EP4R_val).init(base_address + 0x10);

/// EP5R
const EP5R_val = packed struct {
/// EA [0:3]
/// Endpoint address
EA: u4 = 0,
/// STAT_TX [4:5]
/// Status bits, for transmission
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// Data Toggle, for transmission
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// Correct Transfer for
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// Endpoint kind
EP_KIND: u1 = 0,
/// EP_TYPE [9:10]
/// Endpoint type
EP_TYPE: u2 = 0,
/// SETUP [11:11]
/// Setup transaction
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// Status bits, for reception
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// Data Toggle, for reception
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// Correct transfer for
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint 5 register
pub const EP5R = Register(EP5R_val).init(base_address + 0x14);

/// EP6R
const EP6R_val = packed struct {
/// EA [0:3]
/// Endpoint address
EA: u4 = 0,
/// STAT_TX [4:5]
/// Status bits, for transmission
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// Data Toggle, for transmission
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// Correct Transfer for
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// Endpoint kind
EP_KIND: u1 = 0,
/// EP_TYPE [9:10]
/// Endpoint type
EP_TYPE: u2 = 0,
/// SETUP [11:11]
/// Setup transaction
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// Status bits, for reception
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// Data Toggle, for reception
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// Correct transfer for
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint 6 register
pub const EP6R = Register(EP6R_val).init(base_address + 0x18);

/// EP7R
const EP7R_val = packed struct {
/// EA [0:3]
/// Endpoint address
EA: u4 = 0,
/// STAT_TX [4:5]
/// Status bits, for transmission
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// Data Toggle, for transmission
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// Correct Transfer for
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// Endpoint kind
EP_KIND: u1 = 0,
/// EP_TYPE [9:10]
/// Endpoint type
EP_TYPE: u2 = 0,
/// SETUP [11:11]
/// Setup transaction
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// Status bits, for reception
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// Data Toggle, for reception
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// Correct transfer for
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint 7 register
pub const EP7R = Register(EP7R_val).init(base_address + 0x1c);

/// CNTR
const CNTR_val = packed struct {
/// FRES [0:0]
/// Force USB Reset
FRES: u1 = 1,
/// PDWN [1:1]
/// Power down
PDWN: u1 = 1,
/// LPMODE [2:2]
/// Low-power mode
LPMODE: u1 = 0,
/// FSUSP [3:3]
/// Force suspend
FSUSP: u1 = 0,
/// RESUME [4:4]
/// Resume request
RESUME: u1 = 0,
/// L1RESUME [5:5]
/// LPM L1 Resume request
L1RESUME: u1 = 0,
/// unused [6:6]
_unused6: u1 = 0,
/// L1REQM [7:7]
/// LPM L1 state request interrupt
L1REQM: u1 = 0,
/// ESOFM [8:8]
/// Expected start of frame interrupt
ESOFM: u1 = 0,
/// SOFM [9:9]
/// Start of frame interrupt
SOFM: u1 = 0,
/// RESETM [10:10]
/// USB reset interrupt mask
RESETM: u1 = 0,
/// SUSPM [11:11]
/// Suspend mode interrupt
SUSPM: u1 = 0,
/// WKUPM [12:12]
/// Wakeup interrupt mask
WKUPM: u1 = 0,
/// ERRM [13:13]
/// Error interrupt mask
ERRM: u1 = 0,
/// PMAOVRM [14:14]
/// Packet memory area over / underrun
PMAOVRM: u1 = 0,
/// CTRM [15:15]
/// Correct transfer interrupt
CTRM: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register
pub const CNTR = Register(CNTR_val).init(base_address + 0x40);

/// ISTR
const ISTR_val = packed struct {
/// EP_ID [0:3]
/// Endpoint Identifier
EP_ID: u4 = 0,
/// DIR [4:4]
/// Direction of transaction
DIR: u1 = 0,
/// unused [5:6]
_unused5: u2 = 0,
/// L1REQ [7:7]
/// LPM L1 state request
L1REQ: u1 = 0,
/// ESOF [8:8]
/// Expected start frame
ESOF: u1 = 0,
/// SOF [9:9]
/// start of frame
SOF: u1 = 0,
/// RESET [10:10]
/// reset request
RESET: u1 = 0,
/// SUSP [11:11]
/// Suspend mode request
SUSP: u1 = 0,
/// WKUP [12:12]
/// Wakeup
WKUP: u1 = 0,
/// ERR [13:13]
/// Error
ERR: u1 = 0,
/// PMAOVR [14:14]
/// Packet memory area over /
PMAOVR: u1 = 0,
/// CTR [15:15]
/// Correct transfer
CTR: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// interrupt status register
pub const ISTR = Register(ISTR_val).init(base_address + 0x44);

/// FNR
const FNR_val = packed struct {
/// FN [0:10]
/// Frame number
FN: u11 = 0,
/// LSOF [11:12]
/// Lost SOF
LSOF: u2 = 0,
/// LCK [13:13]
/// Locked
LCK: u1 = 0,
/// RXDM [14:14]
/// Receive data - line status
RXDM: u1 = 0,
/// RXDP [15:15]
/// Receive data + line status
RXDP: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// frame number register
pub const FNR = Register(FNR_val).init(base_address + 0x48);

/// DADDR
const DADDR_val = packed struct {
/// ADD [0:6]
/// Device address
ADD: u7 = 0,
/// EF [7:7]
/// Enable function
EF: u1 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// device address
pub const DADDR = Register(DADDR_val).init(base_address + 0x4c);

/// BTABLE
const BTABLE_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// BTABLE [3:15]
/// Buffer table
BTABLE: u13 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Buffer table address
pub const BTABLE = Register(BTABLE_val).init(base_address + 0x50);

/// LPMCSR
const LPMCSR_val = packed struct {
/// LPMEN [0:0]
/// LPM support enable
LPMEN: u1 = 0,
/// LPMACK [1:1]
/// LPM Token acknowledge
LPMACK: u1 = 0,
/// unused [2:2]
_unused2: u1 = 0,
/// REMWAKE [3:3]
/// bRemoteWake value
REMWAKE: u1 = 0,
/// BESL [4:7]
/// BESL value
BESL: u4 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// LPM control and status
pub const LPMCSR = Register(LPMCSR_val).init(base_address + 0x54);

/// BCDR
const BCDR_val = packed struct {
/// BCDEN [0:0]
/// Battery charging detector
BCDEN: u1 = 0,
/// DCDEN [1:1]
/// Data contact detection
DCDEN: u1 = 0,
/// PDEN [2:2]
/// Primary detection
PDEN: u1 = 0,
/// SDEN [3:3]
/// Secondary detection
SDEN: u1 = 0,
/// DCDET [4:4]
/// Data contact detection
DCDET: u1 = 0,
/// PDET [5:5]
/// Primary detection
PDET: u1 = 0,
/// SDET [6:6]
/// Secondary detection
SDET: u1 = 0,
/// PS2DET [7:7]
/// DM pull-up detection
PS2DET: u1 = 0,
/// unused [8:14]
_unused8: u7 = 0,
/// DPPU [15:15]
/// DP pull-up control
DPPU: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Battery charging detector
pub const BCDR = Register(BCDR_val).init(base_address + 0x58);
};

/// Universal serial bus full-speed device
pub const USB_FS = struct {

const base_address = 0x40006800;
/// EP0R
const EP0R_val = packed struct {
/// EA [0:3]
/// Endpoint address
EA: u4 = 0,
/// STAT_TX [4:5]
/// Status bits, for transmission
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// Data Toggle, for transmission
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// Correct Transfer for
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// Endpoint kind
EP_KIND: u1 = 0,
/// EP_TYPE [9:10]
/// Endpoint type
EP_TYPE: u2 = 0,
/// SETUP [11:11]
/// Setup transaction
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// Status bits, for reception
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// Data Toggle, for reception
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// Correct transfer for
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint 0 register
pub const EP0R = Register(EP0R_val).init(base_address + 0x0);

/// EP1R
const EP1R_val = packed struct {
/// EA [0:3]
/// Endpoint address
EA: u4 = 0,
/// STAT_TX [4:5]
/// Status bits, for transmission
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// Data Toggle, for transmission
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// Correct Transfer for
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// Endpoint kind
EP_KIND: u1 = 0,
/// EP_TYPE [9:10]
/// Endpoint type
EP_TYPE: u2 = 0,
/// SETUP [11:11]
/// Setup transaction
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// Status bits, for reception
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// Data Toggle, for reception
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// Correct transfer for
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint 1 register
pub const EP1R = Register(EP1R_val).init(base_address + 0x4);

/// EP2R
const EP2R_val = packed struct {
/// EA [0:3]
/// Endpoint address
EA: u4 = 0,
/// STAT_TX [4:5]
/// Status bits, for transmission
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// Data Toggle, for transmission
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// Correct Transfer for
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// Endpoint kind
EP_KIND: u1 = 0,
/// EP_TYPE [9:10]
/// Endpoint type
EP_TYPE: u2 = 0,
/// SETUP [11:11]
/// Setup transaction
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// Status bits, for reception
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// Data Toggle, for reception
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// Correct transfer for
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint 2 register
pub const EP2R = Register(EP2R_val).init(base_address + 0x8);

/// EP3R
const EP3R_val = packed struct {
/// EA [0:3]
/// Endpoint address
EA: u4 = 0,
/// STAT_TX [4:5]
/// Status bits, for transmission
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// Data Toggle, for transmission
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// Correct Transfer for
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// Endpoint kind
EP_KIND: u1 = 0,
/// EP_TYPE [9:10]
/// Endpoint type
EP_TYPE: u2 = 0,
/// SETUP [11:11]
/// Setup transaction
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// Status bits, for reception
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// Data Toggle, for reception
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// Correct transfer for
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint 3 register
pub const EP3R = Register(EP3R_val).init(base_address + 0xc);

/// EP4R
const EP4R_val = packed struct {
/// EA [0:3]
/// Endpoint address
EA: u4 = 0,
/// STAT_TX [4:5]
/// Status bits, for transmission
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// Data Toggle, for transmission
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// Correct Transfer for
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// Endpoint kind
EP_KIND: u1 = 0,
/// EP_TYPE [9:10]
/// Endpoint type
EP_TYPE: u2 = 0,
/// SETUP [11:11]
/// Setup transaction
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// Status bits, for reception
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// Data Toggle, for reception
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// Correct transfer for
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint 4 register
pub const EP4R = Register(EP4R_val).init(base_address + 0x10);

/// EP5R
const EP5R_val = packed struct {
/// EA [0:3]
/// Endpoint address
EA: u4 = 0,
/// STAT_TX [4:5]
/// Status bits, for transmission
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// Data Toggle, for transmission
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// Correct Transfer for
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// Endpoint kind
EP_KIND: u1 = 0,
/// EP_TYPE [9:10]
/// Endpoint type
EP_TYPE: u2 = 0,
/// SETUP [11:11]
/// Setup transaction
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// Status bits, for reception
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// Data Toggle, for reception
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// Correct transfer for
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint 5 register
pub const EP5R = Register(EP5R_val).init(base_address + 0x14);

/// EP6R
const EP6R_val = packed struct {
/// EA [0:3]
/// Endpoint address
EA: u4 = 0,
/// STAT_TX [4:5]
/// Status bits, for transmission
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// Data Toggle, for transmission
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// Correct Transfer for
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// Endpoint kind
EP_KIND: u1 = 0,
/// EP_TYPE [9:10]
/// Endpoint type
EP_TYPE: u2 = 0,
/// SETUP [11:11]
/// Setup transaction
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// Status bits, for reception
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// Data Toggle, for reception
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// Correct transfer for
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint 6 register
pub const EP6R = Register(EP6R_val).init(base_address + 0x18);

/// EP7R
const EP7R_val = packed struct {
/// EA [0:3]
/// Endpoint address
EA: u4 = 0,
/// STAT_TX [4:5]
/// Status bits, for transmission
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// Data Toggle, for transmission
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// Correct Transfer for
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// Endpoint kind
EP_KIND: u1 = 0,
/// EP_TYPE [9:10]
/// Endpoint type
EP_TYPE: u2 = 0,
/// SETUP [11:11]
/// Setup transaction
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// Status bits, for reception
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// Data Toggle, for reception
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// Correct transfer for
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint 7 register
pub const EP7R = Register(EP7R_val).init(base_address + 0x1c);

/// CNTR
const CNTR_val = packed struct {
/// FRES [0:0]
/// Force USB Reset
FRES: u1 = 1,
/// PDWN [1:1]
/// Power down
PDWN: u1 = 1,
/// LPMODE [2:2]
/// Low-power mode
LPMODE: u1 = 0,
/// FSUSP [3:3]
/// Force suspend
FSUSP: u1 = 0,
/// RESUME [4:4]
/// Resume request
RESUME: u1 = 0,
/// L1RESUME [5:5]
/// LPM L1 Resume request
L1RESUME: u1 = 0,
/// unused [6:6]
_unused6: u1 = 0,
/// L1REQM [7:7]
/// LPM L1 state request interrupt
L1REQM: u1 = 0,
/// ESOFM [8:8]
/// Expected start of frame interrupt
ESOFM: u1 = 0,
/// SOFM [9:9]
/// Start of frame interrupt
SOFM: u1 = 0,
/// RESETM [10:10]
/// USB reset interrupt mask
RESETM: u1 = 0,
/// SUSPM [11:11]
/// Suspend mode interrupt
SUSPM: u1 = 0,
/// WKUPM [12:12]
/// Wakeup interrupt mask
WKUPM: u1 = 0,
/// ERRM [13:13]
/// Error interrupt mask
ERRM: u1 = 0,
/// PMAOVRM [14:14]
/// Packet memory area over / underrun
PMAOVRM: u1 = 0,
/// CTRM [15:15]
/// Correct transfer interrupt
CTRM: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register
pub const CNTR = Register(CNTR_val).init(base_address + 0x40);

/// ISTR
const ISTR_val = packed struct {
/// EP_ID [0:3]
/// Endpoint Identifier
EP_ID: u4 = 0,
/// DIR [4:4]
/// Direction of transaction
DIR: u1 = 0,
/// unused [5:6]
_unused5: u2 = 0,
/// L1REQ [7:7]
/// LPM L1 state request
L1REQ: u1 = 0,
/// ESOF [8:8]
/// Expected start frame
ESOF: u1 = 0,
/// SOF [9:9]
/// start of frame
SOF: u1 = 0,
/// RESET [10:10]
/// reset request
RESET: u1 = 0,
/// SUSP [11:11]
/// Suspend mode request
SUSP: u1 = 0,
/// WKUP [12:12]
/// Wakeup
WKUP: u1 = 0,
/// ERR [13:13]
/// Error
ERR: u1 = 0,
/// PMAOVR [14:14]
/// Packet memory area over /
PMAOVR: u1 = 0,
/// CTR [15:15]
/// Correct transfer
CTR: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// interrupt status register
pub const ISTR = Register(ISTR_val).init(base_address + 0x44);

/// FNR
const FNR_val = packed struct {
/// FN [0:10]
/// Frame number
FN: u11 = 0,
/// LSOF [11:12]
/// Lost SOF
LSOF: u2 = 0,
/// LCK [13:13]
/// Locked
LCK: u1 = 0,
/// RXDM [14:14]
/// Receive data - line status
RXDM: u1 = 0,
/// RXDP [15:15]
/// Receive data + line status
RXDP: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// frame number register
pub const FNR = Register(FNR_val).init(base_address + 0x48);

/// DADDR
const DADDR_val = packed struct {
/// ADD [0:6]
/// Device address
ADD: u7 = 0,
/// EF [7:7]
/// Enable function
EF: u1 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// device address
pub const DADDR = Register(DADDR_val).init(base_address + 0x4c);

/// BTABLE
const BTABLE_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// BTABLE [3:15]
/// Buffer table
BTABLE: u13 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Buffer table address
pub const BTABLE = Register(BTABLE_val).init(base_address + 0x50);

/// LPMCSR
const LPMCSR_val = packed struct {
/// LPMEN [0:0]
/// LPM support enable
LPMEN: u1 = 0,
/// LPMACK [1:1]
/// LPM Token acknowledge
LPMACK: u1 = 0,
/// unused [2:2]
_unused2: u1 = 0,
/// REMWAKE [3:3]
/// bRemoteWake value
REMWAKE: u1 = 0,
/// BESL [4:7]
/// BESL value
BESL: u4 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// LPM control and status
pub const LPMCSR = Register(LPMCSR_val).init(base_address + 0x54);

/// BCDR
const BCDR_val = packed struct {
/// BCDEN [0:0]
/// Battery charging detector
BCDEN: u1 = 0,
/// DCDEN [1:1]
/// Data contact detection
DCDEN: u1 = 0,
/// PDEN [2:2]
/// Primary detection
PDEN: u1 = 0,
/// SDEN [3:3]
/// Secondary detection
SDEN: u1 = 0,
/// DCDET [4:4]
/// Data contact detection
DCDET: u1 = 0,
/// PDET [5:5]
/// Primary detection
PDET: u1 = 0,
/// SDET [6:6]
/// Secondary detection
SDET: u1 = 0,
/// PS2DET [7:7]
/// DM pull-up detection
PS2DET: u1 = 0,
/// unused [8:14]
_unused8: u7 = 0,
/// DPPU [15:15]
/// DP pull-up control
DPPU: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Battery charging detector
pub const BCDR = Register(BCDR_val).init(base_address + 0x58);
};

/// Digital filter for sigma delta
pub const DFSDM = struct {

const base_address = 0x40016000;
/// CHCFG0R1
const CHCFG0R1_val = packed struct {
/// SITP [0:1]
/// SITP
SITP: u2 = 0,
/// SPICKSEL [2:3]
/// SPICKSEL
SPICKSEL: u2 = 0,
/// unused [4:4]
_unused4: u1 = 0,
/// SCDEN [5:5]
/// SCDEN
SCDEN: u1 = 0,
/// CKABEN [6:6]
/// CKABEN
CKABEN: u1 = 0,
/// CHEN [7:7]
/// CHEN
CHEN: u1 = 0,
/// CHINSEL [8:8]
/// CHINSEL
CHINSEL: u1 = 0,
/// unused [9:11]
_unused9: u3 = 0,
/// DATMPX [12:13]
/// DATMPX
DATMPX: u2 = 0,
/// DATPACK [14:15]
/// DATPACK
DATPACK: u2 = 0,
/// CKOUTDIV [16:23]
/// CKOUTDIV
CKOUTDIV: u8 = 0,
/// unused [24:29]
_unused24: u6 = 0,
/// CKOUTSRC [30:30]
/// CKOUTSRC
CKOUTSRC: u1 = 0,
/// DFSDMEN [31:31]
/// DFSDMEN
DFSDMEN: u1 = 0,
};
/// channel configuration y
pub const CHCFG0R1 = Register(CHCFG0R1_val).init(base_address + 0x0);

/// CHCFG0R2
const CHCFG0R2_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// DTRBS [3:7]
/// DTRBS
DTRBS: u5 = 0,
/// OFFSET [8:31]
/// OFFSET
OFFSET: u24 = 0,
};
/// channel configuration y
pub const CHCFG0R2 = Register(CHCFG0R2_val).init(base_address + 0x4);

/// AWSCD0R
const AWSCD0R_val = packed struct {
/// SCDT [0:7]
/// SCDT
SCDT: u8 = 0,
/// unused [8:11]
_unused8: u4 = 0,
/// BKSCD [12:15]
/// BKSCD
BKSCD: u4 = 0,
/// AWFOSR [16:20]
/// AWFOSR
AWFOSR: u5 = 0,
/// unused [21:21]
_unused21: u1 = 0,
/// AWFORD [22:23]
/// AWFORD
AWFORD: u2 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// analog watchdog and short-circuit detector
pub const AWSCD0R = Register(AWSCD0R_val).init(base_address + 0x8);

/// CHWDAT0R
const CHWDAT0R_val = packed struct {
/// WDATA [0:15]
/// WDATA
WDATA: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel watchdog filter data
pub const CHWDAT0R = Register(CHWDAT0R_val).init(base_address + 0xc);

/// CHDATIN0R
const CHDATIN0R_val = packed struct {
/// INDAT0 [0:15]
/// INDAT0
INDAT0: u16 = 0,
/// INDAT1 [16:31]
/// INDAT1
INDAT1: u16 = 0,
};
/// channel data input register
pub const CHDATIN0R = Register(CHDATIN0R_val).init(base_address + 0x10);

/// CHCFG1R1
const CHCFG1R1_val = packed struct {
/// SITP [0:1]
/// SITP
SITP: u2 = 0,
/// SPICKSEL [2:3]
/// SPICKSEL
SPICKSEL: u2 = 0,
/// unused [4:4]
_unused4: u1 = 0,
/// SCDEN [5:5]
/// SCDEN
SCDEN: u1 = 0,
/// CKABEN [6:6]
/// CKABEN
CKABEN: u1 = 0,
/// CHEN [7:7]
/// CHEN
CHEN: u1 = 0,
/// CHINSEL [8:8]
/// CHINSEL
CHINSEL: u1 = 0,
/// unused [9:11]
_unused9: u3 = 0,
/// DATMPX [12:13]
/// DATMPX
DATMPX: u2 = 0,
/// DATPACK [14:15]
/// DATPACK
DATPACK: u2 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// CHCFG1R1
pub const CHCFG1R1 = Register(CHCFG1R1_val).init(base_address + 0x20);

/// CHCFG1R2
const CHCFG1R2_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// DTRBS [3:7]
/// DTRBS
DTRBS: u5 = 0,
/// OFFSET [8:31]
/// OFFSET
OFFSET: u24 = 0,
};
/// CHCFG1R2
pub const CHCFG1R2 = Register(CHCFG1R2_val).init(base_address + 0x24);

/// AWSCD1R
const AWSCD1R_val = packed struct {
/// SCDT [0:7]
/// SCDT
SCDT: u8 = 0,
/// unused [8:11]
_unused8: u4 = 0,
/// BKSCD [12:15]
/// BKSCD
BKSCD: u4 = 0,
/// AWFOSR [16:20]
/// AWFOSR
AWFOSR: u5 = 0,
/// unused [21:21]
_unused21: u1 = 0,
/// AWFORD [22:23]
/// AWFORD
AWFORD: u2 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// AWSCD1R
pub const AWSCD1R = Register(AWSCD1R_val).init(base_address + 0x28);

/// CHWDAT1R
const CHWDAT1R_val = packed struct {
/// WDATA [0:15]
/// WDATA
WDATA: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// CHWDAT1R
pub const CHWDAT1R = Register(CHWDAT1R_val).init(base_address + 0x2c);

/// CHDATIN1R
const CHDATIN1R_val = packed struct {
/// INDAT0 [0:15]
/// INDAT0
INDAT0: u16 = 0,
/// INDAT1 [16:31]
/// INDAT1
INDAT1: u16 = 0,
};
/// CHDATIN1R
pub const CHDATIN1R = Register(CHDATIN1R_val).init(base_address + 0x30);

/// CHCFG2R1
const CHCFG2R1_val = packed struct {
/// SITP [0:1]
/// SITP
SITP: u2 = 0,
/// SPICKSEL [2:3]
/// SPICKSEL
SPICKSEL: u2 = 0,
/// unused [4:4]
_unused4: u1 = 0,
/// SCDEN [5:5]
/// SCDEN
SCDEN: u1 = 0,
/// CKABEN [6:6]
/// CKABEN
CKABEN: u1 = 0,
/// CHEN [7:7]
/// CHEN
CHEN: u1 = 0,
/// CHINSEL [8:8]
/// CHINSEL
CHINSEL: u1 = 0,
/// unused [9:11]
_unused9: u3 = 0,
/// DATMPX [12:13]
/// DATMPX
DATMPX: u2 = 0,
/// DATPACK [14:15]
/// DATPACK
DATPACK: u2 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// CHCFG2R1
pub const CHCFG2R1 = Register(CHCFG2R1_val).init(base_address + 0x40);

/// CHCFG2R2
const CHCFG2R2_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// DTRBS [3:7]
/// DTRBS
DTRBS: u5 = 0,
/// OFFSET [8:31]
/// OFFSET
OFFSET: u24 = 0,
};
/// CHCFG2R2
pub const CHCFG2R2 = Register(CHCFG2R2_val).init(base_address + 0x44);

/// AWSCD2R
const AWSCD2R_val = packed struct {
/// SCDT [0:7]
/// SCDT
SCDT: u8 = 0,
/// unused [8:11]
_unused8: u4 = 0,
/// BKSCD [12:15]
/// BKSCD
BKSCD: u4 = 0,
/// AWFOSR [16:20]
/// AWFOSR
AWFOSR: u5 = 0,
/// unused [21:21]
_unused21: u1 = 0,
/// AWFORD [22:23]
/// AWFORD
AWFORD: u2 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// AWSCD2R
pub const AWSCD2R = Register(AWSCD2R_val).init(base_address + 0x48);

/// CHWDAT2R
const CHWDAT2R_val = packed struct {
/// WDATA [0:15]
/// WDATA
WDATA: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// CHWDAT2R
pub const CHWDAT2R = Register(CHWDAT2R_val).init(base_address + 0x4c);

/// CHDATIN2R
const CHDATIN2R_val = packed struct {
/// INDAT0 [0:15]
/// INDAT0
INDAT0: u16 = 0,
/// INDAT1 [16:31]
/// INDAT1
INDAT1: u16 = 0,
};
/// CHDATIN2R
pub const CHDATIN2R = Register(CHDATIN2R_val).init(base_address + 0x50);

/// CHCFG3R1
const CHCFG3R1_val = packed struct {
/// SITP [0:1]
/// SITP
SITP: u2 = 0,
/// SPICKSEL [2:3]
/// SPICKSEL
SPICKSEL: u2 = 0,
/// unused [4:4]
_unused4: u1 = 0,
/// SCDEN [5:5]
/// SCDEN
SCDEN: u1 = 0,
/// CKABEN [6:6]
/// CKABEN
CKABEN: u1 = 0,
/// CHEN [7:7]
/// CHEN
CHEN: u1 = 0,
/// CHINSEL [8:8]
/// CHINSEL
CHINSEL: u1 = 0,
/// unused [9:11]
_unused9: u3 = 0,
/// DATMPX [12:13]
/// DATMPX
DATMPX: u2 = 0,
/// DATPACK [14:15]
/// DATPACK
DATPACK: u2 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// CHCFG3R1
pub const CHCFG3R1 = Register(CHCFG3R1_val).init(base_address + 0x60);

/// CHCFG3R2
const CHCFG3R2_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// DTRBS [3:7]
/// DTRBS
DTRBS: u5 = 0,
/// OFFSET [8:31]
/// OFFSET
OFFSET: u24 = 0,
};
/// CHCFG3R2
pub const CHCFG3R2 = Register(CHCFG3R2_val).init(base_address + 0x64);

/// AWSCD3R
const AWSCD3R_val = packed struct {
/// SCDT [0:7]
/// SCDT
SCDT: u8 = 0,
/// unused [8:11]
_unused8: u4 = 0,
/// BKSCD [12:15]
/// BKSCD
BKSCD: u4 = 0,
/// AWFOSR [16:20]
/// AWFOSR
AWFOSR: u5 = 0,
/// unused [21:21]
_unused21: u1 = 0,
/// AWFORD [22:23]
/// AWFORD
AWFORD: u2 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// AWSCD3R
pub const AWSCD3R = Register(AWSCD3R_val).init(base_address + 0x68);

/// CHWDAT3R
const CHWDAT3R_val = packed struct {
/// WDATA [0:15]
/// WDATA
WDATA: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// CHWDAT3R
pub const CHWDAT3R = Register(CHWDAT3R_val).init(base_address + 0x6c);

/// CHDATIN3R
const CHDATIN3R_val = packed struct {
/// INDAT0 [0:15]
/// INDAT0
INDAT0: u16 = 0,
/// INDAT1 [16:31]
/// INDAT1
INDAT1: u16 = 0,
};
/// CHDATIN3R
pub const CHDATIN3R = Register(CHDATIN3R_val).init(base_address + 0x70);

/// CHCFG4R1
const CHCFG4R1_val = packed struct {
/// SITP [0:1]
/// SITP
SITP: u2 = 0,
/// SPICKSEL [2:3]
/// SPICKSEL
SPICKSEL: u2 = 0,
/// unused [4:4]
_unused4: u1 = 0,
/// SCDEN [5:5]
/// SCDEN
SCDEN: u1 = 0,
/// CKABEN [6:6]
/// CKABEN
CKABEN: u1 = 0,
/// CHEN [7:7]
/// CHEN
CHEN: u1 = 0,
/// CHINSEL [8:8]
/// CHINSEL
CHINSEL: u1 = 0,
/// unused [9:11]
_unused9: u3 = 0,
/// DATMPX [12:13]
/// DATMPX
DATMPX: u2 = 0,
/// DATPACK [14:15]
/// DATPACK
DATPACK: u2 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// CHCFG4R1
pub const CHCFG4R1 = Register(CHCFG4R1_val).init(base_address + 0x80);

/// CHCFG4R2
const CHCFG4R2_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// DTRBS [3:7]
/// DTRBS
DTRBS: u5 = 0,
/// OFFSET [8:31]
/// OFFSET
OFFSET: u24 = 0,
};
/// CHCFG4R2
pub const CHCFG4R2 = Register(CHCFG4R2_val).init(base_address + 0x84);

/// AWSCD4R
const AWSCD4R_val = packed struct {
/// SCDT [0:7]
/// SCDT
SCDT: u8 = 0,
/// unused [8:11]
_unused8: u4 = 0,
/// BKSCD [12:15]
/// BKSCD
BKSCD: u4 = 0,
/// AWFOSR [16:20]
/// AWFOSR
AWFOSR: u5 = 0,
/// unused [21:21]
_unused21: u1 = 0,
/// AWFORD [22:23]
/// AWFORD
AWFORD: u2 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// AWSCD4R
pub const AWSCD4R = Register(AWSCD4R_val).init(base_address + 0x88);

/// CHWDAT4R
const CHWDAT4R_val = packed struct {
/// WDATA [0:15]
/// WDATA
WDATA: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// CHWDAT4R
pub const CHWDAT4R = Register(CHWDAT4R_val).init(base_address + 0x8c);

/// CHDATIN4R
const CHDATIN4R_val = packed struct {
/// INDAT0 [0:15]
/// INDAT0
INDAT0: u16 = 0,
/// INDAT1 [16:31]
/// INDAT1
INDAT1: u16 = 0,
};
/// CHDATIN4R
pub const CHDATIN4R = Register(CHDATIN4R_val).init(base_address + 0x90);

/// CHCFG5R1
const CHCFG5R1_val = packed struct {
/// SITP [0:1]
/// SITP
SITP: u2 = 0,
/// SPICKSEL [2:3]
/// SPICKSEL
SPICKSEL: u2 = 0,
/// unused [4:4]
_unused4: u1 = 0,
/// SCDEN [5:5]
/// SCDEN
SCDEN: u1 = 0,
/// CKABEN [6:6]
/// CKABEN
CKABEN: u1 = 0,
/// CHEN [7:7]
/// CHEN
CHEN: u1 = 0,
/// CHINSEL [8:8]
/// CHINSEL
CHINSEL: u1 = 0,
/// unused [9:11]
_unused9: u3 = 0,
/// DATMPX [12:13]
/// DATMPX
DATMPX: u2 = 0,
/// DATPACK [14:15]
/// DATPACK
DATPACK: u2 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// CHCFG5R1
pub const CHCFG5R1 = Register(CHCFG5R1_val).init(base_address + 0xa0);

/// CHCFG5R2
const CHCFG5R2_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// DTRBS [3:7]
/// DTRBS
DTRBS: u5 = 0,
/// OFFSET [8:31]
/// OFFSET
OFFSET: u24 = 0,
};
/// CHCFG5R2
pub const CHCFG5R2 = Register(CHCFG5R2_val).init(base_address + 0xa4);

/// AWSCD5R
const AWSCD5R_val = packed struct {
/// SCDT [0:7]
/// SCDT
SCDT: u8 = 0,
/// unused [8:11]
_unused8: u4 = 0,
/// BKSCD [12:15]
/// BKSCD
BKSCD: u4 = 0,
/// AWFOSR [16:20]
/// AWFOSR
AWFOSR: u5 = 0,
/// unused [21:21]
_unused21: u1 = 0,
/// AWFORD [22:23]
/// AWFORD
AWFORD: u2 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// AWSCD5R
pub const AWSCD5R = Register(AWSCD5R_val).init(base_address + 0xa8);

/// CHWDAT5R
const CHWDAT5R_val = packed struct {
/// WDATA [0:15]
/// WDATA
WDATA: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// CHWDAT5R
pub const CHWDAT5R = Register(CHWDAT5R_val).init(base_address + 0xac);

/// CHDATIN5R
const CHDATIN5R_val = packed struct {
/// INDAT0 [0:15]
/// INDAT0
INDAT0: u16 = 0,
/// INDAT1 [16:31]
/// INDAT1
INDAT1: u16 = 0,
};
/// CHDATIN5R
pub const CHDATIN5R = Register(CHDATIN5R_val).init(base_address + 0xb0);

/// CHCFG6R1
const CHCFG6R1_val = packed struct {
/// SITP [0:1]
/// SITP
SITP: u2 = 0,
/// SPICKSEL [2:3]
/// SPICKSEL
SPICKSEL: u2 = 0,
/// unused [4:4]
_unused4: u1 = 0,
/// SCDEN [5:5]
/// SCDEN
SCDEN: u1 = 0,
/// CKABEN [6:6]
/// CKABEN
CKABEN: u1 = 0,
/// CHEN [7:7]
/// CHEN
CHEN: u1 = 0,
/// CHINSEL [8:8]
/// CHINSEL
CHINSEL: u1 = 0,
/// unused [9:11]
_unused9: u3 = 0,
/// DATMPX [12:13]
/// DATMPX
DATMPX: u2 = 0,
/// DATPACK [14:15]
/// DATPACK
DATPACK: u2 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// CHCFG6R1
pub const CHCFG6R1 = Register(CHCFG6R1_val).init(base_address + 0xc0);

/// CHCFG6R2
const CHCFG6R2_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// DTRBS [3:7]
/// DTRBS
DTRBS: u5 = 0,
/// OFFSET [8:31]
/// OFFSET
OFFSET: u24 = 0,
};
/// CHCFG6R2
pub const CHCFG6R2 = Register(CHCFG6R2_val).init(base_address + 0xc4);

/// AWSCD6R
const AWSCD6R_val = packed struct {
/// SCDT [0:7]
/// SCDT
SCDT: u8 = 0,
/// unused [8:11]
_unused8: u4 = 0,
/// BKSCD [12:15]
/// BKSCD
BKSCD: u4 = 0,
/// AWFOSR [16:20]
/// AWFOSR
AWFOSR: u5 = 0,
/// unused [21:21]
_unused21: u1 = 0,
/// AWFORD [22:23]
/// AWFORD
AWFORD: u2 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// AWSCD6R
pub const AWSCD6R = Register(AWSCD6R_val).init(base_address + 0xc8);

/// CHWDAT6R
const CHWDAT6R_val = packed struct {
/// WDATA [0:15]
/// WDATA
WDATA: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// CHWDAT6R
pub const CHWDAT6R = Register(CHWDAT6R_val).init(base_address + 0xcc);

/// CHDATIN6R
const CHDATIN6R_val = packed struct {
/// INDAT0 [0:15]
/// INDAT0
INDAT0: u16 = 0,
/// INDAT1 [16:31]
/// INDAT1
INDAT1: u16 = 0,
};
/// CHDATIN6R
pub const CHDATIN6R = Register(CHDATIN6R_val).init(base_address + 0xd0);

/// CHCFG7R1
const CHCFG7R1_val = packed struct {
/// SITP [0:1]
/// SITP
SITP: u2 = 0,
/// SPICKSEL [2:3]
/// SPICKSEL
SPICKSEL: u2 = 0,
/// unused [4:4]
_unused4: u1 = 0,
/// SCDEN [5:5]
/// SCDEN
SCDEN: u1 = 0,
/// CKABEN [6:6]
/// CKABEN
CKABEN: u1 = 0,
/// CHEN [7:7]
/// CHEN
CHEN: u1 = 0,
/// CHINSEL [8:8]
/// CHINSEL
CHINSEL: u1 = 0,
/// unused [9:11]
_unused9: u3 = 0,
/// DATMPX [12:13]
/// DATMPX
DATMPX: u2 = 0,
/// DATPACK [14:15]
/// DATPACK
DATPACK: u2 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// CHCFG7R1
pub const CHCFG7R1 = Register(CHCFG7R1_val).init(base_address + 0xe0);

/// CHCFG7R2
const CHCFG7R2_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// DTRBS [3:7]
/// DTRBS
DTRBS: u5 = 0,
/// OFFSET [8:31]
/// OFFSET
OFFSET: u24 = 0,
};
/// CHCFG7R2
pub const CHCFG7R2 = Register(CHCFG7R2_val).init(base_address + 0xe4);

/// AWSCD7R
const AWSCD7R_val = packed struct {
/// SCDT [0:7]
/// SCDT
SCDT: u8 = 0,
/// unused [8:11]
_unused8: u4 = 0,
/// BKSCD [12:15]
/// BKSCD
BKSCD: u4 = 0,
/// AWFOSR [16:20]
/// AWFOSR
AWFOSR: u5 = 0,
/// unused [21:21]
_unused21: u1 = 0,
/// AWFORD [22:23]
/// AWFORD
AWFORD: u2 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// AWSCD7R
pub const AWSCD7R = Register(AWSCD7R_val).init(base_address + 0xe8);

/// CHWDAT7R
const CHWDAT7R_val = packed struct {
/// WDATA [0:15]
/// WDATA
WDATA: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// CHWDAT7R
pub const CHWDAT7R = Register(CHWDAT7R_val).init(base_address + 0xec);

/// CHDATIN7R
const CHDATIN7R_val = packed struct {
/// INDAT0 [0:15]
/// INDAT0
INDAT0: u16 = 0,
/// INDAT1 [16:31]
/// INDAT1
INDAT1: u16 = 0,
};
/// CHDATIN7R
pub const CHDATIN7R = Register(CHDATIN7R_val).init(base_address + 0xf0);

/// DFSDM0_CR1
const DFSDM0_CR1_val = packed struct {
/// DFEN [0:0]
/// DFSDM enable
DFEN: u1 = 0,
/// JSWSTART [1:1]
/// Start a conversion of the injected group
JSWSTART: u1 = 0,
/// unused [2:2]
_unused2: u1 = 0,
/// JSYNC [3:3]
/// Launch an injected conversion
JSYNC: u1 = 0,
/// JSCAN [4:4]
/// Scanning conversion mode for injected
JSCAN: u1 = 0,
/// JDMAEN [5:5]
/// DMA channel enabled to read data for the
JDMAEN: u1 = 0,
/// unused [6:7]
_unused6: u2 = 0,
/// JEXTSEL [8:10]
/// Trigger signal selection for launching
JEXTSEL: u3 = 0,
/// unused [11:12]
_unused11: u2 = 0,
/// JEXTEN [13:14]
/// Trigger enable and trigger edge
JEXTEN: u2 = 0,
/// unused [15:16]
_unused15: u1 = 0,
_unused16: u1 = 0,
/// RSWSTART [17:17]
/// Software start of a conversion on the
RSWSTART: u1 = 0,
/// RCONT [18:18]
/// Continuous mode selection for regular
RCONT: u1 = 0,
/// RSYNC [19:19]
/// Launch regular conversion synchronously
RSYNC: u1 = 0,
/// unused [20:20]
_unused20: u1 = 0,
/// RDMAEN [21:21]
/// DMA channel enabled to read data for the
RDMAEN: u1 = 0,
/// unused [22:23]
_unused22: u2 = 0,
/// RCH [24:26]
/// Regular channel selection
RCH: u3 = 0,
/// unused [27:28]
_unused27: u2 = 0,
/// FAST [29:29]
/// Fast conversion mode selection for
FAST: u1 = 0,
/// AWFSEL [30:30]
/// Analog watchdog fast mode
AWFSEL: u1 = 0,
/// unused [31:31]
_unused31: u1 = 0,
};
/// control register 1
pub const DFSDM0_CR1 = Register(DFSDM0_CR1_val).init(base_address + 0x100);

/// DFSDM0_CR2
const DFSDM0_CR2_val = packed struct {
/// JEOCIE [0:0]
/// Injected end of conversion interrupt
JEOCIE: u1 = 0,
/// REOCIE [1:1]
/// Regular end of conversion interrupt
REOCIE: u1 = 0,
/// JOVRIE [2:2]
/// Injected data overrun interrupt
JOVRIE: u1 = 0,
/// ROVRIE [3:3]
/// Regular data overrun interrupt
ROVRIE: u1 = 0,
/// AWDIE [4:4]
/// Analog watchdog interrupt
AWDIE: u1 = 0,
/// SCDIE [5:5]
/// Short-circuit detector interrupt
SCDIE: u1 = 0,
/// CKABIE [6:6]
/// Clock absence interrupt
CKABIE: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// EXCH [8:15]
/// Extremes detector channel
EXCH: u8 = 0,
/// AWDCH [16:23]
/// Analog watchdog channel
AWDCH: u8 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// control register 2
pub const DFSDM0_CR2 = Register(DFSDM0_CR2_val).init(base_address + 0x104);

/// DFSDM0_ISR
const DFSDM0_ISR_val = packed struct {
/// JEOCF [0:0]
/// End of injected conversion
JEOCF: u1 = 0,
/// REOCF [1:1]
/// End of regular conversion
REOCF: u1 = 0,
/// JOVRF [2:2]
/// Injected conversion overrun
JOVRF: u1 = 0,
/// ROVRF [3:3]
/// Regular conversion overrun
ROVRF: u1 = 0,
/// AWDF [4:4]
/// Analog watchdog
AWDF: u1 = 0,
/// unused [5:12]
_unused5: u3 = 0,
_unused8: u5 = 0,
/// JCIP [13:13]
/// Injected conversion in progress
JCIP: u1 = 0,
/// RCIP [14:14]
/// Regular conversion in progress
RCIP: u1 = 0,
/// unused [15:15]
_unused15: u1 = 0,
/// CKABF [16:23]
/// Clock absence flag
CKABF: u8 = 255,
/// SCDF [24:31]
/// short-circuit detector
SCDF: u8 = 0,
};
/// interrupt and status register
pub const DFSDM0_ISR = Register(DFSDM0_ISR_val).init(base_address + 0x108);

/// DFSDM0_ICR
const DFSDM0_ICR_val = packed struct {
/// unused [0:1]
_unused0: u2 = 0,
/// CLRJOVRF [2:2]
/// Clear the injected conversion overrun
CLRJOVRF: u1 = 0,
/// CLRROVRF [3:3]
/// Clear the regular conversion overrun
CLRROVRF: u1 = 0,
/// unused [4:15]
_unused4: u4 = 0,
_unused8: u8 = 0,
/// CLRCKABF [16:23]
/// Clear the clock absence
CLRCKABF: u8 = 0,
/// CLRSCDF [24:31]
/// Clear the short-circuit detector
CLRSCDF: u8 = 0,
};
/// interrupt flag clear register
pub const DFSDM0_ICR = Register(DFSDM0_ICR_val).init(base_address + 0x10c);

/// DFSDM0_JCHGR
const DFSDM0_JCHGR_val = packed struct {
/// JCHG [0:7]
/// Injected channel group
JCHG: u8 = 1,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// injected channel group selection
pub const DFSDM0_JCHGR = Register(DFSDM0_JCHGR_val).init(base_address + 0x110);

/// DFSDM0_FCR
const DFSDM0_FCR_val = packed struct {
/// IOSR [0:7]
/// Integrator oversampling ratio (averaging
IOSR: u8 = 0,
/// unused [8:15]
_unused8: u8 = 0,
/// FOSR [16:25]
/// Sinc filter oversampling ratio
FOSR: u10 = 0,
/// unused [26:28]
_unused26: u3 = 0,
/// FORD [29:31]
/// Sinc filter order
FORD: u3 = 0,
};
/// filter control register
pub const DFSDM0_FCR = Register(DFSDM0_FCR_val).init(base_address + 0x114);

/// DFSDM0_JDATAR
const DFSDM0_JDATAR_val = packed struct {
/// JDATACH [0:2]
/// Injected channel most recently
JDATACH: u3 = 0,
/// unused [3:7]
_unused3: u5 = 0,
/// JDATA [8:31]
/// Injected group conversion
JDATA: u24 = 0,
};
/// data register for injected
pub const DFSDM0_JDATAR = Register(DFSDM0_JDATAR_val).init(base_address + 0x118);

/// DFSDM0_RDATAR
const DFSDM0_RDATAR_val = packed struct {
/// RDATACH [0:2]
/// Regular channel most recently
RDATACH: u3 = 0,
/// unused [3:3]
_unused3: u1 = 0,
/// RPEND [4:4]
/// Regular channel pending
RPEND: u1 = 0,
/// unused [5:7]
_unused5: u3 = 0,
/// RDATA [8:31]
/// Regular channel conversion
RDATA: u24 = 0,
};
/// data register for the regular
pub const DFSDM0_RDATAR = Register(DFSDM0_RDATAR_val).init(base_address + 0x11c);

/// DFSDM0_AWHTR
const DFSDM0_AWHTR_val = packed struct {
/// BKAWH [0:3]
/// Break signal assignment to analog
BKAWH: u4 = 0,
/// unused [4:7]
_unused4: u4 = 0,
/// AWHT [8:31]
/// Analog watchdog high
AWHT: u24 = 0,
};
/// analog watchdog high threshold
pub const DFSDM0_AWHTR = Register(DFSDM0_AWHTR_val).init(base_address + 0x120);

/// DFSDM0_AWLTR
const DFSDM0_AWLTR_val = packed struct {
/// BKAWL [0:3]
/// Break signal assignment to analog
BKAWL: u4 = 0,
/// unused [4:7]
_unused4: u4 = 0,
/// AWLT [8:31]
/// Analog watchdog low
AWLT: u24 = 0,
};
/// analog watchdog low threshold
pub const DFSDM0_AWLTR = Register(DFSDM0_AWLTR_val).init(base_address + 0x124);

/// DFSDM0_AWSR
const DFSDM0_AWSR_val = packed struct {
/// AWLTF [0:7]
/// Analog watchdog low threshold
AWLTF: u8 = 0,
/// AWHTF [8:15]
/// Analog watchdog high threshold
AWHTF: u8 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// analog watchdog status
pub const DFSDM0_AWSR = Register(DFSDM0_AWSR_val).init(base_address + 0x128);

/// DFSDM0_AWCFR
const DFSDM0_AWCFR_val = packed struct {
/// CLRAWLTF [0:7]
/// Clear the analog watchdog low threshold
CLRAWLTF: u8 = 0,
/// CLRAWHTF [8:15]
/// Clear the analog watchdog high threshold
CLRAWHTF: u8 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// analog watchdog clear flag
pub const DFSDM0_AWCFR = Register(DFSDM0_AWCFR_val).init(base_address + 0x12c);

/// DFSDM0_EXMAX
const DFSDM0_EXMAX_val = packed struct {
/// EXMAXCH [0:2]
/// Extremes detector maximum data
EXMAXCH: u3 = 0,
/// unused [3:7]
_unused3: u5 = 0,
/// EXMAX [8:31]
/// Extremes detector maximum
EXMAX: u24 = 8388608,
};
/// Extremes detector maximum
pub const DFSDM0_EXMAX = Register(DFSDM0_EXMAX_val).init(base_address + 0x130);

/// DFSDM0_EXMIN
const DFSDM0_EXMIN_val = packed struct {
/// EXMINCH [0:2]
/// Extremes detector minimum data
EXMINCH: u3 = 0,
/// unused [3:7]
_unused3: u5 = 0,
/// EXMIN [8:31]
/// EXMIN
EXMIN: u24 = 8388607,
};
/// Extremes detector minimum
pub const DFSDM0_EXMIN = Register(DFSDM0_EXMIN_val).init(base_address + 0x134);

/// DFSDM0_CNVTIMR
const DFSDM0_CNVTIMR_val = packed struct {
/// unused [0:3]
_unused0: u4 = 0,
/// CNVCNT [4:31]
/// 28-bit timer counting conversion time t
CNVCNT: u28 = 0,
};
/// conversion timer register
pub const DFSDM0_CNVTIMR = Register(DFSDM0_CNVTIMR_val).init(base_address + 0x138);

/// DFSDM1_CR1
const DFSDM1_CR1_val = packed struct {
/// DFEN [0:0]
/// DFSDM enable
DFEN: u1 = 0,
/// JSWSTART [1:1]
/// Start a conversion of the injected group
JSWSTART: u1 = 0,
/// unused [2:2]
_unused2: u1 = 0,
/// JSYNC [3:3]
/// Launch an injected conversion
JSYNC: u1 = 0,
/// JSCAN [4:4]
/// Scanning conversion mode for injected
JSCAN: u1 = 0,
/// JDMAEN [5:5]
/// DMA channel enabled to read data for the
JDMAEN: u1 = 0,
/// unused [6:7]
_unused6: u2 = 0,
/// JEXTSEL [8:10]
/// Trigger signal selection for launching
JEXTSEL: u3 = 0,
/// unused [11:12]
_unused11: u2 = 0,
/// JEXTEN [13:14]
/// Trigger enable and trigger edge
JEXTEN: u2 = 0,
/// unused [15:16]
_unused15: u1 = 0,
_unused16: u1 = 0,
/// RSWSTART [17:17]
/// Software start of a conversion on the
RSWSTART: u1 = 0,
/// RCONT [18:18]
/// Continuous mode selection for regular
RCONT: u1 = 0,
/// RSYNC [19:19]
/// Launch regular conversion synchronously
RSYNC: u1 = 0,
/// unused [20:20]
_unused20: u1 = 0,
/// RDMAEN [21:21]
/// DMA channel enabled to read data for the
RDMAEN: u1 = 0,
/// unused [22:23]
_unused22: u2 = 0,
/// RCH [24:26]
/// Regular channel selection
RCH: u3 = 0,
/// unused [27:28]
_unused27: u2 = 0,
/// FAST [29:29]
/// Fast conversion mode selection for
FAST: u1 = 0,
/// AWFSEL [30:30]
/// Analog watchdog fast mode
AWFSEL: u1 = 0,
/// unused [31:31]
_unused31: u1 = 0,
};
/// control register 1
pub const DFSDM1_CR1 = Register(DFSDM1_CR1_val).init(base_address + 0x200);

/// DFSDM1_CR2
const DFSDM1_CR2_val = packed struct {
/// JEOCIE [0:0]
/// Injected end of conversion interrupt
JEOCIE: u1 = 0,
/// REOCIE [1:1]
/// Regular end of conversion interrupt
REOCIE: u1 = 0,
/// JOVRIE [2:2]
/// Injected data overrun interrupt
JOVRIE: u1 = 0,
/// ROVRIE [3:3]
/// Regular data overrun interrupt
ROVRIE: u1 = 0,
/// AWDIE [4:4]
/// Analog watchdog interrupt
AWDIE: u1 = 0,
/// SCDIE [5:5]
/// Short-circuit detector interrupt
SCDIE: u1 = 0,
/// CKABIE [6:6]
/// Clock absence interrupt
CKABIE: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// EXCH [8:15]
/// Extremes detector channel
EXCH: u8 = 0,
/// AWDCH [16:23]
/// Analog watchdog channel
AWDCH: u8 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// control register 2
pub const DFSDM1_CR2 = Register(DFSDM1_CR2_val).init(base_address + 0x204);

/// DFSDM1_ISR
const DFSDM1_ISR_val = packed struct {
/// JEOCF [0:0]
/// End of injected conversion
JEOCF: u1 = 0,
/// REOCF [1:1]
/// End of regular conversion
REOCF: u1 = 0,
/// JOVRF [2:2]
/// Injected conversion overrun
JOVRF: u1 = 0,
/// ROVRF [3:3]
/// Regular conversion overrun
ROVRF: u1 = 0,
/// AWDF [4:4]
/// Analog watchdog
AWDF: u1 = 0,
/// unused [5:12]
_unused5: u3 = 0,
_unused8: u5 = 0,
/// JCIP [13:13]
/// Injected conversion in progress
JCIP: u1 = 0,
/// RCIP [14:14]
/// Regular conversion in progress
RCIP: u1 = 0,
/// unused [15:15]
_unused15: u1 = 0,
/// CKABF [16:23]
/// Clock absence flag
CKABF: u8 = 255,
/// SCDF [24:31]
/// short-circuit detector
SCDF: u8 = 0,
};
/// interrupt and status register
pub const DFSDM1_ISR = Register(DFSDM1_ISR_val).init(base_address + 0x208);

/// DFSDM1_ICR
const DFSDM1_ICR_val = packed struct {
/// unused [0:1]
_unused0: u2 = 0,
/// CLRJOVRF [2:2]
/// Clear the injected conversion overrun
CLRJOVRF: u1 = 0,
/// CLRROVRF [3:3]
/// Clear the regular conversion overrun
CLRROVRF: u1 = 0,
/// unused [4:15]
_unused4: u4 = 0,
_unused8: u8 = 0,
/// CLRCKABF [16:23]
/// Clear the clock absence
CLRCKABF: u8 = 0,
/// CLRSCDF [24:31]
/// Clear the short-circuit detector
CLRSCDF: u8 = 0,
};
/// interrupt flag clear register
pub const DFSDM1_ICR = Register(DFSDM1_ICR_val).init(base_address + 0x20c);

/// DFSDM1_JCHGR
const DFSDM1_JCHGR_val = packed struct {
/// JCHG [0:7]
/// Injected channel group
JCHG: u8 = 1,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// injected channel group selection
pub const DFSDM1_JCHGR = Register(DFSDM1_JCHGR_val).init(base_address + 0x210);

/// DFSDM1_FCR
const DFSDM1_FCR_val = packed struct {
/// IOSR [0:7]
/// Integrator oversampling ratio (averaging
IOSR: u8 = 0,
/// unused [8:15]
_unused8: u8 = 0,
/// FOSR [16:25]
/// Sinc filter oversampling ratio
FOSR: u10 = 0,
/// unused [26:28]
_unused26: u3 = 0,
/// FORD [29:31]
/// Sinc filter order
FORD: u3 = 0,
};
/// filter control register
pub const DFSDM1_FCR = Register(DFSDM1_FCR_val).init(base_address + 0x214);

/// DFSDM1_JDATAR
const DFSDM1_JDATAR_val = packed struct {
/// JDATACH [0:2]
/// Injected channel most recently
JDATACH: u3 = 0,
/// unused [3:7]
_unused3: u5 = 0,
/// JDATA [8:31]
/// Injected group conversion
JDATA: u24 = 0,
};
/// data register for injected
pub const DFSDM1_JDATAR = Register(DFSDM1_JDATAR_val).init(base_address + 0x218);

/// DFSDM1_RDATAR
const DFSDM1_RDATAR_val = packed struct {
/// RDATACH [0:2]
/// Regular channel most recently
RDATACH: u3 = 0,
/// unused [3:3]
_unused3: u1 = 0,
/// RPEND [4:4]
/// Regular channel pending
RPEND: u1 = 0,
/// unused [5:7]
_unused5: u3 = 0,
/// RDATA [8:31]
/// Regular channel conversion
RDATA: u24 = 0,
};
/// data register for the regular
pub const DFSDM1_RDATAR = Register(DFSDM1_RDATAR_val).init(base_address + 0x21c);

/// DFSDM1_AWHTR
const DFSDM1_AWHTR_val = packed struct {
/// BKAWH [0:3]
/// Break signal assignment to analog
BKAWH: u4 = 0,
/// unused [4:7]
_unused4: u4 = 0,
/// AWHT [8:31]
/// Analog watchdog high
AWHT: u24 = 0,
};
/// analog watchdog high threshold
pub const DFSDM1_AWHTR = Register(DFSDM1_AWHTR_val).init(base_address + 0x220);

/// DFSDM1_AWLTR
const DFSDM1_AWLTR_val = packed struct {
/// BKAWL [0:3]
/// Break signal assignment to analog
BKAWL: u4 = 0,
/// unused [4:7]
_unused4: u4 = 0,
/// AWLT [8:31]
/// Analog watchdog low
AWLT: u24 = 0,
};
/// analog watchdog low threshold
pub const DFSDM1_AWLTR = Register(DFSDM1_AWLTR_val).init(base_address + 0x224);

/// DFSDM1_AWSR
const DFSDM1_AWSR_val = packed struct {
/// AWLTF [0:7]
/// Analog watchdog low threshold
AWLTF: u8 = 0,
/// AWHTF [8:15]
/// Analog watchdog high threshold
AWHTF: u8 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// analog watchdog status
pub const DFSDM1_AWSR = Register(DFSDM1_AWSR_val).init(base_address + 0x228);

/// DFSDM1_AWCFR
const DFSDM1_AWCFR_val = packed struct {
/// CLRAWLTF [0:7]
/// Clear the analog watchdog low threshold
CLRAWLTF: u8 = 0,
/// CLRAWHTF [8:15]
/// Clear the analog watchdog high threshold
CLRAWHTF: u8 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// analog watchdog clear flag
pub const DFSDM1_AWCFR = Register(DFSDM1_AWCFR_val).init(base_address + 0x22c);

/// DFSDM1_EXMAX
const DFSDM1_EXMAX_val = packed struct {
/// EXMAXCH [0:2]
/// Extremes detector maximum data
EXMAXCH: u3 = 0,
/// unused [3:7]
_unused3: u5 = 0,
/// EXMAX [8:31]
/// Extremes detector maximum
EXMAX: u24 = 8388608,
};
/// Extremes detector maximum
pub const DFSDM1_EXMAX = Register(DFSDM1_EXMAX_val).init(base_address + 0x230);

/// DFSDM1_EXMIN
const DFSDM1_EXMIN_val = packed struct {
/// EXMINCH [0:2]
/// Extremes detector minimum data
EXMINCH: u3 = 0,
/// unused [3:7]
_unused3: u5 = 0,
/// EXMIN [8:31]
/// EXMIN
EXMIN: u24 = 8388607,
};
/// Extremes detector minimum
pub const DFSDM1_EXMIN = Register(DFSDM1_EXMIN_val).init(base_address + 0x234);

/// DFSDM1_CNVTIMR
const DFSDM1_CNVTIMR_val = packed struct {
/// unused [0:3]
_unused0: u4 = 0,
/// CNVCNT [4:31]
/// 28-bit timer counting conversion time t
CNVCNT: u28 = 0,
};
/// conversion timer register
pub const DFSDM1_CNVTIMR = Register(DFSDM1_CNVTIMR_val).init(base_address + 0x238);

/// DFSDM2_CR1
const DFSDM2_CR1_val = packed struct {
/// DFEN [0:0]
/// DFSDM enable
DFEN: u1 = 0,
/// JSWSTART [1:1]
/// Start a conversion of the injected group
JSWSTART: u1 = 0,
/// unused [2:2]
_unused2: u1 = 0,
/// JSYNC [3:3]
/// Launch an injected conversion
JSYNC: u1 = 0,
/// JSCAN [4:4]
/// Scanning conversion mode for injected
JSCAN: u1 = 0,
/// JDMAEN [5:5]
/// DMA channel enabled to read data for the
JDMAEN: u1 = 0,
/// unused [6:7]
_unused6: u2 = 0,
/// JEXTSEL [8:10]
/// Trigger signal selection for launching
JEXTSEL: u3 = 0,
/// unused [11:12]
_unused11: u2 = 0,
/// JEXTEN [13:14]
/// Trigger enable and trigger edge
JEXTEN: u2 = 0,
/// unused [15:16]
_unused15: u1 = 0,
_unused16: u1 = 0,
/// RSWSTART [17:17]
/// Software start of a conversion on the
RSWSTART: u1 = 0,
/// RCONT [18:18]
/// Continuous mode selection for regular
RCONT: u1 = 0,
/// RSYNC [19:19]
/// Launch regular conversion synchronously
RSYNC: u1 = 0,
/// unused [20:20]
_unused20: u1 = 0,
/// RDMAEN [21:21]
/// DMA channel enabled to read data for the
RDMAEN: u1 = 0,
/// unused [22:23]
_unused22: u2 = 0,
/// RCH [24:26]
/// Regular channel selection
RCH: u3 = 0,
/// unused [27:28]
_unused27: u2 = 0,
/// FAST [29:29]
/// Fast conversion mode selection for
FAST: u1 = 0,
/// AWFSEL [30:30]
/// Analog watchdog fast mode
AWFSEL: u1 = 0,
/// unused [31:31]
_unused31: u1 = 0,
};
/// control register 1
pub const DFSDM2_CR1 = Register(DFSDM2_CR1_val).init(base_address + 0x300);

/// DFSDM2_CR2
const DFSDM2_CR2_val = packed struct {
/// JEOCIE [0:0]
/// Injected end of conversion interrupt
JEOCIE: u1 = 0,
/// REOCIE [1:1]
/// Regular end of conversion interrupt
REOCIE: u1 = 0,
/// JOVRIE [2:2]
/// Injected data overrun interrupt
JOVRIE: u1 = 0,
/// ROVRIE [3:3]
/// Regular data overrun interrupt
ROVRIE: u1 = 0,
/// AWDIE [4:4]
/// Analog watchdog interrupt
AWDIE: u1 = 0,
/// SCDIE [5:5]
/// Short-circuit detector interrupt
SCDIE: u1 = 0,
/// CKABIE [6:6]
/// Clock absence interrupt
CKABIE: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// EXCH [8:15]
/// Extremes detector channel
EXCH: u8 = 0,
/// AWDCH [16:23]
/// Analog watchdog channel
AWDCH: u8 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// control register 2
pub const DFSDM2_CR2 = Register(DFSDM2_CR2_val).init(base_address + 0x304);

/// DFSDM2_ISR
const DFSDM2_ISR_val = packed struct {
/// JEOCF [0:0]
/// End of injected conversion
JEOCF: u1 = 0,
/// REOCF [1:1]
/// End of regular conversion
REOCF: u1 = 0,
/// JOVRF [2:2]
/// Injected conversion overrun
JOVRF: u1 = 0,
/// ROVRF [3:3]
/// Regular conversion overrun
ROVRF: u1 = 0,
/// AWDF [4:4]
/// Analog watchdog
AWDF: u1 = 0,
/// unused [5:12]
_unused5: u3 = 0,
_unused8: u5 = 0,
/// JCIP [13:13]
/// Injected conversion in progress
JCIP: u1 = 0,
/// RCIP [14:14]
/// Regular conversion in progress
RCIP: u1 = 0,
/// unused [15:15]
_unused15: u1 = 0,
/// CKABF [16:23]
/// Clock absence flag
CKABF: u8 = 255,
/// SCDF [24:31]
/// short-circuit detector
SCDF: u8 = 0,
};
/// interrupt and status register
pub const DFSDM2_ISR = Register(DFSDM2_ISR_val).init(base_address + 0x308);

/// DFSDM2_ICR
const DFSDM2_ICR_val = packed struct {
/// unused [0:1]
_unused0: u2 = 0,
/// CLRJOVRF [2:2]
/// Clear the injected conversion overrun
CLRJOVRF: u1 = 0,
/// CLRROVRF [3:3]
/// Clear the regular conversion overrun
CLRROVRF: u1 = 0,
/// unused [4:15]
_unused4: u4 = 0,
_unused8: u8 = 0,
/// CLRCKABF [16:23]
/// Clear the clock absence
CLRCKABF: u8 = 0,
/// CLRSCDF [24:31]
/// Clear the short-circuit detector
CLRSCDF: u8 = 0,
};
/// interrupt flag clear register
pub const DFSDM2_ICR = Register(DFSDM2_ICR_val).init(base_address + 0x30c);

/// DFSDM2_JCHGR
const DFSDM2_JCHGR_val = packed struct {
/// JCHG [0:7]
/// Injected channel group
JCHG: u8 = 1,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// injected channel group selection
pub const DFSDM2_JCHGR = Register(DFSDM2_JCHGR_val).init(base_address + 0x310);

/// DFSDM2_FCR
const DFSDM2_FCR_val = packed struct {
/// IOSR [0:7]
/// Integrator oversampling ratio (averaging
IOSR: u8 = 0,
/// unused [8:15]
_unused8: u8 = 0,
/// FOSR [16:25]
/// Sinc filter oversampling ratio
FOSR: u10 = 0,
/// unused [26:28]
_unused26: u3 = 0,
/// FORD [29:31]
/// Sinc filter order
FORD: u3 = 0,
};
/// filter control register
pub const DFSDM2_FCR = Register(DFSDM2_FCR_val).init(base_address + 0x314);

/// DFSDM2_JDATAR
const DFSDM2_JDATAR_val = packed struct {
/// JDATACH [0:2]
/// Injected channel most recently
JDATACH: u3 = 0,
/// unused [3:7]
_unused3: u5 = 0,
/// JDATA [8:31]
/// Injected group conversion
JDATA: u24 = 0,
};
/// data register for injected
pub const DFSDM2_JDATAR = Register(DFSDM2_JDATAR_val).init(base_address + 0x318);

/// DFSDM2_RDATAR
const DFSDM2_RDATAR_val = packed struct {
/// RDATACH [0:2]
/// Regular channel most recently
RDATACH: u3 = 0,
/// unused [3:3]
_unused3: u1 = 0,
/// RPEND [4:4]
/// Regular channel pending
RPEND: u1 = 0,
/// unused [5:7]
_unused5: u3 = 0,
/// RDATA [8:31]
/// Regular channel conversion
RDATA: u24 = 0,
};
/// data register for the regular
pub const DFSDM2_RDATAR = Register(DFSDM2_RDATAR_val).init(base_address + 0x31c);

/// DFSDM2_AWHTR
const DFSDM2_AWHTR_val = packed struct {
/// BKAWH [0:3]
/// Break signal assignment to analog
BKAWH: u4 = 0,
/// unused [4:7]
_unused4: u4 = 0,
/// AWHT [8:31]
/// Analog watchdog high
AWHT: u24 = 0,
};
/// analog watchdog high threshold
pub const DFSDM2_AWHTR = Register(DFSDM2_AWHTR_val).init(base_address + 0x320);

/// DFSDM2_AWLTR
const DFSDM2_AWLTR_val = packed struct {
/// BKAWL [0:3]
/// Break signal assignment to analog
BKAWL: u4 = 0,
/// unused [4:7]
_unused4: u4 = 0,
/// AWLT [8:31]
/// Analog watchdog low
AWLT: u24 = 0,
};
/// analog watchdog low threshold
pub const DFSDM2_AWLTR = Register(DFSDM2_AWLTR_val).init(base_address + 0x324);

/// DFSDM2_AWSR
const DFSDM2_AWSR_val = packed struct {
/// AWLTF [0:7]
/// Analog watchdog low threshold
AWLTF: u8 = 0,
/// AWHTF [8:15]
/// Analog watchdog high threshold
AWHTF: u8 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// analog watchdog status
pub const DFSDM2_AWSR = Register(DFSDM2_AWSR_val).init(base_address + 0x328);

/// DFSDM2_AWCFR
const DFSDM2_AWCFR_val = packed struct {
/// CLRAWLTF [0:7]
/// Clear the analog watchdog low threshold
CLRAWLTF: u8 = 0,
/// CLRAWHTF [8:15]
/// Clear the analog watchdog high threshold
CLRAWHTF: u8 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// analog watchdog clear flag
pub const DFSDM2_AWCFR = Register(DFSDM2_AWCFR_val).init(base_address + 0x32c);

/// DFSDM2_EXMAX
const DFSDM2_EXMAX_val = packed struct {
/// EXMAXCH [0:2]
/// Extremes detector maximum data
EXMAXCH: u3 = 0,
/// unused [3:7]
_unused3: u5 = 0,
/// EXMAX [8:31]
/// Extremes detector maximum
EXMAX: u24 = 8388608,
};
/// Extremes detector maximum
pub const DFSDM2_EXMAX = Register(DFSDM2_EXMAX_val).init(base_address + 0x330);

/// DFSDM2_EXMIN
const DFSDM2_EXMIN_val = packed struct {
/// EXMINCH [0:2]
/// Extremes detector minimum data
EXMINCH: u3 = 0,
/// unused [3:7]
_unused3: u5 = 0,
/// EXMIN [8:31]
/// EXMIN
EXMIN: u24 = 8388607,
};
/// Extremes detector minimum
pub const DFSDM2_EXMIN = Register(DFSDM2_EXMIN_val).init(base_address + 0x334);

/// DFSDM2_CNVTIMR
const DFSDM2_CNVTIMR_val = packed struct {
/// unused [0:3]
_unused0: u4 = 0,
/// CNVCNT [4:31]
/// 28-bit timer counting conversion time t
CNVCNT: u28 = 0,
};
/// conversion timer register
pub const DFSDM2_CNVTIMR = Register(DFSDM2_CNVTIMR_val).init(base_address + 0x338);

/// DFSDM3_CR1
const DFSDM3_CR1_val = packed struct {
/// DFEN [0:0]
/// DFSDM enable
DFEN: u1 = 0,
/// JSWSTART [1:1]
/// Start a conversion of the injected group
JSWSTART: u1 = 0,
/// unused [2:2]
_unused2: u1 = 0,
/// JSYNC [3:3]
/// Launch an injected conversion
JSYNC: u1 = 0,
/// JSCAN [4:4]
/// Scanning conversion mode for injected
JSCAN: u1 = 0,
/// JDMAEN [5:5]
/// DMA channel enabled to read data for the
JDMAEN: u1 = 0,
/// unused [6:7]
_unused6: u2 = 0,
/// JEXTSEL [8:10]
/// Trigger signal selection for launching
JEXTSEL: u3 = 0,
/// unused [11:12]
_unused11: u2 = 0,
/// JEXTEN [13:14]
/// Trigger enable and trigger edge
JEXTEN: u2 = 0,
/// unused [15:16]
_unused15: u1 = 0,
_unused16: u1 = 0,
/// RSWSTART [17:17]
/// Software start of a conversion on the
RSWSTART: u1 = 0,
/// RCONT [18:18]
/// Continuous mode selection for regular
RCONT: u1 = 0,
/// RSYNC [19:19]
/// Launch regular conversion synchronously
RSYNC: u1 = 0,
/// unused [20:20]
_unused20: u1 = 0,
/// RDMAEN [21:21]
/// DMA channel enabled to read data for the
RDMAEN: u1 = 0,
/// unused [22:23]
_unused22: u2 = 0,
/// RCH [24:26]
/// Regular channel selection
RCH: u3 = 0,
/// unused [27:28]
_unused27: u2 = 0,
/// FAST [29:29]
/// Fast conversion mode selection for
FAST: u1 = 0,
/// AWFSEL [30:30]
/// Analog watchdog fast mode
AWFSEL: u1 = 0,
/// unused [31:31]
_unused31: u1 = 0,
};
/// control register 1
pub const DFSDM3_CR1 = Register(DFSDM3_CR1_val).init(base_address + 0x400);

/// DFSDM3_CR2
const DFSDM3_CR2_val = packed struct {
/// JEOCIE [0:0]
/// Injected end of conversion interrupt
JEOCIE: u1 = 0,
/// REOCIE [1:1]
/// Regular end of conversion interrupt
REOCIE: u1 = 0,
/// JOVRIE [2:2]
/// Injected data overrun interrupt
JOVRIE: u1 = 0,
/// ROVRIE [3:3]
/// Regular data overrun interrupt
ROVRIE: u1 = 0,
/// AWDIE [4:4]
/// Analog watchdog interrupt
AWDIE: u1 = 0,
/// SCDIE [5:5]
/// Short-circuit detector interrupt
SCDIE: u1 = 0,
/// CKABIE [6:6]
/// Clock absence interrupt
CKABIE: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// EXCH [8:15]
/// Extremes detector channel
EXCH: u8 = 0,
/// AWDCH [16:23]
/// Analog watchdog channel
AWDCH: u8 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// control register 2
pub const DFSDM3_CR2 = Register(DFSDM3_CR2_val).init(base_address + 0x404);

/// DFSDM3_ISR
const DFSDM3_ISR_val = packed struct {
/// JEOCF [0:0]
/// End of injected conversion
JEOCF: u1 = 0,
/// REOCF [1:1]
/// End of regular conversion
REOCF: u1 = 0,
/// JOVRF [2:2]
/// Injected conversion overrun
JOVRF: u1 = 0,
/// ROVRF [3:3]
/// Regular conversion overrun
ROVRF: u1 = 0,
/// AWDF [4:4]
/// Analog watchdog
AWDF: u1 = 0,
/// unused [5:12]
_unused5: u3 = 0,
_unused8: u5 = 0,
/// JCIP [13:13]
/// Injected conversion in progress
JCIP: u1 = 0,
/// RCIP [14:14]
/// Regular conversion in progress
RCIP: u1 = 0,
/// unused [15:15]
_unused15: u1 = 0,
/// CKABF [16:23]
/// Clock absence flag
CKABF: u8 = 255,
/// SCDF [24:31]
/// short-circuit detector
SCDF: u8 = 0,
};
/// interrupt and status register
pub const DFSDM3_ISR = Register(DFSDM3_ISR_val).init(base_address + 0x408);

/// DFSDM3_ICR
const DFSDM3_ICR_val = packed struct {
/// unused [0:1]
_unused0: u2 = 0,
/// CLRJOVRF [2:2]
/// Clear the injected conversion overrun
CLRJOVRF: u1 = 0,
/// CLRROVRF [3:3]
/// Clear the regular conversion overrun
CLRROVRF: u1 = 0,
/// unused [4:15]
_unused4: u4 = 0,
_unused8: u8 = 0,
/// CLRCKABF [16:23]
/// Clear the clock absence
CLRCKABF: u8 = 0,
/// CLRSCDF [24:31]
/// Clear the short-circuit detector
CLRSCDF: u8 = 0,
};
/// interrupt flag clear register
pub const DFSDM3_ICR = Register(DFSDM3_ICR_val).init(base_address + 0x40c);

/// DFSDM3_JCHGR
const DFSDM3_JCHGR_val = packed struct {
/// JCHG [0:7]
/// Injected channel group
JCHG: u8 = 1,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// injected channel group selection
pub const DFSDM3_JCHGR = Register(DFSDM3_JCHGR_val).init(base_address + 0x410);

/// DFSDM3_FCR
const DFSDM3_FCR_val = packed struct {
/// IOSR [0:7]
/// Integrator oversampling ratio (averaging
IOSR: u8 = 0,
/// unused [8:15]
_unused8: u8 = 0,
/// FOSR [16:25]
/// Sinc filter oversampling ratio
FOSR: u10 = 0,
/// unused [26:28]
_unused26: u3 = 0,
/// FORD [29:31]
/// Sinc filter order
FORD: u3 = 0,
};
/// filter control register
pub const DFSDM3_FCR = Register(DFSDM3_FCR_val).init(base_address + 0x414);

/// DFSDM3_JDATAR
const DFSDM3_JDATAR_val = packed struct {
/// JDATACH [0:2]
/// Injected channel most recently
JDATACH: u3 = 0,
/// unused [3:7]
_unused3: u5 = 0,
/// JDATA [8:31]
/// Injected group conversion
JDATA: u24 = 0,
};
/// data register for injected
pub const DFSDM3_JDATAR = Register(DFSDM3_JDATAR_val).init(base_address + 0x418);

/// DFSDM3_RDATAR
const DFSDM3_RDATAR_val = packed struct {
/// RDATACH [0:2]
/// Regular channel most recently
RDATACH: u3 = 0,
/// unused [3:3]
_unused3: u1 = 0,
/// RPEND [4:4]
/// Regular channel pending
RPEND: u1 = 0,
/// unused [5:7]
_unused5: u3 = 0,
/// RDATA [8:31]
/// Regular channel conversion
RDATA: u24 = 0,
};
/// data register for the regular
pub const DFSDM3_RDATAR = Register(DFSDM3_RDATAR_val).init(base_address + 0x41c);

/// DFSDM3_AWHTR
const DFSDM3_AWHTR_val = packed struct {
/// BKAWH [0:3]
/// Break signal assignment to analog
BKAWH: u4 = 0,
/// unused [4:7]
_unused4: u4 = 0,
/// AWHT [8:31]
/// Analog watchdog high
AWHT: u24 = 0,
};
/// analog watchdog high threshold
pub const DFSDM3_AWHTR = Register(DFSDM3_AWHTR_val).init(base_address + 0x420);

/// DFSDM3_AWLTR
const DFSDM3_AWLTR_val = packed struct {
/// BKAWL [0:3]
/// Break signal assignment to analog
BKAWL: u4 = 0,
/// unused [4:7]
_unused4: u4 = 0,
/// AWLT [8:31]
/// Analog watchdog low
AWLT: u24 = 0,
};
/// analog watchdog low threshold
pub const DFSDM3_AWLTR = Register(DFSDM3_AWLTR_val).init(base_address + 0x424);

/// DFSDM3_AWSR
const DFSDM3_AWSR_val = packed struct {
/// AWLTF [0:7]
/// Analog watchdog low threshold
AWLTF: u8 = 0,
/// AWHTF [8:15]
/// Analog watchdog high threshold
AWHTF: u8 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// analog watchdog status
pub const DFSDM3_AWSR = Register(DFSDM3_AWSR_val).init(base_address + 0x428);

/// DFSDM3_AWCFR
const DFSDM3_AWCFR_val = packed struct {
/// CLRAWLTF [0:7]
/// Clear the analog watchdog low threshold
CLRAWLTF: u8 = 0,
/// CLRAWHTF [8:15]
/// Clear the analog watchdog high threshold
CLRAWHTF: u8 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// analog watchdog clear flag
pub const DFSDM3_AWCFR = Register(DFSDM3_AWCFR_val).init(base_address + 0x42c);

/// DFSDM3_EXMAX
const DFSDM3_EXMAX_val = packed struct {
/// EXMAXCH [0:2]
/// Extremes detector maximum data
EXMAXCH: u3 = 0,
/// unused [3:7]
_unused3: u5 = 0,
/// EXMAX [8:31]
/// Extremes detector maximum
EXMAX: u24 = 8388608,
};
/// Extremes detector maximum
pub const DFSDM3_EXMAX = Register(DFSDM3_EXMAX_val).init(base_address + 0x430);

/// DFSDM3_EXMIN
const DFSDM3_EXMIN_val = packed struct {
/// EXMINCH [0:2]
/// Extremes detector minimum data
EXMINCH: u3 = 0,
/// unused [3:7]
_unused3: u5 = 0,
/// EXMIN [8:31]
/// EXMIN
EXMIN: u24 = 8388607,
};
/// Extremes detector minimum
pub const DFSDM3_EXMIN = Register(DFSDM3_EXMIN_val).init(base_address + 0x434);

/// DFSDM3_CNVTIMR
const DFSDM3_CNVTIMR_val = packed struct {
/// unused [0:3]
_unused0: u4 = 0,
/// CNVCNT [4:31]
/// 28-bit timer counting conversion time t
CNVCNT: u28 = 0,
};
/// conversion timer register
pub const DFSDM3_CNVTIMR = Register(DFSDM3_CNVTIMR_val).init(base_address + 0x438);
};

/// QuadSPI interface
pub const QUADSPI = struct {

const base_address = 0xa0001000;
/// CR
const CR_val = packed struct {
/// EN [0:0]
/// Enable
EN: u1 = 0,
/// ABORT [1:1]
/// Abort request
ABORT: u1 = 0,
/// DMAEN [2:2]
/// DMA enable
DMAEN: u1 = 0,
/// TCEN [3:3]
/// Timeout counter enable
TCEN: u1 = 0,
/// SSHIFT [4:4]
/// Sample shift
SSHIFT: u1 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// DFM [6:6]
/// Dual-flash mode
DFM: u1 = 0,
/// FSEL [7:7]
/// FLASH memory selection
FSEL: u1 = 0,
/// FTHRES [8:12]
/// IFO threshold level
FTHRES: u5 = 0,
/// unused [13:15]
_unused13: u3 = 0,
/// TEIE [16:16]
/// Transfer error interrupt
TEIE: u1 = 0,
/// TCIE [17:17]
/// Transfer complete interrupt
TCIE: u1 = 0,
/// FTIE [18:18]
/// FIFO threshold interrupt
FTIE: u1 = 0,
/// SMIE [19:19]
/// Status match interrupt
SMIE: u1 = 0,
/// TOIE [20:20]
/// TimeOut interrupt enable
TOIE: u1 = 0,
/// unused [21:21]
_unused21: u1 = 0,
/// APMS [22:22]
/// Automatic poll mode stop
APMS: u1 = 0,
/// PMM [23:23]
/// Polling match mode
PMM: u1 = 0,
/// PRESCALER [24:31]
/// Clock prescaler
PRESCALER: u8 = 0,
};
/// control register
pub const CR = Register(CR_val).init(base_address + 0x0);

/// DCR
const DCR_val = packed struct {
/// CKMODE [0:0]
/// Mode 0 / mode 3
CKMODE: u1 = 0,
/// unused [1:7]
_unused1: u7 = 0,
/// CSHT [8:10]
/// Chip select high time
CSHT: u3 = 0,
/// unused [11:15]
_unused11: u5 = 0,
/// FSIZE [16:20]
/// FLASH memory size
FSIZE: u5 = 0,
/// unused [21:31]
_unused21: u3 = 0,
_unused24: u8 = 0,
};
/// device configuration register
pub const DCR = Register(DCR_val).init(base_address + 0x4);

/// SR
const SR_val = packed struct {
/// TEF [0:0]
/// Transfer error flag
TEF: u1 = 0,
/// TCF [1:1]
/// Transfer complete flag
TCF: u1 = 0,
/// FTF [2:2]
/// FIFO threshold flag
FTF: u1 = 0,
/// SMF [3:3]
/// Status match flag
SMF: u1 = 0,
/// TOF [4:4]
/// Timeout flag
TOF: u1 = 0,
/// BUSY [5:5]
/// Busy
BUSY: u1 = 0,
/// unused [6:7]
_unused6: u2 = 0,
/// FLEVEL [8:14]
/// FIFO level
FLEVEL: u7 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// status register
pub const SR = Register(SR_val).init(base_address + 0x8);

/// FCR
const FCR_val = packed struct {
/// CTEF [0:0]
/// Clear transfer error flag
CTEF: u1 = 0,
/// CTCF [1:1]
/// Clear transfer complete
CTCF: u1 = 0,
/// unused [2:2]
_unused2: u1 = 0,
/// CSMF [3:3]
/// Clear status match flag
CSMF: u1 = 0,
/// CTOF [4:4]
/// Clear timeout flag
CTOF: u1 = 0,
/// unused [5:31]
_unused5: u3 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// flag clear register
pub const FCR = Register(FCR_val).init(base_address + 0xc);

/// DLR
const DLR_val = packed struct {
/// DL [0:31]
/// Data length
DL: u32 = 0,
};
/// data length register
pub const DLR = Register(DLR_val).init(base_address + 0x10);

/// CCR
const CCR_val = packed struct {
/// INSTRUCTION [0:7]
/// Instruction
INSTRUCTION: u8 = 0,
/// IMODE [8:9]
/// Instruction mode
IMODE: u2 = 0,
/// ADMODE [10:11]
/// Address mode
ADMODE: u2 = 0,
/// ADSIZE [12:13]
/// Address size
ADSIZE: u2 = 0,
/// ABMODE [14:15]
/// Alternate bytes mode
ABMODE: u2 = 0,
/// ABSIZE [16:17]
/// Alternate bytes size
ABSIZE: u2 = 0,
/// DCYC [18:22]
/// Number of dummy cycles
DCYC: u5 = 0,
/// unused [23:23]
_unused23: u1 = 0,
/// DMODE [24:25]
/// Data mode
DMODE: u2 = 0,
/// FMODE [26:27]
/// Functional mode
FMODE: u2 = 0,
/// SIOO [28:28]
/// Send instruction only once
SIOO: u1 = 0,
/// unused [29:29]
_unused29: u1 = 0,
/// DHHC [30:30]
/// DDR hold half cycle
DHHC: u1 = 0,
/// DDRM [31:31]
/// Double data rate mode
DDRM: u1 = 0,
};
/// communication configuration
pub const CCR = Register(CCR_val).init(base_address + 0x14);

/// AR
const AR_val = packed struct {
/// ADDRESS [0:31]
/// Address
ADDRESS: u32 = 0,
};
/// address register
pub const AR = Register(AR_val).init(base_address + 0x18);

/// ABR
const ABR_val = packed struct {
/// ALTERNATE [0:31]
/// ALTERNATE
ALTERNATE: u32 = 0,
};
/// ABR
pub const ABR = Register(ABR_val).init(base_address + 0x1c);

/// DR
const DR_val = packed struct {
/// DATA [0:31]
/// Data
DATA: u32 = 0,
};
/// data register
pub const DR = Register(DR_val).init(base_address + 0x20);

/// PSMKR
const PSMKR_val = packed struct {
/// MASK [0:31]
/// Status mask
MASK: u32 = 0,
};
/// polling status mask register
pub const PSMKR = Register(PSMKR_val).init(base_address + 0x24);

/// PSMAR
const PSMAR_val = packed struct {
/// MATCH [0:31]
/// Status match
MATCH: u32 = 0,
};
/// polling status match register
pub const PSMAR = Register(PSMAR_val).init(base_address + 0x28);

/// PIR
const PIR_val = packed struct {
/// INTERVAL [0:15]
/// Polling interval
INTERVAL: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// polling interval register
pub const PIR = Register(PIR_val).init(base_address + 0x2c);

/// LPTR
const LPTR_val = packed struct {
/// TIMEOUT [0:15]
/// Timeout period
TIMEOUT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// low-power timeout register
pub const LPTR = Register(LPTR_val).init(base_address + 0x30);
};

/// MCU debug component
pub const DBGMCU = struct {

const base_address = 0xe0042000;
/// IDCODE
const IDCODE_val = packed struct {
/// DEV_ID [0:11]
/// Device identifier
DEV_ID: u12 = 0,
/// unused [12:15]
_unused12: u4 = 0,
/// REV_ID [16:31]
/// Revision identifie
REV_ID: u16 = 0,
};
/// DBGMCU_IDCODE
pub const IDCODE = Register(IDCODE_val).init(base_address + 0x0);

/// CR
const CR_val = packed struct {
/// DBG_SLEEP [0:0]
/// Debug Sleep mode
DBG_SLEEP: u1 = 0,
/// DBG_STOP [1:1]
/// Debug Stop mode
DBG_STOP: u1 = 0,
/// DBG_STANDBY [2:2]
/// Debug Standby mode
DBG_STANDBY: u1 = 0,
/// unused [3:4]
_unused3: u2 = 0,
/// TRACE_IOEN [5:5]
/// Trace pin assignment
TRACE_IOEN: u1 = 0,
/// TRACE_MODE [6:7]
/// Trace pin assignment
TRACE_MODE: u2 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Debug MCU configuration
pub const CR = Register(CR_val).init(base_address + 0x4);

/// APB1FZR1
const APB1FZR1_val = packed struct {
/// DBG_TIM2_STOP [0:0]
/// TIM2 counter stopped when core is
DBG_TIM2_STOP: u1 = 0,
/// unused [1:3]
_unused1: u3 = 0,
/// DBG_TIM6_STOP [4:4]
/// TIM6 counter stopped when core is
DBG_TIM6_STOP: u1 = 0,
/// DBG_TIM7_STOP [5:5]
/// TIM7 counter stopped when core is
DBG_TIM7_STOP: u1 = 0,
/// unused [6:9]
_unused6: u2 = 0,
_unused8: u2 = 0,
/// DBG_RTC_STOP [10:10]
/// RTC counter stopped when core is
DBG_RTC_STOP: u1 = 0,
/// DBG_WWDG_STOP [11:11]
/// Window watchdog counter stopped when
DBG_WWDG_STOP: u1 = 0,
/// DBG_IWDG_STOP [12:12]
/// Independent watchdog counter stopped
DBG_IWDG_STOP: u1 = 0,
/// unused [13:20]
_unused13: u3 = 0,
_unused16: u5 = 0,
/// DBG_I2C1_STOP [21:21]
/// I2C1 SMBUS timeout counter stopped when
DBG_I2C1_STOP: u1 = 0,
/// DBG_I2C2_STOP [22:22]
/// I2C2 SMBUS timeout counter stopped when
DBG_I2C2_STOP: u1 = 0,
/// DBG_I2C3_STOP [23:23]
/// I2C3 SMBUS timeout counter stopped when
DBG_I2C3_STOP: u1 = 0,
/// unused [24:24]
_unused24: u1 = 0,
/// DBG_CAN_STOP [25:25]
/// bxCAN stopped when core is
DBG_CAN_STOP: u1 = 0,
/// unused [26:30]
_unused26: u5 = 0,
/// DBG_LPTIM1_STOP [31:31]
/// LPTIM1 counter stopped when core is
DBG_LPTIM1_STOP: u1 = 0,
};
/// Debug MCU APB1 freeze
pub const APB1FZR1 = Register(APB1FZR1_val).init(base_address + 0x8);

/// APB1FZR2
const APB1FZR2_val = packed struct {
/// unused [0:4]
_unused0: u5 = 0,
/// DBG_LPTIM2_STOP [5:5]
/// LPTIM2 counter stopped when core is
DBG_LPTIM2_STOP: u1 = 0,
/// unused [6:31]
_unused6: u2 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Debug MCU APB1 freeze register
pub const APB1FZR2 = Register(APB1FZR2_val).init(base_address + 0xc);

/// APB2FZR
const APB2FZR_val = packed struct {
/// unused [0:10]
_unused0: u8 = 0,
_unused8: u3 = 0,
/// DBG_TIM1_STOP [11:11]
/// TIM1 counter stopped when core is
DBG_TIM1_STOP: u1 = 0,
/// unused [12:15]
_unused12: u4 = 0,
/// DBG_TIM15_STOP [16:16]
/// TIM15 counter stopped when core is
DBG_TIM15_STOP: u1 = 0,
/// DBG_TIM16_STOP [17:17]
/// TIM16 counter stopped when core is
DBG_TIM16_STOP: u1 = 0,
/// unused [18:31]
_unused18: u6 = 0,
_unused24: u8 = 0,
};
/// Debug MCU APB2 freeze register
pub const APB2FZR = Register(APB2FZR_val).init(base_address + 0x10);
};

/// Floting point unit
pub const FPU = struct {

const base_address = 0xe000ef34;
/// FPCCR
const FPCCR_val = packed struct {
/// LSPACT [0:0]
/// LSPACT
LSPACT: u1 = 0,
/// USER [1:1]
/// USER
USER: u1 = 0,
/// unused [2:2]
_unused2: u1 = 0,
/// THREAD [3:3]
/// THREAD
THREAD: u1 = 0,
/// HFRDY [4:4]
/// HFRDY
HFRDY: u1 = 0,
/// MMRDY [5:5]
/// MMRDY
MMRDY: u1 = 0,
/// BFRDY [6:6]
/// BFRDY
BFRDY: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// MONRDY [8:8]
/// MONRDY
MONRDY: u1 = 0,
/// unused [9:29]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u6 = 0,
/// LSPEN [30:30]
/// LSPEN
LSPEN: u1 = 0,
/// ASPEN [31:31]
/// ASPEN
ASPEN: u1 = 0,
};
/// Floating-point context control
pub const FPCCR = Register(FPCCR_val).init(base_address + 0x0);

/// FPCAR
const FPCAR_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// ADDRESS [3:31]
/// Location of unpopulated
ADDRESS: u29 = 0,
};
/// Floating-point context address
pub const FPCAR = Register(FPCAR_val).init(base_address + 0x4);

/// FPSCR
const FPSCR_val = packed struct {
/// IOC [0:0]
/// Invalid operation cumulative exception
IOC: u1 = 0,
/// DZC [1:1]
/// Division by zero cumulative exception
DZC: u1 = 0,
/// OFC [2:2]
/// Overflow cumulative exception
OFC: u1 = 0,
/// UFC [3:3]
/// Underflow cumulative exception
UFC: u1 = 0,
/// IXC [4:4]
/// Inexact cumulative exception
IXC: u1 = 0,
/// unused [5:6]
_unused5: u2 = 0,
/// IDC [7:7]
/// Input denormal cumulative exception
IDC: u1 = 0,
/// unused [8:21]
_unused8: u8 = 0,
_unused16: u6 = 0,
/// RMode [22:23]
/// Rounding Mode control
RMode: u2 = 0,
/// FZ [24:24]
/// Flush-to-zero mode control
FZ: u1 = 0,
/// DN [25:25]
/// Default NaN mode control
DN: u1 = 0,
/// AHP [26:26]
/// Alternative half-precision control
AHP: u1 = 0,
/// unused [27:27]
_unused27: u1 = 0,
/// V [28:28]
/// Overflow condition code
V: u1 = 0,
/// C [29:29]
/// Carry condition code flag
C: u1 = 0,
/// Z [30:30]
/// Zero condition code flag
Z: u1 = 0,
/// N [31:31]
/// Negative condition code
N: u1 = 0,
};
/// Floating-point status control
pub const FPSCR = Register(FPSCR_val).init(base_address + 0x8);
};

/// Memory protection unit
pub const MPU = struct {

const base_address = 0xe000ed90;
/// MPU_TYPER
const MPU_TYPER_val = packed struct {
/// SEPARATE [0:0]
/// Separate flag
SEPARATE: u1 = 0,
/// unused [1:7]
_unused1: u7 = 0,
/// DREGION [8:15]
/// Number of MPU data regions
DREGION: u8 = 8,
/// IREGION [16:23]
/// Number of MPU instruction
IREGION: u8 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// MPU type register
pub const MPU_TYPER = Register(MPU_TYPER_val).init(base_address + 0x0);

/// MPU_CTRL
const MPU_CTRL_val = packed struct {
/// ENABLE [0:0]
/// Enables the MPU
ENABLE: u1 = 0,
/// HFNMIENA [1:1]
/// Enables the operation of MPU during hard
HFNMIENA: u1 = 0,
/// PRIVDEFENA [2:2]
/// Enable priviliged software access to
PRIVDEFENA: u1 = 0,
/// unused [3:31]
_unused3: u5 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// MPU control register
pub const MPU_CTRL = Register(MPU_CTRL_val).init(base_address + 0x4);

/// MPU_RNR
const MPU_RNR_val = packed struct {
/// REGION [0:7]
/// MPU region
REGION: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// MPU region number register
pub const MPU_RNR = Register(MPU_RNR_val).init(base_address + 0x8);

/// MPU_RBAR
const MPU_RBAR_val = packed struct {
/// REGION [0:3]
/// MPU region field
REGION: u4 = 0,
/// VALID [4:4]
/// MPU region number valid
VALID: u1 = 0,
/// ADDR [5:31]
/// Region base address field
ADDR: u27 = 0,
};
/// MPU region base address
pub const MPU_RBAR = Register(MPU_RBAR_val).init(base_address + 0xc);

/// MPU_RASR
const MPU_RASR_val = packed struct {
/// ENABLE [0:0]
/// Region enable bit.
ENABLE: u1 = 0,
/// SIZE [1:5]
/// Size of the MPU protection
SIZE: u5 = 0,
/// unused [6:7]
_unused6: u2 = 0,
/// SRD [8:15]
/// Subregion disable bits
SRD: u8 = 0,
/// B [16:16]
/// memory attribute
B: u1 = 0,
/// C [17:17]
/// memory attribute
C: u1 = 0,
/// S [18:18]
/// Shareable memory attribute
S: u1 = 0,
/// TEX [19:21]
/// memory attribute
TEX: u3 = 0,
/// unused [22:23]
_unused22: u2 = 0,
/// AP [24:26]
/// Access permission
AP: u3 = 0,
/// unused [27:27]
_unused27: u1 = 0,
/// XN [28:28]
/// Instruction access disable
XN: u1 = 0,
/// unused [29:31]
_unused29: u3 = 0,
};
/// MPU region attribute and size
pub const MPU_RASR = Register(MPU_RASR_val).init(base_address + 0x10);
};

/// SysTick timer
pub const STK = struct {

const base_address = 0xe000e010;
/// CTRL
const CTRL_val = packed struct {
/// ENABLE [0:0]
/// Counter enable
ENABLE: u1 = 0,
/// TICKINT [1:1]
/// SysTick exception request
TICKINT: u1 = 0,
/// CLKSOURCE [2:2]
/// Clock source selection
CLKSOURCE: u1 = 0,
/// unused [3:15]
_unused3: u5 = 0,
_unused8: u8 = 0,
/// COUNTFLAG [16:16]
/// COUNTFLAG
COUNTFLAG: u1 = 0,
/// unused [17:31]
_unused17: u7 = 0,
_unused24: u8 = 0,
};
/// SysTick control and status
pub const CTRL = Register(CTRL_val).init(base_address + 0x0);

/// LOAD
const LOAD_val = packed struct {
/// RELOAD [0:23]
/// RELOAD value
RELOAD: u24 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// SysTick reload value register
pub const LOAD = Register(LOAD_val).init(base_address + 0x4);

/// VAL
const VAL_val = packed struct {
/// CURRENT [0:23]
/// Current counter value
CURRENT: u24 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// SysTick current value register
pub const VAL = Register(VAL_val).init(base_address + 0x8);

/// CALIB
const CALIB_val = packed struct {
/// TENMS [0:23]
/// Calibration value
TENMS: u24 = 0,
/// unused [24:29]
_unused24: u6 = 0,
/// SKEW [30:30]
/// SKEW flag: Indicates whether the TENMS
SKEW: u1 = 0,
/// NOREF [31:31]
/// NOREF flag. Reads as zero
NOREF: u1 = 0,
};
/// SysTick calibration value
pub const CALIB = Register(CALIB_val).init(base_address + 0xc);
};

/// System control block
pub const SCB = struct {

const base_address = 0xe000ed00;
/// CPUID
const CPUID_val = packed struct {
/// Revision [0:3]
/// Revision number
Revision: u4 = 1,
/// PartNo [4:15]
/// Part number of the
PartNo: u12 = 3108,
/// Constant [16:19]
/// Reads as 0xF
Constant: u4 = 15,
/// Variant [20:23]
/// Variant number
Variant: u4 = 0,
/// Implementer [24:31]
/// Implementer code
Implementer: u8 = 65,
};
/// CPUID base register
pub const CPUID = Register(CPUID_val).init(base_address + 0x0);

/// ICSR
const ICSR_val = packed struct {
/// VECTACTIVE [0:8]
/// Active vector
VECTACTIVE: u9 = 0,
/// unused [9:10]
_unused9: u2 = 0,
/// RETTOBASE [11:11]
/// Return to base level
RETTOBASE: u1 = 0,
/// VECTPENDING [12:18]
/// Pending vector
VECTPENDING: u7 = 0,
/// unused [19:21]
_unused19: u3 = 0,
/// ISRPENDING [22:22]
/// Interrupt pending flag
ISRPENDING: u1 = 0,
/// unused [23:24]
_unused23: u1 = 0,
_unused24: u1 = 0,
/// PENDSTCLR [25:25]
/// SysTick exception clear-pending
PENDSTCLR: u1 = 0,
/// PENDSTSET [26:26]
/// SysTick exception set-pending
PENDSTSET: u1 = 0,
/// PENDSVCLR [27:27]
/// PendSV clear-pending bit
PENDSVCLR: u1 = 0,
/// PENDSVSET [28:28]
/// PendSV set-pending bit
PENDSVSET: u1 = 0,
/// unused [29:30]
_unused29: u2 = 0,
/// NMIPENDSET [31:31]
/// NMI set-pending bit.
NMIPENDSET: u1 = 0,
};
/// Interrupt control and state
pub const ICSR = Register(ICSR_val).init(base_address + 0x4);

/// VTOR
const VTOR_val = packed struct {
/// unused [0:8]
_unused0: u8 = 0,
_unused8: u1 = 0,
/// TBLOFF [9:29]
/// Vector table base offset
TBLOFF: u21 = 0,
/// unused [30:31]
_unused30: u2 = 0,
};
/// Vector table offset register
pub const VTOR = Register(VTOR_val).init(base_address + 0x8);

/// AIRCR
const AIRCR_val = packed struct {
/// VECTRESET [0:0]
/// VECTRESET
VECTRESET: u1 = 0,
/// VECTCLRACTIVE [1:1]
/// VECTCLRACTIVE
VECTCLRACTIVE: u1 = 0,
/// SYSRESETREQ [2:2]
/// SYSRESETREQ
SYSRESETREQ: u1 = 0,
/// unused [3:7]
_unused3: u5 = 0,
/// PRIGROUP [8:10]
/// PRIGROUP
PRIGROUP: u3 = 0,
/// unused [11:14]
_unused11: u4 = 0,
/// ENDIANESS [15:15]
/// ENDIANESS
ENDIANESS: u1 = 0,
/// VECTKEYSTAT [16:31]
/// Register key
VECTKEYSTAT: u16 = 0,
};
/// Application interrupt and reset control
pub const AIRCR = Register(AIRCR_val).init(base_address + 0xc);

/// SCR
const SCR_val = packed struct {
/// unused [0:0]
_unused0: u1 = 0,
/// SLEEPONEXIT [1:1]
/// SLEEPONEXIT
SLEEPONEXIT: u1 = 0,
/// SLEEPDEEP [2:2]
/// SLEEPDEEP
SLEEPDEEP: u1 = 0,
/// unused [3:3]
_unused3: u1 = 0,
/// SEVEONPEND [4:4]
/// Send Event on Pending bit
SEVEONPEND: u1 = 0,
/// unused [5:31]
_unused5: u3 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// System control register
pub const SCR = Register(SCR_val).init(base_address + 0x10);

/// CCR
const CCR_val = packed struct {
/// NONBASETHRDENA [0:0]
/// Configures how the processor enters
NONBASETHRDENA: u1 = 0,
/// USERSETMPEND [1:1]
/// USERSETMPEND
USERSETMPEND: u1 = 0,
/// unused [2:2]
_unused2: u1 = 0,
/// UNALIGN__TRP [3:3]
/// UNALIGN_ TRP
UNALIGN__TRP: u1 = 0,
/// DIV_0_TRP [4:4]
/// DIV_0_TRP
DIV_0_TRP: u1 = 0,
/// unused [5:7]
_unused5: u3 = 0,
/// BFHFNMIGN [8:8]
/// BFHFNMIGN
BFHFNMIGN: u1 = 0,
/// STKALIGN [9:9]
/// STKALIGN
STKALIGN: u1 = 0,
/// unused [10:31]
_unused10: u6 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Configuration and control
pub const CCR = Register(CCR_val).init(base_address + 0x14);

/// SHPR1
const SHPR1_val = packed struct {
/// PRI_4 [0:7]
/// Priority of system handler
PRI_4: u8 = 0,
/// PRI_5 [8:15]
/// Priority of system handler
PRI_5: u8 = 0,
/// PRI_6 [16:23]
/// Priority of system handler
PRI_6: u8 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// System handler priority
pub const SHPR1 = Register(SHPR1_val).init(base_address + 0x18);

/// SHPR2
const SHPR2_val = packed struct {
/// unused [0:23]
_unused0: u8 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
/// PRI_11 [24:31]
/// Priority of system handler
PRI_11: u8 = 0,
};
/// System handler priority
pub const SHPR2 = Register(SHPR2_val).init(base_address + 0x1c);

/// SHPR3
const SHPR3_val = packed struct {
/// unused [0:15]
_unused0: u8 = 0,
_unused8: u8 = 0,
/// PRI_14 [16:23]
/// Priority of system handler
PRI_14: u8 = 0,
/// PRI_15 [24:31]
/// Priority of system handler
PRI_15: u8 = 0,
};
/// System handler priority
pub const SHPR3 = Register(SHPR3_val).init(base_address + 0x20);

/// SHCRS
const SHCRS_val = packed struct {
/// MEMFAULTACT [0:0]
/// Memory management fault exception active
MEMFAULTACT: u1 = 0,
/// BUSFAULTACT [1:1]
/// Bus fault exception active
BUSFAULTACT: u1 = 0,
/// unused [2:2]
_unused2: u1 = 0,
/// USGFAULTACT [3:3]
/// Usage fault exception active
USGFAULTACT: u1 = 0,
/// unused [4:6]
_unused4: u3 = 0,
/// SVCALLACT [7:7]
/// SVC call active bit
SVCALLACT: u1 = 0,
/// MONITORACT [8:8]
/// Debug monitor active bit
MONITORACT: u1 = 0,
/// unused [9:9]
_unused9: u1 = 0,
/// PENDSVACT [10:10]
/// PendSV exception active
PENDSVACT: u1 = 0,
/// SYSTICKACT [11:11]
/// SysTick exception active
SYSTICKACT: u1 = 0,
/// USGFAULTPENDED [12:12]
/// Usage fault exception pending
USGFAULTPENDED: u1 = 0,
/// MEMFAULTPENDED [13:13]
/// Memory management fault exception
MEMFAULTPENDED: u1 = 0,
/// BUSFAULTPENDED [14:14]
/// Bus fault exception pending
BUSFAULTPENDED: u1 = 0,
/// SVCALLPENDED [15:15]
/// SVC call pending bit
SVCALLPENDED: u1 = 0,
/// MEMFAULTENA [16:16]
/// Memory management fault enable
MEMFAULTENA: u1 = 0,
/// BUSFAULTENA [17:17]
/// Bus fault enable bit
BUSFAULTENA: u1 = 0,
/// USGFAULTENA [18:18]
/// Usage fault enable bit
USGFAULTENA: u1 = 0,
/// unused [19:31]
_unused19: u5 = 0,
_unused24: u8 = 0,
};
/// System handler control and state
pub const SHCRS = Register(SHCRS_val).init(base_address + 0x24);

/// CFSR_UFSR_BFSR_MMFSR
const CFSR_UFSR_BFSR_MMFSR_val = packed struct {
/// unused [0:0]
_unused0: u1 = 0,
/// IACCVIOL [1:1]
/// Instruction access violation
IACCVIOL: u1 = 0,
/// unused [2:2]
_unused2: u1 = 0,
/// MUNSTKERR [3:3]
/// Memory manager fault on unstacking for a
MUNSTKERR: u1 = 0,
/// MSTKERR [4:4]
/// Memory manager fault on stacking for
MSTKERR: u1 = 0,
/// MLSPERR [5:5]
/// MLSPERR
MLSPERR: u1 = 0,
/// unused [6:6]
_unused6: u1 = 0,
/// MMARVALID [7:7]
/// Memory Management Fault Address Register
MMARVALID: u1 = 0,
/// IBUSERR [8:8]
/// Instruction bus error
IBUSERR: u1 = 0,
/// PRECISERR [9:9]
/// Precise data bus error
PRECISERR: u1 = 0,
/// IMPRECISERR [10:10]
/// Imprecise data bus error
IMPRECISERR: u1 = 0,
/// UNSTKERR [11:11]
/// Bus fault on unstacking for a return
UNSTKERR: u1 = 0,
/// STKERR [12:12]
/// Bus fault on stacking for exception
STKERR: u1 = 0,
/// LSPERR [13:13]
/// Bus fault on floating-point lazy state
LSPERR: u1 = 0,
/// unused [14:14]
_unused14: u1 = 0,
/// BFARVALID [15:15]
/// Bus Fault Address Register (BFAR) valid
BFARVALID: u1 = 0,
/// UNDEFINSTR [16:16]
/// Undefined instruction usage
UNDEFINSTR: u1 = 0,
/// INVSTATE [17:17]
/// Invalid state usage fault
INVSTATE: u1 = 0,
/// INVPC [18:18]
/// Invalid PC load usage
INVPC: u1 = 0,
/// NOCP [19:19]
/// No coprocessor usage
NOCP: u1 = 0,
/// unused [20:23]
_unused20: u4 = 0,
/// UNALIGNED [24:24]
/// Unaligned access usage
UNALIGNED: u1 = 0,
/// DIVBYZERO [25:25]
/// Divide by zero usage fault
DIVBYZERO: u1 = 0,
/// unused [26:31]
_unused26: u6 = 0,
};
/// Configurable fault status
pub const CFSR_UFSR_BFSR_MMFSR = Register(CFSR_UFSR_BFSR_MMFSR_val).init(base_address + 0x28);

/// HFSR
const HFSR_val = packed struct {
/// unused [0:0]
_unused0: u1 = 0,
/// VECTTBL [1:1]
/// Vector table hard fault
VECTTBL: u1 = 0,
/// unused [2:29]
_unused2: u6 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u6 = 0,
/// FORCED [30:30]
/// Forced hard fault
FORCED: u1 = 0,
/// DEBUG_VT [31:31]
/// Reserved for Debug use
DEBUG_VT: u1 = 0,
};
/// Hard fault status register
pub const HFSR = Register(HFSR_val).init(base_address + 0x2c);

/// MMFAR
const MMFAR_val = packed struct {
/// MMFAR [0:31]
/// Memory management fault
MMFAR: u32 = 0,
};
/// Memory management fault address
pub const MMFAR = Register(MMFAR_val).init(base_address + 0x34);

/// BFAR
const BFAR_val = packed struct {
/// BFAR [0:31]
/// Bus fault address
BFAR: u32 = 0,
};
/// Bus fault address register
pub const BFAR = Register(BFAR_val).init(base_address + 0x38);

/// AFSR
const AFSR_val = packed struct {
/// IMPDEF [0:31]
/// Implementation defined
IMPDEF: u32 = 0,
};
/// Auxiliary fault status
pub const AFSR = Register(AFSR_val).init(base_address + 0x3c);
};

/// Nested vectored interrupt
pub const NVIC_STIR = struct {

const base_address = 0xe000ef00;
/// STIR
const STIR_val = packed struct {
/// INTID [0:8]
/// Software generated interrupt
INTID: u9 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Software trigger interrupt
pub const STIR = Register(STIR_val).init(base_address + 0x0);
};

/// Floating point unit CPACR
pub const FPU_CPACR = struct {

const base_address = 0xe000ed88;
/// CPACR
const CPACR_val = packed struct {
/// unused [0:19]
_unused0: u8 = 0,
_unused8: u8 = 0,
_unused16: u4 = 0,
/// CP [20:23]
/// CP
CP: u4 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// Coprocessor access control
pub const CPACR = Register(CPACR_val).init(base_address + 0x0);
};

/// System control block ACTLR
pub const SCB_ACTRL = struct {

const base_address = 0xe000e008;
/// ACTRL
const ACTRL_val = packed struct {
/// DISMCYCINT [0:0]
/// DISMCYCINT
DISMCYCINT: u1 = 0,
/// DISDEFWBUF [1:1]
/// DISDEFWBUF
DISDEFWBUF: u1 = 0,
/// DISFOLD [2:2]
/// DISFOLD
DISFOLD: u1 = 0,
/// unused [3:7]
_unused3: u5 = 0,
/// DISFPCA [8:8]
/// DISFPCA
DISFPCA: u1 = 0,
/// DISOOFP [9:9]
/// DISOOFP
DISOOFP: u1 = 0,
/// unused [10:31]
_unused10: u6 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Auxiliary control register
pub const ACTRL = Register(ACTRL_val).init(base_address + 0x0);
};
pub const interrupts = struct {
pub const TIM1_TRG_COM = 26;
pub const TIM6_DACUNDER = 54;
pub const DMA2_CH5 = 60;
pub const SWPMI1 = 76;
pub const I2C3_ER = 73;
pub const CAN1_SCE = 22;
pub const DFSDM1 = 61;
pub const DFSDM2 = 62;
pub const I2C2_ER = 34;
pub const DMA2_CH1 = 56;
pub const COMP = 64;
pub const SPI2 = 36;
pub const EXTI3 = 9;
pub const LPUART1 = 70;
pub const RNG = 80;
pub const I2C2_EV = 33;
pub const USART2 = 38;
pub const EXTI0 = 6;
pub const LPTIM1 = 65;
pub const EXTI1 = 7;
pub const LPTIM2 = 66;
pub const CAN1_RX1 = 21;
pub const RTC_TAMP_STAMP = 2;
pub const RTC_ALARM = 41;
pub const TIM2 = 28;
pub const EXTI15_10 = 40;
pub const RCC = 5;
pub const DMA2_CH6 = 68;
pub const DMA1_CH6 = 16;
pub const DMA2_CH3 = 58;
pub const USART1 = 37;
pub const I2C3_EV = 72;
pub const SAI1 = 74;
pub const CAN1_RX0 = 20;
pub const TIM7 = 55;
pub const DMA1_CH3 = 13;
pub const DMA2_CH7 = 69;
pub const DMA1_CH1 = 11;
pub const LCD = 78;
pub const TSC = 77;
pub const TIM1_BRK_TIM15 = 24;
pub const SDMMC1 = 49;
pub const DMA2_CH4 = 59;
pub const RTC_WKUP = 3;
pub const DMA1_CH7 = 17;
pub const SPI3 = 51;
pub const I2C4_EV = 83;
pub const DFSDM1_FLT2 = 63;
pub const QUADSPI = 71;
pub const EXTI9_5 = 23;
pub const TIM1_CC = 27;
pub const I2C1_EV = 31;
pub const CRS = 82;
pub const I2C4_ER = 84;
pub const DMA1_CH2 = 12;
pub const WWDG = 0;
pub const DMA1_CH4 = 14;
pub const ADC1 = 18;
pub const UART4 = 52;
pub const EXTI2 = 8;
pub const DFSDM1_FLT3 = 42;
pub const TIM1_UP_TIM16 = 25;
pub const USART3 = 39;
pub const DMA2_CH2 = 57;
pub const I2C1_ER = 32;
pub const CAN1_TX = 19;
pub const FLASH = 4;
pub const TIM3 = 29;
pub const AES = 79;
pub const PVD_PVM = 1;
pub const USB_FS = 67;
pub const SPI1 = 35;
pub const DMA1_CH5 = 15;
pub const EXTI4 = 10;
pub const FPU = 81;
};
