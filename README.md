# CodingCase

- Allows one to convert between different coding styles.

## Getting Started:
Add  `CodingCase` to your `build.zig.zon` .dependencies with:
```
zig fetch --save git+https://github.com/bphilip777/CodingCase.git
```

and in your build fn inside `build.zig` add:
```zig
const codingcase = b.dependency("CodingCase", .{});
exe.root_module.addImport("CodingCase", codingcase.module("CodingCase"));
```

Now in your code, import `codingcase`
```zig
const cc = @import("CodingCase");
```

Example Use Case:
```zig
const std = @import("std");
const cc = @import("CodingCase");
pub fn main() void {
  const a = "HelloWorld";
  const da = std.heap.DebugAllocator(.{}){};
  const allo = da.allocator();
  defer std.debug.assert(.ok == da.deinit());
  const snake = try cc.convert(a, .snake);
  defer allo.free(snake);
  if (std.mem.eql(u8, snake, "hello_world")) std.log.info("It worked!", .{});
}
```
