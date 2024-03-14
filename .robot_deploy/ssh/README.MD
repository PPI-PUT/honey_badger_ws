# SSH

Update your ssh config with *config.txt*

```
cat config.txt >> ~/.ssh/config
```

## Connect using ssh 

```
ssh hb
```

or
```
ssh hborin
```


## Login without password

###  Generate SSH Key Pair (If Necessary)

for example (use other if you wish)

```
ssh-keygen -t rsa -b 2048
```

### Copy the SSH Public Key

```
ssh-copy-id hb && ssh-copy-id hborin
```
