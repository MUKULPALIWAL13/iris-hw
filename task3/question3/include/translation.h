#pragma once

#define TRANSLATION_TABLE_BASE 0x4000

void map_kernel_and_user_space();
unsigned int *get_translation_table();
