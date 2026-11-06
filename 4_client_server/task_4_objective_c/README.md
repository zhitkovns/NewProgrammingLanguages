# TCP-клиент с ретраями через BSD-сокеты

**Тема:** Клиент-серверное взаимодействие - Objective-C

## Описание задачи

TCP-клиент на низкоуровневых BSD-сокетах (`<sys/socket.h>`,
`<netinet/in.h>`, `<arpa/inet.h>`). До 3 попыток с паузой 1 секунда
между ними. Подключение к 127.0.0.1:8080, отправка одной строки,
чтение до 1024 байт ответа.

`try_connect` инкапсулирует одну попытку: `socket`, `inet_pton`,
`connect`. При ошибке на любом шаге сокет закрывается через `close`,
возвращается -1. Основной цикл пробует `try_connect` до 3 раз.

Все системные вызовы (`socket`, `connect`, `send`, `recv`) возвращают
-1 при ошибке - везде проверяется и логируется через `NSLog` с
`strerror(errno)`, чтобы в консоли было читаемое описание ошибки.
`send` может вернуть меньше байт, чем отправлено, но для одной
короткой строки этого достаточно.

## Формат входных и выходных данных

Сервер на 127.0.0.1:8080. Отправляется одна строка, читается ответ.
Все сообщения - в stderr через `NSLog`.

## Установка

Нужен clang и GNUstep (свободная реализация Foundation):

```bash
sudo apt install gnustep-devel gobjc
```

## Запуск

Сборка:

```bash
gcc `gnustep-config --objc-flags` main.m -o client `gnustep-config --base-libs`
```

Запуск (требуется работающий сервер на 127.0.0.1:8080, например из
task_1_odin):

```bash
./client
```
Успешный вывод клиента:

```text
attempt 1 of 3
connected
sent 28 bytes
received: Hello from Objective-C client
```

Вывод сервера в этот момент:

```text
server listening on 127.0.0.1:8080
client 1 connected
received 29 bytes
```

Проверка ретраев (сервер не запущен) - три попытки с паузой 1 секунда:

```text
attempt 1 of 3
connect error: Connection refused
attempt 2 of 3
connect error: Connection refused
attempt 3 of 3
connect error: Connection refused
failed to connect after 3 attempts
```

NSLog пишет в stderr и добавляет временной префикс
YYYY-MM-DD HH:MM:SS.mmm client[PID:tid] перед каждой строкой - это
штатное поведение GNUstep, не ошибка.