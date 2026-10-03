-- Left vertical monitor (ASUSTek PA247CV)
hl.monitor({
    output = "DP-2",
    mode = "1920x1080@60",
    position = "0x0",
    scale = 1,
    transform = 1
})

-- Front main monitor (LG UltraGear) placed to the right of the vertical screen
hl.monitor({
    output = "DP-1",
    mode = "2560x1440@144",
    position = "auto-right",
    scale = 1
})


