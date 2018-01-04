# REQUIRES luafmt https://github.com/trixnz/lua-fmt
find . -name '*.lua' | while read line; do
    luafmt -w replace $line
done
