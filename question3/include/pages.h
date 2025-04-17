#pragma once

#define PAGE_TABLE_BASE 0x4000

void setup_identity_mapping();
unsigned int *get_page_table_base();
