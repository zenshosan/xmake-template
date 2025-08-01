
target("ovr_stack")
    set_kind("binary")
    add_files("buffer_overrun_stack.cpp")
target_end()

target("ovr_heap")
    set_kind("binary")
    add_files("buffer_overrun_heap.cpp")
target_end()

target("uimem")
    set_kind("binary")
    add_files("uninitialized_memory.cpp")
target_end()

target("drace")
    set_kind("binary")
    add_files("data_race.cpp")
target_end()

target("mleak")
    set_kind("binary")
    add_files("memory_leak.cpp")
target_end()

target("ub")
    set_kind("binary")
    add_files("undefined_behavior.cpp")
target_end()
