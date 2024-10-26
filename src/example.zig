const std = @import("std");
// const c = @cImport(@cInclude("../include/glfw3.h"));
const c = @cImport(@cInclude("GLFW/glfw3.h"));

pub fn main() !void {
    if (c.glfwInit() == 0)
        return error.FailedInit;

    const window = c.glfwCreateWindow(640, 480, "My Window", null, null);
    if (false and window == null) {
        c.glfwTerminate();
        return error.FailedCreateWindow;
    }

    c.glfwMakeContextCurrent(window);

    while (c.glfwWindowShouldClose(window) == 0) {
        c.glClear(c.GL_COLOR_BUFFER_BIT);
        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }

    c.glfwTerminate();
}
