
set_project("mylib")
set_version("0.0.1", {build = "%Y%m%d%H%M"})
set_xmakever("3.0.1")

-- Specify the target platforms and architectures
set_allowedplats("windows", "linux")
set_allowedarchs(-- for windows
                 "x64",
                 -- for linux
                 "x86_64")

-- C++ version
set_languages("c++latest")


if is_plat("windows") then
    set_allowedmodes("debug", "releasedbg", "release")
    add_rules("mode.debug", "mode.releasedbg", "mode.release")
elseif is_plat("linux") then
    set_allowedmodes("debug", "releasedbg", "release", "coverage")
    add_rules("mode.debug", "mode.releasedbg", "mode.release", "mode.coverage")
end

if is_mode("coverage") then
    -- .gcno files are not cached, so they will not be generated on rebuild.
    -- disable caching as a workaround.
    -- see https://github.com/xmake-io/xmake/issues/6664
    set_policy("build.ccache", false)
end

-- let VS project detect updates of xmake.lua
add_rules("plugin.vsxmake.autoupdate")

target("libmylib")
    set_kind("static")
    if is_plat("windows") then
        set_basename("libmylib")
    else
        set_basename("mylib")
    end

    add_includedirs("include", {public = true})
    add_includedirs("$(builddir)/config")
    add_files("src/mylib.cpp")
    set_configdir("$(builddir)/config")
    add_configfiles("src/config.h.in")

    -- Platform specific flags
    if is_plat("windows") then
        add_defines("_WINDOWS", "UNICODE", "_UNICODE")
        add_cxflags("/utf-8", "/W3", "/Zc:inline", "/external:W3")

       if is_mode("debug") then
           add_cxflags("/sdl", "/RTC1")
       end
    elseif is_plat("linux") then
        add_defines("_LINUX")
        add_cxflags("-Wall", "-Wextra", "-Wpedantic")

        if is_mode("coverage") then
            -- see https://gcovr.com/en/stable/guide/gcov_parser.html#negative-hit-counts
            add_cxflags("-fprofile-update=atomic")
            add_cxflags("-fprofile-abs-path")
        end
    end
target_end()

    -- Define the test dependency
add_requires("gtest", {configs = {main = false, gmock = false}})

target("unit_test")
    set_kind("binary")
    add_packages("gtest")
    --add_tests("test1")
    add_deps("libmylib")
    add_files("tests/unit/test_main.cpp")

    -- Platform specific flags
    if is_plat("windows") then
        add_defines("_WINDOWS", "UNICODE", "_UNICODE")
        add_cxflags("/utf-8", "/W3", "/Zc:inline", "/external:W3")

       if is_mode("debug") then
           add_cxflags("/sdl", "/RTC1")
       end
    end
target_end()


-- coverage task
target("cov")
    set_kind("phony")
    on_run(function ()
        if not is_mode("coverage") then
            print("This target is only valid in coverage mode.")
            return
        end
        -- generate coverage report using gcovr
        import("lib.detect.find_tool")
        local gcovr = find_tool("gcovr")
        if not gcovr then
            print("gcovr not found")
            return
        end

        -- build test target first
        os.exec("xmake build unit_test")

        -- run tests to generate .gcda files
        os.exec("xmake run unit_test")

        -- make output directory
        os.mkdir("coverage")

        -- args for gcovr
        local args = {
            "--root", ".",
            "--html", "--html-details",
            "--output", "coverage/index.html",
            "--exclude", "tests/.*",
            "--exclude", ".*test.*",
            "--object-directory", "build"
        }

        -- check if gcovr is executable
        if not os.isexec(gcovr.program) then
            print("gcovr is NOT executable")
            print("gcovr.program path:", gcovr.program)
            print("File exists:", os.isfile(gcovr.program))
            return
        end

        -- gcovr with try option
        os.execv(gcovr.program, args, {try = true})
        print("Coverage report generated: coverage/index.html")
    end)
target_end()
