# Ganache-cli 실행
실행 후 Available Accounts의 지갑을 metamask에 import 해서 테스트 가능
```
$ docker-compose up
```

# hardhat 사용 방법
* 환경 파일 설정 및 패키지 설치
```
$ cp .env-example .env
$ yarn install
```
* contract 배포
```
$ yarn hardhat run scripts/deploy.ts --network ganache
```
* contract verify
```
$ yarn hardhat verify 0x2ec11d279fC5245636ECFB1E9bcb1C7034833685 NFTCollectionFactory --network goerli
```
* ABI 생성
```
$ solc ./contracts/ContractName.sol --abi --include-path node_modules/ --base-path .
```

# Testing

```
yarn install
yarn build
yarn test
```

