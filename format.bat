# Requires luafmt https://github.com/trixnz/lua-fmt
# untestet
forfiles /S /M "*.lua" /C "cmd /C luafmt -w replace @PATH"
