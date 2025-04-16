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
const codingcase = @import("CodingCase");
```
