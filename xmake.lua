
set_project("mylib")
set_version("0.0.1", {build = "%Y%m%d%H%M"})

-- the latest version at the moment
set_xmakever("3.0.1")

-- Specify the target platforms and architectures
set_allowedplats("windows", "linux")
set_allowedarchs(-- for windows
                 "windows|x64",
                 -- for linux
                 "linux|x86_64")

-- C++ version
set_languages("c++latest")


if is_plat("windows") then
    set_allowedmodes("debug", "releasedbg", "release")
    add_rules("mode.debug", "mode.releasedbg", "mode.release")
elseif is_plat("linux") then
    set_allowedmodes("debug", "releasedbg", "release", "coverage", "valgrind", "asan", "msan", "lsan", "ubsan", "tsan")
    add_rules("mode.debug", "mode.releasedbg", "mode.release", "mode.coverage", "mode.valgrind", "mode.asan", "mode.msan", "mode.lsan", "mode.ubsan", "mode.tsan")
end

if is_mode("coverage") then
    -- .gcno files are not cached, so they will not be generated on rebuild.
    -- disable caching as a workaround.
    -- see https://github.com/xmake-io/xmake/issues/6664
    set_policy("build.ccache", false)
end

-- let VS project detect updates of xmake.lua
add_rules("plugin.vsxmake.autoupdate")

-- overwrite existing modes
-- see xmake/plugins/project/vsxmake/getinfo.lua


-- Platform specific flags
if is_plat("windows") then
    add_defines("_WINDOWS", "UNICODE", "_UNICODE")
    add_cxflags("/utf-8", "/W3", "/Zc:inline", "/external:W3")
elseif is_plat("linux") then
    add_defines("_LINUX")
    add_cxflags("-Wall", "-Wextra", "-Wpedantic")
end

-- overwrite "mode.debug"
rule("mode.debug")
    on_config(function (target)
        if is_mode("debug") then
            if not target:get("symbols") then
                target:set("symbols", "debug")
            end
            if not target:get("optimize") then
                target:set("optimize", "none")
            end
            target:add("cuflags", "-G")

            if is_plat("windows") then
                target:add("cxflags", "/sdl", "/RTC1")
            end
        end
    end)

-- overwrite "mode.release"
rule("mode.release")
    on_config(function (target)
        if is_mode("release") then
            if not target:get("symbols") and target:kind() ~= "shared" then
                target:set("symbols", "hidden")
            end
            if not target:get("optimize") then
                if target:is_plat("android", "iphoneos") then
                    target:set("optimize", "smallest")
                else
                    target:set("optimize", "fastest")
                end
            end
            if not target:get("strip") then
                target:set("strip", "all")
            end
            target:add("cxflags", "-DNDEBUG")
            target:add("cuflags", "-DNDEBUG")
        end
    end)

-- overwrite "mode.releasedbg"
rule("mode.releasedbg")
    on_config(function (target)
        if is_mode("releasedbg") then
            if not target:get("symbols") then
                target:set("symbols", "debug")
            end
            if not target:get("optimize") then
                if target:is_plat("android", "iphoneos") then
                    target:set("optimize", "smallest")
                else
                    target:set("optimize", "fastest")
                end
            end

            if not target:get("strip") then
                target:set("strip", "all")
            end

            target:add("cxflags", "-DNDEBUG")
            target:add("cuflags", "-DNDEBUG")
            target:add("cuflags", "-lineinfo")
        end
    end)

-- overwrite "mode.coverage"
rule("mode.coverage")
    on_config(function (target)
        if is_mode("coverage") then
            if not target:get("symbols") then
                target:set("symbols", "debug")
            end
            if not target:get("optimize") then
                target:set("optimize", "none")
            end
            target:add("cxflags", "--coverage")
            target:add("mxflags", "--coverage")
            target:add("ldflags", "--coverage")
            target:add("shflags", "--coverage")

            -- see https://gcovr.com/en/stable/guide/gcov_parser.html#negative-hit-counts
            target:add("cxflags", "-fprofile-update=atomic")
            target:add("cxflags", "-fprofile-abs-path")

        end
    end)

-- overwrite "mode.valgrind"
rule("mode.valgrind")
    on_config(function (target)
        if is_mode("valgrind") then
            if not target:get("symbols") then
                target:set("symbols", "debug")
            end
            if not target:get("optimize") then
                if target:is_plat("android", "iphoneos") then
                    target:set("optimize", "smallest")
                else
                    -- O1 is a good choice for valgrind
                    -- see https://valgrind.org/docs/manual/quick-start.html
                    -- see https://xmake.io/api/description/project-target.html#set-optimize
                    target:set("optimize", "fast")
                end
            end
            target:add("cxflags", "-DNDEBUG")
        end
    end)

-- overwrite "mode.asan"
rule("mode.asan")
    after_load(function (target)
        if is_mode("asan") then
            if not target:get("symbols") then
                target:set("symbols", "debug")
            end
            if not target:get("optimize") then
                if target:is_plat("android", "iphoneos") then
                    target:set("optimize", "smallest")
                else
                    target:set("optimize", "fastest")
                end
            end
            target:set("policy", "build.sanitizer.address", true)
        end
    end)

-- overwrite "mode.msan"
rule("mode.msan")
    on_config(function (target)
        if is_mode("msan") then
            if (not (target:has_tool("cxx", "clang") or target:has_tool("cc", "clang"))) then
                os.raise("mode.msan requires Clang toolchain")
            end
        end
    end)

    after_load(function (target)
        if is_mode("msan") then
            if not target:get("symbols") then
                target:set("symbols", "debug")
            end
            if not target:get("optimize") then
                if target:is_plat("android", "iphoneos") then
                    target:set("optimize", "smallest")
                else
                    --target:set("optimize", "fastest")
                    target:set("optimize", "fast")
                end
            end
            target:set("policy", "build.sanitizer.memory", true)
        end
    end)

-- overwrite "mode.lsan"
rule("mode.lsan")
    after_load(function (target)
        if is_mode("lsan") then
            if not target:get("symbols") then
                target:set("symbols", "debug")
            end
            if not target:get("optimize") then
                if target:is_plat("android", "iphoneos") then
                    target:set("optimize", "smallest")
                else
                    target:set("optimize", "fastest")
                end
            end
            target:set("policy", "build.sanitizer.leak", true)
        end
    end)

-- overwrite "mode.ubsan"
rule("mode.ubsan")
    after_load(function (target)
        if is_mode("ubsan") then
            if not target:get("symbols") then
                target:set("symbols", "debug")
            end
            if not target:get("optimize") then
                if target:is_plat("android", "iphoneos") then
                    target:set("optimize", "smallest")
                else
                    target:set("optimize", "fastest")
                end
            end
            target:set("policy", "build.sanitizer.undefined", true)
        end
    end)

rule("mode.tsan")
    after_load(function (target)
        if is_mode("tsan") then
            if not target:get("symbols") then
                target:set("symbols", "debug")
            end
            if not target:get("optimize") then
                if target:is_plat("android", "iphoneos") then
                    target:set("optimize", "smallest")
                else
                    target:set("optimize", "fastest")
                end
            end
            target:set("policy", "build.sanitizer.thread", true)
        end
    end)
rule_end()

-- use gtest as your unit testing framework
add_requires("gtest", {configs = {main = false, gmock = false}})

-- target definitions

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
target_end()

target("unit_test")
    set_kind("binary")
    add_packages("gtest")
    add_deps("libmylib")
    add_files("tests/unit/test_main.cpp")
target_end()

-- coverage measurement
target("cov")
    set_kind("phony")
    add_deps("unit_test")
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

        -- run tests to generate .gcda files
        os.exec("xmake run unit_test")

        -- make output directory
        os.mkdir("coverage-report")

        -- args for gcovr
        local args = {
            "--root", ".",
            "--html", "--html-details",
            "--output", "coverage-report/index.html",
            "--exclude", "examples/.*",
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
        print("Coverage report generated: coverage-report/index.html")
    end)
target_end()

-- run with valgrind
target("valg")
    set_kind("phony")
    add_deps("unit_test")
    on_run(function ()
        if not is_mode("valgrind") then
            print("This target is only valid in valgrind mode.")
            return
        end
        os.exec("valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --log-file=valgrind.log ./build/linux/x86_64/releasedbg/unit_test")
    end)
target_end()

includes("examples")