
set_project("mylib")
set_version("0.0.1", {build = "%Y%m%d%H%M"})
set_xmakever("3.0.1")

-- ビルド対象のプラットフォームとアーキテクチャを指定
set_allowedplats("windows", "mingw")
set_allowedarchs("x64")

-- 使用するC++のバージョンを指定
set_languages("c++latest")


if is_plat("windows") then
    set_allowedmodes("debug", "releasedbg", "release")
    add_rules("mode.debug", "mode.releasedbg", "mode.release")
elseif is_plat("linux") then
    set_allowedmodes("debug", "releasedbg", "release", "coverage")
    add_rules("mode.debug", "mode.releasedbg", "mode.release", "mode.coverage")
end

-- VSプロジェクトにxmake.luaの更新を検知させる
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
