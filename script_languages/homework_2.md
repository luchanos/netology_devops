#### Задание 1
Есть скрипт:

#!/usr/bin/env python3
a = 1
b = '2'
c = a + b
Вопросы:
Вопрос	Ответ
Какое значение будет присвоено переменной c?	???
Как получить для переменной c значение 12?	???
Как получить для переменной c значение 3?	???

Вопрос | Ответ                                                                                                                                                                                                                            |                                                                                                            
--- |----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
Какое значение будет присвоено переменной c? | В данном случае код вызовет ошибку, и переменной c не будет присвоено значение                                                                                                                                                   |
Как получить для переменной c значение 12? | Чтобы получить для переменной c значение 12, необходимо привести переменную a к типу строки (str) и выполнить конкатенацию строк `c = str(a) + b`                                                                                |
Как получить для переменной c значение 3? | В данном случае невозможно получить для переменной c значение 3, так как операция сложения между целым числом и строкой не имеет смысла. Необходимо использовать совместимые типы данных для выполнения арифметических операций. |                                                           |

#### Задание 2
Мы устроились на работу в компанию, где раньше уже был DevOps-инженер. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся.

Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

```
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
        break
```

Для улучшения скрипта можно внести следующие изменения:
- Использовать абсолютный путь к директории репозитория вместо относительного пути. Таким образом, будет ясно, где находятся измененные файлы.
- Учитывать все измененные файлы, а не только первый найденный.
- Проверять статус файла, чтобы убедиться, что он действительно изменен, и исключать файлы, находящиеся в других статусах (например, deleted, untracked).
- Выводить полный путь к измененным файлам.

Исправленный скрипт:
```
#!/usr/bin/env python3

import subprocess

repo_dir = "<path_to_dir>"
git_status_command = ["git", "-C", repo_dir, "status", "-s"]
result = subprocess.run(git_status_command, capture_output=True, text=True).stdout.strip()

changed_files = []

for line in result.split('\n'):
    if line.startswith(' M'):
        file_path = line[3:].strip()
        changed_files.append(file_path)

if changed_files:
    for file_path in changed_files:
        full_path = os.path.join(repo_dir, file_path)
        print(full_path)
else:
    print("No modified files found.")
```
Вывод:
```
/my_repo/file1.txt
/my_repo/dir/file3.txt
```
или
```No modified files found.```

#### Задание 3
Доработать скрипт выше так, чтобы он не только мог проверять локальный репозиторий в текущей директории, но и умел воспринимать путь к репозиторию, который мы передаём, как входной параметр. Мы точно знаем, что начальство будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

```
#!/usr/bin/env python3

import argparse
import os
import subprocess

def get_modified_files(repo_dir):
    git_status_command = ["git", "-C", repo_dir, "status", "-s"]
    result = subprocess.run(git_status_command, capture_output=True, text=True).stdout.strip()

    changed_files = []

    for line in result.split('\n'):
        if line.startswith(' M'):
            file_path = line[3:].strip()
            changed_files.append(file_path)

    return changed_files

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("repo_dir", help="Path to the repository directory")
    args = parser.parse_args()

    repo_dir = args.repo_dir

    changed_files = get_modified_files(repo_dir)

    if changed_files:
        for file_path in changed_files:
            full_path = os.path.join(repo_dir, file_path)
            print(full_path)
    else:
        print("No modified files found.")

if __name__ == "__main__":
    main()
```

#### Задание 4

Наша команда разрабатывает несколько веб-сервисов, доступных по HTTPS. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис.

Проблема в том, что отдел, занимающийся нашей инфраструктурой, очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS-имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков.

Мы хотим написать скрипт, который:

- опрашивает веб-сервисы;
- получает их IP;
- выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>.

- Также должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена — оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: drive.google.com, mail.google.com, google.com.

```
import socket

services = {
    "drive.google.com": "",
    "mail.google.com": "",
    "google.com": ""
}

def get_ip_address(hostname):
    try:
        ip_address = socket.gethostbyname(hostname)
        return ip_address
    except socket.gaierror:
        return None

def check_ip(service, ip_address):
    if service in services and services[service] != "":
        if services[service] != ip_address:
            print(f"[ERROR] {service} IP mismatch: {services[service]} {ip_address}")
    services[service] = ip_address

def main():
    for service in services:
        ip_address = get_ip_address(service)
        if ip_address:
            print(f"{service} - {ip_address}")
            check_ip(service, ip_address)
        else:
            print(f"[ERROR] Failed to resolve {service}")

if __name__ == "__main__":
    main()
```

вывод:

```
drive.google.com - 172.217.12.238
mail.google.com - 172.217.9.197
google.com - 172.217.10.110
```

при ошибке:

```
[ERROR] drive.google.com IP mismatch: 172.217.12.239 172.217.12.238
```
