### The oops message
```
Unable to handle kernel NULL pointer dereference at virtual address 0000000000000000
Mem abort info:
  ESR = 0x0000000096000045
  EC = 0x25: DABT (current EL), IL = 32 bits
  SET = 0, FnV = 0
  EA = 0, S1PTW = 0
  FSC = 0x05: level 1 translation fault
Data abort info:
  ISV = 0, ISS = 0x00000045, ISS2 = 0x00000000
  CM = 0, WnR = 1, TnD = 0, TagAccess = 0
  GCS = 0, Overlay = 0, DirtyBit = 0, Xs = 0
user pgtable: 4k pages, 39-bit VAs, pgdp=0000000041b2c000
[0000000000000000] pgd=0000000000000000, p4d=0000000000000000, pud=0000000000000000
Internal error: Oops: 0000000096000045 [#1] SMP
Modules linked in: hello(O) faulty(O) scull(O)
CPU: 0 PID: 153 Comm: sh Tainted: G           O       6.6.32 #1
Hardware name: linux,dummy-virt (DT)
pstate: 80000005 (Nzcv daif -PAN -UAO -TCO -DIT -SSBS BTYPE=--)
pc : faulty_write+0x8/0x10 [faulty]
lr : vfs_write+0xc8/0x3a0
sp : ffffffc080e7bd20
x29: ffffffc080e7bd80 x28: ffffff8001b88000 x27: 0000000000000000
x26: 0000000000000000 x25: 0000000000000000 x24: 0000000000000000
x23: 000000000000000c x22: 000000000000000c x21: ffffffc080e7bdc0
x20: 000000556bc83a80 x19: ffffff8001be7f00 x18: 0000000000000000
x17: 0000000000000000 x16: 0000000000000000 x15: 0000000000000000
x14: 0000000000000000 x13: 0000000000000000 x12: 0000000000000000
x11: 0000000000000000 x10: 0000000000000000 x9 : 0000000000000000
x8 : 0000000000000000 x7 : 0000000000000000 x6 : 0000000000000000
x5 : 0000000000000000 x4 : ffffffc078c59000 x3 : ffffffc080e7bdc0
x2 : 000000000000000c x1 : 0000000000000000 x0 : 0000000000000000
Call trace:
 faulty_write+0x8/0x10 [faulty]
 ksys_write+0x74/0x10c
 __arm64_sys_write+0x1c/0x28
 invoke_syscall+0x54/0x124
 el0_svc_common.constprop.0+0x40/0xe0
 do_el0_svc+0x1c/0x28
 el0_svc+0x40/0xe4
 el0t_64_sync_handler+0x120/0x12c
 el0t_64_sync+0x190/0x194
Code: ???????? ???????? d2800001 d2800000 (b900003f) 
---[ end trace 0000000000000000 ]---

Message from syslogd@buildroot at Sep  6 14:17:56 ...
 kernel:Internal error: Oops: 0000000096000045 [#1] SMP

Message from syslogd@buildroot at Sep  6 14:17:56 ...
 kernel:Code: ???????? ???????? d2800001 d2800000 (b900003f) 

``` 

### Analysis
The first line of the oops message indicates a null pointer derefrecing error, and then proceeds to give more information about the values stored at diffrent cpu registers when the error occured. One register that can provide some insight about which part of the kernel module caused the error is by looking that the value of the program counter register (PC) which is indicating that the error occured while executing an instruction at 8 bytes offset from the faulty_write function address. 

Then by using this command
```
buildroot/output/host/bin/aarch64-buildroot-linux-gnu-objdump -S  buildroot/output/target/lib/modules/6.6.32/updates/faulty.ko
```
We get this output:

```
buildroot/output/target/lib/modules/6.6.32/updates/faulty.ko:     file format elf64-littleaarch64


Disassembly of section .text:

0000000000000000 <faulty_write>:
   0:   d2800001        mov     x1, #0x0                        // #0
   4:   d2800000        mov     x0, #0x0                        // #0
   8:   b900003f        str     wzr, [x1]
   c:   d65f03c0        ret
...
```

where we can see that at the 8 bytes offset, there is a store instruction that tries to store a value to the address pointed by register x1, meanwhile just from two instructions earlier we can see that that register holds a null pointer. Hence the error