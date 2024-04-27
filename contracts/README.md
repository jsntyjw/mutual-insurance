## 合约地址：

0x58B1e6F7BC643bA1898d88AE2404050D19D3797a

## 部署：


```shell
$ forge script script/DeployUnemploymentInsurance.s.sol:DeployUnemploymentInsurance --rpc-url sepolia（在foundry.toml里面设置好的） --account deployer111（使用cast wallet import deployer111 --interactive 设置好的） --broadcast -vvv
```



### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
