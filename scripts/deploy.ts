import assert from "assert";
import { ethers } from "hardhat";
import { deploy, deployProxy, AUCTION_DURATION, upgradesProxy } from "./common";

async function main() {
  const [owner] = await ethers.getSigners();
  console.log("[Owner account address]: " + owner.address);

  // 관리자 contract 배포하고 유효성 체크
  const manager_role_address = await deploy("ManagerRole", [owner.address]);
  const roleFactory = await ethers.getContractFactory("ManagerRole");
  const roleAttached = await roleFactory.attach(manager_role_address);
  assert(true === (await roleAttached.isAdmin(owner.address)));
  assert(
    false ===
      (await roleAttached.isAdmin("0x59C1a9142Db1e3b2284e0c2A4E371170abDbd038")) // 임의 주소로 유효성 체크
  );
  // NFTMarket, NFTDropMarket, METH 배포
  const royalty_address = await deployProxy("MSORoyaltyRegistry", [], []);

  // 우선 배포자가 거래소 수수료 출금 권한을 갖도록
  const treasury_address = await deployProxy("MuseionTreasury", [], [owner.address]);
  const meth_temp_address = await deploy("METH", [manager_role_address, manager_role_address]);
  const nft_market_address = await deployProxy(
    "NFTMarket",
    [treasury_address, meth_temp_address, royalty_address, AUCTION_DURATION],
    []
  );
  const nft_dropmarket_address = await deployProxy(
    "NFTDropMarket",
    [treasury_address, meth_temp_address, royalty_address],
    []
  );

  /* 
    market 정보 포함해서 METH 생성하고 기존 Market, DropMarket contract에 METH 주소 새롭게 설정
    METH와 Market contract 모두가 서로를 constructor에서 참조하고 있어서 해줘야 하는 처리 과정
  */
  const meth_address = await deploy("METH", [nft_market_address, nft_dropmarket_address]);
  await upgradesProxy(nft_market_address, "NFTMarket", [treasury_address, meth_address, royalty_address, AUCTION_DURATION])
  await upgradesProxy(nft_dropmarket_address, "NFTDropMarket", [treasury_address, meth_address, royalty_address])

  // NFTCollectionFactory, NFTCollection, NFTDropCollection 배포
  const collection_factory_address = await deployProxy(
    "NFTCollectionFactory",
    [manager_role_address],
    [1]
  );
  const nft_collection_address = await deploy("NFTCollection", [
    collection_factory_address,
  ]);
  const nft_dropcollection_address = await deploy("NFTDropCollection", [
    collection_factory_address,
  ]);

  // NFTCollectionFactory에 NFTCollection 컨트랙트의 implementation 주소 설정
  const collectionFactoryContract = await ethers.getContractFactory(
    "NFTCollectionFactory"
  );
  const factoryAttached = await collectionFactoryContract.attach(
    collection_factory_address
  );
  await factoryAttached.adminUpdateNFTCollectionImplementation(
    nft_collection_address
  );

  await factoryAttached.adminUpdateNFTDropCollectionImplementation(
    nft_dropcollection_address
  );
  console.log("[Environment]");
  console.log(`NEXT_PUBLIC_ADDRESS_NFT_COLLECTION_FACTORY=${collection_factory_address}`);
  console.log(`NEXT_PUBLIC_ADDRESS_METH=${meth_address}`);
  console.log(`NEXT_PUBLIC_ADDRESS_NFT_MARKET=${nft_market_address}`);
  console.log(`NEXT_PUBLIC_ADDRESS_NFT_DROP_MARKET=${nft_dropmarket_address}`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
