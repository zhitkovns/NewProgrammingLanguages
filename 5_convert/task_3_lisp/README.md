# Ассоциативный список <-> строки ключ=значение

**Тема:** Конвертация данных - Common Lisp

## Описание задачи

`alist-to-string` пишет alist (список пар `(key . value)`) в строку
формата `key=value\n` на каждую пару. Используется
`with-output-to-string`: он подменяет `*standard-output*` на поток в
строку, `dolist` проходит по alist, `format` с директивой `~A` печатает
без экранирования.

`string-to-alist` - обратная операция. `with-input-from-string` подменяет
`*standard-input*` на строку, `loop ... for line = (read-line in nil)`
читает построчно (nil - не падать на EOF, а вернуть nil). Для каждой
строки ищется позиция `=` через `position`; если найдено - ключ и
значение вырезаются через `subseq`.

Round-trip проверяется через `equal`: `parse(dump(alist))` должен дать
ровно тот же alist.

## Формат входных и выходных данных

Входных данных нет (alist задан в main). Выходные данные: оригинал,
закодированная строка, декодированный alist и флаг round-trip.

## Установка

```bash
sudo apt install sbcl
```

## Запуск

```bash
sbcl --script main.lisp
```
Также работает в CCL и ECL.