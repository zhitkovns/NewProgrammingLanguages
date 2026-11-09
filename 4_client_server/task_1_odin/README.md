# UDP-сервер разрешения имен

**Тема:** Клиент-серверное взаимодействие - ODIN

## Описание задачи

Программа представляет собой UDP-сервер, эмулирующий базовую службу
разрешения имен (как DNS). Сервер слушает порт 8081 на локальном хосте.
В памяти сервера хранится статическая таблица соответствия имен хостов
и IP-адресов.

Клиент отправляет серверу текстовое имя хоста в виде UDP-пакета. Сервер
принимает пакет, извлекает имя (обрезая пробельные символы) и ищет его в
таблице. Если имя найдено, сервер отправляет обратно строку с IP-адресом.
Если имя отсутствует в таблице, возвращается строка NOT_FOUND.

Для предотвращения бесконечного зависания сервер обрабатывает ровно
3 запроса, после чего завершает работу. Все системные вызовы (создание
сокета, прием и отправка пакетов) проверяются на наличие ошибок.

## Формат входных и выходных данных

Входные данные - текстовые UDP-пакеты с именами хостов.
Выходные данные - UDP-пакеты с IP-адресами (или NOT_FOUND) и лог
событий в консоли.

## Установка

Требуется компилятор ODIN. В Windows он скачивается с официального сайта
в виде ZIP-архива.

1. Скачайте архив для Windows с сайта https://odin-lang.org/.
2. Распакуйте в папку (например, D:\Apps\Odin).
3. Добавьте путь к папке с odin.exe в переменную PATH.
4. Для компиляции также требуются Visual Studio Build Tools.

Проверка: `odin version`.

## Запуск

Выполните компиляцию из PowerShell (из папки с файлом):

```powershell
odin build main.odin -file
```

Откройте два окна терминала. В первом запустите сервер:

```powershell
.\main.exe
```

Сервер выведет сообщение и будет ждать UDP-пакеты. Во втором окне
PowerShell скопируйте и выполните этот скрипт. Он автоматически
отправит три запроса и выведет ответы:

```powershell
$udpClient = New-Object System.Net.Sockets.UdpClient
$udpClient.Connect("127.0.0.1", 8081)
$remoteEp = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, 0)

$names = @("google.com", "myhost", "unknown.com")

foreach ($name in $names) {
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($name)
    $udpClient.Send($bytes, $bytes.Length) | Out-Null

    $udpClient.Client.ReceiveTimeout = 2000
    try {
        $response = $udpClient.Receive([ref]$remoteEp)
        $respStr = [System.Text.Encoding]::ASCII.GetString($response)
        Write-Host "Query: $name -> Response: $respStr"
    } catch {
        Write-Host "Query: $name -> Timeout"
    }
}
$udpClient.Close()
```

Ожидаемый вывод клиента:

```text
Query: google.com -> Response: 142.250.74.46
Query: myhost -> Response: 192.168.1.100
Query: unknown.com -> Timeout
```

Ожидаемый вывод сервера:

```text
UDP name resolution server listening on 127.0.0.1:8081
Received query: "google.com" from 127.0.0.1:64754
Sent response: "142.250.74.46"
Received query: "google.com" from 127.0.0.1:61865
Sent response: "142.250.74.46"
Received query: "myhost" from 127.0.0.1:61865
Sent response: "192.168.1.100"
Server stopped after 3 requests
```