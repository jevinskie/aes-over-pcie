# aes-over-pcie
A VHDL implementation of 128 bit AES encryption with a PCIe interface.

The ASIC process we were targeting was not fast enough to keep up with line-speed PCIe serial data. Thus, the ASIC core integrates with a serial<>parallel PCIe bridge IC. The design was be pipelined and parrallelized but that put it over our die size limit. The code is still there for that optimization, if you prefer to do so.

The S-box implemntation is compact and fast thanks to [the design](https://github.com/jevinskie/aes-over-pcie/blob/master/docs/aes/sbox1.pdf) by Edmin NC Mui.
