# Requires luafmt
# untestet
forfiles /S /M "*.lua" /C "cmd /C luafmt -w replace @PATH"
