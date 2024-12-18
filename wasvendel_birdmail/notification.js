exports('ShowTooltip', (text, duration) => {
    const str = CreateVarString(10, "LITERAL_STRING", text);

    const struct1 = new DataView(new ArrayBuffer(48));
    struct1.setUint32(0, duration, true);

    const struct2 = new DataView(new ArrayBuffer(16));
    struct2.setBigUint64(8, BigInt(str), true);

    Citizen.invokeNative("0x049D5C615BD38BAD", struct1, struct2, 1);
});