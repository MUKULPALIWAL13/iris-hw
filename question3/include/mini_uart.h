#pragma once

void uart_init();
void uart_send(char c);
char uart_recv();
void uart_puts(const char *s);
