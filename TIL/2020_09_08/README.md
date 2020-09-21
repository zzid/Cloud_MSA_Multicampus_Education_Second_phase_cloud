# 2020_09_08

- RBAC(Role-Based Access Control)
- chmod {사용자 유형} {+ or -} {권한} {파일명}
- chown {소유자} {파일명}
- Hard link and Symbolic link

### * Hard link : inode 공유하고 있기떄문에 사실상 원본과 같음

### * Symbolic(soft) link : windows의 바로가기와 비슷

- Foreground process and Background process
- Daemon

### service = daemon = server process

- Mirroring (archive)
- Shell script (basic)
- 

* all variable type are string

```bash
num4=`expr \( $num1 + 200 \) / 10 \* 2` >> example of integer expression
```

* Parameter :

```bash
#!/bin/sh

echo "file name is <$0>"

echo "parameter one is <$1>"

echo "parameter two is <$2>"

exit 0
```

---

- if ~ fi
- case ~ esac
- for

### * seq(1 100) == python range(1,101)

### * {1..100} [ bash[o] sh ]

### Cron

- crontab -l : 등록된 크론 확인
- crontab -e : 크론을 등록, 수정
- (/etc/crontab)
- (format)[m h dom mon dow user command]

    ex) 20 03 16 * * root /root/backup.sh