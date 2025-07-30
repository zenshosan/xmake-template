#include <mylib.h>
#include <gtest/gtest.h>

TEST(mylib_test, get_version) {
    auto v = get_version();
    EXPECT_NE(v, nullptr);
}

int main(int argc, char** argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
