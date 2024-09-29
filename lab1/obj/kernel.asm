
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	a009                	j	8020000a <kern_init>

000000008020000a <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000a:	00004517          	auipc	a0,0x4
    8020000e:	00650513          	addi	a0,a0,6 # 80204010 <ticks>
    80200012:	00004617          	auipc	a2,0x4
    80200016:	01660613          	addi	a2,a2,22 # 80204028 <end>
int kern_init(void) {
    8020001a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001c:	8e09                	sub	a2,a2,a0
    8020001e:	4581                	li	a1,0
int kern_init(void) {
    80200020:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200022:	1d5000ef          	jal	ra,802009f6 <memset>

    cons_init();  // init the console
    80200026:	136000ef          	jal	ra,8020015c <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	9de58593          	addi	a1,a1,-1570 # 80200a08 <etext>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	9f650513          	addi	a0,a0,-1546 # 80200a28 <etext+0x20>
    8020003a:	030000ef          	jal	ra,8020006a <cprintf>

    print_kerninfo();
    8020003e:	062000ef          	jal	ra,802000a0 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200042:	12a000ef          	jal	ra,8020016c <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200046:	0e8000ef          	jal	ra,8020012e <clock_init>

    intr_enable();  // enable irq interrupt
    8020004a:	11c000ef          	jal	ra,80200166 <intr_enable>
    
    while (1)
    8020004e:	a001                	j	8020004e <kern_init+0x44>

0000000080200050 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200050:	1141                	addi	sp,sp,-16
    80200052:	e022                	sd	s0,0(sp)
    80200054:	e406                	sd	ra,8(sp)
    80200056:	842e                	mv	s0,a1
    cons_putc(c);
    80200058:	106000ef          	jal	ra,8020015e <cons_putc>
    (*cnt)++;
    8020005c:	401c                	lw	a5,0(s0)
}
    8020005e:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200060:	2785                	addiw	a5,a5,1
    80200062:	c01c                	sw	a5,0(s0)
}
    80200064:	6402                	ld	s0,0(sp)
    80200066:	0141                	addi	sp,sp,16
    80200068:	8082                	ret

000000008020006a <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    8020006a:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    8020006c:	02810313          	addi	t1,sp,40 # 80204028 <end>
int cprintf(const char *fmt, ...) {
    80200070:	8e2a                	mv	t3,a0
    80200072:	f42e                	sd	a1,40(sp)
    80200074:	f832                	sd	a2,48(sp)
    80200076:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200078:	00000517          	auipc	a0,0x0
    8020007c:	fd850513          	addi	a0,a0,-40 # 80200050 <cputch>
    80200080:	004c                	addi	a1,sp,4
    80200082:	869a                	mv	a3,t1
    80200084:	8672                	mv	a2,t3
int cprintf(const char *fmt, ...) {
    80200086:	ec06                	sd	ra,24(sp)
    80200088:	e0ba                	sd	a4,64(sp)
    8020008a:	e4be                	sd	a5,72(sp)
    8020008c:	e8c2                	sd	a6,80(sp)
    8020008e:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200090:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200092:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200094:	576000ef          	jal	ra,8020060a <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    80200098:	60e2                	ld	ra,24(sp)
    8020009a:	4512                	lw	a0,4(sp)
    8020009c:	6125                	addi	sp,sp,96
    8020009e:	8082                	ret

00000000802000a0 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000a0:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a2:	00001517          	auipc	a0,0x1
    802000a6:	98e50513          	addi	a0,a0,-1650 # 80200a30 <etext+0x28>
void print_kerninfo(void) {
    802000aa:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000ac:	fbfff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b0:	00000597          	auipc	a1,0x0
    802000b4:	f5a58593          	addi	a1,a1,-166 # 8020000a <kern_init>
    802000b8:	00001517          	auipc	a0,0x1
    802000bc:	99850513          	addi	a0,a0,-1640 # 80200a50 <etext+0x48>
    802000c0:	fabff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c4:	00001597          	auipc	a1,0x1
    802000c8:	94458593          	addi	a1,a1,-1724 # 80200a08 <etext>
    802000cc:	00001517          	auipc	a0,0x1
    802000d0:	9a450513          	addi	a0,a0,-1628 # 80200a70 <etext+0x68>
    802000d4:	f97ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000d8:	00004597          	auipc	a1,0x4
    802000dc:	f3858593          	addi	a1,a1,-200 # 80204010 <ticks>
    802000e0:	00001517          	auipc	a0,0x1
    802000e4:	9b050513          	addi	a0,a0,-1616 # 80200a90 <etext+0x88>
    802000e8:	f83ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ec:	00004597          	auipc	a1,0x4
    802000f0:	f3c58593          	addi	a1,a1,-196 # 80204028 <end>
    802000f4:	00001517          	auipc	a0,0x1
    802000f8:	9bc50513          	addi	a0,a0,-1604 # 80200ab0 <etext+0xa8>
    802000fc:	f6fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200100:	00004597          	auipc	a1,0x4
    80200104:	32758593          	addi	a1,a1,807 # 80204427 <end+0x3ff>
    80200108:	00000797          	auipc	a5,0x0
    8020010c:	f0278793          	addi	a5,a5,-254 # 8020000a <kern_init>
    80200110:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200114:	43f7d593          	srai	a1,a5,0x3f
}
    80200118:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011a:	3ff5f593          	andi	a1,a1,1023
    8020011e:	95be                	add	a1,a1,a5
    80200120:	85a9                	srai	a1,a1,0xa
    80200122:	00001517          	auipc	a0,0x1
    80200126:	9ae50513          	addi	a0,a0,-1618 # 80200ad0 <etext+0xc8>
}
    8020012a:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020012c:	bf3d                	j	8020006a <cprintf>

000000008020012e <clock_init>:
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    8020012e:	02000793          	li	a5,32
    80200132:	1047a7f3          	csrrs	a5,sie,a5
    80200136:	ffff                	0xffff
    80200138:	ffff                	0xffff

    

    ticks = 0;

    cprintf("++ setup timer interrupts\n");
    8020013a:	00001517          	auipc	a0,0x1
    8020013e:	9c650513          	addi	a0,a0,-1594 # 80200b00 <etext+0xf8>
    ticks = 0;
    80200142:	00004797          	auipc	a5,0x4
    80200146:	ec07b723          	sd	zero,-306(a5) # 80204010 <ticks>
    cprintf("++ setup timer interrupts\n");
    8020014a:	b705                	j	8020006a <cprintf>

000000008020014c <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020014c:	c0102573          	rdtime	a0
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200150:	67e1                	lui	a5,0x18
    80200152:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    80200156:	953e                	add	a0,a0,a5
    80200158:	04f0006f          	j	802009a6 <sbi_set_timer>

000000008020015c <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    8020015c:	8082                	ret

000000008020015e <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    8020015e:	0ff57513          	zext.b	a0,a0
    80200162:	02b0006f          	j	8020098c <sbi_console_putchar>

0000000080200166 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    80200166:	100167f3          	csrrsi	a5,sstatus,2
    8020016a:	8082                	ret

000000008020016c <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    8020016c:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    80200170:	00000797          	auipc	a5,0x0
    80200174:	37878793          	addi	a5,a5,888 # 802004e8 <__alltraps>
    80200178:	10579073          	csrw	stvec,a5
}
    8020017c:	8082                	ret

000000008020017e <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020017e:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    80200180:	1141                	addi	sp,sp,-16
    80200182:	e022                	sd	s0,0(sp)
    80200184:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200186:	00001517          	auipc	a0,0x1
    8020018a:	99a50513          	addi	a0,a0,-1638 # 80200b20 <etext+0x118>
void print_regs(struct pushregs *gpr) {
    8020018e:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200190:	edbff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    80200194:	640c                	ld	a1,8(s0)
    80200196:	00001517          	auipc	a0,0x1
    8020019a:	9a250513          	addi	a0,a0,-1630 # 80200b38 <etext+0x130>
    8020019e:	ecdff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001a2:	680c                	ld	a1,16(s0)
    802001a4:	00001517          	auipc	a0,0x1
    802001a8:	9ac50513          	addi	a0,a0,-1620 # 80200b50 <etext+0x148>
    802001ac:	ebfff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001b0:	6c0c                	ld	a1,24(s0)
    802001b2:	00001517          	auipc	a0,0x1
    802001b6:	9b650513          	addi	a0,a0,-1610 # 80200b68 <etext+0x160>
    802001ba:	eb1ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001be:	700c                	ld	a1,32(s0)
    802001c0:	00001517          	auipc	a0,0x1
    802001c4:	9c050513          	addi	a0,a0,-1600 # 80200b80 <etext+0x178>
    802001c8:	ea3ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001cc:	740c                	ld	a1,40(s0)
    802001ce:	00001517          	auipc	a0,0x1
    802001d2:	9ca50513          	addi	a0,a0,-1590 # 80200b98 <etext+0x190>
    802001d6:	e95ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001da:	780c                	ld	a1,48(s0)
    802001dc:	00001517          	auipc	a0,0x1
    802001e0:	9d450513          	addi	a0,a0,-1580 # 80200bb0 <etext+0x1a8>
    802001e4:	e87ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    802001e8:	7c0c                	ld	a1,56(s0)
    802001ea:	00001517          	auipc	a0,0x1
    802001ee:	9de50513          	addi	a0,a0,-1570 # 80200bc8 <etext+0x1c0>
    802001f2:	e79ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    802001f6:	602c                	ld	a1,64(s0)
    802001f8:	00001517          	auipc	a0,0x1
    802001fc:	9e850513          	addi	a0,a0,-1560 # 80200be0 <etext+0x1d8>
    80200200:	e6bff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    80200204:	642c                	ld	a1,72(s0)
    80200206:	00001517          	auipc	a0,0x1
    8020020a:	9f250513          	addi	a0,a0,-1550 # 80200bf8 <etext+0x1f0>
    8020020e:	e5dff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    80200212:	682c                	ld	a1,80(s0)
    80200214:	00001517          	auipc	a0,0x1
    80200218:	9fc50513          	addi	a0,a0,-1540 # 80200c10 <etext+0x208>
    8020021c:	e4fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200220:	6c2c                	ld	a1,88(s0)
    80200222:	00001517          	auipc	a0,0x1
    80200226:	a0650513          	addi	a0,a0,-1530 # 80200c28 <etext+0x220>
    8020022a:	e41ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    8020022e:	702c                	ld	a1,96(s0)
    80200230:	00001517          	auipc	a0,0x1
    80200234:	a1050513          	addi	a0,a0,-1520 # 80200c40 <etext+0x238>
    80200238:	e33ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    8020023c:	742c                	ld	a1,104(s0)
    8020023e:	00001517          	auipc	a0,0x1
    80200242:	a1a50513          	addi	a0,a0,-1510 # 80200c58 <etext+0x250>
    80200246:	e25ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    8020024a:	782c                	ld	a1,112(s0)
    8020024c:	00001517          	auipc	a0,0x1
    80200250:	a2450513          	addi	a0,a0,-1500 # 80200c70 <etext+0x268>
    80200254:	e17ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200258:	7c2c                	ld	a1,120(s0)
    8020025a:	00001517          	auipc	a0,0x1
    8020025e:	a2e50513          	addi	a0,a0,-1490 # 80200c88 <etext+0x280>
    80200262:	e09ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    80200266:	604c                	ld	a1,128(s0)
    80200268:	00001517          	auipc	a0,0x1
    8020026c:	a3850513          	addi	a0,a0,-1480 # 80200ca0 <etext+0x298>
    80200270:	dfbff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200274:	644c                	ld	a1,136(s0)
    80200276:	00001517          	auipc	a0,0x1
    8020027a:	a4250513          	addi	a0,a0,-1470 # 80200cb8 <etext+0x2b0>
    8020027e:	dedff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    80200282:	684c                	ld	a1,144(s0)
    80200284:	00001517          	auipc	a0,0x1
    80200288:	a4c50513          	addi	a0,a0,-1460 # 80200cd0 <etext+0x2c8>
    8020028c:	ddfff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    80200290:	6c4c                	ld	a1,152(s0)
    80200292:	00001517          	auipc	a0,0x1
    80200296:	a5650513          	addi	a0,a0,-1450 # 80200ce8 <etext+0x2e0>
    8020029a:	dd1ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    8020029e:	704c                	ld	a1,160(s0)
    802002a0:	00001517          	auipc	a0,0x1
    802002a4:	a6050513          	addi	a0,a0,-1440 # 80200d00 <etext+0x2f8>
    802002a8:	dc3ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002ac:	744c                	ld	a1,168(s0)
    802002ae:	00001517          	auipc	a0,0x1
    802002b2:	a6a50513          	addi	a0,a0,-1430 # 80200d18 <etext+0x310>
    802002b6:	db5ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002ba:	784c                	ld	a1,176(s0)
    802002bc:	00001517          	auipc	a0,0x1
    802002c0:	a7450513          	addi	a0,a0,-1420 # 80200d30 <etext+0x328>
    802002c4:	da7ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002c8:	7c4c                	ld	a1,184(s0)
    802002ca:	00001517          	auipc	a0,0x1
    802002ce:	a7e50513          	addi	a0,a0,-1410 # 80200d48 <etext+0x340>
    802002d2:	d99ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002d6:	606c                	ld	a1,192(s0)
    802002d8:	00001517          	auipc	a0,0x1
    802002dc:	a8850513          	addi	a0,a0,-1400 # 80200d60 <etext+0x358>
    802002e0:	d8bff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002e4:	646c                	ld	a1,200(s0)
    802002e6:	00001517          	auipc	a0,0x1
    802002ea:	a9250513          	addi	a0,a0,-1390 # 80200d78 <etext+0x370>
    802002ee:	d7dff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    802002f2:	686c                	ld	a1,208(s0)
    802002f4:	00001517          	auipc	a0,0x1
    802002f8:	a9c50513          	addi	a0,a0,-1380 # 80200d90 <etext+0x388>
    802002fc:	d6fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200300:	6c6c                	ld	a1,216(s0)
    80200302:	00001517          	auipc	a0,0x1
    80200306:	aa650513          	addi	a0,a0,-1370 # 80200da8 <etext+0x3a0>
    8020030a:	d61ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    8020030e:	706c                	ld	a1,224(s0)
    80200310:	00001517          	auipc	a0,0x1
    80200314:	ab050513          	addi	a0,a0,-1360 # 80200dc0 <etext+0x3b8>
    80200318:	d53ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    8020031c:	746c                	ld	a1,232(s0)
    8020031e:	00001517          	auipc	a0,0x1
    80200322:	aba50513          	addi	a0,a0,-1350 # 80200dd8 <etext+0x3d0>
    80200326:	d45ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    8020032a:	786c                	ld	a1,240(s0)
    8020032c:	00001517          	auipc	a0,0x1
    80200330:	ac450513          	addi	a0,a0,-1340 # 80200df0 <etext+0x3e8>
    80200334:	d37ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200338:	7c6c                	ld	a1,248(s0)
}
    8020033a:	6402                	ld	s0,0(sp)
    8020033c:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020033e:	00001517          	auipc	a0,0x1
    80200342:	aca50513          	addi	a0,a0,-1334 # 80200e08 <etext+0x400>
}
    80200346:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200348:	b30d                	j	8020006a <cprintf>

000000008020034a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    8020034a:	1141                	addi	sp,sp,-16
    8020034c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    8020034e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    80200350:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    80200352:	00001517          	auipc	a0,0x1
    80200356:	ace50513          	addi	a0,a0,-1330 # 80200e20 <etext+0x418>
void print_trapframe(struct trapframe *tf) {
    8020035a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    8020035c:	d0fff0ef          	jal	ra,8020006a <cprintf>
    print_regs(&tf->gpr);
    80200360:	8522                	mv	a0,s0
    80200362:	e1dff0ef          	jal	ra,8020017e <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200366:	10043583          	ld	a1,256(s0)
    8020036a:	00001517          	auipc	a0,0x1
    8020036e:	ace50513          	addi	a0,a0,-1330 # 80200e38 <etext+0x430>
    80200372:	cf9ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200376:	10843583          	ld	a1,264(s0)
    8020037a:	00001517          	auipc	a0,0x1
    8020037e:	ad650513          	addi	a0,a0,-1322 # 80200e50 <etext+0x448>
    80200382:	ce9ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    80200386:	11043583          	ld	a1,272(s0)
    8020038a:	00001517          	auipc	a0,0x1
    8020038e:	ade50513          	addi	a0,a0,-1314 # 80200e68 <etext+0x460>
    80200392:	cd9ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    80200396:	11843583          	ld	a1,280(s0)
}
    8020039a:	6402                	ld	s0,0(sp)
    8020039c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    8020039e:	00001517          	auipc	a0,0x1
    802003a2:	ae250513          	addi	a0,a0,-1310 # 80200e80 <etext+0x478>
}
    802003a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003a8:	b1c9                	j	8020006a <cprintf>

00000000802003aa <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003aa:	11853783          	ld	a5,280(a0)
    802003ae:	472d                	li	a4,11
    802003b0:	0786                	slli	a5,a5,0x1
    802003b2:	8385                	srli	a5,a5,0x1
    802003b4:	06f76863          	bltu	a4,a5,80200424 <interrupt_handler+0x7a>
    802003b8:	00001717          	auipc	a4,0x1
    802003bc:	b9070713          	addi	a4,a4,-1136 # 80200f48 <etext+0x540>
    802003c0:	078a                	slli	a5,a5,0x2
    802003c2:	97ba                	add	a5,a5,a4
    802003c4:	439c                	lw	a5,0(a5)
    802003c6:	97ba                	add	a5,a5,a4
    802003c8:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003ca:	00001517          	auipc	a0,0x1
    802003ce:	b2e50513          	addi	a0,a0,-1234 # 80200ef8 <etext+0x4f0>
    802003d2:	b961                	j	8020006a <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003d4:	00001517          	auipc	a0,0x1
    802003d8:	b0450513          	addi	a0,a0,-1276 # 80200ed8 <etext+0x4d0>
    802003dc:	b179                	j	8020006a <cprintf>
            cprintf("User software interrupt\n");
    802003de:	00001517          	auipc	a0,0x1
    802003e2:	aba50513          	addi	a0,a0,-1350 # 80200e98 <etext+0x490>
    802003e6:	b151                	j	8020006a <cprintf>
            cprintf("Supervisor software interrupt\n");
    802003e8:	00001517          	auipc	a0,0x1
    802003ec:	ad050513          	addi	a0,a0,-1328 # 80200eb8 <etext+0x4b0>
    802003f0:	b9ad                	j	8020006a <cprintf>
void interrupt_handler(struct trapframe *tf) {
    802003f2:	1141                	addi	sp,sp,-16
    802003f4:	e406                	sd	ra,8(sp)
            /*(1)设置下次时钟中断- clock_set_next_event()
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
            clock_set_next_event();
    802003f6:	d57ff0ef          	jal	ra,8020014c <clock_set_next_event>
            ticks++;
    802003fa:	00004797          	auipc	a5,0x4
    802003fe:	c1678793          	addi	a5,a5,-1002 # 80204010 <ticks>
    80200402:	6398                	ld	a4,0(a5)
    80200404:	0705                	addi	a4,a4,1
    80200406:	e398                	sd	a4,0(a5)
            if(ticks%100==0){
    80200408:	639c                	ld	a5,0(a5)
    8020040a:	06400713          	li	a4,100
    8020040e:	02e7f7b3          	remu	a5,a5,a4
    80200412:	cb91                	beqz	a5,80200426 <interrupt_handler+0x7c>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200414:	60a2                	ld	ra,8(sp)
    80200416:	0141                	addi	sp,sp,16
    80200418:	8082                	ret
            cprintf("Supervisor external interrupt\n");
    8020041a:	00001517          	auipc	a0,0x1
    8020041e:	b0e50513          	addi	a0,a0,-1266 # 80200f28 <etext+0x520>
    80200422:	b1a1                	j	8020006a <cprintf>
            print_trapframe(tf);
    80200424:	b71d                	j	8020034a <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    80200426:	06400593          	li	a1,100
    8020042a:	00001517          	auipc	a0,0x1
    8020042e:	aee50513          	addi	a0,a0,-1298 # 80200f18 <etext+0x510>
    80200432:	c39ff0ef          	jal	ra,8020006a <cprintf>
                num++;
    80200436:	00004797          	auipc	a5,0x4
    8020043a:	be278793          	addi	a5,a5,-1054 # 80204018 <num>
    8020043e:	6398                	ld	a4,0(a5)
                if(num==10){
    80200440:	46a9                	li	a3,10
                num++;
    80200442:	0705                	addi	a4,a4,1
    80200444:	e398                	sd	a4,0(a5)
                if(num==10){
    80200446:	639c                	ld	a5,0(a5)
    80200448:	fcd796e3          	bne	a5,a3,80200414 <interrupt_handler+0x6a>
}
    8020044c:	60a2                	ld	ra,8(sp)
    8020044e:	0141                	addi	sp,sp,16
                    sbi_shutdown();
    80200450:	ab85                	j	802009c0 <sbi_shutdown>

0000000080200452 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    80200452:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
    80200456:	1141                	addi	sp,sp,-16
    80200458:	e022                	sd	s0,0(sp)
    8020045a:	e406                	sd	ra,8(sp)
    switch (tf->cause) {
    8020045c:	470d                	li	a4,3
void exception_handler(struct trapframe *tf) {
    8020045e:	842a                	mv	s0,a0
    switch (tf->cause) {
    80200460:	04e78663          	beq	a5,a4,802004ac <exception_handler+0x5a>
    80200464:	02f76c63          	bltu	a4,a5,8020049c <exception_handler+0x4a>
    80200468:	4709                	li	a4,2
    8020046a:	02e79563          	bne	a5,a4,80200494 <exception_handler+0x42>
             /* LAB1 CHALLENGE3   YOUR CODE :  */
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
            cprintf("Exception type:Illegal instruction\n");
    8020046e:	00001517          	auipc	a0,0x1
    80200472:	b0a50513          	addi	a0,a0,-1270 # 80200f78 <etext+0x570>
    80200476:	bf5ff0ef          	jal	ra,8020006a <cprintf>
            cprintf("Illegal instruction caught at 0x%x\n",tf->epc);
    8020047a:	10843583          	ld	a1,264(s0)
    8020047e:	00001517          	auipc	a0,0x1
    80200482:	b2250513          	addi	a0,a0,-1246 # 80200fa0 <etext+0x598>
    80200486:	be5ff0ef          	jal	ra,8020006a <cprintf>
            tf->epc=tf->epc+4;
    8020048a:	10843783          	ld	a5,264(s0)
    8020048e:	0791                	addi	a5,a5,4
    80200490:	10f43423          	sd	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200494:	60a2                	ld	ra,8(sp)
    80200496:	6402                	ld	s0,0(sp)
    80200498:	0141                	addi	sp,sp,16
    8020049a:	8082                	ret
    switch (tf->cause) {
    8020049c:	17f1                	addi	a5,a5,-4
    8020049e:	471d                	li	a4,7
    802004a0:	fef77ae3          	bgeu	a4,a5,80200494 <exception_handler+0x42>
}
    802004a4:	6402                	ld	s0,0(sp)
    802004a6:	60a2                	ld	ra,8(sp)
    802004a8:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004aa:	b545                	j	8020034a <print_trapframe>
            cprintf("Exception type:breakpoint\n");
    802004ac:	00001517          	auipc	a0,0x1
    802004b0:	b1c50513          	addi	a0,a0,-1252 # 80200fc8 <etext+0x5c0>
    802004b4:	bb7ff0ef          	jal	ra,8020006a <cprintf>
            cprintf("ebreak caught at 0x%x\n",tf->epc);
    802004b8:	10843583          	ld	a1,264(s0)
    802004bc:	00001517          	auipc	a0,0x1
    802004c0:	b2c50513          	addi	a0,a0,-1236 # 80200fe8 <etext+0x5e0>
    802004c4:	ba7ff0ef          	jal	ra,8020006a <cprintf>
            tf->epc=tf->epc+4;
    802004c8:	10843783          	ld	a5,264(s0)
}
    802004cc:	60a2                	ld	ra,8(sp)
            tf->epc=tf->epc+4;
    802004ce:	0791                	addi	a5,a5,4
    802004d0:	10f43423          	sd	a5,264(s0)
}
    802004d4:	6402                	ld	s0,0(sp)
    802004d6:	0141                	addi	sp,sp,16
    802004d8:	8082                	ret

00000000802004da <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    802004da:	11853783          	ld	a5,280(a0)
    802004de:	0007c363          	bltz	a5,802004e4 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    802004e2:	bf85                	j	80200452 <exception_handler>
        interrupt_handler(tf);
    802004e4:	b5d9                	j	802003aa <interrupt_handler>
	...

00000000802004e8 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    802004e8:	14011073          	csrw	sscratch,sp
    802004ec:	712d                	addi	sp,sp,-288
    802004ee:	e002                	sd	zero,0(sp)
    802004f0:	e406                	sd	ra,8(sp)
    802004f2:	ec0e                	sd	gp,24(sp)
    802004f4:	f012                	sd	tp,32(sp)
    802004f6:	f416                	sd	t0,40(sp)
    802004f8:	f81a                	sd	t1,48(sp)
    802004fa:	fc1e                	sd	t2,56(sp)
    802004fc:	e0a2                	sd	s0,64(sp)
    802004fe:	e4a6                	sd	s1,72(sp)
    80200500:	e8aa                	sd	a0,80(sp)
    80200502:	ecae                	sd	a1,88(sp)
    80200504:	f0b2                	sd	a2,96(sp)
    80200506:	f4b6                	sd	a3,104(sp)
    80200508:	f8ba                	sd	a4,112(sp)
    8020050a:	fcbe                	sd	a5,120(sp)
    8020050c:	e142                	sd	a6,128(sp)
    8020050e:	e546                	sd	a7,136(sp)
    80200510:	e94a                	sd	s2,144(sp)
    80200512:	ed4e                	sd	s3,152(sp)
    80200514:	f152                	sd	s4,160(sp)
    80200516:	f556                	sd	s5,168(sp)
    80200518:	f95a                	sd	s6,176(sp)
    8020051a:	fd5e                	sd	s7,184(sp)
    8020051c:	e1e2                	sd	s8,192(sp)
    8020051e:	e5e6                	sd	s9,200(sp)
    80200520:	e9ea                	sd	s10,208(sp)
    80200522:	edee                	sd	s11,216(sp)
    80200524:	f1f2                	sd	t3,224(sp)
    80200526:	f5f6                	sd	t4,232(sp)
    80200528:	f9fa                	sd	t5,240(sp)
    8020052a:	fdfe                	sd	t6,248(sp)
    8020052c:	14001473          	csrrw	s0,sscratch,zero
    80200530:	100024f3          	csrr	s1,sstatus
    80200534:	14102973          	csrr	s2,sepc
    80200538:	143029f3          	csrr	s3,stval
    8020053c:	14202a73          	csrr	s4,scause
    80200540:	e822                	sd	s0,16(sp)
    80200542:	e226                	sd	s1,256(sp)
    80200544:	e64a                	sd	s2,264(sp)
    80200546:	ea4e                	sd	s3,272(sp)
    80200548:	ee52                	sd	s4,280(sp)

    move  a0, sp
    8020054a:	850a                	mv	a0,sp
    jal trap
    8020054c:	f8fff0ef          	jal	ra,802004da <trap>

0000000080200550 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    80200550:	6492                	ld	s1,256(sp)
    80200552:	6932                	ld	s2,264(sp)
    80200554:	10049073          	csrw	sstatus,s1
    80200558:	14191073          	csrw	sepc,s2
    8020055c:	60a2                	ld	ra,8(sp)
    8020055e:	61e2                	ld	gp,24(sp)
    80200560:	7202                	ld	tp,32(sp)
    80200562:	72a2                	ld	t0,40(sp)
    80200564:	7342                	ld	t1,48(sp)
    80200566:	73e2                	ld	t2,56(sp)
    80200568:	6406                	ld	s0,64(sp)
    8020056a:	64a6                	ld	s1,72(sp)
    8020056c:	6546                	ld	a0,80(sp)
    8020056e:	65e6                	ld	a1,88(sp)
    80200570:	7606                	ld	a2,96(sp)
    80200572:	76a6                	ld	a3,104(sp)
    80200574:	7746                	ld	a4,112(sp)
    80200576:	77e6                	ld	a5,120(sp)
    80200578:	680a                	ld	a6,128(sp)
    8020057a:	68aa                	ld	a7,136(sp)
    8020057c:	694a                	ld	s2,144(sp)
    8020057e:	69ea                	ld	s3,152(sp)
    80200580:	7a0a                	ld	s4,160(sp)
    80200582:	7aaa                	ld	s5,168(sp)
    80200584:	7b4a                	ld	s6,176(sp)
    80200586:	7bea                	ld	s7,184(sp)
    80200588:	6c0e                	ld	s8,192(sp)
    8020058a:	6cae                	ld	s9,200(sp)
    8020058c:	6d4e                	ld	s10,208(sp)
    8020058e:	6dee                	ld	s11,216(sp)
    80200590:	7e0e                	ld	t3,224(sp)
    80200592:	7eae                	ld	t4,232(sp)
    80200594:	7f4e                	ld	t5,240(sp)
    80200596:	7fee                	ld	t6,248(sp)
    80200598:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    8020059a:	10200073          	sret

000000008020059e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    8020059e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005a2:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    802005a4:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005a8:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    802005aa:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    802005ae:	f022                	sd	s0,32(sp)
    802005b0:	ec26                	sd	s1,24(sp)
    802005b2:	e84a                	sd	s2,16(sp)
    802005b4:	f406                	sd	ra,40(sp)
    802005b6:	e44e                	sd	s3,8(sp)
    802005b8:	84aa                	mv	s1,a0
    802005ba:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    802005bc:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    802005c0:	2a01                	sext.w	s4,s4
    if (num >= base) {
    802005c2:	03067e63          	bgeu	a2,a6,802005fe <printnum+0x60>
    802005c6:	89be                	mv	s3,a5
        while (-- width > 0)
    802005c8:	00805763          	blez	s0,802005d6 <printnum+0x38>
    802005cc:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    802005ce:	85ca                	mv	a1,s2
    802005d0:	854e                	mv	a0,s3
    802005d2:	9482                	jalr	s1
        while (-- width > 0)
    802005d4:	fc65                	bnez	s0,802005cc <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    802005d6:	1a02                	slli	s4,s4,0x20
    802005d8:	00001797          	auipc	a5,0x1
    802005dc:	a2878793          	addi	a5,a5,-1496 # 80201000 <etext+0x5f8>
    802005e0:	020a5a13          	srli	s4,s4,0x20
    802005e4:	9a3e                	add	s4,s4,a5
}
    802005e6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    802005e8:	000a4503          	lbu	a0,0(s4)
}
    802005ec:	70a2                	ld	ra,40(sp)
    802005ee:	69a2                	ld	s3,8(sp)
    802005f0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    802005f2:	85ca                	mv	a1,s2
    802005f4:	87a6                	mv	a5,s1
}
    802005f6:	6942                	ld	s2,16(sp)
    802005f8:	64e2                	ld	s1,24(sp)
    802005fa:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    802005fc:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
    802005fe:	03065633          	divu	a2,a2,a6
    80200602:	8722                	mv	a4,s0
    80200604:	f9bff0ef          	jal	ra,8020059e <printnum>
    80200608:	b7f9                	j	802005d6 <printnum+0x38>

000000008020060a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    8020060a:	7119                	addi	sp,sp,-128
    8020060c:	f4a6                	sd	s1,104(sp)
    8020060e:	f0ca                	sd	s2,96(sp)
    80200610:	ecce                	sd	s3,88(sp)
    80200612:	e8d2                	sd	s4,80(sp)
    80200614:	e4d6                	sd	s5,72(sp)
    80200616:	e0da                	sd	s6,64(sp)
    80200618:	fc5e                	sd	s7,56(sp)
    8020061a:	f06a                	sd	s10,32(sp)
    8020061c:	fc86                	sd	ra,120(sp)
    8020061e:	f8a2                	sd	s0,112(sp)
    80200620:	f862                	sd	s8,48(sp)
    80200622:	f466                	sd	s9,40(sp)
    80200624:	ec6e                	sd	s11,24(sp)
    80200626:	892a                	mv	s2,a0
    80200628:	84ae                	mv	s1,a1
    8020062a:	8d32                	mv	s10,a2
    8020062c:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020062e:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    80200632:	5b7d                	li	s6,-1
    80200634:	00001a97          	auipc	s5,0x1
    80200638:	a00a8a93          	addi	s5,s5,-1536 # 80201034 <etext+0x62c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020063c:	00001b97          	auipc	s7,0x1
    80200640:	bd4b8b93          	addi	s7,s7,-1068 # 80201210 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200644:	000d4503          	lbu	a0,0(s10)
    80200648:	001d0413          	addi	s0,s10,1
    8020064c:	01350a63          	beq	a0,s3,80200660 <vprintfmt+0x56>
            if (ch == '\0') {
    80200650:	c121                	beqz	a0,80200690 <vprintfmt+0x86>
            putch(ch, putdat);
    80200652:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200654:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    80200656:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200658:	fff44503          	lbu	a0,-1(s0)
    8020065c:	ff351ae3          	bne	a0,s3,80200650 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
    80200660:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    80200664:	02000793          	li	a5,32
        lflag = altflag = 0;
    80200668:	4c81                	li	s9,0
    8020066a:	4881                	li	a7,0
        width = precision = -1;
    8020066c:	5c7d                	li	s8,-1
    8020066e:	5dfd                	li	s11,-1
    80200670:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
    80200674:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
    80200676:	fdd6059b          	addiw	a1,a2,-35
    8020067a:	0ff5f593          	zext.b	a1,a1
    8020067e:	00140d13          	addi	s10,s0,1
    80200682:	04b56263          	bltu	a0,a1,802006c6 <vprintfmt+0xbc>
    80200686:	058a                	slli	a1,a1,0x2
    80200688:	95d6                	add	a1,a1,s5
    8020068a:	4194                	lw	a3,0(a1)
    8020068c:	96d6                	add	a3,a3,s5
    8020068e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    80200690:	70e6                	ld	ra,120(sp)
    80200692:	7446                	ld	s0,112(sp)
    80200694:	74a6                	ld	s1,104(sp)
    80200696:	7906                	ld	s2,96(sp)
    80200698:	69e6                	ld	s3,88(sp)
    8020069a:	6a46                	ld	s4,80(sp)
    8020069c:	6aa6                	ld	s5,72(sp)
    8020069e:	6b06                	ld	s6,64(sp)
    802006a0:	7be2                	ld	s7,56(sp)
    802006a2:	7c42                	ld	s8,48(sp)
    802006a4:	7ca2                	ld	s9,40(sp)
    802006a6:	7d02                	ld	s10,32(sp)
    802006a8:	6de2                	ld	s11,24(sp)
    802006aa:	6109                	addi	sp,sp,128
    802006ac:	8082                	ret
            padc = '0';
    802006ae:	87b2                	mv	a5,a2
            goto reswitch;
    802006b0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    802006b4:	846a                	mv	s0,s10
    802006b6:	00140d13          	addi	s10,s0,1
    802006ba:	fdd6059b          	addiw	a1,a2,-35
    802006be:	0ff5f593          	zext.b	a1,a1
    802006c2:	fcb572e3          	bgeu	a0,a1,80200686 <vprintfmt+0x7c>
            putch('%', putdat);
    802006c6:	85a6                	mv	a1,s1
    802006c8:	02500513          	li	a0,37
    802006cc:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    802006ce:	fff44783          	lbu	a5,-1(s0)
    802006d2:	8d22                	mv	s10,s0
    802006d4:	f73788e3          	beq	a5,s3,80200644 <vprintfmt+0x3a>
    802006d8:	ffed4783          	lbu	a5,-2(s10)
    802006dc:	1d7d                	addi	s10,s10,-1
    802006de:	ff379de3          	bne	a5,s3,802006d8 <vprintfmt+0xce>
    802006e2:	b78d                	j	80200644 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
    802006e4:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
    802006e8:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    802006ec:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    802006ee:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    802006f2:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    802006f6:	02d86463          	bltu	a6,a3,8020071e <vprintfmt+0x114>
                ch = *fmt;
    802006fa:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
    802006fe:	002c169b          	slliw	a3,s8,0x2
    80200702:	0186873b          	addw	a4,a3,s8
    80200706:	0017171b          	slliw	a4,a4,0x1
    8020070a:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
    8020070c:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
    80200710:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    80200712:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
    80200716:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    8020071a:	fed870e3          	bgeu	a6,a3,802006fa <vprintfmt+0xf0>
            if (width < 0)
    8020071e:	f40ddce3          	bgez	s11,80200676 <vprintfmt+0x6c>
                width = precision, precision = -1;
    80200722:	8de2                	mv	s11,s8
    80200724:	5c7d                	li	s8,-1
    80200726:	bf81                	j	80200676 <vprintfmt+0x6c>
            if (width < 0)
    80200728:	fffdc693          	not	a3,s11
    8020072c:	96fd                	srai	a3,a3,0x3f
    8020072e:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
    80200732:	00144603          	lbu	a2,1(s0)
    80200736:	2d81                	sext.w	s11,s11
    80200738:	846a                	mv	s0,s10
            goto reswitch;
    8020073a:	bf35                	j	80200676 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
    8020073c:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
    80200740:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    80200744:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
    80200746:	846a                	mv	s0,s10
            goto process_precision;
    80200748:	bfd9                	j	8020071e <vprintfmt+0x114>
    if (lflag >= 2) {
    8020074a:	4705                	li	a4,1
            precision = va_arg(ap, int);
    8020074c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    80200750:	01174463          	blt	a4,a7,80200758 <vprintfmt+0x14e>
    else if (lflag) {
    80200754:	1a088e63          	beqz	a7,80200910 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
    80200758:	000a3603          	ld	a2,0(s4)
    8020075c:	46c1                	li	a3,16
    8020075e:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
    80200760:	2781                	sext.w	a5,a5
    80200762:	876e                	mv	a4,s11
    80200764:	85a6                	mv	a1,s1
    80200766:	854a                	mv	a0,s2
    80200768:	e37ff0ef          	jal	ra,8020059e <printnum>
            break;
    8020076c:	bde1                	j	80200644 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
    8020076e:	000a2503          	lw	a0,0(s4)
    80200772:	85a6                	mv	a1,s1
    80200774:	0a21                	addi	s4,s4,8
    80200776:	9902                	jalr	s2
            break;
    80200778:	b5f1                	j	80200644 <vprintfmt+0x3a>
    if (lflag >= 2) {
    8020077a:	4705                	li	a4,1
            precision = va_arg(ap, int);
    8020077c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    80200780:	01174463          	blt	a4,a7,80200788 <vprintfmt+0x17e>
    else if (lflag) {
    80200784:	18088163          	beqz	a7,80200906 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
    80200788:	000a3603          	ld	a2,0(s4)
    8020078c:	46a9                	li	a3,10
    8020078e:	8a2e                	mv	s4,a1
    80200790:	bfc1                	j	80200760 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
    80200792:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    80200796:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200798:	846a                	mv	s0,s10
            goto reswitch;
    8020079a:	bdf1                	j	80200676 <vprintfmt+0x6c>
            putch(ch, putdat);
    8020079c:	85a6                	mv	a1,s1
    8020079e:	02500513          	li	a0,37
    802007a2:	9902                	jalr	s2
            break;
    802007a4:	b545                	j	80200644 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
    802007a6:	00144603          	lbu	a2,1(s0)
            lflag ++;
    802007aa:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
    802007ac:	846a                	mv	s0,s10
            goto reswitch;
    802007ae:	b5e1                	j	80200676 <vprintfmt+0x6c>
    if (lflag >= 2) {
    802007b0:	4705                	li	a4,1
            precision = va_arg(ap, int);
    802007b2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    802007b6:	01174463          	blt	a4,a7,802007be <vprintfmt+0x1b4>
    else if (lflag) {
    802007ba:	14088163          	beqz	a7,802008fc <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
    802007be:	000a3603          	ld	a2,0(s4)
    802007c2:	46a1                	li	a3,8
    802007c4:	8a2e                	mv	s4,a1
    802007c6:	bf69                	j	80200760 <vprintfmt+0x156>
            putch('0', putdat);
    802007c8:	03000513          	li	a0,48
    802007cc:	85a6                	mv	a1,s1
    802007ce:	e03e                	sd	a5,0(sp)
    802007d0:	9902                	jalr	s2
            putch('x', putdat);
    802007d2:	85a6                	mv	a1,s1
    802007d4:	07800513          	li	a0,120
    802007d8:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    802007da:	0a21                	addi	s4,s4,8
            goto number;
    802007dc:	6782                	ld	a5,0(sp)
    802007de:	46c1                	li	a3,16
            num = (unsigned long long)va_arg(ap, void *);
    802007e0:	ff8a3603          	ld	a2,-8(s4)
            goto number;
    802007e4:	bfb5                	j	80200760 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
    802007e6:	000a3403          	ld	s0,0(s4)
    802007ea:	008a0713          	addi	a4,s4,8
    802007ee:	e03a                	sd	a4,0(sp)
    802007f0:	14040263          	beqz	s0,80200934 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
    802007f4:	0fb05763          	blez	s11,802008e2 <vprintfmt+0x2d8>
    802007f8:	02d00693          	li	a3,45
    802007fc:	0cd79163          	bne	a5,a3,802008be <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200800:	00044783          	lbu	a5,0(s0)
    80200804:	0007851b          	sext.w	a0,a5
    80200808:	cf85                	beqz	a5,80200840 <vprintfmt+0x236>
    8020080a:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
    8020080e:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200812:	000c4563          	bltz	s8,8020081c <vprintfmt+0x212>
    80200816:	3c7d                	addiw	s8,s8,-1
    80200818:	036c0263          	beq	s8,s6,8020083c <vprintfmt+0x232>
                    putch('?', putdat);
    8020081c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    8020081e:	0e0c8e63          	beqz	s9,8020091a <vprintfmt+0x310>
    80200822:	3781                	addiw	a5,a5,-32
    80200824:	0ef47b63          	bgeu	s0,a5,8020091a <vprintfmt+0x310>
                    putch('?', putdat);
    80200828:	03f00513          	li	a0,63
    8020082c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020082e:	000a4783          	lbu	a5,0(s4)
    80200832:	3dfd                	addiw	s11,s11,-1
    80200834:	0a05                	addi	s4,s4,1
    80200836:	0007851b          	sext.w	a0,a5
    8020083a:	ffe1                	bnez	a5,80200812 <vprintfmt+0x208>
            for (; width > 0; width --) {
    8020083c:	01b05963          	blez	s11,8020084e <vprintfmt+0x244>
    80200840:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200842:	85a6                	mv	a1,s1
    80200844:	02000513          	li	a0,32
    80200848:	9902                	jalr	s2
            for (; width > 0; width --) {
    8020084a:	fe0d9be3          	bnez	s11,80200840 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
    8020084e:	6a02                	ld	s4,0(sp)
    80200850:	bbd5                	j	80200644 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200852:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80200854:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
    80200858:	01174463          	blt	a4,a7,80200860 <vprintfmt+0x256>
    else if (lflag) {
    8020085c:	08088d63          	beqz	a7,802008f6 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
    80200860:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
    80200864:	0a044d63          	bltz	s0,8020091e <vprintfmt+0x314>
            num = getint(&ap, lflag);
    80200868:	8622                	mv	a2,s0
    8020086a:	8a66                	mv	s4,s9
    8020086c:	46a9                	li	a3,10
    8020086e:	bdcd                	j	80200760 <vprintfmt+0x156>
            err = va_arg(ap, int);
    80200870:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200874:	4719                	li	a4,6
            err = va_arg(ap, int);
    80200876:	0a21                	addi	s4,s4,8
            if (err < 0) {
    80200878:	41f7d69b          	sraiw	a3,a5,0x1f
    8020087c:	8fb5                	xor	a5,a5,a3
    8020087e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200882:	02d74163          	blt	a4,a3,802008a4 <vprintfmt+0x29a>
    80200886:	00369793          	slli	a5,a3,0x3
    8020088a:	97de                	add	a5,a5,s7
    8020088c:	639c                	ld	a5,0(a5)
    8020088e:	cb99                	beqz	a5,802008a4 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
    80200890:	86be                	mv	a3,a5
    80200892:	00000617          	auipc	a2,0x0
    80200896:	79e60613          	addi	a2,a2,1950 # 80201030 <etext+0x628>
    8020089a:	85a6                	mv	a1,s1
    8020089c:	854a                	mv	a0,s2
    8020089e:	0ce000ef          	jal	ra,8020096c <printfmt>
    802008a2:	b34d                	j	80200644 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    802008a4:	00000617          	auipc	a2,0x0
    802008a8:	77c60613          	addi	a2,a2,1916 # 80201020 <etext+0x618>
    802008ac:	85a6                	mv	a1,s1
    802008ae:	854a                	mv	a0,s2
    802008b0:	0bc000ef          	jal	ra,8020096c <printfmt>
    802008b4:	bb41                	j	80200644 <vprintfmt+0x3a>
                p = "(null)";
    802008b6:	00000417          	auipc	s0,0x0
    802008ba:	76240413          	addi	s0,s0,1890 # 80201018 <etext+0x610>
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008be:	85e2                	mv	a1,s8
    802008c0:	8522                	mv	a0,s0
    802008c2:	e43e                	sd	a5,8(sp)
    802008c4:	116000ef          	jal	ra,802009da <strnlen>
    802008c8:	40ad8dbb          	subw	s11,s11,a0
    802008cc:	01b05b63          	blez	s11,802008e2 <vprintfmt+0x2d8>
                    putch(padc, putdat);
    802008d0:	67a2                	ld	a5,8(sp)
    802008d2:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008d6:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    802008d8:	85a6                	mv	a1,s1
    802008da:	8552                	mv	a0,s4
    802008dc:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008de:	fe0d9ce3          	bnez	s11,802008d6 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802008e2:	00044783          	lbu	a5,0(s0)
    802008e6:	00140a13          	addi	s4,s0,1
    802008ea:	0007851b          	sext.w	a0,a5
    802008ee:	d3a5                	beqz	a5,8020084e <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
    802008f0:	05e00413          	li	s0,94
    802008f4:	bf39                	j	80200812 <vprintfmt+0x208>
        return va_arg(*ap, int);
    802008f6:	000a2403          	lw	s0,0(s4)
    802008fa:	b7ad                	j	80200864 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
    802008fc:	000a6603          	lwu	a2,0(s4)
    80200900:	46a1                	li	a3,8
    80200902:	8a2e                	mv	s4,a1
    80200904:	bdb1                	j	80200760 <vprintfmt+0x156>
    80200906:	000a6603          	lwu	a2,0(s4)
    8020090a:	46a9                	li	a3,10
    8020090c:	8a2e                	mv	s4,a1
    8020090e:	bd89                	j	80200760 <vprintfmt+0x156>
    80200910:	000a6603          	lwu	a2,0(s4)
    80200914:	46c1                	li	a3,16
    80200916:	8a2e                	mv	s4,a1
    80200918:	b5a1                	j	80200760 <vprintfmt+0x156>
                    putch(ch, putdat);
    8020091a:	9902                	jalr	s2
    8020091c:	bf09                	j	8020082e <vprintfmt+0x224>
                putch('-', putdat);
    8020091e:	85a6                	mv	a1,s1
    80200920:	02d00513          	li	a0,45
    80200924:	e03e                	sd	a5,0(sp)
    80200926:	9902                	jalr	s2
                num = -(long long)num;
    80200928:	6782                	ld	a5,0(sp)
    8020092a:	8a66                	mv	s4,s9
    8020092c:	40800633          	neg	a2,s0
    80200930:	46a9                	li	a3,10
    80200932:	b53d                	j	80200760 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
    80200934:	03b05163          	blez	s11,80200956 <vprintfmt+0x34c>
    80200938:	02d00693          	li	a3,45
    8020093c:	f6d79de3          	bne	a5,a3,802008b6 <vprintfmt+0x2ac>
                p = "(null)";
    80200940:	00000417          	auipc	s0,0x0
    80200944:	6d840413          	addi	s0,s0,1752 # 80201018 <etext+0x610>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200948:	02800793          	li	a5,40
    8020094c:	02800513          	li	a0,40
    80200950:	00140a13          	addi	s4,s0,1
    80200954:	bd6d                	j	8020080e <vprintfmt+0x204>
    80200956:	00000a17          	auipc	s4,0x0
    8020095a:	6c3a0a13          	addi	s4,s4,1731 # 80201019 <etext+0x611>
    8020095e:	02800513          	li	a0,40
    80200962:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
    80200966:	05e00413          	li	s0,94
    8020096a:	b565                	j	80200812 <vprintfmt+0x208>

000000008020096c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    8020096c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    8020096e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200972:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200974:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200976:	ec06                	sd	ra,24(sp)
    80200978:	f83a                	sd	a4,48(sp)
    8020097a:	fc3e                	sd	a5,56(sp)
    8020097c:	e0c2                	sd	a6,64(sp)
    8020097e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    80200980:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200982:	c89ff0ef          	jal	ra,8020060a <vprintfmt>
}
    80200986:	60e2                	ld	ra,24(sp)
    80200988:	6161                	addi	sp,sp,80
    8020098a:	8082                	ret

000000008020098c <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
    8020098c:	4781                	li	a5,0
    8020098e:	00003717          	auipc	a4,0x3
    80200992:	67273703          	ld	a4,1650(a4) # 80204000 <SBI_CONSOLE_PUTCHAR>
    80200996:	88ba                	mv	a7,a4
    80200998:	852a                	mv	a0,a0
    8020099a:	85be                	mv	a1,a5
    8020099c:	863e                	mv	a2,a5
    8020099e:	00000073          	ecall
    802009a2:	87aa                	mv	a5,a0
int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
    802009a4:	8082                	ret

00000000802009a6 <sbi_set_timer>:
    __asm__ volatile (
    802009a6:	4781                	li	a5,0
    802009a8:	00003717          	auipc	a4,0x3
    802009ac:	67873703          	ld	a4,1656(a4) # 80204020 <SBI_SET_TIMER>
    802009b0:	88ba                	mv	a7,a4
    802009b2:	852a                	mv	a0,a0
    802009b4:	85be                	mv	a1,a5
    802009b6:	863e                	mv	a2,a5
    802009b8:	00000073          	ecall
    802009bc:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
    802009be:	8082                	ret

00000000802009c0 <sbi_shutdown>:
    __asm__ volatile (
    802009c0:	4781                	li	a5,0
    802009c2:	00003717          	auipc	a4,0x3
    802009c6:	64673703          	ld	a4,1606(a4) # 80204008 <SBI_SHUTDOWN>
    802009ca:	88ba                	mv	a7,a4
    802009cc:	853e                	mv	a0,a5
    802009ce:	85be                	mv	a1,a5
    802009d0:	863e                	mv	a2,a5
    802009d2:	00000073          	ecall
    802009d6:	87aa                	mv	a5,a0


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    802009d8:	8082                	ret

00000000802009da <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    802009da:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
    802009dc:	e589                	bnez	a1,802009e6 <strnlen+0xc>
    802009de:	a811                	j	802009f2 <strnlen+0x18>
        cnt ++;
    802009e0:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    802009e2:	00f58863          	beq	a1,a5,802009f2 <strnlen+0x18>
    802009e6:	00f50733          	add	a4,a0,a5
    802009ea:	00074703          	lbu	a4,0(a4)
    802009ee:	fb6d                	bnez	a4,802009e0 <strnlen+0x6>
    802009f0:	85be                	mv	a1,a5
    }
    return cnt;
}
    802009f2:	852e                	mv	a0,a1
    802009f4:	8082                	ret

00000000802009f6 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    802009f6:	ca01                	beqz	a2,80200a06 <memset+0x10>
    802009f8:	962a                	add	a2,a2,a0
    char *p = s;
    802009fa:	87aa                	mv	a5,a0
        *p ++ = c;
    802009fc:	0785                	addi	a5,a5,1
    802009fe:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    80200a02:	fec79de3          	bne	a5,a2,802009fc <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200a06:	8082                	ret
