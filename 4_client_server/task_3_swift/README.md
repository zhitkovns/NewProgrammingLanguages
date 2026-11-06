# TCP-клиент с таймаутом

**Тема:** Клиент-серверное взаимодействие - Swift

## Описание задачи

TCP-клиент на `Network.framework` (стандартный фреймворк Apple, не
сторонняя библиотека). Асинхронная модель: `NWConnection` принимает
stateUpdateHandler, который вызывается при переходах состояний
(preparing/ready/failed/waiting).

После `.ready` отправляется сообщение через `connection.send(...)`,
затем `connection.receive(...)` - оба с completion-handler. Таймаут
5 секунд - через `DispatchQueue.global().asyncAfter(deadline:)`:
если за 5 секунд не пришел ответ, вызывается `finish("timeout")`.

`finish` защищена `NSLock` и флагом `completed`, чтобы сигналить
семафор ровно один раз - несколько путей могут попытаться завершить
соединение (send-error, receive-error, timeout, failed). Без этой
защиты второй `signal()` на семафоре нарушил бы счетчик.

`DispatchSemaphore.wait()` в конце - превращает асинхронный API в
синхронный main. Основной поток ждет до 10 секунд.

## Формат входных и выходных данных

Сервер на 127.0.0.1:8080. Отправляется одна строка, читается ответ.
В stdout - диагностика (connect state, ошибки, ответ).

## Установка

Swift для Linux доступен через swift.org. Инструкция:
https://www.swift.org/install/linux/

Для Ubuntu 22.04+ обычно:

```bash
sudo apt install swift
```

## Запуск

```bash
swiftc main.swift -o client
./client
```