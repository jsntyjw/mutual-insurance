## ~~安装依赖库如 openzeppelin：~~ 解决了！不用安装直接用就好了

## 进入合约文件夹路径

```shell
$ cd .\contracts\
```

## 编译

```shell
$ forge build
```

## 测试

```shell
$ forge test -vvv
```

## 部署

### 已部署好的合约地址：

##### Sepolia：

0xB07CaA395814FF99EbFb8cb77DF2466B639FCbf5

### 本地测试节点部署：

在第一个 shell 中打开本地 anvil 测试网

```shell
$ anvil
```

执行后能够看到自动生成的 测试账号 和 测试账号私钥

在另一个 shell 中进行部署：

```shell
$ forge create src/UnemploymentInsurance.sol:UnemploymentInsurance --interactive
```

部署时会让你填写部署用的账号私钥，可以直接从 anvil 的 shell 中生成的私钥中复制一个过来

然后就能够在本地进行测试了。anvil 测试网的端口是 `http://localhost:8545`

或者使用 cast 测试部署成果：

```shell
$ cast call <部署好的合约地址> "owner()"
$ cast call <部署好的合约地址> "calculatePayout(uint)" 10000
```

### 公开网络部署：

#### Linux/MacOS

```shell
$ forge script script/DeployUnemploymentInsurance.s.sol:DeployUnemploymentInsurance \
    --rpc-url <alchemy申请的节点url> \
    --private-key <你的私钥，带有0x前缀的字符串> \
    --broadcast -vvv

# --private-key 可以由
# --account <提前用cast wallet import deployer111 --interactive 设置的私钥账户>
# 来代替

```

#### windows powershell

```shell
$ forge script script/DeployUnemploymentInsurance.s.sol:DeployUnemploymentInsurance `
    --rpc-url <alchemy申请的节点url> `
    --private-key <你的私钥，带有0x前缀的字符串> `
    --broadcast -vvv

# --private-key 可以由
# --account <提前用cast wallet import deployer111 --interactive 设置的私钥账户>
# 来代替

```


### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

## 万一需要重新安装依赖库如 openzeppelin：

```shell
    $ forge install OpenZeppelin/openzeppelin-contracts --no-commit
    $ forge install foundry-rs/forge-std --no-commit
```
