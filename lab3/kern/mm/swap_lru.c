#include <defs.h>
#include <riscv.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <swap_lru.h>
#include <list.h>


static list_entry_t pra_list_head;

static int
_lru_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
     return 0;
}

static int
_lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    //考虑加入的时候entry可能在链表中

    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_entry_t *curr=(list_entry_t*) mm->sm_priv;
    list_entry_t *entry=&(page->pra_page_link);

    assert(entry != NULL && head != NULL);
    while((curr=list_next(curr))!=head){
        if(curr==entry){
            list_del(entry);
            break;
        }
    }
    list_add(head, entry);
    return 0;
}

static uintptr_t lru_access(uintptr_t addr)
{
    list_entry_t *head=& pra_list_head;
    list_entry_t *curr=& pra_list_head;
    pte_t **ptep_store = NULL;
    struct Page *page = get_page(boot_pgdir, addr, ptep_store);
    if (page != NULL)
    {
        list_entry_t *entry = &(page->pra_page_link);
        while((curr=list_next(curr))!=head){
            if(curr==entry){
                list_del(entry);
                break;
            }
        }
        list_add(head, entry);
    }
    return addr;
}



static int
_lru_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
         assert(head != NULL);
     assert(in_tick==0);
     list_entry_t* entry = list_prev(head);//交换空间里的候选，交换空间里的页面都是可交换的内存页！
    if (entry != head) {
        list_del(entry);
        *ptr_page = le2page(entry, pra_page_link);
    } else {
        *ptr_page = NULL;
    }
    return 0;
}

static int
_lru_check_swap(void) {
    //d c b a 离当前时间 近---远
    cprintf("write Virt Page c in_lru_check_swap\n");
    *(unsigned char *)lru_access(0x3000) = 0x0c;
    assert(pgfault_num==4);
    cprintf("write Virt Page a in_lru_check_swap\n");
    *(unsigned char *)lru_access(0x1000) = 0x0a;
    assert(pgfault_num==4);
    cprintf("write Virt Page d in_lru_check_swap\n");
    *(unsigned char *)lru_access(0x4000) = 0x0d;
    assert(pgfault_num==4);
    cprintf("write Virt Page b in_lru_check_swap\n");
    *(unsigned char *)lru_access(0x2000) = 0x0b;
    assert(pgfault_num==4);
    cprintf("write Virt Page e in_lru_check_swap\n");
    //此时替换c！e b d a 
    *(unsigned char *)lru_access(0x5000) = 0x0e;
    assert(pgfault_num==5);
    cprintf("write Virt Page b in_lru_check_swap\n");
    *(unsigned char *)lru_access(0x2000) = 0x0b;
    //b e d a
    assert(pgfault_num==5);
    cprintf("write Virt Page a in_lru_check_swap\n");
    *(unsigned char *)lru_access(0x1000) = 0x0a;
    //a b e d
    assert(pgfault_num==5);
    cprintf("write Virt Page b in_lru_check_swap\n");
    *(unsigned char *)lru_access(0x2000) = 0x0b;
    //b a e d
    assert(pgfault_num==5);
    cprintf("write Virt Page c in_lru_check_swap\n");
    *(unsigned char *)lru_access(0x3000) = 0x0c;
    //此时替换d。c b a e
    assert(pgfault_num==6);
    cprintf("write Virt Page d in_lru_check_swap\n");
    *(unsigned char *)lru_access(0x4000) = 0x0d;
    assert(pgfault_num==7);
    //此时替换e。 d c b a
    cprintf("write Virt Page e in_lru_check_swap\n");
    *(unsigned char *)lru_access(0x5000) = 0x0e;
    assert(pgfault_num==8);
    //此时替换a。 e d c b 
    cprintf("write Virt Page a in_lru_check_swap\n");
    *(unsigned char *)lru_access(0x1000) = 0x0a;
    //此时替换b。 a e d c
    assert(pgfault_num==9);
    return 0;
}


static int
_lru_init(void)
{
    return 0;
}

static int
_lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}

static int
_lru_tick_event(struct mm_struct *mm)
{ return 0; }


struct swap_manager swap_manager_lru =
{
     .name            = "lru swap manager",
     .init            = &_lru_init,
     .init_mm         = &_lru_init_mm,
     .tick_event      = &_lru_tick_event,
     .map_swappable   = &_lru_map_swappable,
     .set_unswappable = &_lru_set_unswappable,
     .swap_out_victim = &_lru_swap_out_victim,
     .check_swap      = &_lru_check_swap,
};
