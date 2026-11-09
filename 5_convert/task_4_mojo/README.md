# Извлечение каталога файлов из ZIP в CSV

**Тема:** Конвертация данных - Mojo

## Описание задачи

Программа читает ZIP-архив на уровне байтов и извлекает метаданные о
файлах, сохраняя их в формате CSV. Специализированные библиотеки для
работы с ZIP не используются.

ZIP-файл состоит из локальных заголовков и центрального каталога. В
данной программе реализован поиск сигнатуры центрального каталога
(PK\x01\x02). При нахождении заголовка из него извлекаются:
- метод сжатия (2 байта, little-endian)
- сжатый размер (4 байта, little-endian)
- несжатый размер (4 байта, little-endian)
- длина имени файла (2 байта, little-endian)

Затем извлекается само имя файла и формируется строка CSV.

Для чтения бинарных данных используется стандартный метод read_bytes(),
который возвращает массив сырых байтов (List[UInt8]), что позволяет
избежать ошибок, связанных со строгой валидацией кодировки UTF-8.

## Формат входных и выходных данных

Входной файл - test.zip.
Выходной файл - output.csv.
Выходные данные - сообщение об успехе и CSV-файл с каталогом.

## Установка и запуск

Mojo официально не поддерживает Windows нативно, поэтому используется
официально поддерживаемый способ - WSL (Windows Subsystem for Linux) с
дистрибутивом Ubuntu.

1. Откройте PowerShell и запустите WSL:
```powershell
wsl -d Ubuntu
```

2. Внутри WSL установите необходимые пакеты (если еще не сделано):
```bash
sudo apt update && sudo apt install build-essential curl zip -y
```

3. Установите uv и создайте окружение:
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc
uv venv ~/mojo_env
source ~/mojo_env/bin/activate
uv pip install mojo --prerelease allow
```

4. Перейдите в папку с программой (путь к диску D: в WSL):
```bash
cd "/mnt/d/Program Files (x86)/VS Code projects/new_languages/individual/NewProgrammingLanguages/5_convert/task_4_mojo"
```

5. Создайте тестовый ZIP-архив (пустые файлы без сжатия):
```bash
touch file1.txt file2.bin
zip -0 test.zip file1.txt file2.bin
```

6. Соберите и запустите программу:
```bash
mojo build main.mojo -o main
./main
```

Ожидаемый вывод в консоли:
```text
Successfully extracted catalog to output.csv
```

Файл output.csv будет содержать:
```csv
filename,compressed_size,uncompressed_size,compression_method
file1.txt,0,0,0
file2.bin,0,0,0
```