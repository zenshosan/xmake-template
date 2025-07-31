#include <mylib.h>
#include <gtest/gtest.h>

TEST(get_version, nonnull)
{
    auto v = get_version();
    EXPECT_NE(v, nullptr);
}

TEST(myadd, both_are_nonzero)
{
    auto v = myadd(1, 2);
    EXPECT_EQ(v, 1 + 2);
}

TEST(myadd, x_is_zero)
{
    auto v = myadd(0, 2);
    EXPECT_EQ(v, 0 + 2);
}

// Enabling this test will result in 100% coverage.
/*
TEST(myadd, y_is_zero)
{
    auto v = myadd(3, 0);
    EXPECT_EQ(v, 3 + 0);
}
*/

int main(int argc, char **argv)
{
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
