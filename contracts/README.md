## 安装依赖库如openzeppelin：
```shell
$ forge update
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
0x58B1e6F7BC643bA1898d88AE2404050D19D3797a

### 本地测试节点部署：

在第一个shell中打开本地anvil测试网

```shell
$ anvil
```
执行后能够看到自动生成的 测试账号 和 测试账号私钥


在另一个shell中进行部署：

```shell
$ forge create src/UnemploymentInsurance.sol:UnemploymentInsurance --interactive
```
部署时会让你填写部署用的账号私钥，可以直接从anvil的shell中生成的私钥中复制一个过来

然后就能够在本地进行测试了。anvil 测试网的端口是 `http://localhost:8545`

或者使用cast测试部署成果：
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
# --account <使用cast wallet import deployer111 --interactive 提前设置好私钥的账号>
# 来代替

```

#### windows powershell

```shell
$ forge script script/DeployUnemploymentInsurance.s.sol:DeployUnemploymentInsurance `
    --rpc-url <alchemy申请的节点url> `
    --private-key <你的私钥，带有0x前缀的字符串> `
    --broadcast -vvv
    
# --private-key 可以由
# --account <使用cast wallet import deployer111 --interactive 提前设置好私钥的账号>
# 来代替

```


### Build

```shell
$ forge build
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
