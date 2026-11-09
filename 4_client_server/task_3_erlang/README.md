# Сервер сетевых семафоров

**Тема:** Клиент-серверное взаимодействие - Erlang

## Описание задачи

Программа реализует TCP-сервер, управляющий семафорами (примитивами
синхронизации) для удаленных клиентов. Сервер позволяет клиентам
захватывать (ACQUIRE) и освобождать (RELEASE) именованные семафоры.

Архитектура использует модель акторов Erlang:
1. Главный процесс слушает TCP-порт 8083 и порождает новый процесс для
   каждого подключения.
2. Процесс-менеджер (manager_loop) хранит состояние всех семафоров в
   виде словаря (map).
3. Если клиент запрашивает свободный семафор, менеджер помечает его
   занятым и сразу отправляет клиенту ответ OK.
4. Если семафор занят, менеджер добавляет идентификатор процесса клиента
   в очередь. Процесс-обработчик клиента блокируется в ожидании
   сообщения {acquired, Name}.
5. Когда текущий владелец отправляет RELEASE, менеджер извлекает
   первого клиента из очереди, будит его и передает ему права на
   семафор.

Для тестирования также реализован клиент на Erlang, который запускает
два параллельных процесса (Client1 и Client2), имитируя двух
пользователей, ожидающих освобождения семафора.

## Формат входных и выходных данных

Входные данные - текстовые команды по TCP: ACQUIRE <имя> или RELEASE <имя>.
Выходные данные - ответы OK или ERROR, а также лог событий в консоли.

## Установка

Требуется среда Erlang/OTP. В Windows она устанавливается через менеджер
пакетов winget.

Выполните в PowerShell:
```powershell
winget install --id Erlang.ErlangOTP -e
```

Проверка: `erl -version`.

## Компиляция

Выполните компиляцию сервера и клиента из PowerShell (из папки с файлами):

```powershell
erlc main.erl
erlc client.erl
```

## Запуск

Откройте два окна терминала PowerShell.

В первом окне запустите сервер (флаг `-pa .` указывает Erlang искать
скомпилированные модули в текущей папке):

```powershell
erl -noshell -pa . -s main start
```

Сервер выведет сообщение и будет ждать подключения. Во втором окне
запустите клиент (он автоматически откроет два соединения):

```powershell
erl -noshell -pa . -s client start
```

Ожидаемый вывод клиента (Client2 ждет, пока Client1 не сделает RELEASE):

```text
Starting two test clients...
Client1: Sending ACQUIRE lock
Client1: Got OK
Client2: Sending ACQUIRE lock
Client1: Sending RELEASE lock
Client1: Got OK
Client2: Got OK
Client2: Sending RELEASE lock
Client2: Got OK
```

Ожидаемый вывод сервера:

```text
Semaphore TCP server listening on 127.0.0.1:8083
Client connected
Received command: ACQUIRE lock
Granted lock
Client connected
Received command: ACQUIRE lock
Received command: RELEASE lock
Released lock
Granted lock
Received command: RELEASE lock
Released lock
Client disconnected
```