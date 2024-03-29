#### Задание 1
Есть скрипт:

a=1
b=2
c=a+b
d=$a+$b
e=$(($a+$b))
Какие значения переменным c, d, e будут присвоены? Почему?

Переменная | Значение | Обоснование                                                                                                            
--- |----------|------------------------------------------------------------------------------------------------------------------------|
c | "a+b"    | значения переменных a и b не были раскрыты и скрипт просто объединяет их вместе в виде текста                          |
d | "$a+$b"  | значения переменных a и b не были раскрыты. В данном контексте переменные a и b рассматриваются как текстовые значения |
e | 3 | выражение выполняет сложение значений переменных a и b                                                                 |

#### Задание 2
На нашем локальном сервере упал сервис, и мы написали скрипт, который постоянно проверяет его доступность, записывая дату проверок до тех пор, пока сервис не станет доступным. После чего скрипт должен завершиться.

В скрипте допущена ошибка, из-за которой выполнение не может завершиться, при этом место на жёстком диске постоянно уменьшается. Что необходимо сделать, чтобы его исправить:

```
while ((1==1)
do
	curl https://localhost:4757
	if (($? != 0))
	then
		date >> curl.log
	fi
done
```

в цикле пропущена скобка + было бы здорово добавить задержку в 1 секунду, что бы не перегружать сервис 
и добавить флаг для выхода из цикла:

```
while true; do
    curl https://localhost:4757
    if [[ $? -eq 0 ]]; then
        date >> curl.log
        break  # Выход из цикла, если сервис доступен
    fi
    sleep 1
done
```

#### Задание 3
Необходимо написать скрипт, который проверяет доступность трёх IP: 192.168.0.1, 173.194.222.113, 87.250.250.242 по 80 порту и записывает результат в файл log. Проверять доступность необходимо пять раз для каждого узла.

```
#!/bin/bash
ip_addresses=("192.168.0.1" "173.194.222.113" "87.250.250.242")
for ip in "${ip_addresses[@]}"
do
    echo "Проверка доступности IP: $ip"
    for ((i=1; i<=5; i++))
    do
        nc -zvw 1 "$ip" 80 &>> log
        sleep 1
    done
    echo "Проверка IP $ip завершена"
    echo
done
```

#### Задание 4
Необходимо дописать скрипт из предыдущего задания так, чтобы он выполнялся до тех пор, пока один из узлов не окажется недоступным. Если любой из узлов недоступен — IP этого узла пишется в файл error, скрипт прерывается.

```
#!/bin/bash
ip_addresses=("192.168.0.1" "173.194.222.113" "87.250.250.242")
error_flag=false
while true
do
    for ip in "${ip_addresses[@]}"
    do
        echo "Проверка доступности IP: $ip"
        for ((i=1; i<=5; i++))
        do
            nc -zvw 1 "$ip" 80 &>> log
            sleep 1
        done
        
        echo "Проверка IP $ip завершена"
        echo
        
        if [[ $? -ne 0 ]]; then
            echo "Узел $ip недоступен!"
            echo "$ip" >> error
            error_flag=true
        fi
    done
    
    if [[ "$error_flag" = true ]]; then
        echo "Обнаружена ошибка. Прерываем выполнение скрипта."
        break
    fi
done
```

#### Задание 5
Мы хотим, чтобы у нас были красивые сообщения для коммитов в репозиторий. Для этого нужно написать локальный хук для Git, который будет проверять, что сообщение в коммите содержит код текущего задания в квадратных скобках, и количество символов в сообщении не превышает 30. Пример сообщения: [04-script-01-bash] сломал хук.

```
#!/bin/bash

commit_msg_file=$1
commit_msg=$(cat "$commit_msg_file")

if [[ ! $commit_msg =~ \[[0-9]{2}-[a-z]+-[0-9]{2}-[a-z]+\] ]]; then
    echo "Ошибка: Сообщение коммита должно содержать код текущего задания в квадратных скобках!"
    exit 1
fi

if [[ ${#commit_msg} -gt 30 ]]; then
    echo "Ошибка: Сообщение коммита не должно превышать 30 символов!"
    exit 1
fi

exit 0
```