// This is a modified version of buffered_writer.zig from the zig standard library.

// Copyright (c) Zig contributors 
// MIT-License (text at bottom)

const std = @import("std");
const main = @import("nya.zig");

const io = std.io;
const mem = std.mem;


pub fn NyafferedWriter(comptime buffer_size: usize, comptime WriterType: type) type {
    return struct {
        unbuffered_writer: WriterType,
        buf: [buffer_size]u8 = undefined,
        end: usize = 0,

        const Error = {};
        pub const Writer = io.Writer(*Self, Error, write);

        const Self = @This();

        pub fn flush(self: *Self) !void {
            try self.unbuffered_writer.writeAll(self.buf[0..self.end]);
            self.end = 0;
        }

        pub fn writer(self: *Self) Writer {
            return .{ .context = self };
        }

        // It is the responsibility of the caller to not violate the length of the buffer
        // Boundschecking in the write function has been omitted for performance reasons.
        // bytes must be padded to 8 bytes.
        pub inline fn write_fast(self: *Self, bytes: []align(8)const u8) void {
            @setRuntimeSafety(false);
            const real_len = bytes.len;
            var _bytes = bytes.ptr[0..(bytes.len/main.PL)*main.PL + main.PL];
            @memcpy(self.buf[self.end..self.end+_bytes.len], _bytes);
            self.end += real_len;
        }

        pub fn write(self: *Self, bytes: []const u8) void {
            @memcpy(self.buf[self.end..self.end+bytes.len], bytes);
            self.end += bytes.len;
        }
    };
}

// MIT-License text:

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.